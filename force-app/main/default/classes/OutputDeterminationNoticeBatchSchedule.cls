/**
 * 出力	認定通知書バッチスケジュール登録用クラス（OPROARTSアクション用）
 */
global class OutputDeterminationNoticeBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new OutputDeterminationNoticeBatch(),2000); 
    }
}