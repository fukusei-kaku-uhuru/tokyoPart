/**
 * 個人向けお知らせ作成バッチ
 */
public class DV_PersonalAnnouncementCreatBatch implements Database.Batchable<sObject>, Database.Stateful{
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;

    public DV_PersonalAnnouncementCreatBatch() {
    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        System.debug('system time'+ System.now());
        System.debug('system time'+ DateTime.now());
        String query;
        // 条件満たす対象児童(DV)レコードを取得する
        query = 'SELECT Id,'+
                        'NinteiSeikyu__r.OwnerId,'+
                        'NinteiSeikyu__r.IsYusoShinsei__c,'+
                        'NinteiTsuchishoHakkoDate__c,'+
                        'IsNinteiTsushiOshiraseZumi__c,'+
                        'NinteiKyakkaTsuchishoHakkoDate__c,'+
                        'IsNinteiKyakkaTsushiOshiraseZumi__c,'+
                        'JukyuShikakuShometsuTsuchishoHakkoDate__c,'+
                        'IsJukyuShikakuShometsuOshiraseZumi__c,'+
                        'ShikyuNinteiTorikeshiTsuchiHakkoDate__c,'+
                        'IsShikyuNinteiTorikeshiOshiraseZumi__c '+
                'FROM DV_TaishoJido__c '+ 
                'WHERE'+ 
                '(NinteiTsuchishoHakkoDate__c <> null '+
                'AND NinteiTsuchishoHakkoDate__c <= TODAY '+ 
                'AND IsNinteiTsushiOshiraseZumi__c = false) '+ 
                'or '+ 
                '(NinteiKyakkaTsuchishoHakkoDate__c <> null '+
                'AND NinteiKyakkaTsuchishoHakkoDate__c <= TODAY '+ 
                'AND IsNinteiKyakkaTsushiOshiraseZumi__c = false) '+ 
                'or'+ 
                '(JukyuShikakuShometsuTsuchishoHakkoDate__c <> null '+
                'AND JukyuShikakuShometsuTsuchishoHakkoDate__c <= TODAY '+ 
                'AND IsJukyuShikakuShometsuOshiraseZumi__c = false) '+ 
                'or '+ 
                '(ShikyuNinteiTorikeshiTsuchiHakkoDate__c <> null '+
                'AND ShikyuNinteiTorikeshiTsuchiHakkoDate__c <= TODAY '+ 
                'AND IsShikyuNinteiTorikeshiOshiraseZumi__c = false) ';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<DV_TaishoJido__c> scopes) {
        List<KojinOshirase__c> insertList = new List<KojinOshirase__c>();
        List<DV_TaishoJido__c> updateList = new List<DV_TaishoJido__c>();
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('execute PersonalAnnouncementCreatBatch ');
            System.debug(scopes.size());
            System.debug(scopes);
            List<Id> updatedOwnerIdList = new List<id>();
            for (DV_TaishoJido__c taishoJidoObj_old : scopes) {
                if(taishoJidoObj_old.NinteiSeikyu__r.IsYusoShinsei__c == true){
                    continue;
                }
                if(taishoJidoObj_old.NinteiSeikyu__c != null){
                    updatedOwnerIdList.add(taishoJidoObj_old.NinteiSeikyu__r.OwnerId);
                }
            }
            List<User> contactIDList= [select id,contactID from User where id in: updatedOwnerIdList];
            System.debug(contactIDList);
            Map<id,String> contactIDMap = new Map<id,String>();
            for(User user : contactIDList){
                contactIDMap.put(user.id, user.contactID);
            }
            System.debug(contactIDMap);
            for (DV_TaishoJido__c taishoJidoObj_old : scopes) {
                if (contactIDMap.containsKey(taishoJidoObj_old.NinteiSeikyu__r.OwnerId)) {
                    DV_TaishoJido__c taishoJidoObj_new = new DV_TaishoJido__c();
                    taishoJidoObj_new.id = taishoJidoObj_old.id;
                    // 個人向けお知らせ
                    KojinOshirase__c oshirase = new KojinOshirase__c();
                    // 共通項目設定
                    System.debug(taishoJidoObj_old.NinteiSeikyu__c);
                    String contactID= contactIDMap.get(taishoJidoObj_old.NinteiSeikyu__r.OwnerId);
                    System.debug(contactID);
                    oshirase.TorihikisakiSekininsyaId__c = contactID;
                    oshirase.Yukou__c = true;
                    oshirase.KokaiKaishiDate__c = System.today();
                    oshirase.KokaiShuryoDate__c = Date.newInstance(2099, 12, 31);

                    // 認定通知お知らせ
                    Date systemDate = System.today();
                    if(taishoJidoObj_old.NinteiTsuchishoHakkoDate__c != null && 
                    taishoJidoObj_old.NinteiTsuchishoHakkoDate__c <= systemDate && 
                    taishoJidoObj_old.IsNinteiTsushiOshiraseZumi__c == false){
                        System.debug('認定通知');
                        oshirase.OshiraseShubetsu__c = '認定通知';
                        insertList.add(oshirase);
                        taishoJidoObj_new.IsNinteiTsushiOshiraseZumi__c = true;
                    }
                    // 認定却下通知お知らせ
                    else if(
                        taishoJidoObj_old.NinteiKyakkaTsuchishoHakkoDate__c != null &&    
                        taishoJidoObj_old.NinteiKyakkaTsuchishoHakkoDate__c <= systemDate &&
                        taishoJidoObj_old.IsNinteiKyakkaTsushiOshiraseZumi__c == false){
                        System.debug('認定却下通知');
                        oshirase.OshiraseShubetsu__c = '認定却下通知';
                        insertList.add(oshirase);
                        taishoJidoObj_new.IsNinteiKyakkaTsushiOshiraseZumi__c = true;
                    }
                    // 受給資格消滅通知お知らせ
                    else if(
                        taishoJidoObj_old.JukyuShikakuShometsuTsuchishoHakkoDate__c != null &&
                        taishoJidoObj_old.JukyuShikakuShometsuTsuchishoHakkoDate__c <= systemDate &&
                        taishoJidoObj_old.IsJukyuShikakuShometsuOshiraseZumi__c == false){
                        System.debug('受給資格消滅通知');
                        oshirase.OshiraseShubetsu__c = '受給資格消滅通知';
                        insertList.add(oshirase);
                        taishoJidoObj_new.IsJukyuShikakuShometsuOshiraseZumi__c = true;
                    }
                    // 支給認定取消通知お知らせ
                    else if(
                        taishoJidoObj_old.ShikyuNinteiTorikeshiTsuchiHakkoDate__c != null &&
                        taishoJidoObj_old.ShikyuNinteiTorikeshiTsuchiHakkoDate__c <= systemDate &&
                        taishoJidoObj_old.IsShikyuNinteiTorikeshiOshiraseZumi__c == false){
                        System.debug('支給認定取消通知');
                        oshirase.OshiraseShubetsu__c = '支給認定取消通知';
                        insertList.add(oshirase);
                        taishoJidoObj_new.IsShikyuNinteiTorikeshiOshiraseZumi__c = true;
                    }
                    updateList.add(taishoJidoObj_new);
                }
                // // 処理を実行する
                // if(taishoJidoObj_old.NinteiSeikyu__r.IsYusoShinsei__c == true){
                //     continue;
                // }
                
            }
            System.debug(insertList.size());
            System.debug(updateList.size());
            System.debug(insertList);
            System.debug(updateList);
            insert insertList;
            update updateList;
        } catch (Exception e) {
            Database.rollback(sp);
            isErr = true;
            msgErr += '\n' + e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
        }
    }

    /**
     * バッチ終了
     */
    public void finish(Database.BatchableContext bc) {
        if (isErr) {
            // エラー処理、必要があれば
            // ErrorMessage__c err = new ErrorMessage__c();
            // err.ErrorBatch__c = 'DataDeleteAccountBatch';//エラーが発生したApexバッチ名
            // err.ErrorMessage__c = msgErr; // システムから受け取ったエラーメッセージ
            // insert err;
        } 
    }
}