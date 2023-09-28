/**
 * 出力	認定通知書(DV被害者)バッチ処理（OPROARTSアクション用）
 */
public class OutputDeterminationNoticeDvBatch implements Database.Batchable<sObject>, Database.Stateful{
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;
    private JobKanri__c jyobKanri = new JobKanri__c();
    // 仕様名
    private static final String ACTIONNAME = '出力	認定通知書バッチ処理(DV被害者)';
    // クラス名
    private static final String CLASSNAME = 'OutputDeterminationNoticeDvBatch';
    // SPACE
    private static final String CONST_SPACE = ' ';

    public OutputDeterminationNoticeDvBatch() {
    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query;
        
        query = 'SELECT Id,JikkoNichiji__c, JobSettei__r.OproartsActionParamater__c ' +
                    'FROM JobKanri__c ' +
                    'WHERE JobSettei__r.JobShubetsu__c = \'OPROARTSアクション\' ' +
                    'AND JobSettei__r.OproartsActionMei__c = \'出力_認定通知書(DV被害者)\' ';

        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<SObject> scopes) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('execute OutputDeterminationNoticeDvBatch ');
            
            // 現在時刻と上記JobListのJikkoNichiji__cの年月日時分を比較し、一致する場合バッチ処理を実行する
            Boolean isJob = false;

            for(SObject sjob : scopes){
                JobKanri__c job = (JobKanri__c)sjob;
                System.debug('JikkoNichiji__c'+ job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm'));
                System.debug('now'+ DateTime.now().format('yyyy/MM/dd HH:mm'));
                if(job.JikkoNichiji__c != null && job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm') == DateTime.now().format('yyyy/MM/dd HH:mm')){
                    isJob = true;
                    jyobKanri = job;
                    break;
                }
            }

            if(isJob){
                oproarts1__OproartsAction__c oprObj = new oproarts1__OproartsAction__c();
                // 有効
                oprObj.oproarts1__IsActive__c = true;
                // サービス
                oprObj.oproarts1__Service__c = 'sf0234_tokyo';
                // 名前空間プレフィックス
                oprObj.oproarts1__NamespacePrefix__c = 'oproarts1';
                // OPROARTS キー
                oprObj.oproarts1__OproartsKey__c = System.Label.OproartsKey;
                // ステータス
                oprObj.oproarts1__Status__c = 'Unprocessed';
                // タイプ
                oprObj.oproarts1__Type__c = '02_ninteitsuchisho_ikkatsu_d';
                // レコードID
                oprObj.oproarts1__RecordIds__c = 'dummy';
                insert oprObj;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            isErr = true;
            msgErr += '\n' + e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
            // // システム時間
            // Datetime finishDate = DateTime.now();

            // // 共通処理
            // // バッチエラー情報
            // BatchErrorInfo__c info = new BatchErrorInfo__c();
            // // バッチ名
            // info.BatchName__c = ACTIONNAME;
            // // バッチクラス名
            // info.BatchClassName__c = CLASSNAME;
            // // 発生日時
            // info.OccurTime__c = finishDate;
            // // 例外情報
            // info.ExceptionInfo__c = 'ERROR' + CONST_SPACE + ':' + CONST_SPACE + e.getMessage();
            // // 例外発生箇所
            // info.ExceptionStacktrace__c = e.getStackTraceString();
            // // insert info;
        }
    }

    /**
     * バッチ終了
     */
    public void finish(Database.BatchableContext bc) {
        if(String.isNotBlank(jyobKanri.Id)) {
            if (isErr) {
                // エラー処理、ジョブ管理を更新する
                jyobKanri.ShoriKekka__c = 'エラー';
                // エラーメッセージ
                jyobKanri.ErrorMessage__c = msgErr;
                // 処理日時
                jyobKanri.ShoriNichiji__c = DateTime.now();
                update jyobKanri;
            } else {
                // 正常終了処理、ジョブ管理を更新する
                // 処理結果
                jyobKanri.ShoriKekka__c = '成功';
                // 処理日時
                jyobKanri.ShoriNichiji__c = DateTime.now();
                update jyobKanri;
            }
        }

        List<CronTrigger> ctLst = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetail.Name
            FROM CronTrigger WHERE CronJobDetail.Name like '出力_認定通知書(DV被害者)%' and NextFireTime = null];
        
        for(CronTrigger ct : ctLst){
            System.abortJob(ct.Id);
        }
    }
}