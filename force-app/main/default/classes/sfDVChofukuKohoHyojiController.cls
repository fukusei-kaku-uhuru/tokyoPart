public with sharing class sfDVChofukuKohoHyojiController {

    private static final String STATUS_STR_MISHINSEI = '未申請';
    
    @AuraEnabled(cacheable=true)
    public static List<TaishoJido__c> getChofukuKohoJido(Id currentJidoId) {
        try {
            // 表示している対象児童の外部キーを取得
            DV_TaishoJido__c currentJido = [SELECT Id,
                                                   GaibuKey__c
                                              FROM DV_TaishoJido__c
                                             WHERE Id = :currentJidoId
                                             LIMIT 1];
            String recordJidoKey = currentJido.GaibuKey__c;

            List<TaishoJido__c> returnList = new List<TaishoJido__c>();

            // オブジェクトへの権限ない場合は空のリストを返す
            if(!Schema.SObjectType.TaishoJido__c.isAccessible()) {
                return returnList;
            }

            // 外部キーが表示しているレコードと一致する対象児童を取得
            returnList = [SELECT Id,
                                 Name,
                                 NinteiSeikyu__r.Seikyusha__r.ShimeiFurigana__c,
                                 NinteiSeikyu__r.ShinseiKanryoDate__c,
                                 GaibuKey__c
                            FROM TaishoJido__c
                           WHERE GaibuKey__c = :recordJidoKey
                             AND NinteiSeikyu__r.ShinsaStatus__c <> :STATUS_STR_MISHINSEI];
            
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DV_TaishoJido__c> getChofukuKohoJidoDV(Id currentJidoId) {
        try {
            // 表示している対象児童の外部キーを取得
            DV_TaishoJido__c currentJido = [SELECT Id,
                                                   GaibuKey__c
                                              FROM DV_TaishoJido__c
                                             WHERE Id = :currentJidoId
                                             LIMIT 1];
            String recordJidoKey = currentJido.GaibuKey__c;

            List<DV_TaishoJido__c> returnList = new List<DV_TaishoJido__c>();

            // オブジェクトへの権限ない場合は空のリストを返す
            if(!Schema.SObjectType.DV_TaishoJido__c.isAccessible()) {
                return returnList;
            }

            // 外部キーが表示しているレコードと一致する対象児童を取得
            returnList = [SELECT Id,
                                 Name,
                                 NinteiSeikyu__r.Seikyusya__r.ShimeiFurigana__c,
                                 NinteiSeikyu__r.ShinseiKanryoDate__c,
                                 GaibuKey__c
                            FROM DV_TaishoJido__c
                           WHERE GaibuKey__c = :recordJidoKey
                             AND Id <> :currentJidoId
                             AND NinteiSeikyu__r.ShinsaStatus__c <> :STATUS_STR_MISHINSEI];
            
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}