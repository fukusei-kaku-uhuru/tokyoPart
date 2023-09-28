@IsTest
public without sharing class SfTaishoJidoUpDantaiCDTriggerHandlerTest {
    @TestSetup
    static void createTestData() {
        // 請求者
        Seikyusha__c seikyusha = new Seikyusha__c();
        seikyusha.Shimei__c = 'テストクラスユーザ';
        insert seikyusha;
        // 郵送申請
        YusoShinsei__c yusoShinsei = new YusoShinsei__c();
        yusoShinsei.Status__c = '受付';
        insert yusoShinsei;
        // 認定請求
        NinteiSeikyu__c ninteiSeikyu = new NinteiSeikyu__c();
        ninteiSeikyu.Seikyusha__c = seikyusha.id;
        ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
        insert ninteiSeikyu;
        // 対象児童
        TaishoJido__c taishoJido = new TaishoJido__c();
        taishoJido.NinteiSeikyu__c = ninteiSeikyu.id;
        taishoJido.SonotaShousai__c = 'testClassName1';
        insert taishoJido;

        ChihoKokyoDantai__c ckd = new ChihoKokyoDantai__c();
        ckd.TodofukenKanji__c = '東京都';
        ckd.ShikuchosonKanji__c = '中央区';
        ckd.DantaiCode__c = '131024';
        insert ckd;
    }

    @isTest
    public static void test1(){
        updateExcute();
        List<TaishoJido__c> tsjList2 = [select id,Jusho__c,ChihouKoukyouDantaiCode__c from TaishoJido__c where SonotaShousai__c = 'testClassName1'];
        System.assertEquals('131024',tsjList2[0].ChihouKoukyouDantaiCode__c);
    }

    @isTest
    public static void test2(){
        updateExcute2();
        List<TaishoJido__c> tsjList2 = [select id,Jusho__c,ChihouKoukyouDantaiCode__c from TaishoJido__c where SonotaShousai__c = 'testClassName1'];
        System.assertEquals(null,tsjList2[0].ChihouKoukyouDantaiCode__c);
    }

    public static void updateExcute(){
        List<TaishoJido__c> tsjList = [select id,Jusho__c,ChihouKoukyouDantaiCode__c from TaishoJido__c where SonotaShousai__c = 'testClassName1'];
        Test.startTest();
        tsjList[0].Jusho__c = '東京都中央区';
        update tsjList;
        Test.stopTest();
    }

    public static void updateExcute2(){
        List<TaishoJido__c> tsjList = [select id,Jusho__c,ChihouKoukyouDantaiCode__c from TaishoJido__c where SonotaShousai__c = 'testClassName1'];
        Test.startTest();
        tsjList[0].Jusho__c = '東京都123中央区';
        update tsjList;
        Test.stopTest();
    }
}