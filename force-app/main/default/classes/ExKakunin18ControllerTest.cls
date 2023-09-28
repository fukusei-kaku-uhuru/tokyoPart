@isTest
private class ExKakunin18ControllerTest {

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
     * getNinteiSeikyu 一般
     */
    @isTest
    private static void getNinteiSeikyuForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExKakunin18Controller.NinteiSeikyuWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            Test.startTest();
            result = ExKakunin18Controller.getNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.include18);
        Assert.isFalse(result.includeNot18);
    }

    /**
     * getNinteiSeikyu 一般 存在しない
     */
    @isTest
    private static void getNinteiSeikyuNotExistForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExKakunin18Controller.NinteiSeikyuWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            delete seikyu;

            Test.startTest();
            result = ExKakunin18Controller.getNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        Assert.isNull(result.include18);
        Assert.isNull(result.includeNot18);
    }

    /**
     * getNinteiSeikyu DV
     */
    @isTest
    private static void getNinteiSeikyuForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExKakunin18Controller.NinteiSeikyuWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            Test.startTest();
            result = ExKakunin18Controller.getNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.include18);
        Assert.isFalse(result.includeNot18);
    }

    /**
     * getNinteiSeikyu DV 存在しない
     */
    @isTest
    private static void getNinteiSeikyuNotExistForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExKakunin18Controller.NinteiSeikyuWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            delete seikyu;

            Test.startTest();
            result = ExKakunin18Controller.getNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        Assert.isNull(result.include18);
        Assert.isNull(result.includeNot18);
    }

    /**
     * getNinteiSeikyu 里親
     */
    @isTest
    private static void getNinteiSeikyuForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExKakunin18Controller.NinteiSeikyuWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            Test.startTest();
            result = ExKakunin18Controller.getNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.include18);
        Assert.isFalse(result.includeNot18);
    }

    /**
     * getNinteiSeikyu 里親 存在しない
     */
    @isTest
    private static void getNinteiSeikyuNotExistForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExKakunin18Controller.NinteiSeikyuWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            delete seikyu;

            Test.startTest();
            result = ExKakunin18Controller.getNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        Assert.isNull(result.include18);
        Assert.isNull(result.includeNot18);
    }

    /**
     * updateNinteiSeikyu 一般 含む
     */
    @isTest
    private static void updateNinteiSeikyuFukumuForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = false;
            seikyu.SeikyushaKubun_18saiFukumanai__c = true;
            insert seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, true);
            Test.stopTest();
        }

        NinteiSeikyu__c updSeikyu = [
            SELECT
                SeikyushaKubun_18saiFukumu__c,
                SeikyushaKubun_18saiFukumanai__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
        ];
        Assert.isTrue(updSeikyu.SeikyushaKubun_18saiFukumu__c);
        Assert.isFalse(updSeikyu.SeikyushaKubun_18saiFukumanai__c);
    }

    /**
     * updateNinteiSeikyu 一般 含まない
     */
    @isTest
    private static void updateNinteiSeikyuFukumanaiForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, false);
            Test.stopTest();
        }

        NinteiSeikyu__c updSeikyu = [
            SELECT
                SeikyushaKubun_18saiFukumu__c,
                SeikyushaKubun_18saiFukumanai__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
        ];
        Assert.isFalse(updSeikyu.SeikyushaKubun_18saiFukumu__c);
        Assert.isTrue(updSeikyu.SeikyushaKubun_18saiFukumanai__c);
    }

    /**
     * updateNinteiSeikyu 一般 存在しない
     */
    @isTest
    private static void updateNinteiSeikyuNotExistForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = false;
            seikyu.SeikyushaKubun_18saiFukumanai__c = true;
            insert seikyu;

            delete seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, true);
            Test.stopTest();
        }
    }

    /**
     * updateNinteiSeikyu DV 含む
     */
    @isTest
    private static void updateNinteiSeikyuFukumuForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = false;
            seikyu.SeikyushaKubun_18saiFukumanai__c = true;
            insert seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, true);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c updSeikyu = [
            SELECT
                SeikyushaKubun_18saiFukumu__c,
                SeikyushaKubun_18saiFukumanai__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
        ];
        Assert.isTrue(updSeikyu.SeikyushaKubun_18saiFukumu__c);
        Assert.isFalse(updSeikyu.SeikyushaKubun_18saiFukumanai__c);
    }

    /**
     * updateNinteiSeikyu Dv 含まない
     */
    @isTest
    private static void updateNinteiSeikyuFukumanaiForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;


            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, false);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c updSeikyu = [
            SELECT
                SeikyushaKubun_18saiFukumu__c,
                SeikyushaKubun_18saiFukumanai__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
        ];
        Assert.isFalse(updSeikyu.SeikyushaKubun_18saiFukumu__c);
        Assert.isTrue(updSeikyu.SeikyushaKubun_18saiFukumanai__c);
    }

    /**
     * updateNinteiSeikyu DV 存在しない
     */
    @isTest
    private static void updateNinteiSeikyuNotExistForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = false;
            seikyu.SeikyushaKubun_18saiFukumanai__c = true;
            insert seikyu;

            delete seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, true);
            Test.stopTest();
        }
    }

    /**
     * updateNinteiSeikyu 里親 含む
     */
    @isTest
    private static void updateNinteiSeikyuFukumuForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = false;
            seikyu.SeikyushaKubun_18saiFukumanai__c = true;
            insert seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, true);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c updSeikyu = [
            SELECT
                SeikyushaKubun_18saiFukumu__c,
                SeikyushaKubun_18saiFukumanai__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
        ];
        Assert.isTrue(updSeikyu.SeikyushaKubun_18saiFukumu__c);
        Assert.isFalse(updSeikyu.SeikyushaKubun_18saiFukumanai__c);
    }

    /**
     * updateNinteiSeikyu 里親 含まない
     */
    @isTest
    private static void updateNinteiSeikyuFukumanaiForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = true;
            seikyu.SeikyushaKubun_18saiFukumanai__c = false;
            insert seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, false);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c updSeikyu = [
            SELECT
                SeikyushaKubun_18saiFukumu__c,
                SeikyushaKubun_18saiFukumanai__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
        ];
        Assert.isFalse(updSeikyu.SeikyushaKubun_18saiFukumu__c);
        Assert.isTrue(updSeikyu.SeikyushaKubun_18saiFukumanai__c);
    }

    /**
     * updateNinteiSeikyu 里親 存在しない
     */
    @isTest
    private static void updateNinteiSeikyuNotExistForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.SeikyushaKubun_18saiFukumu__c = false;
            seikyu.SeikyushaKubun_18saiFukumanai__c = true;
            insert seikyu;

            delete seikyu;

            Test.startTest();
            ExKakunin18Controller.updateNinteiSeikyu(seikyu.Id, true);
            Test.stopTest();
        }
    }
}