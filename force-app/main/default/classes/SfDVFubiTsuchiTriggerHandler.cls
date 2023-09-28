public with sharing class SfDVFubiTsuchiTriggerHandler {
    
    private final String HUBI_STATUS_STR_RENRAKUZUMI = '不備連絡済み';

    public SfDVFubiTsuchiTriggerHandler() {

    }

    public void afterInsert(Map<Id, DV_FubiTsuchi__c> newFubiTsuchiMap) {

        // 認定請求ページに公開がtrueに設定されたとき不備ステータスを「不備連絡済み」に更新する処理
        // 更新する不備ステータスは、不備通知が認定請求に紐づいていれば対象者の不備STを、対象児童に紐づいていれば対象児童のSTを更新する
        updateHubiStatus(newFubiTsuchiMap, null);
    }

    public void afterUpdate(Map<Id, DV_FubiTsuchi__c> newFubiTsuchiMap, Map<Id, DV_FubiTsuchi__c> oldFubiTsuchiMap) {

        // 認定請求ページに公開がtrueに設定されたとき不備ステータスを「不備連絡済み」に更新する処理
        // 更新する不備ステータスは、不備通知が認定請求に紐づいていれば対象者の不備STを、対象児童に紐づいていれば対象児童のSTを更新する
        updateHubiStatus(newFubiTsuchiMap, oldFubiTsuchiMap);
    }

    /**
     * 不備ステータスを不備連絡済みに更新する処理
     */
    private void updateHubiStatus(Map<Id, DV_FubiTsuchi__c> newFubiTsuchiMap, Map<Id, DV_FubiTsuchi__c> oldFubiTsuchiMap) {

        List<DV_FubiTsuchi__c> targetFubiTsuchiList = new List<DV_FubiTsuchi__c>();
        List<Id> targetNinteiSeikyuIdList        = new List<Id>();
        // 不備ステータスを「不備連絡済み」に更新する対象の不備通知を取得
        for(DV_FubiTsuchi__c newFubiTsuchi :newFubiTsuchiMap.values()) {
            if(newFubiTsuchi.IsNinteiSeikyuPageKoukai__c
            && ( oldFubiTsuchiMap == null
              || !oldFubiTsuchiMap.get(newFubiTsuchi.Id).IsNinteiSeikyuPageKoukai__c)) {
                targetFubiTsuchiList.add(newFubiTsuchi);
            }
        }

        // 不備通知が認定請求に紐付いているか対象児童に紐付いているかを確認
        Set<Id> targetNinteiSeikyuIdSet = new Set<Id>();
        Set<Id> targetTaishoJidoIdSet   = new Set<Id>();
        for(DV_FubiTsuchi__c targetFubiTsuchi :targetFubiTsuchiList) {
            if(String.isNotBlank(targetFubiTsuchi.NinteiSeikyu__c)) {
                targetNinteiSeikyuIdSet.add(targetFubiTsuchi.NinteiSeikyu__c);
            }
            if(String.isNotBlank(targetFubiTsuchi.TaishoJido__c)) {
                targetTaishoJidoIdSet.add(targetFubiTsuchi.TaishoJido__c);
            }
        }

        // 更新する請求者、対象児童を取得し値を設定する
        List<DV_Seikyusha__c> updateSeikyushaList   = new List<DV_Seikyusha__c>();
        List<DV_TaishoJido__c> updateTaishoJidoList = new List<DV_TaishoJido__c>();
        Map<Id, DV_Seikyusha__c> seikyushaMap   = getSeikyushaMap(targetNinteiSeikyuIdSet);
        Map<Id, DV_TaishoJido__c> taishoJidoMap = getTaishoJidoMap(targetTaishoJidoIdSet);
        for(DV_Seikyusha__c seikyusha :seikyushaMap.values()) {
            seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
            updateSeikyushaList.add(seikyusha);
        }
        for(DV_TaishoJido__c taishoJido :taishoJidoMap.values()) {
            taishoJido.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
            updateTaishoJidoList.add(taishoJido);
        }

        Savepoint sp = Database.setSavepoint();
        try{
            // 請求者を更新
            if(updateSeikyushaList.size() > 0) {
                update updateSeikyushaList;
            }

            // 対象児童を更新
            if(updateTaishoJidoList.size() > 0) {
                update updateTaishoJidoList;
            }
        }catch(Exception e){
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }

    /**
     * 不備通知が紐付く認定請求に関連する請求者を取得
     * Map<認定請求のID,請求者レコード>
     */
    private Map<Id, DV_Seikyusha__c> getSeikyushaMap(Set<Id> ninteiSeikyuIdSet) {

        List<DV_NinteiSeikyu__c> targetNinteiSeikyuList = [SELECT Id,
                                                                  Seikyusya__c
                                                             FROM DV_NinteiSeikyu__c
                                                            WHERE Id IN :ninteiSeikyuIdSet];
        Map<Id, Id> targetNinteiSeikyuIdMap = new Map<Id, Id>();
        Set<Id> targetSeikyushaIdSet        = new Set<Id>();
        for(DV_NinteiSeikyu__c ninteiSeikyu :targetNinteiSeikyuList) {
            targetNinteiSeikyuIdMap.put(ninteiSeikyu.Id, ninteiSeikyu.Seikyusya__c);
            targetSeikyushaIdSet.add(ninteiSeikyu.Seikyusya__c);
        }

        List<DV_Seikyusha__c> targetSeikyushaList = [SELECT Id,
                                                            HubiStatus__c
                                                       FROM DV_Seikyusha__c
                                                      WHERE Id IN :targetSeikyushaIdSet];
        Map<Id, DV_Seikyusha__c> seikyushaMap       = new Map<Id, DV_Seikyusha__c>();
        for(DV_Seikyusha__c seikyusha :targetSeikyushaList) {
            seikyushaMap.put(seikyusha.Id, seikyusha);
        }
        
        Map<Id, DV_Seikyusha__c> returnSeikyushaMap = new Map<Id, DV_Seikyusha__c>();
        for(DV_NinteiSeikyu__c ninteiSeikyu :targetNinteiSeikyuList) {
            returnSeikyushaMap.put(ninteiSeikyu.Id, seikyushaMap.get(targetNinteiSeikyuIdMap.get(ninteiSeikyu.Id)));
        }

        return returnSeikyushaMap;
    }

    /**
     * 不備通知が紐付く対象児童を取得
     */
    private Map<Id, DV_TaishoJido__c> getTaishoJidoMap(Set<Id> taishoJidoIdSet) {

        List<DV_TaishoJido__c> targetTaishoJidoList = [SELECT Id,
                                                              HubiStatus__c
                                                         FROM DV_TaishoJido__c
                                                        WHERE Id IN :taishoJidoIdSet];
        Map<Id, DV_TaishoJido__c> returnTaishoJidoMap = new Map<Id, DV_TaishoJido__c>(targetTaishoJidoList);
        return returnTaishoJidoMap;
    }
}