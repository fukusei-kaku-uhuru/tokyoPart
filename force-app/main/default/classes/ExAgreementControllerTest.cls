@isTest
private class ExAgreementControllerTest {

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
     * register
     * 一般
     */
    @isTest
    private static void register_general(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        String resultId;
        System.runAs(u){
            Test.startTest();
            resultId = ExAgreementController.register('');
            Test.stopTest();
        }
        Assert.areEqual(false, String.isBlank(resultId));

        NinteiSeikyu__c seikyu = [
            SELECT
                ShinsaStatus__c
                ,Seikyusha__c
                ,Seikyusha__r.Shimei__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :resultId
            LIMIT 1
        ];

        Assert.areEqual(ExAgreementController.INITIAL_STATUS, seikyu.ShinsaStatus__c);
        Assert.areEqual(false, String.isBlank(seikyu.Seikyusha__c));
        Assert.areEqual(true, String.isBlank(seikyu.Seikyusha__r.Shimei__c));
    }

    /**
     * register
     * 一般
     * 登録済み
     */
    @isTest
    private static void register_general_existed(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu;
        Seikyusha__c seikyusha;
        String resultId;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.Shimei__c = 'TEST';
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu.ShinsaStatus__c = 'OCR処理中';
            insert seikyu;

            Test.startTest();
            resultId = ExAgreementController.register(seikyu.Id);
            Test.stopTest();
        }
        Assert.areEqual(seikyu.Id, resultId);

        NinteiSeikyu__c newSeikyu = [
            SELECT
                ShinsaStatus__c
                ,Seikyusha__r.Shimei__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :resultId
            LIMIT 1
        ];

        Assert.areEqual('OCR処理中', newSeikyu.ShinsaStatus__c);
        Assert.areEqual('TEST', newSeikyu.Seikyusha__r.Shimei__c);
    }

    /**
     * register
     * DV
     */
    @isTest
    private static void register_dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        String resultId;
        System.runAs(u){
            Test.startTest();
            resultId = ExAgreementController.register('');
            Test.stopTest();
        }
        Assert.areEqual(false, String.isBlank(resultId));

        DV_NinteiSeikyu__c seikyu = [
            SELECT
                ShinsaStatus__c
                ,RecordTypeId
                ,Seikyusya__c
                ,Seikyusya__r.Shimei__c
                ,Seikyusya__r.RecordTypeId
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :resultId
            LIMIT 1
        ];

        Assert.areEqual(ExAgreementController.INITIAL_STATUS, seikyu.ShinsaStatus__c);
        Assert.areEqual(ExTestUtil.DV_SEIKYU_ID, seikyu.RecordTypeId);
        Assert.areEqual(false, String.isBlank(seikyu.Seikyusya__c));
        Assert.areEqual(true, String.isBlank(seikyu.Seikyusya__r.Shimei__c));
        Assert.areEqual(ExTestUtil.DV_SEIKYUSHA_ID, seikyu.Seikyusya__r.RecordTypeId);
    }

    /**
     * register
     * DV
     * 登録済み
     */
    @isTest
    private static void register_dv_existed(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        DV_Seikyusha__c seikyusha;
        String resultId;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.Shimei__c = 'TEST';
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu.ShinsaStatus__c = 'OCR処理中';
            insert seikyu;

            Test.startTest();
            resultId = ExAgreementController.register(seikyu.Id);
            Test.stopTest();
        }
        Assert.areEqual(seikyu.Id, resultId);

        DV_NinteiSeikyu__c newSeikyu = [
            SELECT
                ShinsaStatus__c
                ,Seikyusya__r.Shimei__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :resultId
            LIMIT 1
        ];

        Assert.areEqual('OCR処理中', newSeikyu.ShinsaStatus__c);
        Assert.areEqual('TEST', newSeikyu.Seikyusya__r.Shimei__c);
    }

    /**
     * register
     * 里親
     */
    @isTest
    private static void register_satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        String resultId;
        System.runAs(u){
            Test.startTest();
            resultId = ExAgreementController.register('');
            Test.stopTest();
        }
        Assert.areEqual(false, String.isBlank(resultId));

        DV_NinteiSeikyu__c seikyu = [
            SELECT
                ShinsaStatus__c
                ,RecordTypeId
                ,Seikyusya__c
                ,Seikyusya__r.Shimei__c
                ,Seikyusya__r.RecordTypeId
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :resultId
            LIMIT 1
        ];

        Assert.areEqual(ExAgreementController.INITIAL_STATUS, seikyu.ShinsaStatus__c);
        Assert.areEqual(ExTestUtil.SATOYA_SEIKYU_ID, seikyu.RecordTypeId);
        Assert.areEqual(false, String.isBlank(seikyu.Seikyusya__c));
        Assert.areEqual(true, String.isBlank(seikyu.Seikyusya__r.Shimei__c));
        Assert.areEqual(ExTestUtil.SATOYA_SEIKYUSHA_ID, seikyu.Seikyusya__r.RecordTypeId);
    }

    /**
     * register
     * 里親
     * 登録済み
     */
    @isTest
    private static void register_satoya_existed(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu;
        DV_Seikyusha__c seikyusha;
        String resultId;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyushaSatoya();
            seikyusha.Shimei__c = 'TEST';
            insert seikyusha;

            seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu.ShinsaStatus__c = 'OCR処理中';
            insert seikyu;

            Test.startTest();
            resultId = ExAgreementController.register(seikyu.Id);
            Test.stopTest();
        }
        Assert.areEqual(seikyu.Id, resultId);

        DV_NinteiSeikyu__c newSeikyu = [
            SELECT
                ShinsaStatus__c
                ,Seikyusya__r.Shimei__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :resultId
            LIMIT 1
        ];

        Assert.areEqual('OCR処理中', newSeikyu.ShinsaStatus__c);
        Assert.areEqual('TEST', newSeikyu.Seikyusya__r.Shimei__c);
    }
}