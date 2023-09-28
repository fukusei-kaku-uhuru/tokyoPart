/**
 * 出力	不認定通知書バッチスケジュール登録用クラス（OPROARTSアクション用）
 */
global class OutputDisDeterminationBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new OutputDisDeterminationNoticeBatch(),2000); 
    }
}