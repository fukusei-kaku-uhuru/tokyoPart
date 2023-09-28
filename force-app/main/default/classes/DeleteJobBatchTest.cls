@IsTest public without sharing class DeleteJobBatchTest {
    @isTest
    static void Test01() {
        Test.StartTest();
        DeleteJobBatch batch = new DeleteJobBatch('Test');
        Database.executebatch(batch);
        Test.stopTest();
    }
}