@isTest
private class ExSeiyakuDouiControllerTest {

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

    /**
     * getSeiyaku 初回
     */
    @isTest
    private static void getSeiyakuAtFirst(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper result;
        System.runAs(u){
            Test.startTest();
            result = ExSeiyakuDouiController.getSeiyaku('');
            Test.stopTest();
        }

        Assert.isNull(result.NinteiSeikyuSeiyaku_01);
        Assert.isNull(result.NinteiSeikyuSeiyaku_02);
        Assert.isNull(result.NinteiSeikyuSeiyaku_03);
        Assert.isNull(result.NinteiSeikyuSeiyaku_04);
        Assert.isNull(result.NinteiSeikyuSeiyaku_05);
        Assert.isNull(result.NinteiSeikyuSeiyaku_07);
        Assert.isNull(result.NinteiSeikyuSeiyaku_08);
        Assert.isNull(result.NinteiSeikyuSeiyaku_09);
        Assert.isNull(result.NinteiSeikyuSeiyaku_10);
        Assert.isNull(result.NinteiSeikyuSeiyaku_11);
        Assert.isNull(result.NinteiSeikyuSeiyaku_12);
    }

    /**
     * getSeiyaku 一般
     */
    @isTest
    private static void getSeiyakuForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.NinteiSeikyuSeiyaku_01__c = true;
            seikyu.NinteiSeikyuSeiyaku_02__c = true;
            seikyu.NinteiSeikyuSeiyaku_03__c = true;
            seikyu.NinteiSeikyuSeiyaku_04__c = true;
            seikyu.NinteiSeikyuSeiyaku_05__c = true;
            seikyu.NinteiSeikyuSeiyaku_07__c = true;
            seikyu.NinteiSeikyuSeiyaku_08__c = true;
            seikyu.NinteiSeikyuSeiyaku_09__c = true;
            seikyu.NinteiSeikyuSeiyaku_10__c = true;
            seikyu.NinteiSeikyuSeiyaku_11__c = true;
            seikyu.NinteiSeikyuSeiyaku_12__c = true;
            insert seikyu;

