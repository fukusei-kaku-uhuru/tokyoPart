public with sharing class ExTaishoJidoUtil {

    /**
     * 提出が必要な申請書類定義の一覧を抽出する
     */
    public static List<KubunBetsuShinseiShorui__c> getRequiredShinseiShorui(Boolean isDairinin, List<KubunBetsuShinseiShorui__c> kbssList) {

        List<KubunBetsuShinseiShorui__c> requiredShoruiList = new List<KubunBetsuShinseiShorui__c>();
        for (KubunBetsuShinseiShorui__c kbss : kbssList) {
            Boolean isRequiredDairinin = (Boolean)ObjectUtil.nvl(kbss.ShinseiShoruiTeigi__r?.IsRequiredDairinin__c, false);

            // 代理人時以外も必須 もしくは 代理人請求かつ、代理人時必須の申請書類のみ追加する
            if (!isRequiredDairinin
                || (isDairinin && isRequiredDairinin)) {
                requiredShoruiList.add(kbss);
            }
        }

        return requiredShoruiList;
    }

    /**
     * 指定されたIdに紐づくファイル一覧を取得する
     */
    public static List<ContentDocumentLink> getFileList(String linkedEntityId) {
        Set<String> idSet = new Set<String>();
        idSet.add(linkedEntityId);
        return getFileList(idSet);
    }

    /**
     * 指定されたIdに紐づくファイル一覧を取得する
     */
    public static List<ContentDocumentLink> getFileList(Set<String> linkedEntityIdSet){

        if (linkedEntityIdSet.size() == 0) {
            return new List<ContentDocumentLink>();
        }

        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocumentId
                ,ContentDocument.LatestPublishedVersionId
                ,ContentDocument.LatestPublishedVersion.Title
                ,ContentDocument.LatestPublishedVersion.FileExtension
                ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
                ,ContentDocument.LatestPublishedVersion.IsDeletable__c
                ,ContentDocument.LatestPublishedVersion.HoninKakuninShoruiMaskKenkoHoken__c
                ,LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId in :linkedEntityIdSet
            ORDER BY ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiName__c
        ];

        return cdlList;
    }

    /**
     * 指定された書類区分のContentVersionIdを取得する
     * allCvIdLists
     *  └[taishoJidoId]
     *    ├['kazoku'] ─ 家族関係確認用書類のIdリスト
     *    ├['moushitate'] ─ 申立書用書類のIdリスト
     *    └['koza'] ─ 口座確認用書類のIdリスト
     */
    public static Map<String, Map<String, List<String>>> getFilteringFileLists(Set<String> taishoJidoIdSet){
        try {
            // 紐づくファイルをすべて取得する
            List<ContentDocumentLink> allCdlList = getFileList(taishoJidoIdSet);

            // 紐づく対象児童のIdをキーにしたmapに詰め替え
            Map<String, List<ContentDocumentLink>> cdlLists = new Map<String, List<ContentDocumentLink>>();
            for (ContentDocumentLink cdl : allCdlList) {
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                if (cdlLists.containsKey(cdl.LinkedEntityId)) {
                    cdlList = cdlLists.get(cdl.LinkedEntityId);
                }
                cdlList.add(cdl);
                cdlLists.put(cdl.LinkedEntityId, cdlList);
            }

            // 家族確認用書類を取得する
            List<ShinseiShoruiTeigi__c> kazokuKakuninList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();
            Set<Id> kazokuKakuninIds = new Map<Id, ShinseiShoruiTeigi__c>(kazokuKakuninList).keySet();

            // 銀行口座確認用書類を取得する
            List<ShinseiShoruiTeigi__c> kozaKakuninList = ExShinseiShoruiTeigiUtil.getKozaKakunin();
            Set<Id> kozaKakuninIds = new Map<Id, ShinseiShoruiTeigi__c>(kozaKakuninList).keySet();

            // 申立書用書類を取得する
            List<ShinseiShoruiTeigi__c> moushitateList = ExShinseiShoruiTeigiUtil.getListByMoushitatesho();
            Set<Id> moushitateIds = new Map<Id, ShinseiShoruiTeigi__c>(moushitateList).keySet();

            // 条件に合うファイルだけに移し替える
            Map<String, Map<String, List<String>>> allCvIdLists = new Map<String, Map<String, List<String>>>();
            for (String taishoJidoId : taishoJidoIdSet) {
                // 紐づくファイルのうち、指定された書類区分のもののみに絞り込む
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                if (cdlLists.containsKey(taishoJidoId)) {
                    cdlList = cdlLists.get(taishoJidoId);
                }

                List<String> kazokuKakuninIdList = new List<String>();
                List<String> moushitateIdList = new List<String>();
                List<String> kozaKakuninIdList = new List<String>();
                for (ContentDocumentLink cdl : cdlList) {

                    // 家族関係確認書類
                    if (kazokuKakuninIds.contains(cdl.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c)) {
                        kazokuKakuninIdList.add(cdl.ContentDocument.LatestPublishedVersionId);

                    // 申立書
                    } else if (moushitateIds.contains(cdl.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c)) {
                        moushitateIdList.add(cdl.ContentDocument.LatestPublishedVersionId);

                    // 口座確認書類
                    } else if (kozaKakuninIds.contains(cdl.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c)) {
                        kozaKakuninIdList.add(cdl.ContentDocument.LatestPublishedVersionId);
                    }
                }

                Map<String, List<String>> cvIdLists = new Map<String, List<String>>();
                cvIdLists.put('kazoku', kazokuKakuninIdList);
                cvIdLists.put('moushitate', moushitateIdList);
                cvIdLists.put('koza', kozaKakuninIdList);
                allCvIdLists.put(taishoJidoId, cvIdLists);
            }

            return allCvIdLists;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String, List<String>> getFilteringFileList(String taishoJidoId) {
        Map<String, Map<String, List<String>>> allCvIdLists = getFilteringFileLists(new Set<String>(new List<String>{taishoJidoId}));
        return allCvIdLists.get(taishoJidoId);
    }

    @AuraEnabled
    public static Boolean canAddTaishoJido(String recordId){
        try {
            String siteMode = ExLwcUtil.getSiteMode();
            return canAddTaishoJido(recordId, siteMode);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 対象児童が追加可能かチェックする
     */
    public static Boolean canAddTaishoJido(String recordId, String siteMode){
        Integer count = 0;

        if (siteMode == ExLwcUtil.MODE_IPPAN) {
            count = [
                SELECT Id
                FROM TaishoJido__c
                WHERE NinteiSeikyu__c = :recordId
            ].size();
        } else if (siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA) {
            count = [
                SELECT Id
                FROM DV_TaishoJido__c
                WHERE NinteiSeikyu__c = :recordId
            ].size();
        }

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        if (count >= limitSetting.Value__c) {
            return false;
        }

        if (ExLwcUtil.isNinteiSeikyuDisabled(recordId)) {
            return false;
        }

        return true;
    }

    /**
     * 請求者の口座情報が設定されているかチェックする
     * 口座情報に不足があればtrueを返す
     */
    @AuraEnabled
    public static Boolean isNotSeikyushaKozaFilled(String ninteiSeikyuId){
        try {

            String siteMode = ExLwcUtil.getSiteMode();

            // 請求者情報を取得
            Id seikyushaId;
            String yuchoKouzaMeigi;
            String kouzaMeigi;
            if (siteMode == ExLwcUtil.MODE_IPPAN) {
                NinteiSeikyu__c ns = [
                    SELECT
                        Id
                        ,Seikyusha__c
                        ,Seikyusha__r.YuchoKouzaMeigi__c
                        ,Seikyusha__r.KouzaMeigi__c
                    FROM NinteiSeikyu__c
                    WHERE Id = :ninteiSeikyuId
                ];
                seikyushaId = ns.Seikyusha__c;
                yuchoKouzaMeigi = ns.Seikyusha__r.YuchoKouzaMeigi__c;
                kouzaMeigi = ns.Seikyusha__r.KouzaMeigi__c;
            } else if (siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA) {
                DV_NinteiSeikyu__c ns = [
                    SELECT
                        Id
                        ,Seikyusya__c
                        ,Seikyusya__r.YuchoKouzaMeigi__c
                        ,Seikyusya__r.KouzaMeigi__c
                    FROM DV_NinteiSeikyu__c
                    WHERE Id = :ninteiSeikyuId
                ];
                seikyushaId = ns.Seikyusya__c;
                yuchoKouzaMeigi = ns.Seikyusya__r.YuchoKouzaMeigi__c;
                kouzaMeigi = ns.Seikyusya__r.KouzaMeigi__c;
            }

            // 口座名義が登録されていなければ、true
            if (String.isEmpty(yuchoKouzaMeigi) && String.isEmpty(kouzaMeigi)) {
                return true;
            }

            // 口座確認書類が提出されているか確認する
            List<ContentDocumentLink> cdlList = getFileList(seikyushaId);
            ShinseiShoruiTeigi__c kozaKakunin = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            List<String> resultList = ExValidationUtil.needUploadShinseiShorui(cdlList, new List<ShinseiShoruiTeigi__c>{kozaKakunin});

            if (resultList.size() > 0) {
                return true;
            }

            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}