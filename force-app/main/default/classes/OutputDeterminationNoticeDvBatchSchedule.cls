/**
 * 出力	認定通知書(DV被害者)バッチスケジュール登録用クラス（OPROARTSアクション用）
 */
global class OutputDeterminationNoticeDvBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new OutputDeterminationNoticeDvBatch(),2000); 
    }
}