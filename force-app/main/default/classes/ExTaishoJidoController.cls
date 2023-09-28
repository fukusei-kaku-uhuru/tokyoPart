public with sharing class ExTaishoJidoController {

    private static final String SITE_MODE = ExLwcUtil.getSiteMode();
    private static final String MOUSHITATE_KOKENNIN = '1';
    private static final String MOUSHITATE_BEKKYO = '2';
    private static final String MOUSHITATE_RYUGAKU = '3';
    private static final String MOUSHITATE_RIKON = '4';
    private static final String MOUSHITATE_FUBOSITEI = '5';

    public class TaishoJidoWrapper {
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String TaishoshaKubun {get;set;}
        @AuraEnabled public String TaishoshaKubunId {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public String ShimeiFurigana {get;set;}
        @AuraEnabled public Boolean isSelectedTaishosha {get;set;}
        @AuraEnabled public Boolean isYucho {get;set;}
        @AuraEnabled public String KinyuKikan {get;set;}
        @AuraEnabled public String Shiten {get;set;}
        @AuraEnabled public Boolean needMoushitate {get;set;}
        @AuraEnabled public Boolean needKazokuKakuninFile {get;set;}
        @AuraEnabled public Boolean isNotMoushitateFinished {get;set;}
        @AuraEnabled public Boolean needMoushitateFile {get;set;}
        @AuraEnabled public Boolean isNotKozaJohoFinished {get;set;}
        @AuraEnabled public Boolean isNotSeikyushaKozaFilled {get;set;}
        @AuraEnabled public Boolean needKozaKakuninFile {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}
        @AuraEnabled public Boolean isDeletable {get;set;}

        public Boolean IsDairinin {get;set;}
        @AuraEnabled public Boolean IsKokennin {get;set;}
        @AuraEnabled public Boolean IsBekkyo {get;set;}
        @AuraEnabled public Boolean IsRyugaku {get;set;}
        @AuraEnabled public Boolean IsRikon {get;set;}
        @AuraEnabled public Boolean IsFuboSitei {get;set;}
        @AuraEnabled public Boolean IsBetsuJusho {get;set;}

        public TaishoJidoWrapper(TaishoJido__c tj, Boolean isNotSeikyushaKozaFilled) {

            // 対象児童情報
            Id = tj.Id;
            TaishoshaKubun = tj.TaishoshaKubun__r?.Name;
            TaishoshaKubunId = tj.TaishoshaKubun__c;
            Shimei = tj.Shimei__c;
            ShimeiFurigana = tj.ShimeiFurigana__c;

            // 口座区分
            if (tj.UketoriKouzaKubun_Seikyusha__c) {
                isSelectedTaishosha = false;
                this.isNotSeikyushaKozaFilled = isNotSeikyushaKozaFilled;

            } else if (tj.UketoriKouzaKubun_Taishosha__c) {
                isSelectedTaishosha = true;
            }

            // 口座情報（ゆうちょのとき）
            if (String.isNotEmpty(tj.YuchoBango__c)) {
                isYucho = true;

            // 口座情報（ゆうちょ以外のとき）
            } else {
                isYucho = false;
                KinyuKikan = tj.KinyuKikanMei__c + '（' + tj.KinyuKikanCode__c + '）';
                Shiten = tj.ShitenMei__c + '（' + tj.ShitenCode__c + '）';
            }

            needMoushitate = tj.TaishoshaKubun__r.IsMoushitate__c;

            // 各種編集が完了しているかをチェックする
            if (needMoushitate) {
                isNotMoushitateFinished = !tj.MoushitateCheck__c;
            } else {
                isNotMoushitateFinished = false;
                needMoushitateFile = false;
            }
            isNotKozaJohoFinished = !tj.KouzaJohoCheck__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }

            // 編集不可か、差し戻し状態の場合は削除不可
            if (isDisabled || tj.HubiStatus__c == '不備連絡済み') {
                isDeletable = false;
            } else {
                isDeletable = true;
            }

            IsDairinin = tj.SeikyushaKubun_Dairinin__c;
            IsKokennin = tj.Moushitate_KokenninCheck__c;
            IsBekkyo = tj.Moushitate_BekkyoKango__c;
            IsRyugaku = tj.Moushitate_KaigaiRyugakuCheck__c;
            IsRikon = tj.Moushitate_RikonKyogiCheck__c;
            IsFuboSitei = tj.Moushitate_FuboSiteishaCheck__c;
        }

        public TaishoJidoWrapper(DV_TaishoJido__c tj, Boolean isNotSeikyushaKozaFilled) {

            // 対象児童情報
            Id = tj.Id;
            TaishoshaKubun = tj.TaishoshaKubun__r?.Name;
            TaishoshaKubunId = tj.TaishoshaKubun__c;
            Shimei = tj.Shimei__c;
            ShimeiFurigana = tj.ShimeiFurigana__c;

            // 口座区分
            if (tj.UketoriKouzaKubun_Seikyusha__c) {
                isSelectedTaishosha = false;
                this.isNotSeikyushaKozaFilled = isNotSeikyushaKozaFilled;

            } else if (tj.UketoriKouzaKubun_Taishosha__c) {
                isSelectedTaishosha = true;
            }

            // 口座情報（ゆうちょのとき）
            if (String.isNotEmpty(tj.YuchoBango__c)) {
                isYucho = true;

            // 口座情報（ゆうちょ以外のとき）
            } else {
                isYucho = false;
                KinyuKikan = tj.KinyuKikanMei__c + '（' + tj.KinyuKikanCode__c + '）';
                Shiten = tj.ShitenMei__c + '（' + tj.ShitenCode__c + '）';
            }

            needMoushitate = tj.TaishoshaKubun__r.IsMoushitate__c;

            // 各種編集が完了しているかをチェックする
            if (needMoushitate) {
                isNotMoushitateFinished = !tj.MoushitateCheck__c;
            } else {
                isNotMoushitateFinished = false;
                needMoushitateFile = false;
            }
            isNotKozaJohoFinished = !tj.KouzaJohoCheck__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }

            // 編集不可か、差し戻し状態の場合は削除不可
            if (isDisabled || tj.HubiStatus__c == '不備連絡済み') {
                isDeletable = false;
            } else {
                isDeletable = true;
            }

            IsDairinin = tj.SeikyushaKubun_Dairinin__c;
            IsKokennin = tj.Moushitate_KokenninCheck__c;
            IsBekkyo = tj.Moushitate_BekkyoKango__c;
            IsRyugaku = tj.Moushitate_KaigaiRyugakuCheck__c;
            IsRikon = tj.Moushitate_RikonKyogiCheck__c;
            IsFuboSitei = tj.Moushitate_FuboSiteishaCheck__c;
            IsBetsuJusho = tj.Moushitate_BetsuJushoCheck__c;
        }
    }

    /**
     * 対象児童情報を取得
     */
    @AuraEnabled
    public static List<TaishoJidoWrapper> getTaishoJidoList(String recordId){

        List<TaishoJidoWrapper> tjwList = new List<TaishoJidoWrapper>();

        // 対象児童情報を取得
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            tjwList = getTaishoJidoListIppan(recordId);
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            tjwList = getTaishoJidoListDv(recordId);
        }

        // 必要書類が提出出来ているかをチェック
        tjwList = checkNeedShoruiUpload(tjwList);

        return tjwList;
    }

    private static List<TaishoJidoWrapper> getTaishoJidoListIppan(String ninteiSeikyuId) {

        List<TaishoJido__c> tjList = [  select
                                            Id
                                            ,TaishoshaKubun__c
                                            ,TaishoshaKubun__r.Name
                                            ,TaishoshaKubun__r.IsMoushitate__c
                                            ,Shimei__c
                                            ,ShimeiFurigana__c
                                            ,KinyuKikanMei__c
                                            ,KinyuKikanCode__c
                                            ,ShitenMei__c
                                            ,ShitenCode__c
                                            ,YuchoBango__c
                                            ,SeikyushaKubun_Dairinin__c
                                            ,UketoriKouzaKubun_Seikyusha__c
                                            ,UketoriKouzaKubun_Taishosha__c
                                            ,Ninteiseikyu__r.ShinsaStatus__c
                                            ,ShinsaKekkaSaishu__c
                                            ,HubiStatus__c
                                            ,MoushitateCheck__c
                                            ,KouzaJohoCheck__c
                                            ,Moushitate_KokenninCheck__c
                                            ,Moushitate_BekkyoKango__c
                                            ,Moushitate_KaigaiRyugakuCheck__c
                                            ,Moushitate_RikonKyogiCheck__c
                                            ,Moushitate_FuboSiteishaCheck__c
                                        from TaishoJido__c
                                        where NinteiSeikyu__c = :ninteiSeikyuId
                                        order by Name asc
        ];

        Boolean isNotSeikyushaKozaFilled = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ninteiSeikyuId);

        List<TaishoJidoWrapper> tjwList = new List<TaishoJidoWrapper>();
        for (TaishoJido__c tj : tjList) {
            // ラッパー作成
            TaishoJidoWrapper tjw = new TaishoJidoWrapper(tj, isNotSeikyushaKozaFilled);

            tjwList.add(tjw);
        }

        return tjwList;
    }

    private static List<TaishoJidoWrapper> getTaishoJidoListDv(String ninteiSeikyuId) {

        List<DV_TaishoJido__c> tjList = [  select
                                            Id
                                            ,TaishoshaKubun__c
                                            ,TaishoshaKubun__r.Name
                                            ,TaishoshaKubun__r.IsMoushitate__c
                                            ,Shimei__c
                                            ,ShimeiFurigana__c
                                            ,KinyuKikanMei__c
                                            ,KinyuKikanCode__c
                                            ,ShitenMei__c
                                            ,ShitenCode__c
                                            ,YuchoBango__c
                                            ,SeikyushaKubun_Dairinin__c
                                            ,UketoriKouzaKubun_Seikyusha__c
                                            ,UketoriKouzaKubun_Taishosha__c
                                            ,Ninteiseikyu__r.ShinsaStatus__c
                                            ,ShinsaKekkaSaishu__c
                                            ,HubiStatus__c
                                            ,MoushitateCheck__c
                                            ,KouzaJohoCheck__c
                                            ,Moushitate_KokenninCheck__c
                                            ,Moushitate_BekkyoKango__c
                                            ,Moushitate_KaigaiRyugakuCheck__c
                                            ,Moushitate_RikonKyogiCheck__c
                                            ,Moushitate_FuboSiteishaCheck__c
                                            ,Moushitate_BetsuJushoCheck__c
                                        from DV_TaishoJido__c
                                        where
                                            NinteiSeikyu__c = :ninteiSeikyuId
                                        order by Name asc
        ];

        Boolean isNotSeikyushaKozaFilled = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ninteiSeikyuId);

        List<TaishoJidoWrapper> tjwList = new List<TaishoJidoWrapper>();
        for (DV_TaishoJido__c tj : tjList) {
            // ラッパー作成
            TaishoJidoWrapper tjw = new TaishoJidoWrapper(tj, isNotSeikyushaKozaFilled);

            tjwList.add(tjw);
        }

        return tjwList;
    }

    /**
     * 書類の提出がされていない項目をチェックする
     */
    private static List<TaishoJidoWrapper> checkNeedShoruiUpload(List<TaishoJidoWrapper> tjwList) {

        if (tjwList.size() == 0) {
            return tjwList;
        }

        // 対象児童の情報を抽出
        Set<String> taishoJidoIdSet = new Set<String>();
        Set<Id> taishoshaKubunSet = new Set<Id>();
        for (TaishoJidoWrapper tjw : tjwList) {
            taishoJidoIdSet.add(tjw.Id);
            taishoshaKubunSet.add(tjw.TaishoshaKubunId);
        }

        // 対象児童に紐づく書類を取得
        List<ContentDocumentLink> allCdlList = ExTaishoJidoUtil.getFileList(taishoJidoIdSet);

        // 対象児童のIdをキーとしたmapに振り分ける
        Map<String, List<ContentDocumentLink>> cdlLists = ObjectUtil.convertMapList(allCdlList, Schema.ContentDocumentLink.LinkedEntityId);

        // 各種必要書類を取得
        Map<Id, List<KubunBetsuShinseiShorui__c>> allKazokuKakuninShoruis = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiMap(taishoshaKubunSet);
        Map<String, List<ShinseiShoruiTeigi__c>> allMoushitateShoruis = getAllMoushitateShorui();
        List<ShinseiShoruiTeigi__c> kozaKakuninShorui = ExShinseiShoruiTeigiUtil.getKozaKakunin();

        // 対象児童ごとに必要書類の提出が出来ているかチェックする
        for (TaishoJidoWrapper tjw : tjwList) {
            List<ContentDocumentLink> cdlList = cdlLists.get(tjw.Id);

            if (cdlList == null) {
                cdlList = new List<ContentDocumentLink>();
            }

            // 家族関係確認書類の提出状況をチェック
            List<KubunBetsuShinseiShorui__c> kazokuKakuninShoruis = ExTaishoJidoUtil.getRequiredShinseiShorui(tjw.IsDairinin, allKazokuKakuninShoruis.get(tjw.TaishoshaKubunId));
            List<String> kazokuKakuninResultList = ExValidationUtil.needUploadShinseiShorui(cdlList, convertKbssToSstList(kazokuKakuninShoruis));
            tjw.needKazokuKakuninFile = kazokuKakuninResultList.size() > 0;

            // 申立書書類の提出状況をチェック
            if ((Boolean)ObjectUtil.nvl(tjw.needMoushitate, false)) {
                List<ShinseiShoruiTeigi__c> moushitateShoruis = getRequiredMoushitateShorui(tjw, allMoushitateShoruis);
                List<String> moushitateResultList = ExValidationUtil.needUploadShinseiShorui(cdlList, moushitateShoruis);
                tjw.needMoushitateFile = moushitateResultList.size() > 0;
            }

            // 口座確認書類の提出状況をチェック
            if ((Boolean)ObjectUtil.nvl(tjw.isSelectedTaishosha, false)) {
                List<String> kozaKakuninResultList = ExValidationUtil.needUploadShinseiShorui(cdlList, kozaKakuninShorui);
                tjw.needKozaKakuninFile = kozaKakuninResultList.size() > 0;
            } else {
                tjw.needKozaKakuninFile = false;
            }
        }

        return tjwList;
    }

    private static Map<String, List<ShinseiShoruiTeigi__c>> getAllMoushitateShorui() {
        List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getRequiredMoushitateShorui(new List<String>{
            MOUSHITATE_KOKENNIN, MOUSHITATE_BEKKYO, MOUSHITATE_RYUGAKU, MOUSHITATE_RIKON, MOUSHITATE_FUBOSITEI
        });

        return ObjectUtil.convertMapList(sstList, Schema.ShinseiShoruiTeigi__c.MoushitateshoKubun__c);
    }

    private static List<ShinseiShoruiTeigi__c> getRequiredMoushitateShorui(TaishoJidoWrapper tjw, Map<String, List<ShinseiShoruiTeigi__c>> allMoushitateShoruis) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();

        if (tjw.IsKokennin && allMoushitateShoruis.containsKey(MOUSHITATE_KOKENNIN)) {sstList.addAll(allMoushitateShoruis.get(MOUSHITATE_KOKENNIN));}
        if (tjw.IsBekkyo && allMoushitateShoruis.containsKey(MOUSHITATE_BEKKYO)) {sstList.addAll(allMoushitateShoruis.get(MOUSHITATE_BEKKYO));}
        if (tjw.IsRyugaku && allMoushitateShoruis.containsKey(MOUSHITATE_RYUGAKU)) {sstList.addAll(allMoushitateShoruis.get(MOUSHITATE_RYUGAKU));}
        if (tjw.IsRikon && allMoushitateShoruis.containsKey(MOUSHITATE_RIKON)) {sstList.addAll(allMoushitateShoruis.get(MOUSHITATE_RIKON));}
        if (tjw.IsFuboSitei && allMoushitateShoruis.containsKey(MOUSHITATE_FUBOSITEI)) {sstList.addAll(allMoushitateShoruis.get(MOUSHITATE_FUBOSITEI));}

        return sstList;
    }

    /**
     * 区分別申請書類 → 申請書類定義Obj
     */
    private static List<ShinseiShoruiTeigi__c> convertKbssToSstList(List<KubunBetsuShinseiShorui__c> kbssList) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        for (KubunBetsuShinseiShorui__c kbss : kbssList) {
            sstList.add(new ShinseiShoruiTeigi__c(
                Id = kbss.ShinseiShoruiTeigi__c
                ,Name = kbss.ShinseiShoruiTeigi__r.Name
                ,IsNiniTeisyutsu__c = kbss.ShinseiShoruiTeigi__r.IsNiniTeisyutsu__c
            ));
        }

        return sstList;
    }

    /**
     * 対象児童を削除する
     */
    @AuraEnabled
    public static void deleteTaishoJido(String ninteiSeikyuId, String taishoJidoId){
        try {
            // 未申請かチェック
            if (ExLwcUtil.isNinteiSeikyuDisabled(ninteiSeikyuId)) {
                throw new AuraHandledException('');
            }

            // 紐づくファイルを削除
            List<ContentDocumentLink> cdlList = [
                SELECT
                    Id
                    ,ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :taishoJidoId
            ];

            List<ContentDocument> cdList = new List<ContentDocument>();
            for (ContentDocumentLink cdl : cdlList) {
                cdList.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }

            delete cdList;

            // 対象児童を削除
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                delete new TaishoJido__c(Id = taishoJidoId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                delete new DV_TaishoJido__c(Id = taishoJidoId);
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}