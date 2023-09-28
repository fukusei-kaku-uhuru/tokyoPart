/**
 * 郵送申請バッチスケジュール登録用クラス
 */
global class YusoShinseiOutPutBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new YusoShinseiOutPutBatch(),200); 
    }
}