@isTest
public with sharing class ExFubiTsuchiContlollerTest {
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
    private static void getFubiTsuchiForGeneral(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu1;
        TaishoJido__c jido1;
        TaishoJido__c jido2;
        FubiTsuchi__c fubi1;
        FubiTsuchi__c fubi2;

        ExFubiTsuchiContloller.fubitsuchiWrapper result;
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

            fubi1 = new FubiTsuchi__c(
                NinteiSeikyu__c = seikyu1.Id,
                TaishoJido__c = jido1.Id,
                KofuDate__c = Date.today()
            );
            fubi2 = new FubiTsuchi__c(
                NinteiSeikyu__c = seikyu1.Id,
                TaishoJido__c = jido2.Id
            );
            insert new List<FubiTsuchi__c>{fubi1, fubi2};

            Test.startTest();
            result = ExFubiTsuchiContloller.getFubiTsuchi(seikyu1.Id);
            Test.stopTest();
            
            Assert.areEqual(2, result.fubiTsuchiList.size());

            Assert.areEqual(fubi1.Id, result.fubiTsuchiList[0].parentId);
            Assert.areEqual('対象児童1氏名', result.fubiTsuchiList[0].fubiTaishoshaShimei);
            Assert.areEqual(Date.today().format(), result.fubiTsuchiList[0].kofuDate);
            
            Assert.areEqual(fubi2.Id, result.fubiTsuchiList[1].parentId);
            Assert.areEqual('対象児童2氏名', result.fubiTsuchiList[1].fubiTaishoshaShimei);
            Assert.areEqual(null, result.fubiTsuchiList[1].kofuDate);
        }

    }

    /** getTaishoJido DV */
    @isTest
    private static void getFubiTsuchiForDV(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu1;
        DV_TaishoJido__c jido1;
        DV_TaishoJido__c jido2;
        DV_FubiTsuchi__c fubi1;
        DV_FubiTsuchi__c fubi2;

        ExFubiTsuchiContloller.fubitsuchiWrapper result;
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

            fubi1 = new DV_FubiTsuchi__c(
                NinteiSeikyu__c = seikyu1.Id,
                TaishoJido__c = jido1.Id,
                KofuDate__c = Date.today()
            );
            fubi2 = new DV_FubiTsuchi__c(
                NinteiSeikyu__c = seikyu1.Id,
                TaishoJido__c = jido2.Id
            );
            insert new List<DV_FubiTsuchi__c>{fubi1, fubi2};

            Test.startTest();
            result = ExFubiTsuchiContloller.getFubiTsuchi(seikyu1.Id);
            Test.stopTest();
            
            Assert.areEqual(2, result.fubiTsuchiList.size());

            Assert.areEqual(fubi1.Id, result.fubiTsuchiList[0].parentId);
            Assert.areEqual('対象児童1氏名', result.fubiTsuchiList[0].fubiTaishoshaShimei);
            Assert.areEqual(Date.today().format(), result.fubiTsuchiList[0].kofuDate);
            
            Assert.areEqual(fubi2.Id, result.fubiTsuchiList[1].parentId);
            Assert.areEqual('対象児童2氏名', result.fubiTsuchiList[1].fubiTaishoshaShimei);
            Assert.areEqual(null, result.fubiTsuchiList[1].kofuDate);
        }

    }
}