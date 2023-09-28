/**
 * AWS連携用バッチ処理
 */
public class AWSIntegrationProcessingBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts{
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;
    private JobKanri__c jyobKanri = new JobKanri__c();

    // 仕様名
    private static final String ACTIONNAME = 'AWS連携用バッチ処理';
    // クラス名
    private static final String CLASSNAME = 'AWSIntegrationProcessingBatch';
    // SPACE
    private static final String CONST_SPACE = ' ';
    // POST
    private static final String REQUEST_METHOD_POST = 'POST';
    // Content-Type
    private static final String REQUEST_HEADER_CONTENT_TYPE = 'Content-Type';
    // UTF-8
    private static final String REQUEST_HEADER_CONTENT_TYPE_VALUE = 'application/json;charset=UTF-8';

    public AWSIntegrationProcessingBatch() {
    }

    /**
     * 処理対象を取得する
     */
    public List<String> start(Database.BatchableContext bc) { 
        List<String> str = new List<String>();
        str.add('121');
        String query;
        // システム時間
        Datetime finishDate = DateTime.now();

        // ジョブ管理とジョブ設定からパラメータを取得する
        // TODO パラメータ未定
        List<JobKanri__c> jobList = [SELECT Id,JikkoNichiji__c, JobSettei__r.LambdaURL__c, JobSettei__r.LambdaSecret__c, JobSettei__r.LambdaParamater__c 
                                        FROM JobKanri__c 
                                        WHERE JobSettei__r.JobShubetsu__c = 'AWS'];

        // 現在時刻と上記JobListのJikkoNichiji__cの年月日時分を比較し、一致する場合バッチ処理を実行する
        Boolean isJob = false;
        String url = '';
        String secret = '';
        String paramater = '';

        for(JobKanri__c job : jobList){
            System.debug('JikkoNichiji__c'+ job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm'));
            System.debug('now'+ DateTime.now().format('yyyy/MM/dd HH:mm'));
            if(job.JikkoNichiji__c != null && job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm') == DateTime.now().format('yyyy/MM/dd HH:mm')){
                isJob = true;
                jyobKanri = job;
                secret = job.JobSettei__r.LambdaSecret__c;
                paramater = job.JobSettei__r.LambdaParamater__c;
                url = job.JobSettei__r.LambdaURL__c;
                break;
            }
        }

        // 時間一致しない場合、バッチをスキップする
        if(!isJob){
            return new List<String>();
        }

        // TODO URLから下記の処理対象を判定する
        // 出力_認定請求案内の宛名印刷リスト
        // 出力_申請済みリスト
        // 出力_審査済みリスト(認定)
        // 出力_審査済みリスト(不認定)
        // 出力_振込データ(事前口座存在確認)
        // 出力_振込データ
        // 出力_振込データ(不備修正用)
        // 取込_金融機関マスタ更新

        // AWS連携用のパラメータを設定する
        // 下記はサンプルです
        // {
        //     "params": {
        //         "query": "match_list"
        //     }
        //     "secret": "xxxxxxxxxxxx",
        //     "JobKanriId__c": "a0Q1y00000HOLEHEA5"
        // }

        Map<String, Object> params = new Map<String, Object>();
        params.put('params', paramater);
        params.put('secret', secret);
        params.put('JobKanriId__c', jyobKanri.Id);

        // AWS連携処理実装
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(REQUEST_METHOD_POST);
        // json、utf-8指定
        req.setHeader(REQUEST_HEADER_CONTENT_TYPE, REQUEST_HEADER_CONTENT_TYPE_VALUE);

        // リクエストボディの設定
        req.setBody(JSON.serialize(params));
        
        system.debug('******** json : ' + JSON.serialize(params));

        HttpResponse response;
        try {
            // APIコール
            response = http.send(req);
            system.debug('******** response : ' + response);
            if (response.getStatusCode() == 200) {
                // HTTPステータス正常時
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                //TODO body未定
                String resultFlg = (String) results.get('resultFlg');
                String resultErrorCode = (String) results.get('resultErrorCode');
                String resultMsg = (String) results.get('resultMsg');
                
            } 
        } catch (Exception ex) {
            System.debug('******** ex : ' + ex.getMessage());
            System.debug('******** ex : ' + ex.getStackTraceString());
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
            info.ExceptionInfo__c = 'ERROR' + CONST_SPACE + ':' + CONST_SPACE + ex.getMessage();
            // 例外発生箇所
            info.ExceptionStacktrace__c = ex.getStackTraceString();
            insert info;
        }

        // TODO:連携結果を更新する
        // 仕様未定
        return str;
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<String> scopes) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('execute AWSIntegrationProcessingBatch ');
            System.debug('execute scopes ' + scopes);
            
            
            // TODO:連携結果を更新する
            // 仕様未定


        } catch (Exception ex) {
            Database.rollback(sp);
            isErr = true;
            msgErr += '\n' + ex.getTypeName() + ': ' + ex.getMessage() + '\n' + ex.getStackTraceString();

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
            info.ExceptionInfo__c = 'ERROR' + CONST_SPACE + ':' + CONST_SPACE + ex.getMessage();
            // 例外発生箇所
            info.ExceptionStacktrace__c = ex.getStackTraceString();
            insert info;
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
    }
}