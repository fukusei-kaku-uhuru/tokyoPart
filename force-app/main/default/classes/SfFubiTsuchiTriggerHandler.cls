public with sharing class SfFubiTsuchiTriggerHandler {

    private final String HUBI_STATUS_STR_RENRAKUZUMI = '不備連絡済み';

    public SfFubiTsuchiTriggerHandler() {

    }

    public void afterInsert(Map<Id, FubiTsuchi__c> newFubiTsuchiMap) {

        // 以下条件で不備ステータスを「不備連絡済み」に更新する処理
        // 郵送の場合は局出し年月日に値が設定されたとき
        // webの場合は認定請求ページに公開がtrueに設定されたとき
        // 更新する不備ステータスは、不備通知が認定請求に紐づいていれば対象者の不備STを、対象児童に紐づいていれば対象児童のSTを更新する
        updateHubiStatus(newFubiTsuchiMap, null);
    }

    public void afterUpdate(Map<Id, FubiTsuchi__c> newFubiTsuchiMap, Map<Id, FubiTsuchi__c> oldFubiTsuchiMap) {

        // 以下条件で不備ステータスを「不備連絡済み」に更新する処理
        // 郵送の場合は局出し年月日に値が設定されたとき
        // webの場合は認定請求ページに公開がtrueに設定されたとき
        // 更新する不備ステータスは、不備通知が認定請求に紐づいていれば対象者の不備STを、対象児童に紐づいていれば対象児童のSTを更新する
        updateHubiStatus(newFubiTsuchiMap, oldFubiTsuchiMap);
    }

    /**
     * 不備ステータスを不備連絡済みに更新する処理
     */
    private void updateHubiStatus(Map<Id, FubiTsuchi__c> newFubiTsuchiMap, Map<Id, FubiTsuchi__c> oldFubiTsuchiMap) {

        List<FubiTsuchi__c> targetFubiTsuchiList = new List<FubiTsuchi__c>();
        List<Id> targetNinteiSeikyuIdList        = new List<Id>();
        // 不備ステータスを「不備連絡済み」に更新する対象の不備通知を取得
        for(FubiTsuchi__c newFubiTsuchi :newFubiTsuchiMap.values()) {
            
            // 局出し年月日に値が設定された場合、更新対象とする
            if(newFubiTsuchi.KyokudashiNengappiDate__c != null
            && ( oldFubiTsuchiMap == null
              || oldFubiTsuchiMap.get(newFubiTsuchi.Id).KyokudashiNengappiDate__c == null)) {
                targetFubiTsuchiList.add(newFubiTsuchi);
            // 認定請求ページに公開がtrueに設定された場合、更新対象とする
            } else if(newFubiTsuchi.IsNinteiSeikyuPageKoukai__c
            && ( oldFubiTsuchiMap == null
              || !oldFubiTsuchiMap.get(newFubiTsuchi.Id).IsNinteiSeikyuPageKoukai__c)) {
                targetFubiTsuchiList.add(newFubiTsuchi);
            }
        }

        // 不備通知が認定請求に紐付いているか対象児童に紐付いているかを確認
        Set<Id> targetNinteiSeikyuIdSet = new Set<Id>();
        Set<Id> targetTaishoJidoIdSet   = new Set<Id>();
        for(FubiTsuchi__c targetFubiTsuchi :targetFubiTsuchiList) {
            if(String.isNotBlank(targetFubiTsuchi.NinteiSeikyu__c)) {
                targetNinteiSeikyuIdSet.add(targetFubiTsuchi.NinteiSeikyu__c);
            }
            if(String.isNotBlank(targetFubiTsuchi.TaishoJido__c)) {
                targetTaishoJidoIdSet.add(targetFubiTsuchi.TaishoJido__c);
            }
        }

        // 更新する請求者、対象児童を取得し値を設定する
        List<Seikyusha__c> updateSeikyushaList   = new List<Seikyusha__c>();
        List<TaishoJido__c> updateTaishoJidoList = new List<TaishoJido__c>();
        Map<Id, Seikyusha__c> seikyushaMap   = getSeikyushaMap(targetNinteiSeikyuIdSet);
        Map<Id, TaishoJido__c> taishoJidoMap = getTaishoJidoMap(targetTaishoJidoIdSet);
        for(Seikyusha__c seikyusha :seikyushaMap.values()) {
            seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
            updateSeikyushaList.add(seikyusha);
        }
        for(TaishoJido__c taishoJido :taishoJidoMap.values()) {
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
    private Map<Id, Seikyusha__c> getSeikyushaMap(Set<Id> ninteiSeikyuIdSet) {

        List<NinteiSeikyu__c> targetNinteiSeikyuList = [SELECT Id,
                                                               Seikyusha__c
                                                          FROM NinteiSeikyu__c
                                                         WHERE Id IN :ninteiSeikyuIdSet];
        Map<Id, Id> targetNinteiSeikyuIdMap = new Map<Id, Id>();
        Set<Id> targetSeikyushaIdSet        = new Set<Id>();
        for(NinteiSeikyu__c ninteiSeikyu :targetNinteiSeikyuList) {
            targetNinteiSeikyuIdMap.put(ninteiSeikyu.Id, ninteiSeikyu.Seikyusha__c);
            targetSeikyushaIdSet.add(ninteiSeikyu.Seikyusha__c);
        }

        List<Seikyusha__c> targetSeikyushaList = [SELECT Id,
                                                         HubiStatus__c
                                                    FROM Seikyusha__c
                                                   WHERE Id IN :targetSeikyushaIdSet];
        Map<Id, Seikyusha__c> seikyushaMap       = new Map<Id, Seikyusha__c>();
        for(Seikyusha__c seikyusha :targetSeikyushaList) {
            seikyushaMap.put(seikyusha.Id, seikyusha);
        }
        
        Map<Id, Seikyusha__c> returnSeikyushaMap = new Map<Id, Seikyusha__c>();
        for(NinteiSeikyu__c ninteiSeikyu :targetNinteiSeikyuList) {
            returnSeikyushaMap.put(ninteiSeikyu.Id, seikyushaMap.get(targetNinteiSeikyuIdMap.get(ninteiSeikyu.Id)));
        }

        return returnSeikyushaMap;
    }

    /**
     * 不備通知が紐付く対象児童を取得
     */
    private Map<Id, TaishoJido__c> getTaishoJidoMap(Set<Id> taishoJidoIdSet) {

        List<TaishoJido__c> targetTaishoJidoList = [SELECT Id,
                                                           HubiStatus__c
                                                      FROM TaishoJido__c
                                                     WHERE Id IN :taishoJidoIdSet];
        Map<Id, TaishoJido__c> returnTaishoJidoMap = new Map<Id, TaishoJido__c>(targetTaishoJidoList);
        return returnTaishoJidoMap;
    }
}