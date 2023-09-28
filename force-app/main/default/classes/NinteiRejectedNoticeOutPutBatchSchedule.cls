/**
 * 不認定通知書出力バッチスケジュール登録用クラス
 */
global class NinteiRejectedNoticeOutPutBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new NinteiRejectedNoticeOutPutBatch(), 2000);
    }
}