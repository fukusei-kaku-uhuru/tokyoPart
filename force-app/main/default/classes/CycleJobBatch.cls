/**
 * 周期ジョブバッチ処理
 */
public class CycleJobBatch implements Database.Batchable<sObject>, Database.Stateful{

    // 仕様名
    private static final String ACTIONNAME = '周期ジョブバッチ処理';
    // クラス名
    private static final String CLASSNAME = 'CycleJobBatch';
    // SPACE
    private static final String CONST_SPACE = ' ';

    private static final String STATUS_STR_OCR_SHORICHU         = 'OCR処理中';
    private static final String STATUS_STR_SHINSAMACHI_00       = '0次審査待ち';
    private static final String STATUS_STR_SHINSAMACHI_01       = '1次審査待ち';

    private static final String SHINSE_START_DATE               = '2023-04-01';         // 申請期間開始日
    private static final String SHINSE_END_DATE                 = '2024-03-31';         // 申請期間終了日
    private static final String FILEKIND_B                      = 'B';                  // ファイル種別　B：認定請求書一枚目の裏
    private static final String SYUBETSU_YUSO                   = '郵送';
    
    
    // private static final String MYNUMBERCARD                    = '公的個人認証';
    
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;

    public CycleJobBatch() {

    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;

        System.debug('start CycleJobBatch ');

        // STが「OCR処理中」の認定請求を取得する
        query = 'SELECT Id, IsYusoShinsei__c ' + 
                'FROM NinteiSeikyu__c ' +
                'WHERE ShinsaStatus__c = :STATUS_STR_OCR_SHORICHU';

        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<SObject> scopes) {

        System.debug('execute CycleJobBatch ');

        List<Id> nsIDList = new List<Id>();
        List<Id> nstjIDList = new List<Id>();
        List<Id> idList = new List<Id>();
        
        List<Id> contentIdList = new List<Id>();
        Map<Id, Id> child2NsMap = new Map<Id, Id>();
        Map<Id, Id> cdl2NsMap = new Map<Id, Id>();
        Map<Id, List<ContentVersion>> nsFinishMap = new Map<Id, List<ContentVersion>>();
        String strNsId;
        NinteiSeikyu__c ns;
        List<NinteiSeikyu__c> updTargerList = new List<NinteiSeikyu__c>();
        String kindKbn = '';
        Boolean kanryoFlg = true;

        Savepoint sp = Database.setSavepoint();

        try {
            for (SObject obj : scopes) {
                // 郵送対象オブジェクトIDを抽出
                if (((NinteiSeikyu__c)obj).IsYusoShinsei__c){
                    nsIDList.add(obj.Id);
                }
                nsFinishMap.put(obj.Id, new List<ContentVersion>());
            }

            // 認定請求レコードと紐づいて対象児童を取得する
            if (nsIDList.size() > 0 ) {
                List<TaishoJido__c> taishoJidoList = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c WHERE NinteiSeikyu__c = :nsIDList];
                for (TaishoJido__c tj : taishoJidoList) {
                    child2NsMap.put(tj.Id, tj.NinteiSeikyu__c);
                    nstjIDList.add(tj.Id);
                }
                nstjIDList.addAll(nsIDList);
            
                System.debug(nstjIDList);
                // ContentDocumentLink対象レコードを抽出
                List<ContentDocumentLink> taishoLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = :nstjIDList ORDER BY LinkedEntityId];
                
                for (ContentDocumentLink cdl : taishoLinkList) {
                    // ContentVersion取得用ContentDocumentLinkID
                    contentIdList.add(cdl.ContentDocumentId);
                    // 対象児童レコード
                    if (child2NsMap.containsKey(cdl.LinkedEntityId)){
                        strNsId = child2NsMap.get(cdl.LinkedEntityId);
                    } else {
                        // 認定請求レコード
                        strNsId = cdl.LinkedEntityId;
                    }
                    // コンテンツドキュメント単位に認定請求を設定
                    cdl2NsMap.put(cdl.ContentDocumentId, strNsId);
                }

                // ContentVersion対象レコードを抽出
                List<ContentVersion> cvList = [
                                                SELECT Id, ContentDocumentId, OCR_Kanryo__c, Title, Shubetsu__c
                                                FROM ContentVersion 
                                                WHERE ShinseiShoruiTeigiId__c != null AND ContentDocumentId = :contentIdList
                                                AND IsLatest = true];

                for(ContentVersion cv : cvList){
                    nsFinishMap.get(cdl2NsMap.get(cv.ContentDocumentId)).add(cv);
                }
            }

