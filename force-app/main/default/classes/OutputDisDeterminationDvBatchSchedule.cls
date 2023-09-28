/**
 * 出力	不認定通知書(DV被害者)バッチスケジュール登録用クラス（OPROARTSアクション用）
 */
global class OutputDisDeterminationDvBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new OutputDisDeterminationNoticeDvBatch(),2000); 
    }
}