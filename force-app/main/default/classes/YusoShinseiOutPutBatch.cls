/**
 * 郵送申請バッチ処理
 */
public class YusoShinseiOutPutBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;
    // 処理件数
    private Integer resultCount = 0;
    
    private JobKanri__c jyobKanri = new JobKanri__c();
    // 仕様名
    private static final String ACTIONNAME = '郵送申請バッチ処理';
    // クラス名
    private static final String CLASSNAME = 'YusoShinseiOutPutBatch';
    // SPACE
    private static final String CONST_SPACE = ' ';

    public YusoShinseiOutPutBatch() {
    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query;
        System.debug('system time'+ System.now());

        List<JobKanri__c> jobList = [SELECT Id,JikkoNichiji__c  
                                        FROM JobKanri__c 
                                        WHERE JobSettei__r.JobShubetsu__c = 'APEX' 
                                        AND JobSettei__r.ApexJobMei__c = '郵送申請情報出力'];

        // 現在時刻と上記JobListのJikkoNichiji__cの年月日時分を比較し、一致する場合バッチ処理を実行する
        Boolean isJob = false;

        for(JobKanri__c job : jobList){
            System.debug('JikkoNichiji__c'+ job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm'));
            System.debug('now'+ DateTime.now().format('yyyy/MM/dd HH:mm'));
            if(job.JikkoNichiji__c != null && job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm') == DateTime.now().format('yyyy/MM/dd HH:mm')){
                isJob = true;
                jyobKanri = job;
                break;
            }
        }
        
        if(!isJob){
            query = 'SELECT Id FROM YusoShinsei__c Limit 0 ';
        } else {
            query = 'SELECT Id,Name, ' +
                    ' ShimeiKana__c, ' +
                    ' YusoAtena__c, ' +
                    ' YusoYubinBangou__c, ' +
                    ' YusoTodouFuken__c, ' +
                    ' YusoShikuChoson__c, ' +
                    ' YusoChiban__c, ' +
                    ' YusoHeyaBangou__c, ' +
                    ' Status__c ' +
            ' FROM YusoShinsei__c WHERE Status__c= \'受付\' AND KyokudashiNengappiDate__c = null';
        }
        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<SObject> scopes) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('execute YusoShinseiOutPutBatch ');
            
            if(scopes.size() > 0) {
                resultCount = scopes.size();
                List<String> csvRowValues = new List<String>();
                List<YusoShinsei__c> yusoShinseiList = new List<YusoShinsei__c>();
                Integer no = 1;
                for (SObject obj : scopes) {
                    YusoShinsei__c yusoShinsei = (YusoShinsei__c)obj;

                    // CSV出力用のデータを作成する
                    String yubinBangou = yusoShinsei?.YusoYubinBangou__c==null?'':yusoShinsei?.YusoYubinBangou__c;
                    String todouFuken = yusoShinsei?.YusoTodouFuken__c==null?'':yusoShinsei?.YusoTodouFuken__c;
                    String shikuChoson = yusoShinsei?.YusoShikuChoson__c==null?'':yusoShinsei?.YusoShikuChoson__c;
                    String chiban = yusoShinsei?.YusoChiban__c==null?'':yusoShinsei?.YusoChiban__c;
                    String heyaBangou = yusoShinsei?.YusoHeyaBangou__c==null?'':yusoShinsei?.YusoHeyaBangou__c;
                    String name = yusoShinsei?.YusoAtena__c==null?'':yusoShinsei?.YusoAtena__c;
                    String nameKana = yusoShinsei?.ShimeiKana__c==null?'':yusoShinsei?.ShimeiKana__c;
                    String yusoShinseiName = yusoShinsei?.Name==null?'':yusoShinsei?.Name;

                    String csvRow = '"' +  no + '","'+ yusoShinsei?.Id + '","'+ name + '","'+ nameKana + '","' + yubinBangou + '"'+ ',"' + todouFuken + shikuChoson + chiban + heyaBangou  + '","'+  '","発送済み","' + yusoShinseiName + '"';
                    csvRowValues.add(csvRow);

                    yusoShinsei.Status__c = '発送中';
                    yusoShinseiList.add(yusoShinsei);

                    no++;
                }
                
                // ContentVersion作成
                ContentVersion cv = new ContentVersion();
                ContentVersion cvResult = new ContentVersion();
                
                String title = '郵送申請書';

                // 現在時刻をファイル名に付与
                cv.PathOnClient = title + Datetime.now().format('yyyy-MM-dd HH:mm:ss', 'JST') + '.csv'; // ファイル名
                cv.Title = title + Datetime.now().format('yyyy-MM-dd HH:mm:ss', 'JST')+'.csv'; // ファイルタイトル
                
                cv.ContentLocation = 'S'; // ファイルはSalesforce上に保存

                String csvColumnHeader = '"no","id","name","name_kana","postcode","address","KyokudashiNengappiDate__c","Status__c","yuso_no"\n';
                String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');

                cv.VersionData = Blob.valueOf(csvFile);   // ファイルデータ

                insert cv;

                cvResult = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

                // コンテンツドキュメントリンクを保存する
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.ContentDocumentId = cvResult.ContentDocumentId;
                conDocLink.LinkedEntityId = jyobKanri.Id; // リンクしたオブジェクトの ID
                conDocLink.ShareType = 'V'; // 必須 V、C、I(詳細の意味はAPI参照)
                conDocLink.Visibility = 'AllUsers'; // (他の設定値はAPI参照)
                insert conDocLink;

                // 対象郵送申請のステータスは「受付」を「発送済み」に更新する
                update yusoShinseiList;
            }
        } catch (Exception e) {
            System.debug('-----e-------' + e.getStackTraceString());
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
                
                if(resultCount > 0) {
                    // 処理結果
                    jyobKanri.ShoriKekka__c = '成功';
                } else {
                    jyobKanri.ShoriKekka__c = '成功（対象データなし）';
                }
                // 処理日時
                jyobKanri.ShoriNichiji__c = DateTime.now();
                update jyobKanri;
            }
        }

        List<CronTrigger> ctLst = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetail.Name
            FROM CronTrigger WHERE CronJobDetail.Name like '郵送申請情報出力%' and NextFireTime = null];
        
        for(CronTrigger ct : ctLst){
            System.abortJob(ct.Id);
        }
    }
}