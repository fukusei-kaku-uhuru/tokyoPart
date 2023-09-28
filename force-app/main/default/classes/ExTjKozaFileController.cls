public with sharing class ExTjKozaFileController {

    private static final String SITE_MODE = ExLwcUtil.getSiteMode();

    private static final ShinseiShoruiTeigi__c KOZA_KAKUNIN = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];

    public class KozaWrapper {
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public Boolean isSelectedTaishosha {get;set;}
        @AuraEnabled public List<Map<String, String>> KozaOption {get;set;}
        @AuraEnabled public List<String> KozaShoruiList {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}

        public KozaWrapper(){}

        public KozaWrapper(TaishoJido__c tj){
            Shimei = tj.Shimei__c;
            isSelectedTaishosha = tj.UketoriKouzaKubun_Taishosha__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }

        public KozaWrapper(DV_TaishoJido__c tj){
            Shimei = tj.Shimei__c;
            isSelectedTaishosha = tj.UketoriKouzaKubun_Taishosha__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }
    }

    /**
     * 口座ファイル情報を取得
     */
    @AuraEnabled
    public static KozaWrapper getKozaData(String taishoJidoId){
        try {

            KozaWrapper kw;
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                kw = getTaishoJidoDataIppan(taishoJidoId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                kw = getTaishoJidoDataDv(taishoJidoId);
            }

            // 口座情報提出書類オプションを取得
            kw.kozaOption = getKozaOption();

            // 提出済の口座情報書類を取得
            kw.KozaShoruiList = getKozaShoruiList(taishoJidoId);

            return kw;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static KozaWrapper getTaishoJidoDataIppan(String taishoJidoId) {
        TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,UketoriKouzaKubun_Taishosha__c
                ,ShinsaKekkaSaishu__c
            FROM TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new KozaWrapper(tj);
    }

    private static KozaWrapper getTaishoJidoDataDv(String taishoJidoId) {
        DV_TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,UketoriKouzaKubun_Taishosha__c
                ,ShinsaKekkaSaishu__c
            FROM DV_TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new KozaWrapper(tj);
    }

    private static List<Map<String, String>> getKozaOption() {
        return new List<Map<String, String>>{
            new Map<String, String>{
                    'label' => KOZA_KAKUNIN.Name
                    ,'value' => KOZA_KAKUNIN.Id
                }
            };
    }

    @AuraEnabled
    public static List<String> getKozaShoruiList(String taishoJidoId) {
        try {

            // 対象児童に紐づく書類一覧を取得
            List<ContentDocumentLink> cdlList = [
                SELECT
                    Id
                    ,ContentDocument.LatestPublishedVersionId
                    ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :taishoJidoId
                AND ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c = :KOZA_KAKUNIN.Id
                ORDER BY ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiName__c
            ];

            List<String> cvIdList = new List<String>();
            for (ContentDocumentLink cdl : cdlList) {
                cvIdList.add(cdl.ContentDocument.LatestPublishedVersionId);
            }

            return cvIdList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 口座確認書類が提出されているかをチェックする
     */
    @AuraEnabled
    public static List<String> needUploadShinseiShorui(String taishoJidoId){
        try {
            // 対象児童に紐づく書類一覧を取得
            List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(taishoJidoId);

            return ExValidationUtil.needUploadShinseiShorui(cdlList, new List<ShinseiShoruiTeigi__c>{KOZA_KAKUNIN});

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}