public with sharing class SfNinteiSeikyuBeforeInsertProcess {

    public static void setUketsukeBangoShimo2Keta(List<NinteiSeikyu__c> newList){
        for(NinteiSeikyu__c ns : newList){
            if(ns.SequenceBango__c != null){
                ns.UketsukeBangoShimo2Keta__c = ns.SequenceBango__c.right(2);
            }
        }
    }
}