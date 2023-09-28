public with sharing class SfFurikomiTriggerHandler {

    private final String FURIKOMI_STATUS_STR_SHISHUTSUKANRYO = '支出完了';
    private final Set<String> FURIKOMI_STATUS_STR_ERROR_SET = new Set<String>{'口座照会フォーマット変換エラー', '口座照会エラー', '支出エラー'};

    private final String SHISHUTSU_JYOKYO_STR_SUBETEKANRYO = '全て完了';
    private final String SHISHUTSU_JYOKYO_STR_ICHIBUKANRYO = '一部完了';

    private final String HUBI_STATUS_STR_MIRENRAKU = '不備未連絡';

    Savepoint sp;

    public SfFurikomiTriggerHandler() {

    }

    public void afterUpdate(Map<Id, Furikomi__c> newFurikomiMap, Map<Id, Furikomi__c> oldFurikomiMap) {

        sp = Database.setSavepoint();

        // 関連する振込の振込ステータスを確認し認定請求の支出状況を更新
        updateNinteiSeikyuShishutsuJokyo(newFurikomiMap, oldFurikomiMap);

        // 関連する振込の振込ステータスを確認し認定請求（DV被害者用）の支出状況を更新
        updateNinteiSeikyuShishutsuJokyoDV(newFurikomiMap, oldFurikomiMap);


        // 振込ステータスに口座照会フォーマット変換エラー、口座照会エラーまたは支出エラーが入ったら対象児童の不備ステータスを「不備未連絡」に更新する
        updateJidoHubiMirenraku(newFurikomiMap, oldFurikomiMap);

        // 振込ステータスに口座照会フォーマット変換エラー、口座照会エラーまたは支出エラーが入ったら対象児童（DV被害者用）の不備ステータスを「不備未連絡」に更新する
        updateJidoHubiMirenrakuDV(newFurikomiMap, oldFurikomiMap);
    }

    /**
     * 対象の認定請求に関連するすべての振込の振込ステータスにこの値が入ったら認定請求の支出状況を「全て完了」に、
     * 対象の認定請求に関連するいずれかの振込の振込ステータスにこの値が入ったら認定請求の支出状況を「一部完了」に更新する
     */
    private void updateNinteiSeikyuShishutsuJokyo(Map<Id, Furikomi__c> newFurikomiMap, Map<Id, Furikomi__c> oldFurikomiMap) {

        // 振込ステータスに「支出完了」が設定されたものを対象にする
        List<Furikomi__c> targetFurikomiList = new List<Furikomi__c>();
        Set<Id> furikomiIdSet                = new Set<Id>();
        for(Furikomi__c furikomi :newFurikomiMap.values()) {
            Furikomi__c oldFurikomi = oldFurikomiMap.get(furikomi.Id);
            if(String.isNotBlank(furikomi.FurikomiStatus__c) && furikomi.FurikomiStatus__c.equals(FURIKOMI_STATUS_STR_SHISHUTSUKANRYO)
            && (String.isBlank(oldFurikomi.FurikomiStatus__c) || !oldFurikomi.FurikomiStatus__c.equals(FURIKOMI_STATUS_STR_SHISHUTSUKANRYO))) {
                targetFurikomiList.add(furikomi);
                furikomiIdSet.add(furikomi.Id);
            }
        }

        // 振込に関連する対象児童を取得
        List<TaishoJido__c> relatedTaishoJidoList = [SELECT Id,
                                                            NinteiSeikyu__c,
                                                            FurikomiId__c
                                                       FROM TaishoJido__c
                                                      WHERE FurikomiId__c IN :furikomiIdSet];
        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        for(TaishoJido__c jido :relatedTaishoJidoList) {
            ninteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
        }

        // 取得した認定請求IDの認定請求に関連する対象児童を取得
        // 対象児童が紐付く振込の振込ステータスを取得
        List<TaishoJido__c> targetTaishoJidoList = [SELECT Id,
                                                           NinteiSeikyu__c,
                                                           FurikomiId__r.FurikomiStatus__c
                                                      FROM TaishoJido__c
                                                     WHERE NinteiSeikyu__c IN :ninteiSeikyuIdSet];
        Map<Id, List<TaishoJido__c>> targetTaishoJidoMap = new Map<Id, List<TaishoJido__c>>();
        for(TaishoJido__c jido :targetTaishoJidoList) {
            if(!targetTaishoJidoMap.containsKey(jido.NinteiSeikyu__c)) {
                targetTaishoJidoMap.put(jido.NinteiSeikyu__c, new List<TaishoJido__c>());
            }
            targetTaishoJidoMap.get(jido.NinteiSeikyu__c).add(jido);
        }

        // 更新対象の認定請求を取得
        List<NinteiSeikyu__c> updateNinteiSeikyu = [SELECT Id,
                                                           ShishutsuJyokyo__c
                                                      FROM NinteiSeikyu__c
                                                     WHERE Id IN :ninteiSeikyuIdSet];
        for(NinteiSeikyu__c ninteiSeikyu :updateNinteiSeikyu) {
            List<TaishoJido__c> jidoList = targetTaishoJidoMap.get(ninteiSeikyu.Id);

            Boolean isSubeteKanryo = true;
            for(TaishoJido__c jido :jidoList) {
                if(String.isBlank(jido.FurikomiId__r.FurikomiStatus__c) || !jido.FurikomiId__r.FurikomiStatus__c.equals(FURIKOMI_STATUS_STR_SHISHUTSUKANRYO)) {
                    isSubeteKanryo = false;
                }
            }

            if(isSubeteKanryo) {
                ninteiSeikyu.ShishutsuJyokyo__c = SHISHUTSU_JYOKYO_STR_SUBETEKANRYO;
            } else {
                ninteiSeikyu.ShishutsuJyokyo__c = SHISHUTSU_JYOKYO_STR_ICHIBUKANRYO;
            }
        }

        try{
            // 認定請求を更新
            if(updateNinteiSeikyu.size() > 0) {
                update updateNinteiSeikyu;
            }

        }catch(Exception e){
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }

    /**
     * 対象の認定請求に関連するすべての振込の振込ステータスにこの値が入ったら認定請求（DV被害者用）の支出状況を「全て完了」に、
     * 対象の認定請求に関連するいずれかの振込の振込ステータスにこの値が入ったら認定請求（DV被害者用）の支出状況を「一部完了」に更新する
     */
    private void updateNinteiSeikyuShishutsuJokyoDV(Map<Id, Furikomi__c> newFurikomiMap, Map<Id, Furikomi__c> oldFurikomiMap) {

        // 振込ステータスに「支出完了」が設定されたものを対象にする
        List<Furikomi__c> targetFurikomiList = new List<Furikomi__c>();
        Set<Id> furikomiIdSet                = new Set<Id>();
        for(Furikomi__c furikomi :newFurikomiMap.values()) {
            Furikomi__c oldFurikomi = oldFurikomiMap.get(furikomi.Id);
            if(String.isNotBlank(furikomi.FurikomiStatus__c) && furikomi.FurikomiStatus__c.equals(FURIKOMI_STATUS_STR_SHISHUTSUKANRYO)
            && (String.isBlank(oldFurikomi.FurikomiStatus__c) || !oldFurikomi.FurikomiStatus__c.equals(FURIKOMI_STATUS_STR_SHISHUTSUKANRYO))) {
                targetFurikomiList.add(furikomi);
                furikomiIdSet.add(furikomi.Id);
            }
        }

        // 振込に関連する対象児童（DV被害者用）を取得
        List<DV_TaishoJido__c> relatedTaishoJidoList = [SELECT Id,
                                                               NinteiSeikyu__c,
                                                               FurikomiId__c
                                                          FROM DV_TaishoJido__c
                                                         WHERE FurikomiId__c IN :furikomiIdSet];
        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        for(DV_TaishoJido__c jido :relatedTaishoJidoList) {
            ninteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
        }

        // 取得した認定請求IDの認定請求に関連する対象児童（DV被害者用）を取得
        // 対象児童（DV被害者用）が紐付く振込の振込ステータスを取得
        List<DV_TaishoJido__c> targetTaishoJidoList = [SELECT Id,
                                                              NinteiSeikyu__c,
                                                              FurikomiId__r.FurikomiStatus__c
                                                         FROM DV_TaishoJido__c
                                                        WHERE NinteiSeikyu__c IN :ninteiSeikyuIdSet];
        Map<Id, List<DV_TaishoJido__c>> targetTaishoJidoMap = new Map<Id, List<DV_TaishoJido__c>>();
        for(DV_TaishoJido__c jido :targetTaishoJidoList) {
            if(!targetTaishoJidoMap.containsKey(jido.NinteiSeikyu__c)) {
                targetTaishoJidoMap.put(jido.NinteiSeikyu__c, new List<DV_TaishoJido__c>());
            }
            targetTaishoJidoMap.get(jido.NinteiSeikyu__c).add(jido);
        }

        // 更新対象の認定請求（DV被害者用）を取得
        List<DV_NinteiSeikyu__c> updateNinteiSeikyu = [SELECT Id,
                                                              ShishutsuJyokyo__c
                                                         FROM DV_NinteiSeikyu__c
                                                        WHERE Id IN :ninteiSeikyuIdSet];
        for(DV_NinteiSeikyu__c ninteiSeikyu :updateNinteiSeikyu) {
            List<DV_TaishoJido__c> jidoList = targetTaishoJidoMap.get(ninteiSeikyu.Id);

            Boolean isSubeteKanryo = true;
            for(DV_TaishoJido__c jido :jidoList) {
                if(String.isBlank(jido.FurikomiId__r.FurikomiStatus__c) || !jido.FurikomiId__r.FurikomiStatus__c.equals(FURIKOMI_STATUS_STR_SHISHUTSUKANRYO)) {
                    isSubeteKanryo = false;
                }
            }

            if(isSubeteKanryo) {
                ninteiSeikyu.ShishutsuJyokyo__c = SHISHUTSU_JYOKYO_STR_SUBETEKANRYO;
            } else {
                ninteiSeikyu.ShishutsuJyokyo__c = SHISHUTSU_JYOKYO_STR_ICHIBUKANRYO;
            }
        }

        try{
            // 認定請求（DV被害者用）を更新
            if(updateNinteiSeikyu.size() > 0) {
                update updateNinteiSeikyu;
            }

        }catch(Exception e){
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }

    /**
     * 振込ステータスに口座照会フォーマット変換エラー、口座照会エラーまたは支出エラーが入ったら対象児童の不備ステータスを「不備未連絡」に更新する
     */
    private void updateJidoHubiMirenraku(Map<Id, Furikomi__c> newFurikomiMap, Map<Id, Furikomi__c> oldFurikomiMap) {

        // 振込ステータスに口座紹介エラーまたは支出エラーが設定されたものを対象にする
        List<Furikomi__c> targetFurikomiList = new List<Furikomi__c>();
        Set<Id> furikomiIdSet                = new Set<Id>();
        for(Furikomi__c furikomi :newFurikomiMap.values()) {
            Furikomi__c oldFurikomi = oldFurikomiMap.get(furikomi.Id);
            if(FURIKOMI_STATUS_STR_ERROR_SET.contains(furikomi.FurikomiStatus__c)
            && !furikomi.FurikomiStatus__c.equals(oldFurikomi.FurikomiStatus__c)) {
                targetFurikomiList.add(furikomi);
                furikomiIdSet.add(furikomi.Id);
            }
        }

        // 関連の対象児童を取得
        List<TaishoJido__c> jidoList = [SELECT Id,
                                               HubiStatus__c
                                          FROM TaishoJido__c
                                         WHERE FurikomiId__c IN :furikomiIdSet];
        for(TaishoJido__c jido :jidoList) {
            jido.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        }

        try{
            // 認定請求を更新
            if(jidoList.size() > 0) {
                update jidoList;
            }

        }catch(Exception e){
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }

    /**
     * 振込ステータスに口座照会フォーマット変換エラー、口座照会エラーまたは支出エラーが入ったら対象児童（DV被害者用）の不備ステータスを「不備未連絡」に更新する
     */
    private void updateJidoHubiMirenrakuDV(Map<Id, Furikomi__c> newFurikomiMap, Map<Id, Furikomi__c> oldFurikomiMap) {

        // 振込ステータスに口座紹介エラーまたは支出エラーが設定されたものを対象にする
        List<Furikomi__c> targetFurikomiList = new List<Furikomi__c>();
        Set<Id> furikomiIdSet                = new Set<Id>();
        for(Furikomi__c furikomi :newFurikomiMap.values()) {
            Furikomi__c oldFurikomi = oldFurikomiMap.get(furikomi.Id);
            if(FURIKOMI_STATUS_STR_ERROR_SET.contains(furikomi.FurikomiStatus__c)
            && !furikomi.FurikomiStatus__c.equals(oldFurikomi.FurikomiStatus__c)) {
                targetFurikomiList.add(furikomi);
                furikomiIdSet.add(furikomi.Id);
            }
        }

        // 関連の対象児童を取得
        List<DV_TaishoJido__c> jidoList = [SELECT Id,
                                                  HubiStatus__c
                                             FROM DV_TaishoJido__c
                                            WHERE FurikomiId__c IN :furikomiIdSet];
        for(DV_TaishoJido__c jido :jidoList) {
            jido.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        }

        try{
            // 認定請求を更新
            if(jidoList.size() > 0) {
                update jidoList;
            }

        }catch(Exception e){
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }
}