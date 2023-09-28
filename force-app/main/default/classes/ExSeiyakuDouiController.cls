public with sharing class ExSeiyakuDouiController {

    private static final String INITIAL_STATUS = '未申請';

    private static String siteMode = ExLwcUtil.getSiteMode();

    @AuraEnabled
  	public static NinteiSeikyuSeiyakuWrapper getSeiyaku(String recordId) {

        NinteiSeikyuSeiyakuWrapper wrapper = new NinteiSeikyuSeiyakuWrapper();
        if (String.isBlank(recordId)) {
            return wrapper;
        }

        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<NinteiSeikyu__c> ninteiList = [
                SELECT
                    Id
                    ,NinteiSeikyuSeiyaku_01__c
                    ,NinteiSeikyuSeiyaku_02__c
                    ,NinteiSeikyuSeiyaku_03__c
                    ,NinteiSeikyuSeiyaku_04__c
                    ,NinteiSeikyuSeiyaku_05__c
                    ,NinteiSeikyuSeiyaku_07__c
                    ,NinteiSeikyuSeiyaku_08__c
                    ,NinteiSeikyuSeiyaku_09__c
                    ,NinteiSeikyuSeiyaku_10__c
                    ,NinteiSeikyuSeiyaku_11__c
                    ,NinteiSeikyuSeiyaku_12__c
                FROM
                    NinteiSeikyu__c
                WHERE
                    Id = :recordId
            ];

            if (ninteiList.size() > 0) {
                NinteiSeikyu__c nintei = ninteiList.get(0);
                wrapper.NinteiSeikyuSeiyaku_01 = nintei.NinteiSeikyuSeiyaku_01__c;
                wrapper.NinteiSeikyuSeiyaku_02 = nintei.NinteiSeikyuSeiyaku_02__c;
                wrapper.NinteiSeikyuSeiyaku_03 = nintei.NinteiSeikyuSeiyaku_03__c;
                wrapper.NinteiSeikyuSeiyaku_04 = nintei.NinteiSeikyuSeiyaku_04__c;
                wrapper.NinteiSeikyuSeiyaku_05 = nintei.NinteiSeikyuSeiyaku_05__c;
                wrapper.NinteiSeikyuSeiyaku_07 = nintei.NinteiSeikyuSeiyaku_07__c;
                wrapper.NinteiSeikyuSeiyaku_08 = nintei.NinteiSeikyuSeiyaku_08__c;
                wrapper.NinteiSeikyuSeiyaku_09 = nintei.NinteiSeikyuSeiyaku_09__c;
                wrapper.NinteiSeikyuSeiyaku_10 = nintei.NinteiSeikyuSeiyaku_10__c;
                wrapper.NinteiSeikyuSeiyaku_11 = nintei.NinteiSeikyuSeiyaku_11__c;
                wrapper.NinteiSeikyuSeiyaku_12 = nintei.NinteiSeikyuSeiyaku_12__c;
            }
        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){  // DV OR 里親
            List<DV_NinteiSeikyu__c> ninteiList = [
                SELECT
                    Id
                    ,NinteiSeikyuSeiyaku_01__c
                    ,NinteiSeikyuSeiyaku_02__c
                    ,NinteiSeikyuSeiyaku_03__c
                    ,NinteiSeikyuSeiyaku_04__c
                    ,NinteiSeikyuSeiyaku_05__c
                    ,NinteiSeikyuSeiyaku_07__c
                    ,NinteiSeikyuSeiyaku_08__c
                    ,NinteiSeikyuSeiyaku_09__c
                    ,NinteiSeikyuSeiyaku_10__c
                    ,NinteiSeikyuSeiyaku_11__c
                    ,NinteiSeikyuSeiyaku_12__c
                FROM
                    DV_NinteiSeikyu__c
                WHERE
                    Id = :recordId
                AND
                    RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
            ];

            if (ninteiList.size() > 0) {
                DV_NinteiSeikyu__c nintei = ninteiList.get(0);
                wrapper.NinteiSeikyuSeiyaku_01 = nintei.NinteiSeikyuSeiyaku_01__c;
                wrapper.NinteiSeikyuSeiyaku_02 = nintei.NinteiSeikyuSeiyaku_02__c;
                wrapper.NinteiSeikyuSeiyaku_03 = nintei.NinteiSeikyuSeiyaku_03__c;
                wrapper.NinteiSeikyuSeiyaku_04 = nintei.NinteiSeikyuSeiyaku_04__c;
                wrapper.NinteiSeikyuSeiyaku_05 = nintei.NinteiSeikyuSeiyaku_05__c;
                wrapper.NinteiSeikyuSeiyaku_07 = nintei.NinteiSeikyuSeiyaku_07__c;
                wrapper.NinteiSeikyuSeiyaku_08 = nintei.NinteiSeikyuSeiyaku_08__c;
                wrapper.NinteiSeikyuSeiyaku_09 = nintei.NinteiSeikyuSeiyaku_09__c;
                wrapper.NinteiSeikyuSeiyaku_10 = nintei.NinteiSeikyuSeiyaku_10__c;
                wrapper.NinteiSeikyuSeiyaku_11 = nintei.NinteiSeikyuSeiyaku_11__c;
                wrapper.NinteiSeikyuSeiyaku_12 = nintei.NinteiSeikyuSeiyaku_12__c;
            }
        }
        return wrapper;
    }

    @AuraEnabled
    public static void register(String recordId, NinteiSeikyuSeiyakuWrapper input) {

        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            NinteiSeikyu__c nsObj = new NinteiSeikyu__c();
            nsObj.Id = recordId;

            nsObj.NinteiSeikyuSeiyaku_01__c = input.NinteiSeikyuSeiyaku_01;
            nsObj.NinteiSeikyuSeiyaku_02__c = input.NinteiSeikyuSeiyaku_02;
            nsObj.NinteiSeikyuSeiyaku_03__c = input.NinteiSeikyuSeiyaku_03;
            nsObj.NinteiSeikyuSeiyaku_04__c = input.NinteiSeikyuSeiyaku_04;
            nsObj.NinteiSeikyuSeiyaku_05__c = input.NinteiSeikyuSeiyaku_05;
            nsObj.NinteiSeikyuSeiyaku_07__c = input.NinteiSeikyuSeiyaku_07;
            nsObj.NinteiSeikyuSeiyaku_08__c = input.NinteiSeikyuSeiyaku_08;
            nsObj.NinteiSeikyuSeiyaku_09__c = input.NinteiSeikyuSeiyaku_09;
            nsObj.NinteiSeikyuSeiyaku_10__c = input.NinteiSeikyuSeiyaku_10;
            nsObj.NinteiSeikyuSeiyaku_11__c = input.NinteiSeikyuSeiyaku_11;
            nsObj.NinteiSeikyuSeiyaku_12__c = input.NinteiSeikyuSeiyaku_12;

            update nsObj;

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ //DV OR 里親
            DV_NinteiSeikyu__c nsObj = new DV_NinteiSeikyu__c();
            nsObj.Id = recordId;

            nsObj.NinteiSeikyuSeiyaku_01__c = input.NinteiSeikyuSeiyaku_01;
            nsObj.NinteiSeikyuSeiyaku_02__c = input.NinteiSeikyuSeiyaku_02;
            nsObj.NinteiSeikyuSeiyaku_03__c = input.NinteiSeikyuSeiyaku_03;
            nsObj.NinteiSeikyuSeiyaku_04__c = input.NinteiSeikyuSeiyaku_04;
            nsObj.NinteiSeikyuSeiyaku_05__c = input.NinteiSeikyuSeiyaku_05;
            nsObj.NinteiSeikyuSeiyaku_07__c = input.NinteiSeikyuSeiyaku_07;
            nsObj.NinteiSeikyuSeiyaku_08__c = input.NinteiSeikyuSeiyaku_08;
            nsObj.NinteiSeikyuSeiyaku_09__c = input.NinteiSeikyuSeiyaku_09;
            nsObj.NinteiSeikyuSeiyaku_10__c = input.NinteiSeikyuSeiyaku_10;
            nsObj.NinteiSeikyuSeiyaku_11__c = input.NinteiSeikyuSeiyaku_11;
            nsObj.NinteiSeikyuSeiyaku_12__c = input.NinteiSeikyuSeiyaku_12;

            update nsObj;
        }
    }

    public class NinteiSeikyuSeiyakuWrapper{
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_01 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_02 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_03 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_04 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_05 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_07 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_08 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_09 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_10 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_11 {get; set;}
        @AuraEnabled public Boolean NinteiSeikyuSeiyaku_12 {get; set;}
    }
}