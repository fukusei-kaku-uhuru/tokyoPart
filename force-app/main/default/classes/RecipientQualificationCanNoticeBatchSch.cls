/**
 * 出力  受給資格取消通知書バッチスケジュール登録用クラス（OPROARTSアクション用）
 */
global class RecipientQualificationCanNoticeBatchSch implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executebatch(new RecipientQualificationCancelNoticeBatch(),2000); 
    }
}