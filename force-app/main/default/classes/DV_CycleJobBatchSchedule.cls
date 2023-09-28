/**
 * 周期ジョブバッチ処理（DV被害者・里親）スケジュール登録用クラス
 */
global class DV_CycleJobBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new DV_CycleJobBatch(), 2000);
    }
}