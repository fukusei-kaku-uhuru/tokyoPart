/**
 * 周期ジョブバッチ処理スケジュール登録用クラス
 */
global class CycleJobBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new CycleJobBatch(), 2000);
    }
}