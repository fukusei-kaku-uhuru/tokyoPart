@isTest
public with sharing class ExOshiraseSatooyaControllerTest {
    
    // 期間内レコードあり
    @isTest
    private static void WithinRange(){

        Satooya_ZentaiOshirase__c oshirase = new Satooya_ZentaiOshirase__c();
        oshirase.Satooya_KokaiKaishiDate__c = Date.today();
        oshirase.Satooya_KokaiShuryoDate__c = Date.today();
        oshirase.Satooya_Yukou__c = TRUE;
        insert oshirase;

        ExOshiraseSatooyaController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseSatooyaController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(1, result.oshiraseList.size());

    }

    // 期間内レコードなし
    @isTest
    private static void WithoutRange(){

        Satooya_ZentaiOshirase__c oshirase = new Satooya_ZentaiOshirase__c();
        oshirase.Satooya_KokaiKaishiDate__c = Date.today().addDays(-1);
        oshirase.Satooya_KokaiShuryoDate__c = Date.today().addDays(-1);
        oshirase.Satooya_Yukou__c = TRUE;
        insert oshirase;

        ExOshiraseSatooyaController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseSatooyaController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(0, result.oshiraseList.size());

    }

    // 有効・無効混在
    @isTest
    private static void YukouMukou(){

        Satooya_ZentaiOshirase__c oshirase = new Satooya_ZentaiOshirase__c();
        oshirase.Satooya_KokaiKaishiDate__c = Date.today();
        oshirase.Satooya_KokaiShuryoDate__c = Date.today();
        oshirase.Satooya_Yukou__c = TRUE;

        insert oshirase;

        oshirase = new Satooya_ZentaiOshirase__c();
        oshirase.Satooya_KokaiKaishiDate__c = Date.today();
        oshirase.Satooya_KokaiShuryoDate__c = Date.today();
        oshirase.Satooya_Yukou__c = FALSE;

        insert oshirase;

        ExOshiraseSatooyaController.OshiraseWrapper result;
        Test.startTest();
        result = ExOshiraseSatooyaController.getLast5Record();
        Test.stopTest();

        Assert.areEqual(1, result.oshiraseList.size());

    }

}