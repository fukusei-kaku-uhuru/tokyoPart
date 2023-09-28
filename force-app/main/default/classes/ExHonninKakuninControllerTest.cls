@isTest
private class ExHonninKakuninControllerTest {

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
     * getHonninKakunin 一般 公的個人認証済み
     */
    @isTest
    private static void getHonninKakuninMyNumberForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value;
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
    }

    /**
     * getHonninKakunin 一般 券面アップロード済み
     */
    @isTest
    private static void getHonninKakuninFileUploadForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isTrue(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin 一般 券面アップロード済み（審査結果(最終)がOK）
     */
    @isTest
    private static void getHonninKakuninFileUploadForGeneral2(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            seikyusha.ShinsaKekkaSaishu__c = 'OK';
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isFalse(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin 一般 券面アップロード済み（審査結果(最終)がNG）
     */
    @isTest
    private static void getHonninKakuninFileUploadForGeneral3(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            seikyusha.ShinsaKekkaSaishu__c = 'NG';
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isFalse(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin 一般 券面アップロード済み（審査結果(最終)が不備）
     */
    @isTest
    private static void getHonninKakuninFileUploadForGeneral4(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            seikyusha.ShinsaKekkaSaishu__c = '不備';
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isTrue(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin 一般 未確認
     */
    @isTest
    private static void getHonninKakuninNotForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value, result.approvedBy);
        Assert.isFalse(result.hasApproved);
    }

    /**
     * getHonninKakunin DV 公的個人認証済み
     */
    @isTest
    private static void getHonninKakuninMyNumberForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value;
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
    }

    /**
     * getHonninKakunin DV 券面アップロード済み（審査結果（最終）がOK）
     */
    @isTest
    private static void getHonninKakuninFileUploadForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isTrue(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin DV 券面アップロード済み
     */
    @isTest
    private static void getHonninKakuninFileUploadForDv2(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            seikyusha.ShinsaKekkaSaishu__c = 'OK';
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isFalse(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin DV 券面アップロード済み（審査結果（最終）がNG）
     */
    @isTest
    private static void getHonninKakuninFileUploadForDv3(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            seikyusha.ShinsaKekkaSaishu__c = 'NG';
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isFalse(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin DV 券面アップロード済み（審査結果（最終）が不備）
     */
    @isTest
    private static void getHonninKakuninFileUploadForDv4(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            seikyusha.ShinsaKekkaSaishu__c = '不備';
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isTrue(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin DV 未認証
     */
    @isTest
    private static void getHonninKakuninNotForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isFalse(result.hasApproved);
    }

    /**
     * getHonninKakunin 里親 公的個人認証済み
     */
    @isTest
    private static void getHonninKakuninMyNumberForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value;
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
    }

    /**
     * getHonninKakunin 里親 券面アップロード済み
     */
    @isTest
    private static void getHonninKakuninFileUploadForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            seikyusha.HonninKakuninHoho__c = ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value;
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[1].value, result.approvedBy);
        Assert.isTrue(result.hasApproved);
        Assert.isTrue(result.validShinsaKekka);
    }

    /**
     * getHonninKakunin 里親 未確認
     */
    @isTest
    private static void getHonninKakuninNotForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        System.runAs(u){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExHonninKakuninController.getHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS, result.approvedByOptions);
        Assert.areEqual(ExHonninKakuninController.APPROVED_BY_OPTIONS[0].value, result.approvedBy);
        Assert.isFalse(result.hasApproved);
    }

    /**
     * clearHonninkakunin 一般
     */
    @isTest
    private static void clearHonninKakuninForIppan(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyusha();
            seikyusha.HonninKakuninHoho__c = '公的個人認証';
            insert seikyusha;

            NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyu(seikyusha);
            insert seikyu;

            Test.startTest();
            ExHonninKakuninController.clearHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.isNull([SELECT Id, HonninKakuninHoho__c FROM Seikyusha__c WHERE Id = :seikyusha.Id].HonninKakuninHoho__c);
    }

    /**
     * clearHonninkakunin DV
     */
    @isTest
    private static void clearHonninKakuninForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        DV_Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyushaDv();
            seikyusha.HonninKakuninHoho__c = '公的個人認証';
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            Test.startTest();
            ExHonninKakuninController.clearHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.isNull([SELECT Id, HonninKakuninHoho__c FROM DV_Seikyusha__c WHERE Id = :seikyusha.Id].HonninKakuninHoho__c);
    }

    /**
     * clearHonninkakunin 里親
     */
    @isTest
    private static void clearHonninKakuninForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        ExHonninKakuninController.HonninKakuninWrapper result;
        DV_Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = ExTestUtil.getSeikyushaSatoya();
            seikyusha.HonninKakuninHoho__c = '公的個人認証';
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            Test.startTest();
            ExHonninKakuninController.clearHonninKakunin(seikyu.Id);
            Test.stopTest();
        }

        Assert.isNull([SELECT Id, HonninKakuninHoho__c FROM DV_Seikyusha__c WHERE Id = :seikyusha.Id].HonninKakuninHoho__c);
    }


}