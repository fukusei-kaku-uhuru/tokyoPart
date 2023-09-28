@IsTest
public without sharing class OutputDeterminationNoticeDvBatchTest {
    @isTest
    public static void testNo01(){
        Test.startTest();
        JobSettei__c js = new JobSettei__c();
        js.OproartsActionParamater__c = '';
        js.JobShubetsu__c = 'OPROARTSアクション';
        js.OproartsActionMei__c = '出力_認定通知書(DV被害者)';
        insert js;

        JobKanri__c jk= new JobKanri__c();
        jk.JikkoNichiji__c = Datetime.now();
        jk.JobSettei__c = js.id;
        insert jk;
        
        OutputDeterminationNoticeDvBatch bt = new OutputDeterminationNoticeDvBatch();
        Database.executebatch(bt);
        Test.stopTest();
    }
}