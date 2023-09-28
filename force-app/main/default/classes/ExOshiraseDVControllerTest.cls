@isTest
public with sharing class ExOshiraseDVControllerTest {
    
    // 期間内レコードあり
    @isTest
    private static void WithinRange(){

        DV_ZentaiOshirase__c oshirase = new DV_ZentaiOshirase__c();
        oshirase.DV_KokaiShuryoDate__c = Date.today();
        oshirase.DV_KokaiKaishiDate__c = Date.today();
        oshirase.DV_Yukou__c = TRUE;
        insert oshirase;

        ExOshiraseDVController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseDVController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(1, result.oshiraseList.size());

    }

    // 期間内レコードなし
    @isTest
    private static void WithoutRange(){

        DV_ZentaiOshirase__c oshirase = new DV_ZentaiOshirase__c();
        oshirase.DV_KokaiShuryoDate__c = Date.today().addDays(-1);
        oshirase.DV_KokaiKaishiDate__c = Date.today().addDays(-1);
        oshirase.DV_Yukou__c = TRUE;
        insert oshirase;

        ExOshiraseDVController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseDVController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(0, result.oshiraseList.size());

    }

    // 有効・無効混在
    @isTest
    private static void YukouMukou(){

        DV_ZentaiOshirase__c oshirase = new DV_ZentaiOshirase__c();
        oshirase.DV_KokaiShuryoDate__c = Date.today();
        oshirase.DV_KokaiKaishiDate__c = Date.today();
        oshirase.DV_Yukou__c = TRUE;

        insert oshirase;

        oshirase = new DV_ZentaiOshirase__c();
        oshirase.DV_KokaiShuryoDate__c = Date.today();
        oshirase.DV_KokaiKaishiDate__c = Date.today();
        oshirase.DV_Yukou__c = FALSE;

        insert oshirase;

        ExOshiraseDVController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseDVController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(1, result.oshiraseList.size());

    }

}