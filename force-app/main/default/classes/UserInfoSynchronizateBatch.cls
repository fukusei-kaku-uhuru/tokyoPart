/**
 * ユーザ情報同期バッチ処理
 */
public class UserInfoSynchronizateBatch implements Database.Batchable<sObject>, Database.Stateful{

    // 仕様名
    private static final String ACTIONNAME = 'ユーザ情報同期バッチ処理';
    // クラス名
    private static final String CLASSNAME = 'UserInfoSynchronizateBatch';
    // SPACE
    private static final String CONST_SPACE = ' ';
    // ジョブ名
    private static final String JOBNAME = '更新_ユーザ名とメール同期処理';
    // ジョブクラス名
    private static final String JOBCLASSNAME = 'UserInfoSynchronizateBatchSchedule';
    // 実行間隔　30分間
    private static final Integer RUN_INTERVAL = 30;

    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;
    
    public UserInfoSynchronizateBatch() {

    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;

        System.debug('start UserInfoSynchronizateBatch');

        // ユーザ名とメールが一致しないのコミュニティユーザを取得する
        query = 'SELECT '
                + 'id, Username, contactid, contact.name, contact.Email, name, email '
                + ' FROM user where contactid != null AND IsSameedUserNameAndEmail__c = false AND IsActive = true';

        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<SObject> scopes) {
        System.debug('execute UserInfoSynchronizateBatch');

        List<User> updUserList = new List<User>();
        User updObj;
        Savepoint sp = Database.setSavepoint();
        try {
            
            for (SObject obj : scopes) {
                user u = (user)obj;
                updObj = new User();
                updObj.Id = u.Id;
                updObj.Username = u.email;
                updUserList.add(updObj);
            }

            if (updUserList.size() > 0) {
                System.debug('update...');
                update updUserList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            isErr = true;
            msgErr += '\n' + e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
            // システム時間
            Datetime finishDate = DateTime.now();

            // 共通処理
            // バッチエラー情報
            BatchErrorInfo__c info = new BatchErrorInfo__c();
            // バッチ名
            info.BatchName__c = ACTIONNAME;
            // バッチクラス名
            info.BatchClassName__c = CLASSNAME;
            // 発生日時
            info.OccurTime__c = finishDate;
            // 例外情報
            info.ExceptionInfo__c = 'ERROR' + CONST_SPACE + ':' + CONST_SPACE + e.getMessage();
            // 例外発生箇所
            info.ExceptionStacktrace__c = e.getStackTraceString();
            insert info;
        }
    }

    /**
     * バッチ終了
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('finish UserInfoSynchronizateBatch ');
        String strJobName = JOBNAME + '%';

        List<CronTrigger> ctLst = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger WHERE CronJobDetail.Name like :strJobName];
        
        System.debug(ctLst);

        for(CronTrigger ct : ctLst) {
            System.abortJob(ct.Id);
        }

        Type t = Type.forName(JOBCLASSNAME);
        Datetime dt = Datetime.now();
        dt = dt.addMinutes(RUN_INTERVAL);
        if (dt.minute() >= 0 &&  dt.minute() < 30) {
            dt = DateTime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), 15, 0);
        } else {
            dt = DateTime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), 45, 0);
        }
        String sch = String.valueOf(dt.second()) + ' ' +
            String.valueOf(dt.minute()) + ' ' +
            String.valueOf(dt.hour()) + ' ' +
            String.valueOf(dt.day()) + ' ' +
            String.valueOf(dt.month()) + ' ? ' +
            String.valueOf(dt.year());
        System.schedule(JOBNAME + dt.format('yyyyMMddHHmmss'), sch, (Schedulable)t.newInstance());

        if (isErr) {
            // エラー処理、必要があれば
            // ErrorMessage__c err = new ErrorMessage__c();
            // err.ErrorBatch__c = 'CycleJobBatch';//エラーが発生したApexバッチ名
            // err.ErrorMessage__c = msgErr; // システムから受け取ったエラーメッセージ
            // insert err;
        } 
    }

}