public with sharing class ExShinseiKanryoController {

    /**
     * 認定請求受付番号を取得する
     */
    @AuraEnabled
    public static String getNinteiSeikyuNo(String recordId){
        try {
            String siteMode = ExLwcUtil.getSiteMode();

            String ninteiSeikyuNo;

            if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
                NinteiSeikyu__c ns = [
                    SELECT
                        NinteiSeikyuUketsukeBangou__c
                    FROM
                        NinteiSeikyu__c
                    WHERE
                        Id = :recordId
                ];
                ninteiSeikyuNo = ns.NinteiSeikyuUketsukeBangou__c;

            }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV・里親
                DV_NinteiSeikyu__c ns = [
                    SELECT
                        NinteiSeikyuUketsukeBangou__c
                    FROM
                        DV_NinteiSeikyu__c
                    WHERE
                        Id = :recordId
                    AND
                        RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
                ];
                ninteiSeikyuNo = ns.NinteiSeikyuUketsukeBangou__c;

            }

            return ninteiSeikyuNo;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}