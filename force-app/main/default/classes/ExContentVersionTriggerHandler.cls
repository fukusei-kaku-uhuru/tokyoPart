public without sharing class ExContentVersionTriggerHandler {

    /**
     * 申請書類の情報を設定する
     */
    public static void updateShinseiShoruiTeigiData(List<ContentVersion> cvList) {

        Set<String> shinseiShoruiTeigiIdSet = new Set<String>();
        for (ContentVersion cv : cvList) {
            shinseiShoruiTeigiIdSet.add(cv.ShinseiShoruiTeigiId__c);
        }

        Map<Id, ShinseiShoruiTeigi__c> sstMap = new Map<Id, ShinseiShoruiTeigi__c>([
            SELECT
                Id
                ,Name
                ,OCR_Syoruisyubetu__c
            FROM
                ShinseiShoruiTeigi__c
            WHERE Id in :shinseiShoruiTeigiIdSet
        ]);

        for (ContentVersion cv : cvList) {
            ShinseiShoruiTeigi__c sst = sstMap.get(cv.ShinseiShoruiTeigiId__c);
            cv.ShinseiShoruiTeigiName__c = sst?.Name;
            cv.OCR_Syoruisyubetu__c = sst?.OCR_Syoruisyubetu__c;
        }
    }
}