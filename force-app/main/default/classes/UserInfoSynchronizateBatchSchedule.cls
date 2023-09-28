/**
 * ユーザ情報同期バッチスケジュール登録用クラス
 */
global class UserInfoSynchronizateBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new UserInfoSynchronizateBatch(), 2000); 
    }
}