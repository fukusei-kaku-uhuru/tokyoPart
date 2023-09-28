@isTest
private class ExFileUploadControllerTest {

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

    private static List<ShinseiShoruiTeigi__c> createShoruiTeigiList(){
        ShinseiShoruiTeigi__c myNumber = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '個人番号カード',
            IsMyNumber__c = true,
            IsKenkoHoken__c = false,
            Order__c = 1
        );
        ShinseiShoruiTeigi__c untenMenkyoshoOmote = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '運転免許証（表面）',
            IsMyNumber__c = false,
            IsKenkoHoken__c = false,
            ShoruiTeigiKey__c = '運転免許証',
            Order__c = 2
        );
        ShinseiShoruiTeigi__c untenMenkyoshoUra = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '運転免許証（裏面）',
            IsMyNumber__c = false,
            IsKenkoHoken__c = false,
            ShoruiTeigiKey__c = '運転免許証',
            Order__c = 3
        );
        ShinseiShoruiTeigi__c juminhyo = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '住民票の写し',
            IsMyNumber__c = false,
            IsKenkoHoken__c = false,
            IsJuminHyo__c = true,
            Order__c = 4
        );
        ShinseiShoruiTeigi__c kenkoHoken = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証',
            IsMyNumber__c = false,
            IsKenkoHoken__c = true,
            Order__c = 5
        );
        ShinseiShoruiTeigi__c nenkinTecho = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '国民年金手帳',
            IsMyNumber__c = false,
            IsKenkoHoken__c = false,
            Order__c = 6
        );

        List<ShinseiShoruiTeigi__c> teigiList = new List<ShinseiShoruiTeigi__c>{
            myNumber,
            untenMenkyoshoOmote,
            untenMenkyoshoUra,
            juminhyo,
            kenkoHoken,
            nenkinTecho
        };
        insert teigiList;

        return teigiList;
    }

    /**
     * getFileType
     */
    @isTest
    private static void getFileType(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ExFileUploadController.FileTypeWrapper result;
        System.runAs(portalUser){
            result = ExFileUploadController.getFileType();
        }

        Assert.areEqual(6, result.fileTypeList.size());

        Assert.areEqual(teigiList[0].Id, result.fileTypeList[0].fileTeigiId);
        Assert.areEqual('個人番号カード', result.fileTypeList[0].fileTeigiName);
        Assert.areEqual('個人番号カード', result.fileTypeList[0].fileViewTeigiName);
        Assert.isTrue(result.fileTypeList[0].isMyNumber);
        Assert.isFalse(result.fileTypeList[0].isKenkoHoken);

        Assert.areEqual(teigiList[1].Id, result.fileTypeList[1].fileTeigiId);
        Assert.areEqual('運転免許証（表面）', result.fileTypeList[1].fileTeigiName);
        Assert.areEqual('運転免許証（表面）', result.fileTypeList[1].fileViewTeigiName);
        Assert.isFalse(result.fileTypeList[1].isMyNumber);
        Assert.isFalse(result.fileTypeList[1].isKenkoHoken);

        Assert.areEqual(teigiList[2].Id, result.fileTypeList[2].fileTeigiId);
        Assert.areEqual('運転免許証（裏面）', result.fileTypeList[2].fileTeigiName);
        Assert.areEqual('運転免許証（裏面）', result.fileTypeList[2].fileViewTeigiName);
        Assert.isFalse(result.fileTypeList[2].isMyNumber);
        Assert.isFalse(result.fileTypeList[2].isKenkoHoken);

        Assert.areEqual(teigiList[3].Id, result.fileTypeList[3].fileTeigiId);
        Assert.areEqual('住民票の写し', result.fileTypeList[3].fileTeigiName);
        Assert.areEqual('住民票の写し', result.fileTypeList[3].fileViewTeigiName);
        Assert.isFalse(result.fileTypeList[3].isMyNumber);
        Assert.isFalse(result.fileTypeList[3].isKenkoHoken);
        Assert.isTrue(result.fileTypeList[3].isJuminHyo);

        Assert.areEqual(teigiList[4].Id, result.fileTypeList[4].fileTeigiId);
        Assert.areEqual('国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証', result.fileTypeList[4].fileTeigiName);
        Assert.areEqual('国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証', result.fileTypeList[4].fileViewTeigiName);
        Assert.isFalse(result.fileTypeList[4].isMyNumber);
        Assert.isTrue(result.fileTypeList[4].isKenkoHoken);

        Assert.areEqual(teigiList[5].Id, result.fileTypeList[5].fileTeigiId);
        Assert.areEqual('国民年金手帳', result.fileTypeList[5].fileTeigiName);
        Assert.areEqual('国民年金手帳', result.fileTypeList[5].fileViewTeigiName);
        Assert.isFalse(result.fileTypeList[5].isMyNumber);
        Assert.isFalse(result.fileTypeList[5].isKenkoHoken);
    }

    /**
     * getDocument
     * OK
     * General
     */
    @isTest
    private static void getDocumentFile_OK_General(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv_1;
        ContentVersion cv_2;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                Shimei__c = '請求者氏名'
            );
            insert seikyusha;

            NinteiSeikyu__c seikyu = new NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusha__c = seikyusha.Id
            );
            insert seikyu;

            cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '住民票の写し';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(2, result.fileList.size());

        Assert.areEqual(cv_1.Id, result.fileList[0].contentVersionId);
        Assert.areEqual(teigiList[3].Id, result.fileList[0].fileTeigiId);
        Assert.areEqual(cv_2.Id, result.fileList[1].contentVersionId);
        Assert.areEqual(teigiList[4].Id, result.fileList[1].fileTeigiId);

        Assert.isTrue(result.checkOK);
    }

    /**
     * getDocument
     * OK
     * Dv
     */
    @isTest
    private static void getDocumentFile_OK_Dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv_1;
        ContentVersion cv_2;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '住民票の写し';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(2, result.fileList.size());

        Assert.areEqual(cv_1.Id, result.fileList[0].contentVersionId);
        Assert.areEqual(teigiList[3].Id, result.fileList[0].fileTeigiId);
        Assert.areEqual(cv_2.Id, result.fileList[1].contentVersionId);
        Assert.areEqual(teigiList[4].Id, result.fileList[1].fileTeigiId);

        Assert.isTrue(result.checkOK);
    }

    /**
     * getDocument
     * OK
     * Satoya
     */
    @isTest
    private static void getDocumentFile_OK_Satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv_1;
        ContentVersion cv_2;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.SATOYA_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '住民票の写し';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert cv_1;

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(1, result.fileList.size());

        Assert.areEqual(cv_1.Id, result.fileList[0].contentVersionId);
        Assert.areEqual(teigiList[3].Id, result.fileList[0].fileTeigiId);

        Assert.isTrue(result.checkOK);
    }

    /**
     * getDocument
     * OK
     * contains key
     */
    @isTest
    private static void getDocumentFile_OK_containsKey(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv_1;
        ContentVersion cv_2;
        ContentVersion cv_3;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                Shimei__c = '請求者氏名'
            );
            insert seikyusha;

            NinteiSeikyu__c seikyu = new NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusha__c = seikyusha.Id
            );
            insert seikyu;

            cv_1 = ExTestUtil.getContentVersion(
                teigiList[0],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            cv_2 = ExTestUtil.getContentVersion(
                teigiList[1],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_2.ShinseiShoruiTeigiName__c = '運転免許証（表面）';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            cv_3 = ExTestUtil.getContentVersion(
                teigiList[2],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_3.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_3.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_3.ShinseiShoruiTeigiName__c = '運転免許証（裏面）';
            cv_3.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_3.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2, cv_3};

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(3, result.fileList.size());

        Assert.areEqual(cv_1.Id, result.fileList[0].contentVersionId);
        Assert.areEqual(teigiList[0].Id, result.fileList[0].fileTeigiId);
        Assert.areEqual(cv_2.Id, result.fileList[1].contentVersionId);
        Assert.areEqual(teigiList[1].Id, result.fileList[1].fileTeigiId);
        Assert.areEqual(cv_3.Id, result.fileList[2].contentVersionId);
        Assert.areEqual(teigiList[2].Id, result.fileList[2].fileTeigiId);

        Assert.isTrue(result.checkOK);
    }

    /**
     * getDocument
     * NG
     * General
     */
    @isTest
    private static void getDocumentFile_NG_General(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                Shimei__c = '請求者氏名'
            );
            insert seikyusha;

            NinteiSeikyu__c seikyu = new NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusha__c = seikyusha.Id
            );
            insert seikyu;

            cv = ExTestUtil.getContentVersion(
                teigiList[0],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv.HoninKakuninShoruiMyNumberOmote__c = true;
            cv.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;
            insert cv;

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(1, result.fileList.size());

        Assert.areEqual(cv.Id, result.fileList[0].contentVersionId);
        Assert.areEqual(teigiList[0].Id, result.fileList[0].fileTeigiId);

        Assert.isFalse(result.checkOK);
    }

    /**
     * getDocument
     * NG
     * Dv
     */
    @isTest
    private static void getDocumentFile_NG_Dv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            insert seikyu;

            cv = ExTestUtil.getContentVersion(
                teigiList[0],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv.HoninKakuninShoruiMyNumberOmote__c = true;
            cv.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;
            insert cv;

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(1, result.fileList.size());

        Assert.areEqual(cv.Id, result.fileList[0].contentVersionId);
        Assert.areEqual(teigiList[0].Id, result.fileList[0].fileTeigiId);

        Assert.isFalse(result.checkOK);
    }

    /**
     * getDocument
     * NG
     * Satoya
     */
    @isTest
    private static void getDocumentFile_NG_Satoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ContentVersion cv;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            insert seikyu;

            Test.startTest();
            result = ExFileUploadController.getDocument(seikyu.Id, '');
            Test.stopTest();
        }

        Assert.areEqual(0, result.fileList.size());

        Assert.isFalse(result.checkOK);
    }

    /**
     * getDocument recordId empty
     */
    @isTest
    private static void getDocumentRecordIdEmpty(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        ExFileUploadController.FileDetailWrapper result;
        System.runAs(portalUser){
            Test.startTest();
            result = ExFileUploadController.getDocument('', '');
            Test.stopTest();
        }

        Assert.isNull(result);
    }

    /**
     * updateContentVersion
     */
    @isTest
    private static void updateContentVersion(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ContentVersion cv;
        System.runAs(portalUser){
            cv = new ContentVersion(
                NetworkId = ExTestUtil.GENERAL_NETWORK_ID,
                pathOnClient = '個人番号カード.png',
                title = '個人番号カード.png',
                versiondata = Blob.valueOf('Blob')
            );
            insert cv;

            Test.startTest();
            ExFileUploadController.updateContentVersion(
                cv.Id,
                teigiList[0].Id,
                true,
                true
            );
            Test.stopTest();
        }

        ContentVersion newCv = [
            SELECT
                ShinseiShoruiTeigiId__c,
                HoninKakuninShoruiMyNumberOmote__c,
                HoninKakuninShoruiMaskKenkoHoken__c,
                Yoto__c,
                Shubetsu__c
            FROM
                ContentVersion
            WHERE
                Id = :cv.Id
            LIMIT 1
        ];
        Assert.areEqual(teigiList[0].Id, newCv.ShinseiShoruiTeigiId__c);
        Assert.isTrue(newCv.HoninKakuninShoruiMyNumberOmote__c);
        Assert.isTrue(newCv.HoninKakuninShoruiMaskKenkoHoken__c);
        Assert.areEqual(ExFileUploadController.YOTO_FILE_UPLOAD, newCv.Yoto__c);
        Assert.areEqual(ExFileUploadController.SHUBETSU_FILE_UPLOAD, newCv.Shubetsu__c);
    }

    /**
     * updateContentVersion
     * not exists
     */
    @isTest
    private static void updateContentVersionNotExists(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ContentVersion cv;
        System.runAs(portalUser){
            cv = new ContentVersion(
                NetworkId = ExTestUtil.GENERAL_NETWORK_ID,
                pathOnClient = '個人番号カード.png',
                title = '個人番号カード.png',
                versiondata = Blob.valueOf('Blob')
            );
            insert cv;

            cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            delete [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];

            Test.startTest();
            ExFileUploadController.updateContentVersion(
                cv.Id,
                teigiList[0].Id,
                true,
                true
            );
            Test.stopTest();
        }
    }

    /**
     * updateNinteiSeikyu
     * 一般
     */
    @isTest
    private static void updateNinteiSeikyuForGeneral(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        NinteiSeikyu__c seikyu;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                Shimei__c = '請求者氏名'
            );
            insert seikyusha;

            seikyu = new NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusha__c = seikyusha.Id
            );
            insert seikyu;

            ContentVersion cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            ContentVersion cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            Test.startTest();
            ExFileUploadController.updateNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        NinteiSeikyu__c newSeikyu = [
            SELECT
                TempuShitanohaHyomenNomi__c,
                MaskingCheck_02__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];
        Assert.isTrue(newSeikyu.TempuShitanohaHyomenNomi__c);
        Assert.isTrue(newSeikyu.MaskingCheck_02__c);
    }

    /**
     * updateNinteiSeikyu
     * 一般
     * not exists
     */
    @isTest
    private static void updateNinteiSeikyuNotExistsForGeneral(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        NinteiSeikyu__c seikyu;
        System.runAs(portalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                Shimei__c = '請求者氏名'
            );
            insert seikyusha;

            seikyu = new NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusha__c = seikyusha.Id
            );
            insert seikyu;

            ContentVersion cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            ContentVersion cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.GENERAL_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            delete seikyu;

            Test.startTest();
            ExFileUploadController.updateNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }
    }

    /**
     * updateNinteiSeikyu
     * DV
     */
    @isTest
    private static void updateNinteiSeikyuForDv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        DV_NinteiSeikyu__c seikyu;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = new DV_Seikyusha__c(
                Shimei__c = '請求者氏名',
                RecordTypeId = ExTestUtil.DV_SEIKYUSHA_ID
            );
            insert seikyusha;

            seikyu = new DV_NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusya__c = seikyusha.Id,
                RecordTypeId = ExTestUtil.DV_SEIKYU_ID
            );
            insert seikyu;

            ContentVersion cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            ContentVersion cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            Test.startTest();
            ExFileUploadController.updateNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c newSeikyu = [
            SELECT
                TempuShitanohaHyomenNomi__c,
                MaskingCheck_02__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];
        Assert.isTrue(newSeikyu.TempuShitanohaHyomenNomi__c);
        Assert.isTrue(newSeikyu.MaskingCheck_02__c);
    }

    /**
     * updateNinteiSeikyu
     * DV
     * not exists
     */
    @isTest
    private static void updateNinteiSeikyuNotExistsForDv(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        DV_NinteiSeikyu__c seikyu;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = new DV_Seikyusha__c(
                Shimei__c = '請求者氏名',
                RecordTypeId = ExTestUtil.DV_SEIKYUSHA_ID
            );
            insert seikyusha;

            seikyu = new DV_NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusya__c = seikyusha.Id,
                RecordTypeId = ExTestUtil.DV_SEIKYU_ID
            );
            insert seikyu;

            ContentVersion cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            ContentVersion cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.DV_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            delete seikyu;

            Test.startTest();
            ExFileUploadController.updateNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }
    }

    /**
     * updateNinteiSeikyu
     * 里親
     */
    @isTest
    private static void updateNinteiSeikyuForSatoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        DV_NinteiSeikyu__c seikyu;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = new DV_Seikyusha__c(
                Shimei__c = '請求者氏名',
                RecordTypeId = ExTestUtil.SATOYA_SEIKYUSHA_ID
            );
            insert seikyusha;

            seikyu = new DV_NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusya__c = seikyusha.Id,
                RecordTypeId = ExTestUtil.SATOYA_SEIKYU_ID
            );
            insert seikyu;

            ContentVersion cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.SATOYA_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            ContentVersion cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.SATOYA_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            Test.startTest();
            ExFileUploadController.updateNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }

        DV_NinteiSeikyu__c newSeikyu = [
            SELECT
                TempuShitanohaHyomenNomi__c,
                MaskingCheck_02__c
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id = :seikyu.Id
            LIMIT 1
        ];
        Assert.isTrue(newSeikyu.TempuShitanohaHyomenNomi__c);
        Assert.isTrue(newSeikyu.MaskingCheck_02__c);
    }

    /**
     * updateNinteiSeikyu
     * 里親
     * not exists
     */
    @isTest
    private static void updateNinteiSeikyuNotExistsForSatoya(){
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiList = createShoruiTeigiList();

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        DV_NinteiSeikyu__c seikyu;
        System.runAs(portalUser){
            DV_Seikyusha__c seikyusha = new DV_Seikyusha__c(
                Shimei__c = '請求者氏名',
                RecordTypeId = ExTestUtil.SATOYA_SEIKYUSHA_ID
            );
            insert seikyusha;

            seikyu = new DV_NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusya__c = seikyusha.Id,
                RecordTypeId = ExTestUtil.SATOYA_SEIKYU_ID
            );
            insert seikyu;

            ContentVersion cv_1 = ExTestUtil.getContentVersion(
                teigiList[3],
                seikyu.Id,
                ExTestUtil.SATOYA_NETWORK_ID
            );
            cv_1.HoninKakuninShoruiMyNumberOmote__c = true;
            cv_1.HoninKakuninShoruiMaskKenkoHoken__c = false;
            cv_1.ShinseiShoruiTeigiName__c = '個人番号カード';
            cv_1.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_1.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            ContentVersion cv_2 = ExTestUtil.getContentVersion(
                teigiList[4],
                seikyu.Id,
                ExTestUtil.SATOYA_NETWORK_ID
            );
            cv_2.HoninKakuninShoruiMyNumberOmote__c = false;
            cv_2.HoninKakuninShoruiMaskKenkoHoken__c = true;
            cv_2.ShinseiShoruiTeigiName__c = '国民健康保険、健康保険、船員保険、後期高齢者医療又は介護保険の被保険者証';
            cv_2.Yoto__c = ExFileUploadController.YOTO_FILE_UPLOAD;
            cv_2.Shubetsu__c = ExFileUploadController.SHUBETSU_FILE_UPLOAD;

            insert new List<ContentVersion>{cv_1, cv_2};

            delete seikyu;

            Test.startTest();
            ExFileUploadController.updateNinteiSeikyu(seikyu.Id);
            Test.stopTest();
        }
    }

    /**
     * updateSeikyusha
     * 一般
     */
    @isTest
    private static void updateSeikyushaForGeneral(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = new Seikyusha__c(
                Shimei__c = '請求者氏名'
            );
            insert seikyusha;

            NinteiSeikyu__c seikyu = new NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusha__c = seikyusha.Id
            );
            insert seikyu;

            Test.startTest();
            ExFileUploadController.updateSeikyusha(seikyu.Id);
            Test.stopTest();
        }

        Seikyusha__c newSeikyusha = [
            SELECT
                HonninKakuninHoho__c
            FROM
                Seikyusha__c
            WHERE
                Id = :seikyusha.Id
            LIMIT 1
        ];
        Assert.areEqual(ExFileUploadController.HOHO_FILE_UPLOAD, newSeikyusha.HonninKakuninHoho__c);
    }

    /**
     * updateSeikyusha
     * DV
     */
    @isTest
    private static void updateSeikyushaForDv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = new DV_Seikyusha__c(
                Shimei__c = '請求者氏名',
                RecordTypeId = ExTestUtil.DV_SEIKYUSHA_ID
            );
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = new DV_NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusya__c = seikyusha.Id,
                RecordTypeId = ExTestUtil.DV_SEIKYU_ID
            );
            insert seikyu;

            Test.startTest();
            ExFileUploadController.updateSeikyusha(seikyu.Id);
            Test.stopTest();
        }

        DV_Seikyusha__c newSeikyusha = [
            SELECT
                HonninKakuninHoho__c
            FROM
                DV_Seikyusha__c
            WHERE
                Id = :seikyusha.Id
            LIMIT 1
        ];
        Assert.areEqual(ExFileUploadController.HOHO_FILE_UPLOAD, newSeikyusha.HonninKakuninHoho__c);
    }

    /**
     * updateSeikyusha
     * 里親
     */
    @isTest
    private static void updateSeikyushaForSatoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_Seikyusha__c seikyusha;
        System.runAs(u){
            seikyusha = new DV_Seikyusha__c(
                Shimei__c = '請求者氏名',
                RecordTypeId = ExTestUtil.SATOYA_SEIKYUSHA_ID
            );
            insert seikyusha;

            DV_NinteiSeikyu__c seikyu = new DV_NinteiSeikyu__c(
                ShinsaStatus__c = '未申請',
                Seikyusya__c = seikyusha.Id,
                RecordTypeId = ExTestUtil.SATOYA_SEIKYU_ID
            );
            insert seikyu;

            Test.startTest();
            ExFileUploadController.updateSeikyusha(seikyu.Id);
            Test.stopTest();
        }

        DV_Seikyusha__c newSeikyusha = [
            SELECT
                HonninKakuninHoho__c
            FROM
                DV_Seikyusha__c
            WHERE
                Id = :seikyusha.Id
            LIMIT 1
        ];
        Assert.areEqual(ExFileUploadController.HOHO_FILE_UPLOAD, newSeikyusha.HonninKakuninHoho__c);
    }
}