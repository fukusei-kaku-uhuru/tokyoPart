@isTest
public class SfNinteiSeikyuBeforeInsertProcessTest {

    @isTest
    private static void test(){
        NinteiSeikyu__c ns1 = new NinteiSeikyu__c();
        ns1.SequenceBango__c = '00000001';
        List<NinteiSeikyu__c> nsList = new List<NinteiSeikyu__c>{ns1};

        Test.startTest();
        SfNinteiSeikyuBeforeInsertProcess.setUketsukeBangoShimo2Keta(nsList);
        Test.stopTest();

        System.assertEquals(ns1.UketsukeBangoShimo2Keta__c, '01');
    }

    @isTest
    static void testForTrigger(){
        Test.startTest();
        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        insert ns;
        update ns;
        Test.stopTest();        
    }
}