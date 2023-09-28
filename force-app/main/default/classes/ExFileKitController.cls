public with sharing class ExFileKitController {

    @AuraEnabled
    public static void updateContentVersion(String contentVersionId, String shinseiShoruiTeigiId, Boolean isKenkoHoken){
        try {
            ContentVersion cv = new ContentVersion(
                Id = contentVersionId
                ,ShinseiShoruiTeigiId__c = shinseiShoruiTeigiId
                ,HoninKakuninShoruiMaskKenkoHoken__c = isKenkoHoken
                ,IsDeletable__c = true
                ,Shubetsu__c = 'Web'
            );

            update cv;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}