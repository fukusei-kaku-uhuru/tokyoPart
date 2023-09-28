/**
 * AWS連携用バッチスケジュール登録用クラス
 */
global class AWSIntegrationProcessingBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new AWSIntegrationProcessingBatch(),2000); 
    }
}