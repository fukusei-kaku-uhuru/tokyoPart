/**
 * 認定通知書出力バッチスケジュール登録用クラス
 */
global class NinteiNoticeOutPutBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new NinteiNoticeOutPutBatch(), 2000);
    }
}