public with sharing class SfContentVersionBeforeTriggerProcess {

    public static void setIsDeletable(List<ContentVersion> cvList){
        for(ContentVersion cv : cvList){
            if(cv.MaskingFubi__c){
                cv.IsDeletable__c = true;
            }
        }
    }
}