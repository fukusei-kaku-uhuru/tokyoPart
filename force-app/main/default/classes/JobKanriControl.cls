public without sharing class JobKanriControl {

    
    // 仕様名
    private static final String ACTIONNAME = 'ジョブ管理バッチ処理';
    // クラス名
    private static final String CLASSNAME = 'JobKanriControl';
    // SPACE
    private static final String CONST_SPACE = ' ';

    private static final String JOB_OPROARTS='OPROARTSアクション';
    private static final String JOB_LAMBDA='AWS';

    private static final Map<String, String> APEXMap = new Map<String, String>{
        '郵送申請情報出力' => 'YusoShinseiOutPutBatchSchedule'
        , '認定通知書出力' => 'NinteiNoticeOutPutBatchSchedule'
        , '不認定通知書出力' => 'NinteiRejectedNoticeOutPutBatchSchedule'
    };

    private static final Map<String, String> OPROARTSMap = new Map<String, String>{
        '出力_認定通知書(通常)' => 'OutPutDeterminationNoticeBatchSchedule'
        , '出力_不認定通知書(通常)' => 'OutPutDisDeterminationBatchSchedule'
        , '出力_認定通知書(DV被害者)' => 'OutPutDeterminationNoticeDvBatchSchedule'
        , '出力_不認定通知書(DV被害者)' => 'OutPutDisDeterminationDvBatchSchedule'
    };

    private static final String AWSIntegrationProcessingBatch = 'AWS連携用バッチ';

    @AuraEnabled
    public static Result cancleJob(String recordId){
        System.debug('cancleJob RecordId=' + recordId);
        // エラーメッセージ
        String msgErr = ''; 
        Boolean isErr = false;

        String jobName = '';

        Result result = new Result();

        Savepoint sp = Database.setSavepoint();
        try {
            // ジョブ管理レコード作成
            JobKanri__c jkRec = getJobRecord(recordId);

            // ジョブ種別を判定
            if (JOB_OPROARTS.equals(jkRec.JobShubetsu__c)){
                // OPROARTSアクション
                jobName = jkRec.JobSettei__r.OproartsActionMei__c + jkRec.JikkoNichiji__c.format('yyyyMMddHHmmss');
            } else if (JOB_LAMBDA.equals(jkRec.JobShubetsu__c)) {
                // JOB_LAMBDA
                jobName = AWSIntegrationProcessingBatch + jkRec.JikkoNichiji__c.format('yyyyMMddHHmmss');
            } else {
                // APEX
                jobName = jkRec.JobSettei__r.ApexJobMei__c + jkRec.JikkoNichiji__c.format('yyyyMMddHHmmss');
            }
            // スケジュール済みジョブのスケジュール情報取得
            List<CronTrigger> ctLst = [SELECT Id, 
                                            CronJobDetail.Name, 
                                            NextFireTime, 
                                            State, 
                                            StartTime, 
                                            EndTime 
                                    FROM CronTrigger
                                    WHERE CronJobDetail.Name = :jobName
                                        AND NextFireTime = :jkRec.JikkoNichiji__c
                                        AND State = 'WAITING'];
            
            if (ctLst != null) {
                for (CronTrigger ct : ctLst) {
                    System.abortJob(ct.Id);
                }
            }

            // 処理結果
            jkRec.ShoriKekka__c = '取り消し';
            // リクエスト済み
            jkRec.RequestZumi__c = false;
            update jkRec;
            
            result.status = 'OK';
        } catch (Exception e) {
            Database.rollback(sp);
            result.status = 'NG';
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
        return result;
    }

    @AuraEnabled
    public static Result registJob(String recordId){
        System.debug('registJob RecordId=' + recordId);
        // エラーメッセージ
        String msgErr = ''; 
        Boolean isErr = false;
        
        Result result = new Result();

        Savepoint sp = Database.setSavepoint();
        try {
            // ジョブ管理レコード作成
            JobKanri__c jkRec = getJobRecord(recordId);

            // ジョブ種別を判定
            if (JOB_OPROARTS.equals(jkRec.JobShubetsu__c)){
                System.debug('OPROARTSアクション名：' + jkRec.JobSettei__r.OproartsActionMei__c);
                // OPROARTSアクション
                Type t = Type.forName(OPROARTSMap.get(jkRec.JobSettei__r.OproartsActionMei__c));
                String sch = getsch(jkRec.JikkoNichiji__c);
                String scheduleId = System.schedule(jkRec.JobSettei__r.OproartsActionMei__c + jkRec.JikkoNichiji__c.format('yyyyMMddHHmmss'), sch, (Schedulable)t.newInstance());
            } else if (JOB_LAMBDA.equals(jkRec.JobShubetsu__c)) {
                // JOB_LAMBDA
                Type t = Type.forName('AWSIntegrationProcessingBatchSchedule');
                String sch = getsch(jkRec.JikkoNichiji__c);
                String scheduleId = System.schedule(AWSIntegrationProcessingBatch + jkRec.JikkoNichiji__c.format('yyyyMMddHHmmss'), sch, (Schedulable)t.newInstance());
            } else {
                System.debug('APEX名：' + jkRec.JobSettei__r.ApexJobMei__c);
                // APEX
                Type t = Type.forName(APEXMap.get(jkRec.JobSettei__r.ApexJobMei__c));
                String sch = getsch(jkRec.JikkoNichiji__c);
                String scheduleId = System.schedule(jkRec.JobSettei__r.ApexJobMei__c + jkRec.JikkoNichiji__c.format('yyyyMMddHHmmss'), sch, (Schedulable)t.newInstance());
            }

            // リクエスト済み
            jkRec.RequestZumi__c = true;

            update jkRec;

            result.status = 'OK';
        } catch (Exception e) {
            Database.rollback(sp);
            result.status = 'NG';
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
        return result;
    }

    private static JobKanri__c getJobRecord(String recordId){
        JobKanri__c jkRec =
            [SELECT ID, 
                    Name,
                    Status__c,
                    JobShubetsu__c,
                    JikkoNichiji__c,
                    RequestZumi__c,
                    ShoriKekka__c,
                    ShoriNichiji__c,
                    ErrorMessage__c,
                    JobSettei__c,
                    JobSettei__r.ApexJobMei__c,
                    JobSettei__r.OproartsActionMei__c,
                    JobSettei__r.OproartsActionParamater__c,
                    JobSettei__r.LambdaURL__c,
                    JobSettei__r.LambdaSecret__c,
                    JobSettei__r.LambdaParamater__c
            FROM JobKanri__c WHERE ID = :recordId];

        return jkRec;
    }

    private static String getsch(Datetime dtRuntime){
        // Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
        String sch = String.valueOf(dtRuntime.second()) + ' ' +
            String.valueOf(dtRuntime.minute()) + ' ' +
            String.valueOf(dtRuntime.hour()) + ' ' +
            String.valueOf(dtRuntime.day()) + ' ' +
            String.valueOf(dtRuntime.month()) + ' ? ' +
            String.valueOf(dtRuntime.year());

        return sch;
    }

    public class Result {
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }

}