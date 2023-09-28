@isTest
public with sharing class SfContentVersionBeforeTriggerProcessTest {
    @isTest
    private static void test(){
        ContentVersion cv = new ContentVersion();
        cv.MaskingFubi__c = true;
        List<ContentVersion> cvList = new List<ContentVersion>{cv};

        Test.startTest();
        SfContentVersionBeforeTriggerProcess.setIsDeletable(cvList);
        Test.stopTest();

        System.assertEquals(true, cv.IsDeletable__c);
    }

    @isTest
    private static void testTrigger(){
        Contentversion cv = new Contentversion();
        cv.Title = '123';
        cv.PathOnClient = 'test';
        cv.PathOnClient = 'test.pdf';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        Test.startTest();
        insert cv;
        update cv;
        Test.stopTest();
    }
}