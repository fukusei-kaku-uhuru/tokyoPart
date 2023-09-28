public with sharing class ExKakunin18Controller {

    private static String siteMode = ExLwcUtil.getSiteMode();
    
    @AuraEnabled(cacheable=false)
    public static NinteiSeikyuWrapper getNinteiSeikyu(String recordId) {
        NinteiSeikyuWrapper wrapper = new NinteiSeikyuWrapper();

        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<NinteiSeikyu__c> objList = [
                SELECT
                    Id
                    ,SeikyushaKubun_18saiFukumu__c
                    ,SeikyushaKubun_18saiFukumanai__c
                FROM
                    NinteiSeikyu__c
                WHERE
                    Id = :recordId
            ];
            if (objList.size() == 0) {
                return wrapper;
            }
            NinteiSeikyu__c obj = objList.get(0);
            wrapper.include18 = obj.SeikyushaKubun_18saiFukumu__c;
            wrapper.includeNot18 = obj.SeikyushaKubun_18saiFukumanai__c;

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV OR 里親
            List<DV_NinteiSeikyu__c> objList = [
                SELECT
                    Id
                    ,SeikyushaKubun_18saiFukumu__c
                    ,SeikyushaKubun_18saiFukumanai__c
                FROM
                    DV_NinteiSeikyu__c
                WHERE
                    Id = :recordId
                AND
                    RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
            ];
            if (objList.size() == 0) {
                return wrapper;
            }
            DV_NinteiSeikyu__c obj = objList.get(0);
            wrapper.include18 = obj.SeikyushaKubun_18saiFukumu__c;
            wrapper.includeNot18 = obj.SeikyushaKubun_18saiFukumanai__c;

        }

        return wrapper;
    }

    @AuraEnabled
    public static void updateNinteiSeikyu(String recordId, Boolean isInclude18) {
        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<NinteiSeikyu__c> objList = [
                SELECT
                    Id
                FROM
                    NinteiSeikyu__c
                WHERE
                    Id = :recordId
            ];
            if (objList.size() == 0) {
                return;
            }
            NinteiSeikyu__c updateObj = objList.get(0);
            if (isInclude18) {
                updateObj.SeikyushaKubun_18saiFukumu__c = true;
                updateObj.SeikyushaKubun_18saiFukumanai__c = false;
            }
            else {
                updateObj.SeikyushaKubun_18saiFukumu__c = false;
                updateObj.SeikyushaKubun_18saiFukumanai__c = true;
            }
            update updateObj;

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV OR 里親
            List<DV_NinteiSeikyu__c> objList = [
                SELECT
                    Id
                FROM
                    DV_NinteiSeikyu__c
                WHERE
                    Id = :recordId
                AND
                    RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
            ];
            if (objList.size() == 0) {
                return;
            }
            DV_NinteiSeikyu__c updateObj = objList.get(0);
            if (isInclude18) {
                updateObj.SeikyushaKubun_18saiFukumu__c = true;
                updateObj.SeikyushaKubun_18saiFukumanai__c = false;
            }
            else {
                updateObj.SeikyushaKubun_18saiFukumu__c = false;
                updateObj.SeikyushaKubun_18saiFukumanai__c = true;
            }
            update updateObj;

        }

        return;
    }
    
    public class NinteiSeikyuWrapper{
        @AuraEnabled public Boolean include18 {get; set;}
        @AuraEnabled public Boolean includeNot18 {get; set;}
    }
}