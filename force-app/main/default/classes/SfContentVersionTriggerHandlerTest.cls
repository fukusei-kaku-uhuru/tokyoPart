@IsTest
public class SfContentVersionTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        List<Contentversion> cvList = new List<Contentversion>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys9 = new YusoShinsei__c();
        ysList.add(ys9);

        YusoShinsei__c ys10 = new YusoShinsei__c();
        ysList.add(ys10);
        insert ysList;

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.YusoShinsei__c = ys9.id;
        NinteiSeikyu__c ns2 = new NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys10.id;

        insert ns;
        insert ns2;

        TaishoJido__c ts = new TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        TaishoJido__c ts2 = new TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        insert ts;
        insert ts2;
        // OCRのWEBテスト
        Contentversion cv9 = new Contentversion();
        cv9.Title = '123';
        cv9.PathOnClient = 'test9';
        cv9.PathOnClient = 'test9.pdf';
        cv9.Shubetsu__c = null;
        cv9.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv9);

        Contentversion cv10 = new Contentversion();
        cv10.Title = '123';
        cv10.PathOnClient = 'test10';
        cv10.PathOnClient = 'test10.pdf';
        cv10.Shubetsu__c = null;
        cv10.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv10);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv9.id];
        System.debug('FFFFFFFFFFFFFFFFF'+cvId.ContentDocumentId);
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ts.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink; 
    }
    
    @IsTest
    public static void testbackupFile() {

        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        Test.startTest();

        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test'; 
        cv.PathOnClient = 'test.pdf';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;

        Test.stopTest();
    }

    
    @IsTest
    public static void testInsertContentDocumentLink() {
        // テスト中はTest.startTestとTest.stopTestで非同期操作を囲みます
        Test.startTest();

        List<Contentversion> cvList = new List<Contentversion>();
        List<ShinseiShoruiTeigi__c> ssList = new List<ShinseiShoruiTeigi__c>();
        List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();

        YusoShinsei__c ys = new YusoShinsei__c();
        ysList.add(ys);

        YusoShinsei__c ys2 = new YusoShinsei__c();
        ysList.add(ys2);

        YusoShinsei__c ys3 = new YusoShinsei__c();
        ysList.add(ys3);

        YusoShinsei__c ys4 = new YusoShinsei__c();
        ysList.add(ys4);

        YusoShinsei__c ys5 = new YusoShinsei__c();
        ysList.add(ys5);

        YusoShinsei__c ys6 = new YusoShinsei__c();
        ysList.add(ys6);

        YusoShinsei__c ys7 = new YusoShinsei__c();
        ysList.add(ys7);

        YusoShinsei__c ys8 = new YusoShinsei__c();
        ysList.add(ys8);

        YusoShinsei__c ys9 = new YusoShinsei__c();
        ysList.add(ys9);

        YusoShinsei__c ys10 = new YusoShinsei__c();
        ysList.add(ys10);
        insert ysList;


        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.YusoShinsei__c = ys9.id;
        NinteiSeikyu__c ns2 = new NinteiSeikyu__c();
        ns2.YusoShinsei__c = ys10.id;

        insert ns;
        insert ns2;

        TaishoJido__c ts = new TaishoJido__c();
        ts.NinteiSeikyu__c = ns.id;
        TaishoJido__c ts2 = new TaishoJido__c();
        ts2.NinteiSeikyu__c = ns2.id;
        insert ts;
        insert ts2;

        // Mockオブジェクトをインジェクションします
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        ShinseiShoruiTeigi__c ss = new ShinseiShoruiTeigi__c();
        ss.ShoruiSetsumei__c = 'A';
        ssList.add(ss);

        ShinseiShoruiTeigi__c ss2 = new ShinseiShoruiTeigi__c();
        ss2.ShoruiSetsumei__c = 'B';
        ssList.add(ss2);

        ShinseiShoruiTeigi__c ss3 = new ShinseiShoruiTeigi__c();
        ss3.ShoruiSetsumei__c = 'C';
        ssList.add(ss3);

        ShinseiShoruiTeigi__c ss4 = new ShinseiShoruiTeigi__c();
        ss4.ShoruiSetsumei__c = 'D';
        ssList.add(ss4);

        ShinseiShoruiTeigi__c ss5 = new ShinseiShoruiTeigi__c();
        ss5.ShoruiSetsumei__c = 'E';
        ssList.add(ss5);

        ShinseiShoruiTeigi__c ss6 = new ShinseiShoruiTeigi__c();
        ss6.ShoruiSetsumei__c = 'F';
        ssList.add(ss6);

        insert ssList;

        Contentversion cv = new Contentversion();
        cv.Title = ys.Id + '-1-A';
        cv.PathOnClient = 'test1'; 
        cv.PathOnClient = 'test1.pdf';
        cv.Shubetsu__c = '郵送';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv);

        Contentversion cv2 = new Contentversion();
        cv2.Title =  ys2.Id +'-1-B';
        cv2.PathOnClient = 'test2';
        cv2.PathOnClient = 'test2.pdf';
        cv2.Shubetsu__c = '郵送';
        cv2.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv2);

        Contentversion cv3 = new Contentversion();
        cv3.Title = ys3.Id +'-1-C';
        cv3.PathOnClient = 'test3';
        cv3.PathOnClient = 'test3.pdf';
        cv3.Shubetsu__c = '郵送';
        cv3.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv3);

        Contentversion cv4 = new Contentversion();
        cv4.Title = ys4.Id +'-1-D';
        cv4.PathOnClient = 'test4';
        cv4.PathOnClient = 'test4.pdf';
        cv4.Shubetsu__c = '郵送';
        cv4.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv4);

        Contentversion cv5 = new Contentversion();
        cv5.Title = ys5.Id +'-1-E';
        cv5.PathOnClient = 'test5';
        cv5.PathOnClient = 'test5.pdf';
        cv5.Shubetsu__c = '郵送';
        cv5.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv5);

        Contentversion cv6 = new Contentversion();
        cv6.Title = ys6.Id +'-1-F';
        cv6.PathOnClient = 'test6';
        cv6.PathOnClient = 'test6.pdf';
        cv6.Shubetsu__c = '郵送';
        cv6.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv6);

        Contentversion cv7 = new Contentversion();
        cv7.Title = '1234567890123455678-1-G';
        cv7.PathOnClient = 'test7';
        cv7.PathOnClient = 'test7.pdf';
        cv7.Shubetsu__c = '郵送';
        cv7.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv7);

        Contentversion cv8 = new Contentversion();
        cv8.Title = '123';
        cv8.PathOnClient = 'test8';
        cv8.PathOnClient = 'test8.pdf';
        cv8.Shubetsu__c = '郵送';
        cv8.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv8);


        // OCRのWEBテスト
        Contentversion cv9 = new Contentversion();
        cv9.Title = '123';
        cv9.PathOnClient = 'test9';
        cv9.PathOnClient = 'test9.pdf';
        cv9.Shubetsu__c = '';
        cv9.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv9);

        Contentversion cv10 = new Contentversion();
        cv10.Title = '123';
        cv10.PathOnClient = 'test10';
        cv10.PathOnClient = 'test10.pdf';
        cv10.Shubetsu__c = '';
        cv10.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cvList.add(cv10);
        insert cvList;

        Contentversion cvId = [select id,ContentDocumentId from Contentversion where id =: cv9.id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=  ts.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Test.stopTest();
    }
    @IsTest
    public static void testStartOrcServiceAPIForWeb() {
        Test.startTest();
        String queryString = 'SELECT Id, Shubetsu__c, OCR_Syoruisyubetu__c FROM ContentVersion WHERE PathOnClient = \'test9.pdf\'';
        List<ContentVersion> cvList = (List<ContentVersion>) Database.query(queryString);

        // Contentversion cvNew = [select id,Shubetsu__c,OCR_Syoruisyubetu__c from Contentversion where PathOnClient ='test9.pdf'];
        cvList[0].Shubetsu__c = 'Web';
        cvList[0].OCR_Syoruisyubetu__c = 'ocr_ininjo';
        Test.stopTest();
        update cvList;
        
    }

}