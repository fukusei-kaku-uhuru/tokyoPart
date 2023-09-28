/**
 * 蛭田の一時的バッチ(メンテ用)
 */
public class HirutaBatch implements Database.Batchable<sObject>{

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start');
        List<ContentVersion> ContentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE ShinseiShoruiTeigiId__c != NULL OR Shubetsu__c != NULL];

        System.debug('ContentVersionList:' + ContentVersionList);
        // 重複削除
        Set<ID> idList = new Set<ID>();
        for (ContentVersion con : ContentVersionList) {
            idList.add(con.ContentDocumentId);
        }
        System.debug('idList' + idList);
        return Database.getQueryLocator(
            [SELECT Id FROM ContentDocument WHERE Id IN :idList]
        );
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<ContentDocument> scopes) {
        System.debug('execute');
        System.debug(scopes);
        
         
        // 削除処理
        List<Database.DeleteResult> resultList = Database.delete(scopes, false);
        System.debug('results.size():' + resultList.size());
        for (Integer i = 0; i < resultList.size(); i++) {
            Database.DeleteResult result = resultList[i];
            System.debug('getId:' + result.getId());
            System.debug('isSuccess:' + result.isSuccess());
        }
        // ゴミ箱から削除
        //List<Database.EmptyRecycleBinResult> recycleResultList = Database.emptyRecycleBin(scopes);
        //System.debug('recycleResultList.size():' + recycleResultList.size());
        
    }
    

    /**
     * バッチ終了
     */
    public void finish(Database.BatchableContext bc) {
        //なにもしない
    }
}