@IsTest
public without sharing class SfDVNinteiSeikyuUKTKNoTriggerHandlerTest {
    @isTest
    public static void test1(){
        Test.startTest();
        // 郵送申請
        YusoShinsei__c yusoShinsei = new YusoShinsei__c();
        insert yusoShinsei;
        // 認定請求(DV)
        DV_NinteiSeikyu__c ninteiSeikyu = new DV_NinteiSeikyu__c();
        ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
        insert ninteiSeikyu;
        
        DV_NinteiSeikyu__c obj = [select id,SequenceBango__c from DV_NinteiSeikyu__c where id =: ninteiSeikyu.id];
        System.assertEquals(true,obj.SequenceBango__c != null);
        Test.stopTest();
    }
}