            for (Id nsId : nsFinishMap.keySet()) {
                kanryoFlg = true;
                // 郵送の場合
                if (nsIDList.contains(nsId)) {
                    List<ContentVersion> allcvList = nsFinishMap.get(nsId);                
                    // 認定請求単位で認定請求と対象児童に紐づくファイルのOCR完了フラグを判定する
                    for (ContentVersion cv : allcvList) {
                        kindKbn = cv.Title.right(1);
                        // 郵送かつ認定請求書のファイル名の最後がBの場合、チェック対象外
                        if (SYUBETSU_YUSO.equals(cv.Shubetsu__c) && FILEKIND_B.equals(kindKbn)){
                            continue;
                        } else {
                            if (cv.OCR_Kanryo__c == false){
                                kanryoFlg = false;
                                break;
                            }
                        }
                    }
                }
                if (kanryoFlg) {
                    // 完了場合、審査ステータスは「0次審査待ち」を更新する
                    ns = new NinteiSeikyu__c();
                    ns.Id = nsId;
                    if (nsIDList.contains(nsId)) {
                        // 郵送の場合
                        ns.ShinsaStatus__c = STATUS_STR_SHINSAMACHI_00;
                    } else {
                       // Webの場合
                        ns.ShinsaStatus__c = STATUS_STR_SHINSAMACHI_01;
                    }
                    ns.ShinseiKanryoDate__c = Date.today();
                    updTargerList.add(ns);

                    // 居住期間更新対象
                    idList.add(nsId);
                }
            }

            // 認定請求レコードの更新対象がある場合
            if (updTargerList.size() > 0) {
                update updTargerList;
            }

            // 対象児童居住期間の更新対象がある場合
            if (idList.size() > 0) {
                // 対象児童居住期間計算する
                List<TaishoJido__c> tjList = [
                    SELECT  id
                            , KyojuKikan__c 
                            ,  IsTochuTennyuShussei__c, TennyuShusseiDate__c
                            ,  IsTochuTenshutsu__c, TenshutsuDate__c
                            //  TaishoshaKubun__r.Name 
                            FROM TaishoJido__c 
                            WHERE NinteiSeikyu__c IN :idList];
                
                if (tjList != null && tjList.size() > 0) {
                    // 対象児童居住期間計算する
                    updKyojuKikan(tjList);
                }
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
        
        System.debug('finish CycleJobBatch ');

        if (isErr) {
            // エラー処理、必要があれば
            // ErrorMessage__c err = new ErrorMessage__c();
            // err.ErrorBatch__c = 'CycleJobBatch';//エラーが発生したApexバッチ名
            // err.ErrorMessage__c = msgErr; // システムから受け取ったエラーメッセージ
            // insert err;
        } 
    }

