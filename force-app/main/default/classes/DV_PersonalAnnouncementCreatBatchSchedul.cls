/**
 * 個人向けお知らせ(DV)作成バッチスケジュール登録用クラス
 */
global class DV_PersonalAnnouncementCreatBatchSchedul implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new DV_PersonalAnnouncementCreatBatch(),2000); 
    }
}