@IsTest
public without sharing class SfSeikyushaForUpdateDantaiCDHandlerTest {

    // @TestSetup
    // static void createTestData() {
     
    // }

    @isTest
    public static void test1(){
        Test.startTest();
        Seikyusha__c seikyusha = new Seikyusha__c();
        seikyusha.Shimei__c = 'testClassName1';
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = new NinteiSeikyu__c();
        ninteiSeikyu.Seikyusha__c = seikyusha.id;
        insert ninteiSeikyu;

        ChihoKokyoDantai__c ckd = new ChihoKokyoDantai__c();
        ckd.TodofukenKanji__c = '東京都';
        ckd.ShikuchosonKanji__c = '中央区';
        ckd.DantaiCode__c = '131024';
        insert ckd;

        seikyusha.Jusho__c = '東京都中央区';
        update seikyusha;
        NinteiSeikyu__c ninteiSeikyuKeka = [select id,ChihouKoukyouDantaiCode__c from NinteiSeikyu__c where id =: ninteiSeikyu.id];
        System.assertEquals('131024',ninteiSeikyuKeka.ChihouKoukyouDantaiCode__c);
        Test.stopTest();
    }

    @isTest
    public static void test2(){
        Seikyusha__c seikyusha = new Seikyusha__c();
        seikyusha.Shimei__c = 'testClassName1';
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = new NinteiSeikyu__c();
        ninteiSeikyu.Seikyusha__c = seikyusha.id;
        insert ninteiSeikyu;

        ChihoKokyoDantai__c ckd = new ChihoKokyoDantai__c();
        ckd.TodofukenKanji__c = '東京都';
        ckd.ShikuchosonKanji__c = '中央区';
        ckd.DantaiCode__c = '131024';
        insert ckd;

        Test.startTest();
        seikyusha.Jusho__c = '存在しない住所';
        update seikyusha;
        NinteiSeikyu__c ninteiSeikyuKeka = [select id,ChihouKoukyouDantaiCode__c from NinteiSeikyu__c where id =: ninteiSeikyu.id];
        System.assertEquals(null,ninteiSeikyuKeka.ChihouKoukyouDantaiCode__c);
        Test.stopTest();   
    }
}