@isTest
private class ExLwcUtilTest {

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
     * fileCountLimit
     */
    @isTest
    private static void getFileCountLimit(){
        Test.startTest();
        Decimal result = ExLwcUtil.fileCountLimit;
        Test.stopTest();
    }

    /**
     * fileSizeLimit
     */
    @isTest
    private static void getFileSizeLimit(){
        Test.startTest();
        Decimal result = ExLwcUtil.fileSizeLimit;
        Test.stopTest();
    }

    /**
     * fileExtensions
     */
    @isTest
    private static void getFileExtensions(){
        Test.startTest();
        List<String> result = ExLwcUtil.fileExtensions;
        Test.stopTest();
    }

    /**
     * fileOwnerId
     */
    @isTest
    private static void getFileOwnerId(){
        Test.startTest();
        String result = ExLwcUtil.fileOwnerId;
        Test.stopTest();
    }

    /**
     * getSiteMode
     * 一般
     */
    @isTest
    private static void getSiteMode_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        String result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSiteMode();
            Test.stopTest();
        }

        Assert.areEqual(ExLwcUtil.MODE_IPPAN, result);
    }

    /**
     * getSiteMode
     * DV
     */
    @isTest
    private static void getSiteMode_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        String result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSiteMode();
            Test.stopTest();
        }

        Assert.areEqual(ExLwcUtil.MODE_DV, result);
    }

    /**
     * getSiteMode
     * 里親
     */
    @isTest
    private static void getSiteMode_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        String result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSiteMode();
            Test.stopTest();
        }

        Assert.areEqual(ExLwcUtil.MODE_SATOYA, result);
    }

    /**
     * getSiteMode
     * システム管理者
     */
    @isTest
    private static void getSiteMode_others(){
        Test.startTest();
        String result = ExLwcUtil.getSiteMode();
        Test.stopTest();

        Assert.isNull(result);
    }

    /**
     * isSiteModeIppan
     * 一般
     */
    @isTest
    private static void isSiteModeIppan_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeIppan();
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * isSiteModeIppan
     * DV
     */
    @isTest
    private static void isSiteModeIppan_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeIppan();
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isSiteModeIppan
     * 里親
     */
    @isTest
    private static void isSiteModeIppan_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeIppan();
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isSiteModeIppan
     * システム管理者
     */
    @isTest
    private static void isSiteModeIppan_others(){
        Test.startTest();
        Boolean result = ExLwcUtil.isSiteModeIppan();
        Test.stopTest();

        Assert.isFalse(result);
    }

    /**
     * isSiteModeDv
     * 一般
     */
    @isTest
    private static void isSiteModeDv_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeDv();
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isSiteModeDv
     * DV
     */
    @isTest
    private static void isSiteModeDv_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeDv();
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * isSiteModeDv
     * 里親
     */
    @isTest
    private static void isSiteModeDv_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeDv();
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isSiteModeDv
     * システム管理者
     */
    @isTest
    private static void isSiteModeDv_others(){
        Test.startTest();
        Boolean result = ExLwcUtil.isSiteModeDv();
        Test.stopTest();

        Assert.isFalse(result);
    }

    /**
     * isSiteModeSatoya
     * 一般
     */
    @isTest
    private static void isSiteModeSatoya_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeSatoya();
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isSiteModeSatoya
     * dv
     */
    @isTest
    private static void isSiteModeSatoya_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeSatoya();
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isSiteModeSatoya
     * 里親
     */
    @isTest
    private static void isSiteModeSatoya_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isSiteModeSatoya();
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * isSiteModeSatoya
     * システム管理者
     */
    @isTest
    private static void isSiteModeSatoya_others(){
        Test.startTest();
        Boolean result = ExLwcUtil.isSiteModeSatoya();
        Test.stopTest();

        Assert.isFalse(result);
    }

    /**
     * getSeikyuRecordTypeId
     * 一般
     */
    @isTest
    private static void getSeikyuRecordTypeId_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSeikyuRecordTypeId();
            Test.stopTest();
        }

        Assert.isNull(result);
    }

    /**
     * getSeikyuRecordTypeId
     * DV
     */
    @isTest
    private static void getSeikyuRecordTypeId_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSeikyuRecordTypeId();
            Test.stopTest();
        }

        Id expected = Schema.SObjectType.DV_NinteiSeikyu__c.getRecordTypeInfosByDeveloperName().get(ExLwcUtil.TYPE_NAME_DV).getRecordTypeId();
        Assert.areEqual(expected, result);
    }

    /**
     * getSeikyuRecordTypeId
     * 里親
     */
    @isTest
    private static void getSeikyuRecordTypeId_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSeikyuRecordTypeId();
            Test.stopTest();
        }

        Id expected = Schema.SObjectType.DV_NinteiSeikyu__c.getRecordTypeInfosByDeveloperName().get(ExLwcUtil.TYPE_NAME_SATOYA).getRecordTypeId();
        Assert.areEqual(expected, result);
    }

    /**
     * getSeikyushaRecordTypeId
     * 一般
     */
    @isTest
    private static void getSeikyushaRecordTypeId_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSeikyushaRecordTypeId();
            Test.stopTest();
        }

        Assert.isNull(result);
    }

    /**
     * getSeikyushaRecordTypeId
     * DV
     */
    @isTest
    private static void getSeikyushaRecordTypeId_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSeikyushaRecordTypeId();
            Test.stopTest();
        }

        Id expected = Schema.SObjectType.DV_Seikyusha__c.getRecordTypeInfosByDeveloperName().get(ExLwcUtil.TYPE_NAME_DV).getRecordTypeId();
        Assert.areEqual(expected, result);
    }

    /**
     * getSeikyushaRecordTypeId
     * 里親
     */
    @isTest
    private static void getSeikyushaRecordTypeId_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getSeikyushaRecordTypeId();
            Test.stopTest();
        }

        Id expected = Schema.SObjectType.DV_Seikyusha__c.getRecordTypeInfosByDeveloperName().get(ExLwcUtil.TYPE_NAME_SATOYA).getRecordTypeId();
        Assert.areEqual(expected, result);
    }

    /**
     * getTaishoJidoRecordTypeId
     * 一般
     */
    @isTest
    private static void getTaishoJidoRecordTypeId_general(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getTaishoJidoRecordTypeId();
            Test.stopTest();
        }

        Assert.isNull(result);
    }

    /**
     * getTaishoJidoRecordTypeId
     * DV
     */
    @isTest
    private static void getTaishoJidoRecordTypeId_dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getTaishoJidoRecordTypeId();
            Test.stopTest();
        }

        Id expected = Schema.SObjectType.DV_TaishoJido__c.getRecordTypeInfosByDeveloperName().get(ExLwcUtil.TYPE_NAME_DV).getRecordTypeId();
        Assert.areEqual(expected, result);
    }

    /**
     * getTaishoJidoRecordTypeId
     * 里親
     */
    @isTest
    private static void getTaishoJidoRecordTypeId_satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Id result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.getTaishoJidoRecordTypeId();
            Test.stopTest();
        }

        Id expected = Schema.SObjectType.DV_TaishoJido__c.getRecordTypeInfosByDeveloperName().get(ExLwcUtil.TYPE_NAME_SATOYA).getRecordTypeId();
        Assert.areEqual(expected, result);
    }

    /**
     * checkFileUploadLimit
     * 上限に達していない
     */
    @isTest
    private static void checkFileUploadLimit_below(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        // テスト時にカスタムメタデータの値をセット
        ExLwcUtil.fileCountLimit = 2;

        ShinseiShoruiTeigi__c sst = ExTestUtil.getSstListKojinNinsho(1)[0];
        insert sst;

        Boolean result;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;
            ContentVersion cv = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            Test.startTest();
            result = ExLwcUtil.checkFileUploadLimit(ns.Id, sst.Id);
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * checkFileUploadLimit
     * 上限に達している
     */
    @isTest
    private static void checkFileUploadLimit_over(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        // テスト時にカスタムメタデータの値をセット
        ExLwcUtil.fileCountLimit = 2;

        ShinseiShoruiTeigi__c sst = ExTestUtil.getSstListKojinNinsho(1)[0];
        insert sst;

        Boolean result;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;
            ContentVersion cv1 = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            ContentVersion cv2 = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert new List<ContentVersion>{cv1, cv2};

            Test.startTest();
            result = ExLwcUtil.checkFileUploadLimit(ns.Id, sst.Id);
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * getColumnLabels
     * 正常
     */
    @isTest
    private static void getColumnLabels_success(){
        String objectName = 'Seikyusha__c';
        List<String> columnNames = new List<String>{'Shimei__c', 'ShimeiFurigana__c'};

        Test.startTest();
        Map<String, String> result = ExLwcUtil.getColumnLabels(objectName, columnNames);
        Test.stopTest();

        Assert.areEqual(Seikyusha__c.Shimei__c.getDescribe().getLabel(), result.get('Shimei__c'));
        Assert.areEqual(Seikyusha__c.ShimeiFurigana__c.getDescribe().getLabel(), result.get('ShimeiFurigana__c'));
    }

    /**
     * getColumnLabels
     * 存在しないオブジェクト
     */
    @isTest
    private static void getColumnLabels_objectNotExists(){
        String objectName = 'UNEXPECTED_OBJECT_mdt';
        List<String> columnNames = new List<String>{'Shimei__c', 'ShimeiFurigana__c'};

        Boolean isException = false;
        Test.startTest();
        try{
            Map<String, String> result = ExLwcUtil.getColumnLabels(objectName, columnNames);
        }catch(AuraHandledException e){
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    /**
     * getColumnLabels
     * 存在しない項目
     */
    @isTest
    private static void getColumnLabels_fieldNotExists(){
        String objectName = 'Seikyusha__c';
        List<String> columnNames = new List<String>{'UNEXPECTED_FIELD_mdt', 'ShimeiFurigana__c'};

        Boolean isException = false;
        Test.startTest();
        try{
            Map<String, String> result = ExLwcUtil.getColumnLabels(objectName, columnNames);
        }catch(AuraHandledException e){
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    /**
     * getColumnLabel
     * 正常
     */
    @isTest
    private static void getColumnLabel_success(){
        String objectName = 'Seikyusha__c';
        String columnName = 'Shimei__c';

        Test.startTest();
        String result = ExLwcUtil.getColumnLabel(objectName, columnName);
        Test.stopTest();

        Assert.areEqual(Seikyusha__c.Shimei__c.getDescribe().getLabel(), result);
    }

    /**
     * getColumnLabel
     * 存在しないオブジェクト
     */
    @isTest
    private static void getColumnLabel_objectNotExists(){
        String objectName = 'UNEXPECTED_OBJECT_mdt';
        String columnName = 'Shimei__c';

        Boolean isException = false;
        Test.startTest();
        try{
            String result = ExLwcUtil.getColumnLabel(objectName, columnName);
        }catch(AuraHandledException e){
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    /**
     * getColumnLabel
     * 存在しない項目
     */
    @isTest
    private static void getColumnLabel_fieldNotExists(){
        String objectName = 'Seikyusha__c';
        String columnName = 'UNEXPECTED_FIELD_mdt';

        Boolean isException = false;
        Test.startTest();
        try{
            String result = ExLwcUtil.getColumnLabel(objectName, columnName);
        }catch(AuraHandledException e){
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    /**
     * getPickList
     * 正常
     */
    @isTest
    private static void getPickList_success(){
        String objectName = 'DV_TaishoJido__c';
        String columnName = 'TaishoShinkiSochi__c';

        Test.startTest();
        List<Map<String, String>> results = ExLwcUtil.getPickList(objectName, columnName);
        Test.stopTest();

        List<Schema.PicklistEntry> pList = DV_TaishoJido__c.TaishoShinkiSochi__c.getDescribe().getPicklistValues();
        Integer i = 0;
        for(Schema.PicklistEntry p: pList){
            Map<String, String> result = results[i++];
            Assert.areEqual(p.getLabel(), result.get('label'));
            Assert.areEqual(p.getValue(), result.get('value'));
        }
    }

    /**
     * getPickList
     * 存在しないオブジェクト
     */
    @isTest
    private static void getPickList_objectNotExists(){
        String objectName = 'UNEXPECTED_OBJECT_mdt';
        String columnName = 'TaishoShinkiSochi__c';

        Boolean isException = false;
        Test.startTest();
        try{
            List<Map<String, String>> results = ExLwcUtil.getPickList(objectName, columnName);
        }catch(AuraHandledException e){
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    /**
     * getPickList
     * 非選択リスト
     */
    @isTest
    private static void getPickList_notPickListField(){
        String objectName = 'DV_TaishoJido__c';
        String columnName = 'Id';

        Test.startTest();
        List<Map<String, String>> results = ExLwcUtil.getPickList(objectName, columnName);
        Test.stopTest();

        Assert.areEqual(0, results.size());
    }

    /**
     * getHensyuPhase
     * 引数が空
     */
    @isTest
    private static void getHensyuPhase_argEmpty(){
        Test.startTest();
        String result = ExLwcUtil.getHensyuPhase('');
        Test.stopTest();

        Assert.areEqual('', result);
    }

    /**
     * getHensyuPhase
     * 一般
     * 正常
     */
    @isTest
    private static void getHensyuPhase_general_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        String result;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.HensyuPhase__c = 'SDI1';
            insert ns;

            Test.startTest();
            result = ExLwcUtil.getHensyuPhase(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual('SDI1', result);
    }

    /**
     * getHensyuPhase
     * 一般
     * 存在しない
     */
    @isTest
    private static void getHensyuPhase_general_notExists(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.HensyuPhase__c = 'SDI1';
            insert ns;

            delete ns;

            Test.startTest();
            try{
                String result = ExLwcUtil.getHensyuPhase(ns.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * getHensyuPhase
     * DV
     * 正常
     */
    @isTest
    private static void getHensyuPhase_dv_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        String result;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.HensyuPhase__c = 'SDI1';
            insert ns;

            Test.startTest();
            result = ExLwcUtil.getHensyuPhase(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual('SDI1', result);
    }

    /**
     * getHensyuPhase
     * DV
     * 存在しない
     */
    @isTest
    private static void getHensyuPhase_dv_notExists(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.HensyuPhase__c = 'SDI1';
            insert ns;

            delete ns;

            Test.startTest();
            try{
                String result = ExLwcUtil.getHensyuPhase(ns.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * getHensyuPhase
     * 里親
     * 正常
     */
    @isTest
    private static void getHensyuPhase_satoya_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        String result;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.HensyuPhase__c = 'SDI1';
            insert ns;

            Test.startTest();
            result = ExLwcUtil.getHensyuPhase(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual('SDI1', result);
    }

    /**
     * getHensyuPhase
     * 里親
     * 存在しない
     */
    @isTest
    private static void getHensyuPhase_satoya_notExists(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.HensyuPhase__c = 'SDI1';
            insert ns;

            delete ns;

            Test.startTest();
            try{
                String result = ExLwcUtil.getHensyuPhase(ns.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * updateHensyuPhase用
     * stepsの作成
     */
    private static List<ExLwcUtil.ProgressStep> getProgressSteps(){
        List<ExLwcUtil.ProgressStep> steps = new List<ExLwcUtil.ProgressStep>();

        ExLwcUtil.ProgressStep step1 = new ExLwcUtil.ProgressStep();
        step1.label = '請求者';
        step1.id = 'SKS1';
        steps.add(step1);

        ExLwcUtil.ProgressStep step2 = new ExLwcUtil.ProgressStep();
        step2.label = '対象児童';
        step2.id = 'TJD1';
        steps.add(step2);

        ExLwcUtil.ProgressStep step3 = new ExLwcUtil.ProgressStep();
        step3.label = '最終確認';
        step3.id = 'SKN';
        steps.add(step3);

        ExLwcUtil.ProgressStep step4 = new ExLwcUtil.ProgressStep();
        step4.label = '完了';
        step4.id = 'KNR';
        steps.add(step4);

        return steps;
    }

    /**
     * updateHensyuPhase
     * 編集フェーズに含まれない
     */
    @isTest
    private static void updateHensyuPhase_notContains(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c ns;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            ns = ExTestUtil.getNinteiSeikyu(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'TJD2';

            Test.startTest();
            ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            Test.stopTest();
        }

        NinteiSeikyu__c newNs = [SELECT HensyuPhase__c FROM NinteiSeikyu__c WHERE Id = :ns.Id LIMIT 1];
        Assert.areEqual('TJD1', newNs.HensyuPhase__c);
    }

    /**
     * updateHensyuPhase
     * 含まれるが更新しない
     */
    @isTest
    private static void updateHensyuPhase_notProgressed(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c ns;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            ns = ExTestUtil.getNinteiSeikyu(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKS1';

            Test.startTest();
            ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            Test.stopTest();
        }

        NinteiSeikyu__c newNs = [SELECT HensyuPhase__c FROM NinteiSeikyu__c WHERE Id = :ns.Id LIMIT 1];
        Assert.areEqual('TJD1', newNs.HensyuPhase__c);
    }

    /**
     * updateHensyuPhase
     * 更新
     * 一般
     * 正常
     */
    @isTest
    private static void updateHensyuPhase_general_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c ns;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            ns = ExTestUtil.getNinteiSeikyu(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKN';

            Test.startTest();
            ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            Test.stopTest();
        }

        NinteiSeikyu__c newNs = [SELECT HensyuPhase__c FROM NinteiSeikyu__c WHERE Id = :ns.Id LIMIT 1];
        Assert.areEqual('SKN', newNs.HensyuPhase__c);
    }

    /**
     * updateHensyuPhase
     * 更新
     * 一般
     * 存在しない
     */
    @isTest
    private static void updateHensyuPhase_general_notExist(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            delete ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKN';

            Test.startTest();
            try{
                ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * updateHensyuPhase
     * 更新
     * DV
     * 正常
     */
    @isTest
    private static void updateHensyuPhase_dv_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c ns;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKN';

            Test.startTest();
            ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c newNs = [SELECT HensyuPhase__c FROM DV_NinteiSeikyu__c WHERE Id = :ns.Id LIMIT 1];
        Assert.areEqual('SKN', newNs.HensyuPhase__c);
    }

    /**
     * updateHensyuPhase
     * 更新
     * DV
     * 存在しない
     */
    @isTest
    private static void updateHensyuPhase_dv_notExist(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            delete ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKN';

            Test.startTest();
            try{
                ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * updateHensyuPhase
     * 更新
     * 里親
     * 正常
     */
    @isTest
    private static void updateHensyuPhase_satoya_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c ns;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKN';

            Test.startTest();
            ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c newNs = [SELECT HensyuPhase__c FROM DV_NinteiSeikyu__c WHERE Id = :ns.Id LIMIT 1];
        Assert.areEqual('SKN', newNs.HensyuPhase__c);
    }

    /**
     * updateHensyuPhase
     * 更新
     * 里親
     * 存在しない
     */
    @isTest
    private static void updateHensyuPhase_satoya_notExist(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.HensyuPhase__c = 'TJD1';
            insert ns;

            delete ns;

            List<ExLwcUtil.ProgressStep> steps = getProgressSteps();
            String displayTemplateId = 'SKN';

            Test.startTest();
            try{
                ExLwcUtil.updateHensyuPhase(ns.Id, steps, displayTemplateId);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * isNinteiSeikyuDisabled
     * 一般
     * 正常
     */
    @isTest
    private static void isNinteiSeikyuDisabled_blank(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExLwcUtil.isNinteiSeikyuDisabled('');
            Test.stopTest();
        }

        Assert.isFalse(result);
    }

    /**
     * isNinteiSeikyuDisabled
     * 一般
     * 正常
     */
    @isTest
    private static void isNinteiSeikyuDisabled_general_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            Test.startTest();
            result = ExLwcUtil.isNinteiSeikyuDisabled(ns.Id);
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * isNinteiSeikyuDisabled
     * 一般
     * 存在しない
     */
    @isTest
    private static void isNinteiSeikyuDisabled_general_notExist(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            delete ns;

            Test.startTest();
            try{
                Boolean result = ExLwcUtil.isNinteiSeikyuDisabled(ns.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * isNinteiSeikyuDisabled
     * DV
     * 正常
     */
    @isTest
    private static void isNinteiSeikyuDisabled_dv_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            Test.startTest();
            result = ExLwcUtil.isNinteiSeikyuDisabled(ns.Id);
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * isNinteiSeikyuDisabled
     * DV
     * 存在しない
     */
    @isTest
    private static void isNinteiSeikyuDisabled_dv_notExist(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            delete ns;

            Test.startTest();
            try{
                Boolean result = ExLwcUtil.isNinteiSeikyuDisabled(ns.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * isNinteiSeikyuDisabled
     * 里親
     * 正常
     */
    @isTest
    private static void isNinteiSeikyuDisabled_satoya_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean result;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            Test.startTest();
            result = ExLwcUtil.isNinteiSeikyuDisabled(ns.Id);
            Test.stopTest();
        }

        Assert.isTrue(result);
    }

    /**
     * isNinteiSeikyuDisabled
     * 里親
     * 存在しない
     */
    @isTest
    private static void isNinteiSeikyuDisabled_satoya_notExist(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        Boolean isException = false;
        System.runAs(portalUser){
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            delete ns;

            Test.startTest();
            try{
                Boolean result = ExLwcUtil.isNinteiSeikyuDisabled(ns.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);
    }

    /**
     * isNotStatusMishinsei
     * 未申請
     */
    @isTest
    private static void isNotStatusMishinsei_mishinsei(){
        String shinsaStatus = '未申請';

        Test.startTest();
        Boolean result = ExLwcUtil.isNotStatusMishinsei(shinsaStatus);
        Test.stopTest();

        Assert.isFalse(result);
    }

    /**
     * isNotStatusMishinsei
     * 申請済
     */
    @isTest
    private static void isNotStatusMishinsei_shinseizumi(){
        String shinsaStatus = '審査完了';

        Test.startTest();
        Boolean result = ExLwcUtil.isNotStatusMishinsei(shinsaStatus);
        Test.stopTest();

        Assert.isTrue(result);
    }

    /**
     * getFileLimit
     * 正常
     */
    @isTest
    private static void getFileLimit_success(){
        ExLwcUtil.fileExtensions = new List<String>{
            'docs'
            ,'gif'
            ,'tiff'
        };

        Test.startTest();
        ExLwcUtil.FileLimitWrapper result = ExLwcUtil.getFileLimit();
        Test.stopTest();

        Assert.areEqual(3, result.acceptExtensions.size());
        Assert.areEqual('.docs', result.acceptExtensions[0]);
        Assert.areEqual('.gif', result.acceptExtensions[1]);
        Assert.areEqual('.tiff', result.acceptExtensions[2]);

        Assert.areEqual('拡張子：DOCS / GIF / TIFF', result.extensionMessage);

        Assert.areEqual('1ファイルあたりのサイズ上限：5MB', result.sizeMessage);
    }

    /**
     * getFileLimit
     * 異常
     */
    @isTest
    private static void getFileLimit_error(){
        ExLwcUtil.fileExtensions = new List<String>{
            null // String.toUpperCase()でエラー
            ,'gif'
            ,'tiff'
        };

        Boolean isException = false;
        Test.startTest();
        try{
            ExLwcUtil.FileLimitWrapper result = ExLwcUtil.getFileLimit();
        }catch(AuraHandledException e){
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    /**
     * getFileSizeMbLimit
     */
    @isTest
    private static void getFileSizeMbLimit(){
        ExLwcUtil.fileSizeLimit = 10;

        Test.startTest();
        Decimal result = ExLwcUtil.getFileSizeMbLimit();
        Test.stopTest();

        Assert.areEqual(10, result);
    }

    /**
     * changeDocumentOwner
     */
    @isTest
    private static void changeDocumentOwner(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ExLwcUtil.fileOwnerId = UserInfo.getUserId();

        ShinseiShoruiTeigi__c sst = ExTestUtil.getSstListKojinNinsho(1)[0];

        ContentVersion cv;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;
            cv = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            Test.startTest();
            ExLwcUtil.changeDocumentOwner(cv.Id);
            Test.stopTest();
        }

        ContentVersion newCv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocument newCd = [SELECT OwnerId FROM ContentDocument WHERE Id = :newCv.ContentDocumentId LIMIT 1];
        Assert.areEqual(UserInfo.getUserId(), newCd.OwnerId);
    }

    /**
     * updateFileDeletableFlg
     * 0件
     */
    @isTest
    private static void updateFileDeletableFlg_filesEmpty(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ShinseiShoruiTeigi__c sst = ExTestUtil.getSstListKojinNinsho(1)[0];

        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            Set<Id> linkedEntitySet = new Set<Id>{s.Id, ns.Id};

            Test.startTest();
            ExLwcUtil.updateFileDeletableFlg(linkedEntitySet);
            Test.stopTest();
        }
    }

    /**
     * updateFileDeletableFlg
     * 正常
     */
    @isTest
    private static void updateFileDeletableFlg_success(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        ShinseiShoruiTeigi__c sst = ExTestUtil.getSstListKojinNinsho(1)[0];

        ContentVersion cv1;
        ContentVersion cv2;
        ContentVersion cv3;
        ContentVersion cv4;
        System.runAs(portalUser){
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            cv1 = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            cv1.IsDeletable__c = true;
            cv2 = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            cv2.IsDeletable__c = true;
            cv3 = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            cv3.IsDeletable__c = true;
            cv4 = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            cv4.IsDeletable__c = true;
            insert new List<ContentVersion>{cv1, cv2, cv3, cv4};

            Set<Id> linkedEntitySet = new Set<Id>{s.Id, ns.Id};

            Test.startTest();
            ExLwcUtil.updateFileDeletableFlg(linkedEntitySet);
            Test.stopTest();
        }

        List<ContentVersion> newCvs = [
            SELECT
                IsDeletable__c
            FROM
                ContentVersion
            WHERE
                Id IN :new Set<Id>{cv1.Id, cv2.Id, cv3.Id, cv4.Id}
            LIMIT 4
        ];
        Assert.isFalse(newCvs[0].IsDeletable__c);
        Assert.isFalse(newCvs[1].IsDeletable__c);
        Assert.isFalse(newCvs[2].IsDeletable__c);
        Assert.isFalse(newCvs[3].IsDeletable__c);
    }
}