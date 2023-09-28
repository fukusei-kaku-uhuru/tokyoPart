@isTest
public class SfDVFurikomiUtilTest {
    @isTest
    private static void furikomiSet001(){
        Furikomi__c furikomiObj = new Furikomi__c();
        DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();

        taishoJidoObj.KinyuKikanCode__c = '1111';
        taishoJidoObj.KouzaBangou__c = '1234567';

        Test.startTest();
        SfDVFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void furikomiSet002(){
        Furikomi__c furikomiObj = new Furikomi__c();
        DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();

        taishoJidoObj.YuchoKigo__c = '11111';
        taishoJidoObj.YuchoBango__c = '1234561';

        Test.startTest();
        SfDVFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void furikomiSet003(){
        Furikomi__c furikomiObj = new Furikomi__c();
        DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();

        taishoJidoObj.SK_KinyuKikanCode__c = '1111';
        taishoJidoObj.SK_KouzaBango__c = '1234567';

        Test.startTest();
        SfDVFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void furikomiSet004(){
        Furikomi__c furikomiObj = new Furikomi__c();
        DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();

        taishoJidoObj.SK_YuchoKigo__c = '11111';
        taishoJidoObj.SK_YuchoBango__c = '1234561';

        Test.startTest();
        SfDVFurikomiUtil.FurikomiSet(furikomiObj, taishoJidoObj);
        Test.stopTest();
    }

    @isTest
    private static void getyokinshumoku001(){
        Test.startTest();
        SfDVFurikomiUtil.getYokinShumoku(true, false, false);
        Test.stopTest();
    }
    @isTest
    private static void getyokinshumoku002(){
        Test.startTest();
        SfDVFurikomiUtil.getYokinShumoku(false, true, false);
        Test.stopTest();
    }
    @isTest
    private static void getyokinshumoku003(){
        Test.startTest();
        SfDVFurikomiUtil.getYokinShumoku(false, false, true);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku001(){
        Test.startTest();
        SfDVFurikomiUtil.getYuchoYokinShumoku(true, false, false, false);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku002(){
        Test.startTest();
        SfDVFurikomiUtil.getYuchoYokinShumoku(false, true, false, false);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku003(){
        Test.startTest();
        SfDVFurikomiUtil.getYuchoYokinShumoku(false, false, true, false);
        Test.stopTest();
    }
    @isTest
    private static void getyuchoyokinshumoku004(){
        Test.startTest();
        SfDVFurikomiUtil.getYuchoYokinShumoku(false, false, false, true);
        Test.stopTest();
    }

    @isTest
    private static void createfurikomi001(){
        DV_Seikyusha__c seikyushaObj = new DV_Seikyusha__c();
        insert seikyushaObj;

        DV_NinteiSeikyu__c ninteiSeikyuObj = new DV_NinteiSeikyu__c();
        ninteiSeikyuObj.Seikyusya__c = seikyushaObj.Id;
        insert ninteiSeikyuObj;

        DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();
        taishoJidoObj.NinteiSeikyu__c = ninteiSeikyuObj.Id;
        taishoJidoObj.ShinsaKekkaSaishu__c = SfDVFurikomiUtil.SHINSA_KEKKA_STR_OK;
        insert taishoJidoObj;

        Map<Id, DV_Seikyusha__c> newSeikyushaMap = new Map<Id, DV_Seikyusha__c>();
        Map<Id, DV_Seikyusha__c> oldSeikyushaMap = new Map<Id, DV_Seikyusha__c>();
        oldSeikyushaMap.put(seikyushaObj.Id, seikyushaObj);

        DV_Seikyusha__c newSeikyushaObj = new DV_Seikyusha__c();
        newSeikyushaObj.Id = seikyushaObj.Id;
        newSeikyushaObj.ShinsaKekkaSaishu__c = SfDVFurikomiUtil.SHINSA_KEKKA_STR_OK;
        newSeikyushaMap.put(newSeikyushaObj.Id, newSeikyushaObj);

        Test.startTest();
        SfDVFurikomiUtil.createFurikomi(newSeikyushaMap, oldSeikyushaMap);
        Test.stopTest();
    }

    @isTest
    private static void createfurikomi002(){
        DV_Seikyusha__c seikyushaObj = new DV_Seikyusha__c();
        seikyushaObj.ShinsaKekkaSaishu__c = SfDVFurikomiUtil.SHINSA_KEKKA_STR_OK;
        insert seikyushaObj;

        DV_NinteiSeikyu__c ninteiSeikyuObj = new DV_NinteiSeikyu__c();
        ninteiSeikyuObj.Seikyusya__c = seikyushaObj.Id;
        insert ninteiSeikyuObj;

        DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();
        taishoJidoObj.NinteiSeikyu__c = ninteiSeikyuObj.Id;
        insert taishoJidoObj;

        Map<Id, DV_TaishoJido__c> newTaishoJidoMap = new Map<Id, DV_TaishoJido__c>();
        Map<Id, DV_TaishoJido__c> oldTaishoJidoMap = new Map<Id, DV_TaishoJido__c>();
        oldTaishoJidoMap.put(taishoJidoObj.Id, taishoJidoObj);

        DV_TaishoJido__c newTaishoJidoObj = new DV_TaishoJido__c();
        newTaishoJidoObj.NinteiSeikyu__c = ninteiSeikyuObj.Id;
        newTaishoJidoObj.Id = taishoJidoObj.Id;
        newTaishoJidoObj.ShinsaKekkaSaishu__c = SfDVFurikomiUtil.SHINSA_KEKKA_STR_OK;
        newTaishoJidoMap.put(newTaishoJidoObj.Id, newTaishoJidoObj);

        Test.startTest();
        SfDVFurikomiUtil.createFurikomi(newTaishoJidoMap, oldTaishoJidoMap);
        Test.stopTest();
    }
}