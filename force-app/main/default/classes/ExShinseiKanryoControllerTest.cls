@isTest
private class ExShinseiKanryoControllerTest {

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
     * getNinteiSeikyuNo
     * 一般
     */
    @isTest
    private static void getNinteiSeikyuNoForGeneral(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu;

        String result;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExShinseiKanryoController.getNinteiSeikyuNo(seikyu.Id);
            Test.stopTest();
        }

        seikyu = [
            SELECT
                NinteiSeikyuUketsukeBangou__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];
        Assert.areEqual(seikyu.NinteiSeikyuUketsukeBangou__c, result);
    }

    /**
     * getNinteiSeikyuNo
     * 一般
     * not exists
     */
    @isTest
    private static void getNinteiSeikyuNoNotExistsForGeneral(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            delete seikyu;

            try{
                Test.startTest();
                ExShinseiKanryoController.getNinteiSeikyuNo(seikyu.Id);
                Test.stopTest();
            }catch(AuraHandledException e){
                isException = true;
            }
        }

        Assert.isTrue(isException);
    }

    /**
     * getNinteiSeikyuNo
     * DV
     */
    @isTest
    private static void getNinteiSeikyuNoForDv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;

        String result;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExShinseiKanryoController.getNinteiSeikyuNo(seikyu.Id);
            Test.stopTest();
        }

        seikyu = [
            SELECT
                NinteiSeikyuUketsukeBangou__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];
        Assert.areEqual(seikyu.NinteiSeikyuUketsukeBangou__c, result);
    }

    /**
     * getNinteiSeikyuNo
     * DV
     * not exists
     */
    @isTest
    private static void getNinteiSeikyuNoNotExistsForDv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            delete seikyu;

            try{
                Test.startTest();
                ExShinseiKanryoController.getNinteiSeikyuNo(seikyu.Id);
                Test.stopTest();
            }catch(AuraHandledException e){
                isException = true;
            }
        }

        Assert.isTrue(isException);
    }

    /**
     * getNinteiSeikyuNo
     * 里親
     */
    @isTest
    private static void getNinteiSeikyuNoForSatoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;

        String result;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExShinseiKanryoController.getNinteiSeikyuNo(seikyu.Id);
            Test.stopTest();
        }

        seikyu = [
            SELECT
                NinteiSeikyuUketsukeBangou__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];
        Assert.areEqual(seikyu.NinteiSeikyuUketsukeBangou__c, result);
    }

    /**
     * getNinteiSeikyuNo
     * 里親
     * not exists
     */
    @isTest
    private static void getNinteiSeikyuNoNotExistsForSatoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            delete seikyu;

            try{
                Test.startTest();
                ExShinseiKanryoController.getNinteiSeikyuNo(seikyu.Id);
                Test.stopTest();
            }catch(AuraHandledException e){
                isException = true;
            }
        }

        Assert.isTrue(isException);
    }
}