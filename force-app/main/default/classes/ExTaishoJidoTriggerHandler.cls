public with sharing class ExTaishoJidoTriggerHandler {

    /**
     * Web用の項目に入っている値を、OCR用項目側にも反映する
     */
    public static void convertWebValueToOcrValue(List<TaishoJido__c> tjList) {

        Set<Id> nsIdSet = new Set<Id>();
        for (TaishoJido__c tj : tjList) {
            nsIdSet.add(tj.NinteiSeikyu__c);
        }
        // 紐づく認定請求を取得
        Map<Id, NinteiSeikyu__c> nsMap = new Map<Id, NinteiSeikyu__c>([SELECT Id, IsYusoShinsei__c FROM NinteiSeikyu__c WHERE Id in :nsIdSet]);


        for (TaishoJido__c tj : tjList) {
            // 郵送の場合は、処理を実行しない
            if (nsMap.get(tj.NinteiSeikyu__c).IsYusoShinsei__c) {
                continue;
            }

            tj.Tennyu_Ari__c = tj.IsTochuTennyuShussei__c;
            tj.Tennyu_Nashi__c = !tj.IsTochuTennyuShussei__c;

            tj.Tenshutu_Ari__c = tj.IsTochuTenshutsu__c;
            tj.Tenshutu_Nashi__c = !tj.IsTochuTenshutsu__c;
        }
    }
}