    /**
     * 居住期間計算する
     */
    private void updKyojuKikan(List<TaishoJido__c> targetList){
        
        List<TaishoJido__c> updList = new List<TaishoJido__c>();
        TaishoJido__c targetTJ;

        for (TaishoJido__c taishoJido : targetList) {
            // 申請日（作成日）
            Date shinseiDate;
            // 転入日
            Date tennyuShusseiDate;
            // 転出日
            Date tenshutsuDate;
            // 居住期間
            Integer intPeriodOfResidence = 0;

            // 転入・出生日
            tennyuShusseiDate = taishoJido.TennyuShusseiDate__c;
            // 転出(予定)日
            if (taishoJido.TenshutsuDate__c != null) {
                tenshutsuDate = taishoJido.TenshutsuDate__c.addDays(-1);
            }
            shinseiDate = Date.today();
            // system.debug('対象者区分.対象者区分名：' + taishoJido.TaishoshaKubun__r.Name);

            // 対象者区分の対象者区分名がA-1「ずっと住み続けている人 」   都内在住（転入転出なし）
            // if (TAISHOSHAKUBUN_NAME_A_1.equals(taishoJido.TaishoshaKubun__r.Name)) {
            // 転入・出生日と転出日両方が未設定
            if (taishoJido.IsTochuTenshutsu__c == false && taishoJido.IsTochuTennyuShussei__c == false) {
                // 居住期間は1年間を設定
                intPeriodOfResidence = 12;
            } else if (taishoJido.IsTochuTenshutsu__c == true && taishoJido.IsTochuTennyuShussei__c == true) {
                if (tenshutsuDate < tennyuShusseiDate) {
                    // 都内転出 次に 都内転入
                    if ( shinseiDate <= tenshutsuDate || tennyuShusseiDate <= shinseiDate ) {
                        // 転出前の居住期間を計算
                        intPeriodOfResidence = Date.valueOf(SHINSE_START_DATE).monthsBetween(tenshutsuDate) + 1;
                        // 転入後の居住期間を計算
                        if (tennyuShusseiDate.day() != 1 ){
                            // 1日以外の場合、次の月を設定
                            tennyuShusseiDate = tennyuShusseiDate.addMonths(1);
                        }
                        intPeriodOfResidence += tennyuShusseiDate.monthsBetween(Date.valueOf(SHINSE_END_DATE)) + 1;
                    } else {
                        intPeriodOfResidence = 0;
                    }
                } else {
                    // 期間内　都内転入 次に 都内転出
                    // 申請日前転出　または　申請日後転入
                    if ( shinseiDate < tennyuShusseiDate || tenshutsuDate < shinseiDate ) {
                        intPeriodOfResidence = 0;
                    } else {
                        // 1日以外の場合、次の月を設定
                        if (tennyuShusseiDate.day() != 1 ){
                            tennyuShusseiDate = tennyuShusseiDate.addMonths(1);
                        }
                        intPeriodOfResidence = tennyuShusseiDate.monthsBetween(tenshutsuDate) + 1;
                    }
                }
            } else if (taishoJido.IsTochuTenshutsu__c == true ) {
                // 都内転出
                // 転出済場合、給付対象外
                if( tenshutsuDate < shinseiDate ) {
                    intPeriodOfResidence = 0;
                } else {
                    intPeriodOfResidence = Date.valueOf(SHINSE_START_DATE).monthsBetween(tenshutsuDate) + 1;
                }
            } else if (taishoJido.IsTochuTennyuShussei__c == true ) {
                // 都内転入
                // 申請日後転入場合、給付対象外
                if( tennyuShusseiDate > shinseiDate ) {
                    intPeriodOfResidence = 0;
                } else {
                    if (tennyuShusseiDate.day() != 1 ){
                        // 1日以外の場合、次の月を設定
                        tennyuShusseiDate = tennyuShusseiDate.addMonths(1);
                    }
                    intPeriodOfResidence = tennyuShusseiDate.monthsBetween(Date.valueOf(SHINSE_END_DATE)) + 1;
                }
            }

            if(intPeriodOfResidence < 0 || intPeriodOfResidence > 12) {
                intPeriodOfResidence = 0;
            }

            targetTJ = new TaishoJido__c();
            targetTJ.Id = taishoJido.Id;
            // 居住期間(ヵ月)(自動)
            targetTJ.KyojuKikan__c = intPeriodOfResidence;

            updList.add(targetTJ);
        }

        if (updList.size() > 0) {
            update updList;
        }
    }
}