@isTest
public with sharing class sfDVChofukuKohoHyojiControllerTest {

    @TestSetup
    private static void setUp(){


    }

    @isTest
    private static void test(){
            Seikyusha__c seikyusha = sfTestUtil.getSeikyusha();
            insert seikyusha;

            NinteiSeikyu__c ninteiSeikyu = sfTestUtil.getNinteiSeikyu(seikyusha.Id);
            insert ninteiSeikyu;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>();
            for (Integer i = 0; i < 2; i++) {
                TaishoJido__c taishoJido = sfTestUtil.getTaishoJido(ninteiSeikyu.Id);
                tjList.add(taishoJido);
            }
            insert tjList;

            DV_Seikyusha__c seikyushaDv = sfTestUtil.getSeikyushaDV();
            insert seikyushaDv;

            DV_NinteiSeikyu__c ninteiSeikyuDv = sfTestUtil.getNinteiSeikyuDV(seikyushaDv.Id);
            insert ninteiSeikyuDv;

            DV_TaishoJido__c taishoJidoDV = sfTestUtil.getTaishoJidoDV(ninteiSeikyuDv.Id);
            insert taishoJidoDV;

            List<TaishoJido__c> result = sfDVChofukuKohoHyojiController.getChofukuKohoJido(taishoJidoDV.Id);

            Assert.areEqual('2023_テストタロウ_2020-01-01', result[0].GaibuKey__c);
    }

    @isTest
    private static void testdv(){
            DV_Seikyusha__c seikyusha = sfTestUtil.getSeikyushaDV();
            insert seikyusha;

            DV_NinteiSeikyu__c ninteiSeikyu = sfTestUtil.getNinteiSeikyuDV(seikyusha.Id);
            insert ninteiSeikyu;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();
            for (Integer i = 0; i < 2; i++) {
                DV_TaishoJido__c taishoJido = sfTestUtil.getTaishoJidoDV(ninteiSeikyu.Id);
                tjList.add(taishoJido);
            }
            insert tjList;

            List<DV_TaishoJido__c> result = sfDVChofukuKohoHyojiController.getChofukuKohoJidoDV(tjList[0].Id);

            List<DV_TaishoJido__c> tjList2 = new List<DV_TaishoJido__c>();
            for (Integer i = 0; i < 2; i++) {
                DV_TaishoJido__c taishoJido = sfTestUtil.getTaishoJidoDV(ninteiSeikyu.Id);
                tjList2.add(taishoJido);
            }
            insert tjList2;

            result = sfDVChofukuKohoHyojiController.getChofukuKohoJidoDV(tjList2[0].Id);

            Assert.areEqual('2023_テストタロウ_2020-01-01', result[0].GaibuKey__c);
            
    }
}