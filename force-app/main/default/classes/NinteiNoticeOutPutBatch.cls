/**
 * 認定通知書出力バッチ処理
 */
public class NinteiNoticeOutPutBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;
    // 処理件数
    private Integer resultCount = 0;
    
    private JobKanri__c jyobKanri = new JobKanri__c();
    // 仕様名
    private static final String ACTIONNAME = '認定通知書出力バッチ処理';
    // クラス名
    private static final String CLASSNAME = 'NinteiNoticeOutPutBatch';
    // ジョブ名
    private static final String JOBNAME = '認定通知書出力';
    // SPACE
    private static final String CONST_SPACE = ' ';

    public NinteiNoticeOutPutBatch() {

    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query;
        System.debug('start NinteiNoticeOutPutBatch ');

        List<JobKanri__c> jobList = [SELECT Id, JikkoNichiji__c  
                                        FROM JobKanri__c 
                                        WHERE JobSettei__r.JobShubetsu__c = 'APEX' 
                                        AND JobSettei__r.ApexJobMei__c = :JOBNAME ];

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
            query = 'SELECT Id FROM TaishoJido__c Limit 0 ';
        } else {
            query = 'SELECT Id ' +
                    ', SeikyushaShimei__c ' +
                    ', BunsyoKanriBangou__c ' +
                    ', NinteiTsuchishoHakkoDate__c ' +
                    ', Shimei__c ' +
                    ', Nintei_KetteiNengappiDate__c ' +
                    ', ShikyuNinteiKaishiTsukiTochoDate__c ' +
                    ', Nintei_Goukeigaku__c ' +
                    ', SeikyuBangou__c ' +
                ' FROM TaishoJido__c ' +
                ' WHERE ShoninKekka__c = \'認定\' AND NinteiTsuchiStatus__c = null AND IsYusoShinsei__c = true ';
        }

        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<SObject> scopes) {
        System.debug('execute NinteiNoticeOutPutBatch ');

        Savepoint sp = Database.setSavepoint();
        try {
            if(scopes.size() > 0) {
                resultCount = scopes.size();
                List<String> csvRowValues = new List<String>();
                List<TaishoJido__c> tjList = new List<TaishoJido__c>();
                Integer no = 1;
                for (SObject obj : scopes) {
                    TaishoJido__c tj = (TaishoJido__c)obj;

                    // CSV出力用のデータを作成する
                    String seikyushaShimei = tj?.SeikyushaShimei__c==null?'':tj?.SeikyushaShimei__c;
                    String bunsyoKanriBangou = tj?.BunsyoKanriBangou__c==null?'':tj?.BunsyoKanriBangou__c;
                    String ninteiTsuchishoHakkoDate = CommonConvertString.convertSeireki2WarekiYMD(tj.NinteiTsuchishoHakkoDate__c);
                    String shimei = tj?.Shimei__c==null?'':tj?.Shimei__c;
                    String ninteiKetteiNengappiDate = CommonConvertString.convertSeireki2WarekiYMD(tj.Nintei_KetteiNengappiDate__c);
                    String shikyuNinteiKaishiTsukiTochoDate = CommonConvertString.convertSeireki2WarekiYM(tj.ShikyuNinteiKaishiTsukiTochoDate__c);
                    String ninteiGoukeigaku = tj?.Nintei_Goukeigaku__c==null?'':String.valueOf(tj?.Nintei_Goukeigaku__c);
                    String seikyuBangou = tj?.SeikyuBangou__c==null?'':tj?.SeikyuBangou__c;

                    String csvRow = '"' +  no + '","'+ tj?.Id + '","'+ seikyushaShimei + '","'+ bunsyoKanriBangou + '","' + 
                        ninteiTsuchishoHakkoDate + '"'+ ',"' + shimei + '","'+ ninteiKetteiNengappiDate + '","'+ 
                        shikyuNinteiKaishiTsukiTochoDate  + '","'+  ninteiGoukeigaku  + '","'+ seikyuBangou + '"';
                    csvRowValues.add(csvRow);

                    tj.NinteiTsuchiStatus__c = '通知手配中（郵送）';
                    tjList.add(tj);

                    no++;
                }
                
                // ContentVersion作成
                ContentVersion cv = new ContentVersion();
                ContentVersion cvResult = new ContentVersion();
                
                String title = '認定通知書';

                // 現在時刻をファイル名に付与
                cv.PathOnClient = title + Datetime.now().format('yyyy-MM-dd HH:mm:ss', 'JST') + '.csv'; // ファイル名
                cv.Title = title + Datetime.now().format('yyyy-MM-dd HH:mm:ss', 'JST')+'.csv'; // ファイルタイトル
                
                cv.ContentLocation = 'S'; // ファイルはSalesforce上に保存

                String csvColumnHeader = '"no","id","seikyushaShimei","bunsyoKanriBangou","ninteiTsuchishoHakkoDate","shimei",'+
                    '"ninteiKetteiNengappiDate","shikyuNinteiKaishiTsukiTochoDate","ninteiGoukeigaku","seikyuBangou"\n';
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

                // 対象児童のXXXXは「XXXX」を「XXXX」に更新する
                if (tjList.size() > 0){
                    update tjList;
                }
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

        String strJobName = JOBNAME + '%';

        List<CronTrigger> ctLst = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetail.Name
            FROM CronTrigger WHERE CronJobDetail.Name like :strJobName and NextFireTime = null];
        
        for(CronTrigger ct : ctLst){
            System.abortJob(ct.Id);
        }
    }

}