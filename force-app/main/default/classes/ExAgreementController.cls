public with sharing class ExAgreementController {

    @TestVisible private static final String INITIAL_STATUS = '未申請';

    private static String siteMode = ExLwcUtil.getSiteMode();

    @AuraEnabled
    public static String register(String recordId){

        String resultId = '';

        if(siteMode == ExLwcUtil.MODE_IPPAN){
            // 登録済データの場合、そのままidを返す
            List<NinteiSeikyu__c> nsList = [
                SELECT
                    Id
                FROM
                    NinteiSeikyu__c
                WHERE
                    Id = :recordId
            ];
            if(nsList.size() == 1){
                return recordId;
            }

            // 請求者：空で作成
            Seikyusha__c s = new Seikyusha__c();
            insert s;

            // 認定請求：空で作成
            NinteiSeikyu__c ns = new NinteiSeikyu__c(
                Seikyusha__c = s.Id // 請求者と紐づけ
                ,ShinsaStatus__c = INITIAL_STATUS // ステータス初期化
            );
            insert ns;

            resultId = ns.Id;
        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){
            // 登録済データの場合、そのままidを返す
            List<DV_NinteiSeikyu__c> nsList = [
                SELECT
                    Id
                FROM
                    DV_NinteiSeikyu__c
                WHERE
                    Id = :recordId
            ];
            if(nsList.size() == 1){
                return recordId;
            }

            // 請求者：空で作成
            DV_Seikyusha__c s = new DV_Seikyusha__c(
                RecordTypeId = ExLwcUtil.getSeikyushaRecordTypeId() // レコードタイプ
            );
            insert s;

            // 認定請求：空で作成
            DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c(
                RecordTypeId = ExLwcUtil.getSeikyuRecordTypeId() // レコードタイプ
                ,Seikyusya__c = s.Id // 請求者と紐づけ
                ,ShinsaStatus__c = INITIAL_STATUS // ステータス初期化
            );
            insert ns;

            resultId = ns.Id;
        }

        return resultId;
    }
}