@IsTest
public class DV_CycleJobBatchTest {
    @IsTest
    public static void test01() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        insert ysList;

        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        insert ts;
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        update cvnew;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }

    @IsTest
    public static void test02() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);
        insert ysList;

        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.ShinsaStatus__c = 'OCR処理中';

        DV_NinteiSeikyu__c ns2 = new DV_NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys2.id;
        ns2.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        insert ns2;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        insert ts;
        DV_TaishoJido__c ts2 = new DV_TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        insert ts2;
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title = '1234';
        cv2.PathOnClient = 'test10';
        cv2.PathOnClient = 'test10.pdf';
        cv2.Shubetsu__c = '';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));

        cvList.add(cv2);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Contentversion cvId2 = [select id,ContentDocumentId from Contentversion where id =: cv2.id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=  ns2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId= cvId2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        Contentversion cvnew2 = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId2.id];
        cvnew2.Shubetsu__c = 'Web';
        cvnew2.ShinseiShoruiTeigiId__c = cvnew2.ContentDocumentId;
        cvnew2.OCR_Syoruisyubetu__c = 'ocr_fuboshitei';
        update cvnew2;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }

    @IsTest
    public static void test03() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);
        insert ysList;

        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.ShinsaStatus__c = 'OCR処理中';

        DV_NinteiSeikyu__c ns2 = new DV_NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys2.id;
        ns2.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        insert ns2;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        ts.IsTochuTenshutsu__c = true;
        ts.IsTochuTennyuShussei__c = true;
        ts.TennyuShusseiDate__c = Date.today();
        ts.TenshutsuDate__c = Date.today() - 1;
        insert ts;
        DV_TaishoJido__c ts2 = new DV_TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        ts2.IsTochuTenshutsu__c = true;
        ts2.IsTochuTennyuShussei__c = true;
        ts2.TennyuShusseiDate__c = Date.today();
        ts2.TenshutsuDate__c = Date.today() - 1;
        insert ts2;
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title = '1234';
        cv2.PathOnClient = 'test10';
        cv2.PathOnClient = 'test10.pdf';
        cv2.Shubetsu__c = '';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));

        cvList.add(cv2);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Contentversion cvId2 = [select id,ContentDocumentId from Contentversion where id =: cv2.id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=  ns2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId= cvId2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        Contentversion cvnew2 = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId2.id];
        cvnew2.Shubetsu__c = 'Web';
        cvnew2.ShinseiShoruiTeigiId__c = cvnew2.ContentDocumentId;
        cvnew2.OCR_Syoruisyubetu__c = 'ocr_fuboshitei';
        update cvnew2;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }

    @IsTest
    public static void test04() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);
        insert ysList;

        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.ShinsaStatus__c = 'OCR処理中';

        DV_NinteiSeikyu__c ns2 = new DV_NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys2.id;
        ns2.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        insert ns2;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        ts.IsTochuTenshutsu__c = true;
        ts.IsTochuTennyuShussei__c = true;
        ts.TennyuShusseiDate__c = Date.today() - 1;
        ts.TenshutsuDate__c = Date.today();
        insert ts;
        DV_TaishoJido__c ts2 = new DV_TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        ts2.IsTochuTenshutsu__c = true;
        ts2.IsTochuTennyuShussei__c = true;
        ts2.TennyuShusseiDate__c = Date.today() - 1;
        ts2.TenshutsuDate__c = Date.today();
        insert ts2;
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title = '1234';
        cv2.PathOnClient = 'test10';
        cv2.PathOnClient = 'test10.pdf';
        cv2.Shubetsu__c = '';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));

        cvList.add(cv2);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Contentversion cvId2 = [select id,ContentDocumentId from Contentversion where id =: cv2.id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=  ns2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId= cvId2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        Contentversion cvnew2 = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId2.id];
        cvnew2.Shubetsu__c = 'Web';
        cvnew2.ShinseiShoruiTeigiId__c = cvnew2.ContentDocumentId;
        cvnew2.OCR_Syoruisyubetu__c = 'ocr_fuboshitei';
        update cvnew2;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }

    @IsTest
    public static void test05() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);
        insert ysList;

        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.ShinsaStatus__c = 'OCR処理中';

        DV_NinteiSeikyu__c ns2 = new DV_NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys2.id;
        ns2.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        insert ns2;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        ts.IsTochuTenshutsu__c = true;
        ts.TennyuShusseiDate__c = Date.today() - 1;
        ts.TenshutsuDate__c = Date.today();
        insert ts;
        DV_TaishoJido__c ts2 = new DV_TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        ts2.IsTochuTenshutsu__c = true;
        ts2.TennyuShusseiDate__c = Date.today() - 1;
        ts2.TenshutsuDate__c = Date.today();
        insert ts2;
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title = '1234';
        cv2.PathOnClient = 'test10';
        cv2.PathOnClient = 'test10.pdf';
        cv2.Shubetsu__c = '';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));

        cvList.add(cv2);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Contentversion cvId2 = [select id,ContentDocumentId from Contentversion where id =: cv2.id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=  ns2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId= cvId2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        Contentversion cvnew2 = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId2.id];
        cvnew2.Shubetsu__c = 'Web';
        cvnew2.ShinseiShoruiTeigiId__c = cvnew2.ContentDocumentId;
        cvnew2.OCR_Syoruisyubetu__c = 'ocr_fuboshitei';
        update cvnew2;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }

    @IsTest
    public static void test06() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);
        insert ysList;

        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.ShinsaStatus__c = 'OCR処理中';

        DV_NinteiSeikyu__c ns2 = new DV_NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys2.id;
        ns2.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        insert ns2;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        ts.IsTochuTennyuShussei__c = true;
        ts.TennyuShusseiDate__c = Date.today() - 1;
        ts.TenshutsuDate__c = Date.today();
        insert ts;
        DV_TaishoJido__c ts2 = new DV_TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        ts2.IsTochuTennyuShussei__c = true;
        ts2.TennyuShusseiDate__c = Date.today() - 1;
        ts2.TenshutsuDate__c = Date.today();
        insert ts2;
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title = '1234';
        cv2.PathOnClient = 'test10';
        cv2.PathOnClient = 'test10.pdf';
        cv2.Shubetsu__c = '';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));

        cvList.add(cv2);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Contentversion cvId2 = [select id,ContentDocumentId from Contentversion where id =: cv2.id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=  ns2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId= cvId2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        Contentversion cvnew2 = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId2.id];
        cvnew2.Shubetsu__c = 'Web';
        cvnew2.ShinseiShoruiTeigiId__c = cvnew2.ContentDocumentId;
        cvnew2.OCR_Syoruisyubetu__c = 'ocr_fuboshitei';
        update cvnew2;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }

    @IsTest
    public static void test07() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        
        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));
        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);
        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);
        insert ysList;
        DV_Seikyusha__c dsk = new DV_Seikyusha__c();
        dsk.HonninKakuninHoho__c = '公的個人認証';
        insert dsk;
        DV_NinteiSeikyu__c ns = new DV_NinteiSeikyu__c();
        ns.YusoShinsei__c = ys.id;
        ns.Seikyusya__c = dsk.id;
        ns.ShinsaStatus__c = 'OCR処理中';

        DV_NinteiSeikyu__c ns2 = new DV_NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys2.id;
        ns2.ShinsaStatus__c = 'OCR処理中';
        insert ns;
        insert ns2;
        DV_TaishoJido__c ts = new DV_TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        ts.IsTochuTennyuShussei__c = true;
        ts.TennyuShusseiDate__c = Date.today() - 1;
        ts.TenshutsuDate__c = Date.today();
        insert ts;
        DV_TaishoJido__c ts2 = new DV_TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        ts2.IsTochuTennyuShussei__c = true;
        ts2.TennyuShusseiDate__c = Date.today() - 1;
        ts2.TenshutsuDate__c = Date.today();
        insert ts2;   
        
        // OCRのWEBテスト
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test9';
        cv.PathOnClient = 'test9.pdf';
        cv.Shubetsu__c = '';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title = '1234';
        cv2.PathOnClient = 'test10';
        cv2.PathOnClient = 'test10.pdf';
        cv2.Shubetsu__c = '';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));

        cvList.add(cv2);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ns.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Contentversion cvId2 = [select id,ContentDocumentId from Contentversion where id =: cv2.id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=  ts2.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId= cvId2.ContentDocumentId;
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        Contentversion cvnew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId.id];
        cvnew.Shubetsu__c = 'Web';
        cvnew.ShinseiShoruiTeigiId__c = cvnew.ContentDocumentId;
        cvnew.OCR_Syoruisyubetu__c = 'ocr_ininijo';
        Contentversion cvnew2 = [select id,Shubetsu__c,OCR_Syoruisyubetu__c,ContentDocumentId from Contentversion where id =: cvId2.id];
        cvnew2.Shubetsu__c = 'Web';
        cvnew2.ShinseiShoruiTeigiId__c = cvnew2.ContentDocumentId;
        cvnew2.OCR_Syoruisyubetu__c = 'ocr_fuboshitei';
        update cvnew2;
        Test.startTest();
        DV_CycleJobBatch cjb = new DV_CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();
    }
}