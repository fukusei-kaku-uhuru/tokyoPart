@isTest
public with sharing class ExNinteiKekkaControllerTest {

    @TestSetup
    private static void setUp(){
        String uniqueKey = ExTestUtil.getUniqueKey();

        String generalName = ExTestUtil.GENERAL_PREFIX + uniqueKey;
        String dvName = ExTestUtil.DV_PREFIX + uniqueKey;
        String satoyaName = ExTestUtil.SATOYA_PREFIX + uniqueKey;

        Account generalAcc = ExTestUtil.getPersonAccount(generalName);
        Account dvAcc = ExTestUtil.getPersonAccount(dvName);
        Account satoyaAcc = ExTestUtil.getPersonAccount(satoyaName);
        insert new List<Account>{generalAcc, dvAcc, satoyaAcc};

        User generalUser = ExTestUtil.getGeneralUser(generalName, generalAcc.Id);
        User dvUser = ExTestUtil.getDvUser(dvName, dvAcc.Id);
        User satoyaUser = ExTestUtil.getSatoyaUser(satoyaName, satoyaAcc.Id);
        insert new List<User>{generalUser, dvUser, satoyaUser};
    }

    /** getTaishoJido 一般 */
    @isTest
    private static void getTaishoJidoForGeneral(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu1;
        NinteiSeikyu__c seikyu2;
        TaishoJido__c jido1;
        TaishoJido__c jido2;

        ExNinteiKekkaController.taishoJidoWrapper result;
        System.runAs(platformUser){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            seikyu1 = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu1.ShinsaStatus__c = '1次審査中';
            insert seikyu1;

            jido1 = new TaishoJido__c(
                NinteiSeikyu__c = seikyu1.Id,
                Shimei__c = '対象児童1氏名',
                NinteiTsuchishoHakkoDate__c = Date.today(),
                ShoninKekka__c = '認定',
                Shometsu_Date__c = Date.today()
            );
            jido2 = new TaishoJido__c(
                NinteiSeikyu__c = seikyu1.Id,
                Shimei__c = '対象児童2氏名',
                ShoninKekka__c = '保留'
            );
            insert new List<TaishoJido__c>{jido1, jido2};

            Test.startTest();
            result = ExNinteiKekkaController.getTaishoJido(seikyu1.Id);
            Test.stopTest();
            
            Assert.areEqual(2, result.taishoJidoList.size());

            Assert.areEqual(jido1.Id, result.taishoJidoList[0].parentId);
            Assert.areEqual('対象児童1氏名', result.taishoJidoList[0].shimei);
            Assert.areEqual('認定', result.taishoJidoList[0].shoninKekka);
            Assert.areEqual(Date.today().format(), result.taishoJidoList[0].ninteiTsuchishoHakkoDate);
            Assert.areEqual(false, result.taishoJidoList[0].isDownload);
            Assert.areEqual(true, result.taishoJidoList[0].isNintei);
            Assert.areEqual(false, result.taishoJidoList[0].isNotShometsu);
            Assert.areEqual(0, result.taishoJidoList[0].childList.size());
            
            Assert.areEqual(jido2.Id, result.taishoJidoList[1].parentId);
            Assert.areEqual('対象児童2氏名', result.taishoJidoList[1].shimei);
            Assert.areEqual('－', result.taishoJidoList[1].shoninKekka);
            Assert.areEqual(null, result.taishoJidoList[1].ninteiTsuchishoHakkoDate);
            Assert.areEqual(false, result.taishoJidoList[1].isDownload);
            Assert.areEqual(false, result.taishoJidoList[1].isNintei);
            Assert.areEqual(true, result.taishoJidoList[1].isNotShometsu);
            Assert.areEqual(0, result.taishoJidoList[1].childList.size());
        }
    }

    /** getNinteiSeikyu DV */
    @isTest
    private static void getTaishoJidoForDv(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu1;
        DV_NinteiSeikyu__c seikyu2;
        DV_TaishoJido__c jido1;
        DV_TaishoJido__c jido2;

        ExNinteiKekkaController.taishoJidoWrapper result;
        System.runAs(platformUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            seikyu1 = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu1.ShinsaStatus__c = '1次審査中';
            insert seikyu1;

            jido1 = new DV_TaishoJido__c(
                NinteiSeikyu__c = seikyu1.Id,
                Shimei__c = '対象児童1氏名',
                NinteiTsuchishoHakkoDate__c = Date.today(),
                ShoninKekka__c = '認定',
                Shometsu_Date__c = Date.today()
            );
            jido2 = new DV_TaishoJido__c(
                NinteiSeikyu__c = seikyu1.Id,
                Shimei__c = '対象児童2氏名',
                ShoninKekka__c = '保留'
            );
            insert new List<DV_TaishoJido__c>{jido1, jido2};

            Test.startTest();
            result = ExNinteiKekkaController.getTaishoJido(seikyu1.Id);
            Test.stopTest();
            
            Assert.areEqual(2, result.taishoJidoList.size());

            Assert.areEqual(jido1.Id, result.taishoJidoList[0].parentId);
            Assert.areEqual('対象児童1氏名', result.taishoJidoList[0].shimei);
            Assert.areEqual('認定', result.taishoJidoList[0].shoninKekka);
            Assert.areEqual(Date.today().format(), result.taishoJidoList[0].ninteiTsuchishoHakkoDate);
            Assert.areEqual(false, result.taishoJidoList[0].isDownload);
            Assert.areEqual(true, result.taishoJidoList[0].isNintei);
            Assert.areEqual(false, result.taishoJidoList[0].isNotShometsu);
            Assert.areEqual(0, result.taishoJidoList[0].childList.size());
            
            Assert.areEqual(jido2.Id, result.taishoJidoList[1].parentId);
            Assert.areEqual('対象児童2氏名', result.taishoJidoList[1].shimei);
            Assert.areEqual('－', result.taishoJidoList[1].shoninKekka);
            Assert.areEqual(null, result.taishoJidoList[1].ninteiTsuchishoHakkoDate);
            Assert.areEqual(false, result.taishoJidoList[1].isDownload);
            Assert.areEqual(false, result.taishoJidoList[1].isNintei);
            Assert.areEqual(true, result.taishoJidoList[1].isNotShometsu);
            Assert.areEqual(0, result.taishoJidoList[1].childList.size());
        }
    }
}