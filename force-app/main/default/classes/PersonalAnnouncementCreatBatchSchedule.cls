/**
 * 個人向けお知らせ作成バッチスケジュール登録用クラス
 */
global class PersonalAnnouncementCreatBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new PersonalAnnouncementCreatBatch(),2000); 
    }
}