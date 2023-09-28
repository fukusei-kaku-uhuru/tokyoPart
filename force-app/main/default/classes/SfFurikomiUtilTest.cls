@isTest
public class SfFurikomiUtilTest {

    @isTest
    private static void furikomiSet001(){
        Furikomi__c furikomiObj = new Furikomi__c();
        TaishoJido__c taishoJidoObj = new TaishoJido__c();

        taishoJidoObj.KinyuKikanCode__c = '1111';
        taishoJidoObj.KouzaBangou__c = '1234567';

        Test.startTest();
        SfFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void furikomiSet002(){
        Furikomi__c furikomiObj = new Furikomi__c();
        TaishoJido__c taishoJidoObj = new TaishoJido__c();

        taishoJidoObj.YuchoKigo__c = '11111';
        taishoJidoObj.YuchoBango__c = '1234561';

        Test.startTest();
        SfFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void furikomiSet003(){
        Furikomi__c furikomiObj = new Furikomi__c();
        TaishoJido__c taishoJidoObj = new TaishoJido__c();

        taishoJidoObj.SK_KinyuKikanCode__c = '1111';
        taishoJidoObj.SK_KouzaBango__c = '1234567';

        Test.startTest();
        SfFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void furikomiSet004(){
        Furikomi__c furikomiObj = new Furikomi__c();
        TaishoJido__c taishoJidoObj = new TaishoJido__c();

        taishoJidoObj.SK_YuchoKigo__c = '11111';
        taishoJidoObj.SK_YuchoBango__c = '1234561';

        Test.startTest();
        SfFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void getyokinshumoku001(){
        Test.startTest();
        SfFurikomiUtil.getYokinShumoku(true, false, false);
        Test.stopTest();
    }
    @isTest
    private static void getyokinshumoku002(){
        Test.startTest();
        SfFurikomiUtil.getYokinShumoku(false, true, false);
        Test.stopTest();
    }
    @isTest
    private static void getyokinshumoku003(){
        Test.startTest();
        SfFurikomiUtil.getYokinShumoku(false, false, true);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku001(){
        Test.startTest();
        SfFurikomiUtil.getYuchoYokinShumoku(true, false, false, false);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku002(){
        Test.startTest();
        SfFurikomiUtil.getYuchoYokinShumoku(false, true, false, false);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku003(){
        Test.startTest();
        SfFurikomiUtil.getYuchoYokinShumoku(false, false, true, false);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku004(){
        Test.startTest();
        SfFurikomiUtil.getYuchoYokinShumoku(false, false, false, true);
        Test.stopTest();
    }

    @isTest
    private static void createfurikomi001(){
        Seikyusha__c seikyushaObj = new Seikyusha__c();
        insert seikyushaObj;

        NinteiSeikyu__c ninteiSeikyuObj = new NinteiSeikyu__c();
        ninteiSeikyuObj.Seikyusha__c = seikyushaObj.Id;
        insert ninteiSeikyuObj;

        TaishoJido__c taishoJidoObj = new TaishoJido__c();
        taishoJidoObj.NinteiSeikyu__c = ninteiSeikyuObj.Id;
        taishoJidoObj.ShinsaKekkaSaishu__c = SfFurikomiUtil.SHINSA_KEKKA_STR_OK;
        insert taishoJidoObj;

        Map<Id, Seikyusha__c> newSeikyushaMap = new Map<Id, Seikyusha__c>();
        Map<Id, Seikyusha__c> oldSeikyushaMap = new Map<Id, Seikyusha__c>();
        oldSeikyushaMap.put(seikyushaObj.Id, seikyushaObj);

        Seikyusha__c newSeikyushaObj = new Seikyusha__c();
        newSeikyushaObj.Id = seikyushaObj.Id;
        newSeikyushaObj.ShinsaKekkaSaishu__c = SfFurikomiUtil.SHINSA_KEKKA_STR_OK;
        newSeikyushaMap.put(newSeikyushaObj.Id, newSeikyushaObj);

        Test.startTest();
        SfFurikomiUtil.createFurikomi(newSeikyushaMap, oldSeikyushaMap);
        Test.stopTest();
    }

    @isTest
    private static void createfurikomi002(){
        Seikyusha__c seikyushaObj = new Seikyusha__c();
        seikyushaObj.ShinsaKekkaSaishu__c = SfFurikomiUtil.SHINSA_KEKKA_STR_OK;
        insert seikyushaObj;

        NinteiSeikyu__c ninteiSeikyuObj = new NinteiSeikyu__c();
        ninteiSeikyuObj.Seikyusha__c = seikyushaObj.Id;
        insert ninteiSeikyuObj;

        TaishoJido__c taishoJidoObj = new TaishoJido__c();
        taishoJidoObj.NinteiSeikyu__c = ninteiSeikyuObj.Id;
        insert taishoJidoObj;

        Map<Id, TaishoJido__c> newTaishoJidoMap = new Map<Id, TaishoJido__c>();
        Map<Id, TaishoJido__c> oldTaishoJidoMap = new Map<Id, TaishoJido__c>();
        oldTaishoJidoMap.put(taishoJidoObj.Id, taishoJidoObj);

        TaishoJido__c newTaishoJidoObj = new TaishoJido__c();
        newTaishoJidoObj.NinteiSeikyu__c = ninteiSeikyuObj.Id;
        newTaishoJidoObj.Id = taishoJidoObj.Id;
        newTaishoJidoObj.ShinsaKekkaSaishu__c = SfFurikomiUtil.SHINSA_KEKKA_STR_OK;
        newTaishoJidoMap.put(newTaishoJidoObj.Id, newTaishoJidoObj);

        Test.startTest();
        SfFurikomiUtil.createFurikomi(newTaishoJidoMap, oldTaishoJidoMap);
        Test.stopTest();
    }
}