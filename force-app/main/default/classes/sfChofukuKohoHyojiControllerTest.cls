@isTest
private class sfChofukuKohoHyojiControllerTest {

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

            List<TaishoJido__c> result = sfChofukuKohoHyojiController.getChofukuKohoJido(tjList[0].Id);

            List<TaishoJido__c> tjList2 = new List<TaishoJido__c>();
            for (Integer i = 0; i < 2; i++) {
                TaishoJido__c taishoJido = sfTestUtil.getTaishoJido(ninteiSeikyu.Id);
                tjList2.add(taishoJido);
            }
            insert tjList2;

            result = sfChofukuKohoHyojiController.getChofukuKohoJido(tjList2[0].Id);

            Assert.areEqual('2023_テストタロウ_2020-01-01', result[0].GaibuKey__c);
            
    }
}