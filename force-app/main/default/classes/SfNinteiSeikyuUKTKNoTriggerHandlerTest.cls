@IsTest
public without sharing class SfNinteiSeikyuUKTKNoTriggerHandlerTest {
    @isTest
    public static void test1(){
        Test.startTest();
        // 郵送申請
        YusoShinsei__c yusoShinsei = new YusoShinsei__c();
        insert yusoShinsei;
        // 認定請求
        NinteiSeikyu__c ninteiSeikyu = new NinteiSeikyu__c();
        ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
        insert ninteiSeikyu;
        Test.stopTest();
        NinteiSeikyu__c obj = [select id,SequenceBango__c from NinteiSeikyu__c where id=:ninteiSeikyu.id];
        System.assertEquals(true,obj.SequenceBango__c != null);
    }
}