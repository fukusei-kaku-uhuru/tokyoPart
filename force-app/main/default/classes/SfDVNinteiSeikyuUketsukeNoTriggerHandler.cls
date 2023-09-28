public without sharing class SfDVNinteiSeikyuUketsukeNoTriggerHandler {
public void onBeforeInsert(List<DV_NinteiSeikyu__c> newList, Map<Id, DV_NinteiSeikyu__c> oldMap){
        
        Integer size = newList.size();
        
        List<UketsukeBangoHatsuban__c> seqList = getNextAutoNumbers(size);
        
        Integer index = 0;
        for(DV_NinteiSeikyu__c dvNinteiSeikyu : newList){
            dvNinteiSeikyu.SequenceBango__c = seqList[index].Name;
            index++;
        }
    }
    
   public List<UketsukeBangoHatsuban__c> getNextAutoNumbers(Integer size){
    
        List<UketsukeBangoHatsuban__c> seqList = new List<UketsukeBangoHatsuban__c>();
        for(Integer i = 0; i < size; i++){
            UketsukeBangoHatsuban__c seq = new UketsukeBangoHatsuban__c();
            seqList.add(seq);
        }

        Savepoint sp = Database.setSavePoint();        

        insert seqList;
        
        List<Id> idList = new List<Id>();
        
        for(UketsukeBangoHatsuban__c seq : seqList){
            idList.add(seq.Id);
        }
        
        seqList = [SELECT Id, Name FROM UketsukeBangoHatsuban__c WHERE Id IN :idList];        

        Database.rollback(sp);
        
        return seqList;
    }
}