            Test.startTest();
            result = ExSeiyakuDouiController.getSeiyaku(seikyu.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.NinteiSeikyuSeiyaku_01);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_02);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_03);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_04);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_05);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_07);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_08);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_09);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_10);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_11);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_12);
    }

    /**
     * getSeiyaku DV
     */
    @isTest
    private static void getSeiyakuForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.NinteiSeikyuSeiyaku_01__c = true;
            seikyu.NinteiSeikyuSeiyaku_02__c = true;
            seikyu.NinteiSeikyuSeiyaku_03__c = true;
            seikyu.NinteiSeikyuSeiyaku_04__c = true;
            seikyu.NinteiSeikyuSeiyaku_05__c = true;
            seikyu.NinteiSeikyuSeiyaku_07__c = true;
            seikyu.NinteiSeikyuSeiyaku_08__c = true;
            seikyu.NinteiSeikyuSeiyaku_09__c = true;
            seikyu.NinteiSeikyuSeiyaku_10__c = true;
            seikyu.NinteiSeikyuSeiyaku_11__c = true;
            seikyu.NinteiSeikyuSeiyaku_12__c = true;
            insert seikyu;

            Test.startTest();
            result = ExSeiyakuDouiController.getSeiyaku(seikyu.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.NinteiSeikyuSeiyaku_01);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_02);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_03);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_04);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_05);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_07);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_08);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_09);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_10);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_11);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_12);
    }

    /**
     * getSeiyaku 里親
     */
    @isTest
    private static void getSeiyakuForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.NinteiSeikyuSeiyaku_01__c = true;
            seikyu.NinteiSeikyuSeiyaku_02__c = true;
            seikyu.NinteiSeikyuSeiyaku_03__c = true;
            seikyu.NinteiSeikyuSeiyaku_04__c = true;
            seikyu.NinteiSeikyuSeiyaku_05__c = true;
            seikyu.NinteiSeikyuSeiyaku_07__c = true;
            seikyu.NinteiSeikyuSeiyaku_08__c = true;
            seikyu.NinteiSeikyuSeiyaku_09__c = true;
            seikyu.NinteiSeikyuSeiyaku_10__c = true;
            seikyu.NinteiSeikyuSeiyaku_11__c = true;
            seikyu.NinteiSeikyuSeiyaku_12__c = true;
            insert seikyu;

            Test.startTest();
            result = ExSeiyakuDouiController.getSeiyaku(seikyu.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.NinteiSeikyuSeiyaku_01);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_02);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_03);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_04);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_05);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_07);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_08);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_09);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_10);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_11);
        Assert.isTrue(result.NinteiSeikyuSeiyaku_12);
    }

    /**
     * register 一般
     */
    @isTest
    private static void registerForGeneralUpdate(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper input = new ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper();
        input.NinteiSeikyuSeiyaku_01 = true;
        input.NinteiSeikyuSeiyaku_02 = true;
        input.NinteiSeikyuSeiyaku_03 = true;
        input.NinteiSeikyuSeiyaku_04 = true;
        input.NinteiSeikyuSeiyaku_05 = true;
        input.NinteiSeikyuSeiyaku_07 = true;
        input.NinteiSeikyuSeiyaku_08 = true;
        input.NinteiSeikyuSeiyaku_09 = true;
        input.NinteiSeikyuSeiyaku_10 = true;
        input.NinteiSeikyuSeiyaku_11 = true;
        input.NinteiSeikyuSeiyaku_12 = true;

        NinteiSeikyu__c seikyu;
        Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.NinteiSeikyuSeiyaku_01__c = false;
            seikyu.NinteiSeikyuSeiyaku_02__c = false;
            seikyu.NinteiSeikyuSeiyaku_03__c = false;
            seikyu.NinteiSeikyuSeiyaku_04__c = false;
            seikyu.NinteiSeikyuSeiyaku_05__c = false;
            seikyu.NinteiSeikyuSeiyaku_07__c = false;
            seikyu.NinteiSeikyuSeiyaku_08__c = false;
            seikyu.NinteiSeikyuSeiyaku_09__c = false;
            seikyu.NinteiSeikyuSeiyaku_10__c = false;
            seikyu.NinteiSeikyuSeiyaku_11__c = false;
            seikyu.NinteiSeikyuSeiyaku_12__c = false;
            insert seikyu;

            Test.startTest();
            ExSeiyakuDouiController.register(seikyu.Id, input);
            Test.stopTest();
        }

        NinteiSeikyu__c updSeikyu = [
            SELECT
                ShinsaStatus__c,
                Seikyusha__c,
                Seikyusha__r.Shimei__c,
                NinteiSeikyuSeiyaku_01__c,
                NinteiSeikyuSeiyaku_02__c,
                NinteiSeikyuSeiyaku_03__c,
                NinteiSeikyuSeiyaku_04__c,
                NinteiSeikyuSeiyaku_05__c,
                NinteiSeikyuSeiyaku_07__c,
                NinteiSeikyuSeiyaku_08__c,
                NinteiSeikyuSeiyaku_09__c,
                NinteiSeikyuSeiyaku_10__c,
                NinteiSeikyuSeiyaku_11__c,
                NinteiSeikyuSeiyaku_12__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];

        Assert.areEqual('未申請', updSeikyu.ShinsaStatus__c);

        Assert.areEqual(seikyusha.Id, updSeikyu.Seikyusha__c);
        Assert.areEqual('請求者氏名', updSeikyu.Seikyusha__r.Shimei__c);

        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_01__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_02__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_03__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_04__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_05__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_07__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_08__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_09__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_10__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_11__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_12__c);
    }

    /**
     * register DV 更新
     */
    @isTest
    private static void registerForDvUpdate(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper input = new ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper();
        input.NinteiSeikyuSeiyaku_01 = true;
        input.NinteiSeikyuSeiyaku_02 = true;
        input.NinteiSeikyuSeiyaku_03 = true;
        input.NinteiSeikyuSeiyaku_04 = true;
        input.NinteiSeikyuSeiyaku_05 = true;
        input.NinteiSeikyuSeiyaku_07 = true;
        input.NinteiSeikyuSeiyaku_08 = true;
        input.NinteiSeikyuSeiyaku_09 = true;
        input.NinteiSeikyuSeiyaku_10 = true;
        input.NinteiSeikyuSeiyaku_11 = true;
        input.NinteiSeikyuSeiyaku_12 = true;

        DV_Seikyusha__c seikyusha;
        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.NinteiSeikyuSeiyaku_01__c = false;
            seikyu.NinteiSeikyuSeiyaku_02__c = false;
            seikyu.NinteiSeikyuSeiyaku_03__c = false;
            seikyu.NinteiSeikyuSeiyaku_04__c = false;
            seikyu.NinteiSeikyuSeiyaku_05__c = false;
            seikyu.NinteiSeikyuSeiyaku_07__c = false;
            seikyu.NinteiSeikyuSeiyaku_08__c = false;
            seikyu.NinteiSeikyuSeiyaku_09__c = false;
            seikyu.NinteiSeikyuSeiyaku_10__c = false;
            seikyu.NinteiSeikyuSeiyaku_11__c = false;
            seikyu.NinteiSeikyuSeiyaku_12__c = false;
            insert seikyu;

            Test.startTest();
            ExSeiyakuDouiController.register(seikyu.Id, input);
            Test.stopTest();
        }


        DV_NinteiSeikyu__c updSeikyu = [
            SELECT
                ShinsaStatus__c,
                Seikyusya__c,
                Seikyusya__r.Shimei__c,
                NinteiSeikyuSeiyaku_01__c,
                NinteiSeikyuSeiyaku_02__c,
                NinteiSeikyuSeiyaku_03__c,
                NinteiSeikyuSeiyaku_04__c,
                NinteiSeikyuSeiyaku_05__c,
                NinteiSeikyuSeiyaku_07__c,
                NinteiSeikyuSeiyaku_08__c,
                NinteiSeikyuSeiyaku_09__c,
                NinteiSeikyuSeiyaku_10__c,
                NinteiSeikyuSeiyaku_11__c,
                NinteiSeikyuSeiyaku_12__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
            Id = :seikyu.Id
            LIMIT 1
        ];

        Assert.areEqual('未申請', seikyu.ShinsaStatus__c);

        Assert.areEqual(seikyusha.Id, updSeikyu.Seikyusya__c);
        Assert.areEqual('請求者氏名', updSeikyu.Seikyusya__r.Shimei__c);

        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_01__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_02__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_03__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_04__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_05__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_07__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_08__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_09__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_10__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_11__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_12__c);
    }

    /**
     * register 里親 更新
     */
    @isTest
    private static void registerForSatoyaUpdate(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper input = new ExSeiyakuDouiController.NinteiSeikyuSeiyakuWrapper();
        input.NinteiSeikyuSeiyaku_01 = true;
        input.NinteiSeikyuSeiyaku_02 = true;
        input.NinteiSeikyuSeiyaku_03 = true;
        input.NinteiSeikyuSeiyaku_04 = true;
        input.NinteiSeikyuSeiyaku_05 = true;
        input.NinteiSeikyuSeiyaku_07 = true;
        input.NinteiSeikyuSeiyaku_08 = true;
        input.NinteiSeikyuSeiyaku_09 = true;
        input.NinteiSeikyuSeiyaku_10 = true;
        input.NinteiSeikyuSeiyaku_11 = true;
        input.NinteiSeikyuSeiyaku_12 = true;

        DV_Seikyusha__c seikyusha;
        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.NinteiSeikyuSeiyaku_01__c = false;
            seikyu.NinteiSeikyuSeiyaku_02__c = false;
            seikyu.NinteiSeikyuSeiyaku_03__c = false;
            seikyu.NinteiSeikyuSeiyaku_04__c = false;
            seikyu.NinteiSeikyuSeiyaku_05__c = false;
            seikyu.NinteiSeikyuSeiyaku_07__c = false;
            seikyu.NinteiSeikyuSeiyaku_08__c = false;
            seikyu.NinteiSeikyuSeiyaku_09__c = false;
            seikyu.NinteiSeikyuSeiyaku_10__c = false;
            seikyu.NinteiSeikyuSeiyaku_11__c = false;
            seikyu.NinteiSeikyuSeiyaku_12__c = false;
            insert seikyu;

            Test.startTest();
            ExSeiyakuDouiController.register(seikyu.Id, input);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c updSeikyu = [
            SELECT
                ShinsaStatus__c,
                Seikyusya__c,
                Seikyusya__r.Shimei__c,
                NinteiSeikyuSeiyaku_01__c,
                NinteiSeikyuSeiyaku_02__c,
                NinteiSeikyuSeiyaku_03__c,
                NinteiSeikyuSeiyaku_04__c,
                NinteiSeikyuSeiyaku_05__c,
                NinteiSeikyuSeiyaku_07__c,
                NinteiSeikyuSeiyaku_08__c,
                NinteiSeikyuSeiyaku_09__c,
                NinteiSeikyuSeiyaku_10__c,
                NinteiSeikyuSeiyaku_11__c,
                NinteiSeikyuSeiyaku_12__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];

        Assert.areEqual('未申請', updSeikyu.ShinsaStatus__c);

        Assert.areEqual(seikyusha.Id, updSeikyu.Seikyusya__c);
        Assert.areEqual('請求者氏名', updSeikyu.Seikyusya__r.Shimei__c);

        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_01__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_02__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_03__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_04__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_05__c);
        // Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_06__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_07__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_08__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_09__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_10__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_11__c);
        Assert.isTrue(updSeikyu.NinteiSeikyuSeiyaku_12__c);
    }
}