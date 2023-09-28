@isTest
public class AWSIntegrationProcessingBatchTest {
    @IsTest
    static void runBatchWithData() {
        AWSIntegrationProcessingBatch batch = new AWSIntegrationProcessingBatch();

        JobSettei__c setting = new JobSettei__c();
        setting.LambdaURL__c = 'https://test.com';
        setting.LambdaSecret__c = 'test';
        setting.LambdaParamater__c = 'test';
        setting.JobShubetsu__c = 'AWS';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = System.now();
        jk.JobSettei__c = setting.Id;
        insert jk;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(true));

        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    static void runBatchWithData2() {
        AWSIntegrationProcessingBatch batch = new AWSIntegrationProcessingBatch();

        JobSettei__c setting = new JobSettei__c();
        setting.LambdaURL__c = 'https://test.com';
        setting.LambdaSecret__c = 'test';
        setting.LambdaParamater__c = 'test';
        setting.JobShubetsu__c = 'AWS';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = System.now();
        jk.JobSettei__c = setting.Id;
        insert jk;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Database.executeBatch(batch);
        Test.stopTest();
    }
}