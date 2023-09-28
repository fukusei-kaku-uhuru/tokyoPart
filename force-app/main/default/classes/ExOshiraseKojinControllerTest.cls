@isTest
public with sharing class ExOshiraseKojinControllerTest {
    
    // 期間内レコードあり
    @isTest
    private static void WithinRange(){

        KojinOshirase__c oshirase = new KojinOshirase__c();
        oshirase.KokaiKaishiDate__c = Date.today();
        oshirase.KokaiShuryoDate__c = Date.today();
        oshirase.Yukou__c = TRUE;
        insert oshirase;

        ExOshiraseKojinController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseKojinController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(1, result.oshiraseList.size());

    }

    // 期間内レコードなし
    @isTest
    private static void WithoutRange(){

        KojinOshirase__c oshirase = new KojinOshirase__c();
        oshirase.KokaiKaishiDate__c = Date.today().addDays(-1);
        oshirase.KokaiShuryoDate__c = Date.today().addDays(-1);
        oshirase.Yukou__c = TRUE;
        insert oshirase;

        ExOshiraseKojinController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseKojinController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(0, result.oshiraseList.size());

    }

    // 有効・無効混在
    @isTest
    private static void YukouMukou(){

        KojinOshirase__c oshirase = new KojinOshirase__c();
        oshirase.KokaiKaishiDate__c = Date.today();
        oshirase.KokaiShuryoDate__c = Date.today();
        oshirase.Yukou__c = TRUE;

        insert oshirase;

        oshirase = new KojinOshirase__c();
        oshirase.KokaiKaishiDate__c = Date.today();
        oshirase.KokaiShuryoDate__c = Date.today();
        oshirase.Yukou__c = FALSE;

        insert oshirase;

        ExOshiraseKojinController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseKojinController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(1, result.oshiraseList.size());

    }

}