public with sharing class SfDVTaishoJidoTriggerHandler {
    
    public final String STATUS_STR_MISHINSEI        = '未申請';
    public final String STATUS_STR_SHINSAMACHI_01   = '1次審査待ち';
    public final String STATUS_STR_SHINSAMACHI_02   = '2次審査待ち';
    public final String STATUS_STR_UNMATCH          = 'アンマッチ判定';
    public final String STATUS_STR_SHINSAKANRYO     = '審査完了';

    public final String SHINSA_STATUS_STR_OK        = 'OK';
    public final String SHINSA_STATUS_STR_NG        = 'NG';
    public final String SHINSA_STATUS_STR_FUBI      = '不備';
    public final String FUBI_STATUS_STR_MIRENRAKU   = '不備未連絡';
    public final String FUBI_STATUS_STR_RENRAKUZUMI = '不備連絡済み';
    public final String SHINSA_JYOKYO_STR_SUBETE    = '全て完了';
    public final String SHINSA_JYOKYO_STR_ICHIBU    = '一部完了';
    public final String SHONIN_JYOKYO_STR_SUBETE    = '全て完了';
    public final String SHONIN_JYOKYO_STR_ICHIBU    = '一部完了';

    public final String KAKUNIN_HOHO_KENMEN = '券面アップロード';

    public final String SHINSA_KEKKA_STR_OK         = 'OK';

    public final Set<String> LOCK_TARGET_ESCALATION_STATUS = new Set<String>{'事務局内確認中', 'エスカレーション中(事務局内)', 'エスカレーション中(都庁様)'};
    public final Set<String> LOCK_TARGET_CHOSA_STATUS      = new Set<String>{'調査中'};

    public final Set<String> SHONIN_KANRYO_SHONIN_KEKKA_STR = new Set<String>{'認定', '不認定'};

    public Set<Id> updateNinteiSeikyuIdSet; // 更新する認定請求のIDを格納するSet

    public Set<Id> targetFubiTsuchiTaishoJidoIdSet; // 関連する不備通知を更新するかどうか確認する対象の対象児童のIdを格納するSet

    public SfDVTaishoJidoTriggerHandler() {

    }

    public void beforeInsert(List<DV_TaishoJido__c> newTaishoJidoList) {
    }

    public void afterInsert(List<DV_TaishoJido__c> newTaishoJidoList) {
    }

    public void beforeUpdate(Map<Id, DV_TaishoJido__c> newTaishoJidoMap, Map<Id, DV_TaishoJido__c> oldTaishoJidoMap) {
        
        // 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
        // 審査結果(0次)および審査結果(最終)に「不備」が入っていれば不備ステータスを「不備未連絡」にする
        updateShinsaKekkaSaishu(newTaishoJidoMap, oldTaishoJidoMap);
        
        // 振込レコードを作成
        SfDVFurikomiUtil.createFurikomi(newTaishoJidoMap, oldTaishoJidoMap);
    }

    public void afterUpdate(Map<Id, DV_TaishoJido__c> newTaishoJidoMap, Map<Id, DV_TaishoJido__c> oldTaishoJidoMap) {

        // 更新する認定請求のIDを格納するSetを初期化
        updateNinteiSeikyuIdSet = new Set<Id>();

        targetFubiTsuchiTaishoJidoIdSet = new Set<Id>();
        
        // 関連する認定請求を格納するMap
        Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap = getRelatedNinteiSeikyuMap(newTaishoJidoMap);

        // 関連する認定請求に紐付く対象児童を格納するMap
        Map<Id, List<DV_TaishoJido__c>> relatedTaishoJidoMap = getRelatedTaishoJidoMap(newTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
        relatedNinteiSeikyuMap = setNinteiSeikyuFubiRenrakuzumi(relatedNinteiSeikyuMap, newTaishoJidoMap, oldTaishoJidoMap, relatedTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
        Map<Id, List<DV_FubiTsuchi__c>> updateFubiTsuchiMap = setSaishinseiFubiTsuchi(targetFubiTsuchiTaishoJidoIdSet, relatedNinteiSeikyuMap, newTaishoJidoMap, relatedTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
        List<DV_Seikyusha__c> updateSeikyushaList = setClearKakuninHohoSeikyusha(updateFubiTsuchiMap, relatedNinteiSeikyuMap);

        // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」、いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
        relatedNinteiSeikyuMap = setStatusShinsaKanryo(relatedNinteiSeikyuMap, newTaishoJidoMap, oldTaishoJidoMap, relatedTaishoJidoMap);

        // 同じ認定請求の対象児童の承認結果が全て入っている場合、認定請求の承認状況を「すべて完了」にする
        // 同じ認定請求の対象児童のいずれかに承認結果が入っている場合、認定請求の承認状況を「一部完了」にする
        relatedNinteiSeikyuMap = setShoninJyokyoSubeteKanryo(relatedNinteiSeikyuMap, newTaishoJidoMap, oldTaishoJidoMap, relatedTaishoJidoMap);

        // 認定請求を更新
        updateNinteiSeikyu(relatedNinteiSeikyuMap);

        // 不備通知を更新
        updateFubiTsuchi(updateFubiTsuchiMap);

        // 請求者を更新
        updateSeikyusha(updateSeikyushaList);
    }

    /**
     * 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
     */
    private void updateShinsaKekkaSaishu(Map<Id, DV_TaishoJido__c> newTaishoJidoMap, Map<Id, DV_TaishoJido__c> oldTaishoJidoMap) {

        for(Id jidoId :newTaishoJidoMap.keySet()) {
            // 審査結果(2次)に値が入ったときのみ処理を実行
            if(String.isBlank(newTaishoJidoMap.get(jidoId).ShinsaKekka_02__c)
            || newTaishoJidoMap.get(jidoId).ShinsaKekka_02__c.equals(oldTaishoJidoMap.get(jidoId).ShinsaKekka_02__c)) {
                continue;
            }

            // 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
            if(String.isNotBlank(newTaishoJidoMap.get(jidoId).ShinsaKekka_01__c)
            && String.isNotBlank(newTaishoJidoMap.get(jidoId).ShinsaKekka_02__c)
            && newTaishoJidoMap.get(jidoId).ShinsaKekka_01__c.equals(newTaishoJidoMap.get(jidoId).ShinsaKekka_02__c)) {
               newTaishoJidoMap.get(jidoId).ShinsaKekkaSaishu__c = newTaishoJidoMap.get(jidoId).ShinsaKekka_01__c;
            }            
        }

        for(Id jidoId :newTaishoJidoMap.keySet()) {
            // 審査結果(0次)や審査結果(最終)に不備が入った場合不備ステータスを不備未連絡に更新
            if((SHINSA_STATUS_STR_FUBI.equals(newTaishoJidoMap.get(jidoId).ShinsaKekka_00__c)
                && !SHINSA_STATUS_STR_FUBI.equals(oldTaishoJidoMap.get(jidoId).ShinsaKekka_00__c))
                || (SHINSA_STATUS_STR_FUBI.equals(newTaishoJidoMap.get(jidoId).ShinsaKekkaSaishu__c)
                && !SHINSA_STATUS_STR_FUBI.equals(oldTaishoJidoMap.get(jidoId).ShinsaKekkaSaishu__c))) {
                    newTaishoJidoMap.get(jidoId).HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU;
            }
        }
    }

    /**
     * 関連する認定請求を格納するMapを取得
     */
    private Map<Id, DV_NinteiSeikyu__c> getRelatedNinteiSeikyuMap(Map<Id, DV_TaishoJido__c> newTaishoJidoMap) {

        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        for(DV_TaishoJido__c jido :newTaishoJidoMap.values()) {
            ninteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
        }
        List<DV_NinteiSeikyu__c> relatedNinteiSeikyuList = [SELECT Id,
                                                                   Seikyusya__c,
                                                                   ShinsaStatus__c,
                                                                   ShinsaJyokyo__c,
                                                                   Seikyusya__r.ShinsaKekka_00__c,
                                                                   Seikyusya__r.ShinsaKekka_01__c,
                                                                   Seikyusya__r.ShinsaKekkaSaishu__c,
                                                                   Seikyusya__r.HubiStatus__c,
                                                                   Seikyusya__r.EscalationStatus__c,
                                                                   Seikyusya__r.ChosaStatus__c,
                                                                   Seikyusya__r.HonninKakuninHoho__c
                                                              FROM DV_NinteiSeikyu__c
                                                             WHERE Id IN :ninteiSeikyuIdSet];
        Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap = new Map<Id, DV_NinteiSeikyu__c>(relatedNinteiSeikyuList);

        return relatedNinteiSeikyuMap;
    }

    /**
     * 関連する認定請求に紐付く対象児童を格納するMap
     */
    private Map<Id, List<DV_TaishoJido__c>> getRelatedTaishoJidoMap(Map<Id, DV_TaishoJido__c> newTaishoJidoMap) {

        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        Map<Id, Set<Id>> taishoJidoIdMap = new Map<Id, Set<Id>>(); // 認定請求IDから対象児童のIDのSetを取得するMap
        for(DV_TaishoJido__c jido :newTaishoJidoMap.values()) {
            ninteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
            if(!taishoJidoIdMap.containsKey(jido.NinteiSeikyu__c)) {
                taishoJidoIdMap.put(jido.NinteiSeikyu__c, new Set<Id>());
            }
            taishoJidoIdMap.get(jido.NinteiSeikyu__c).add(jido.Id);
        }
        List<DV_TaishoJido__c> relatedTaishoJidoList = [SELECT Id,
                                                               NinteiSeikyu__c,
                                                               ShinsaKekka_00__c,
                                                               ShinsaKekka_01__c,
                                                               ShinsaKekkaSaishu__c,
                                                               HubiStatus__c,
                                                               EscalationStatus__c,
                                                               ChosaStatus__c,
                                                               ShoninKekka__c
                                                          FROM DV_TaishoJido__c
                                                         WHERE NinteiSeikyu__c IN :ninteiSeikyuIdSet];
        Map<Id, List<DV_TaishoJido__c>> relatedTaishoJidoMap = new Map<Id, List<DV_TaishoJido__c>>();
        for(DV_TaishoJido__c jido :relatedTaishoJidoList) {
            if(!taishoJidoIdMap.containsKey(jido.NinteiSeikyu__c)) {
                continue;
            }

            Set<Id> targetJidoIdSet = taishoJidoIdMap.get(jido.NinteiSeikyu__c);
            for(Id targetJidoId :targetJidoIdSet) {

                if(!relatedTaishoJidoMap.containsKey(targetJidoId)) {
                    relatedTaishoJidoMap.put(targetJidoId, new List<DV_TaishoJido__c>());
                }

                // 処理を実行している対象児童自身はrelatedTaishoJidoMapに入れない
                if(targetJidoId == jido.Id) {
                    continue;
                }

                relatedTaishoJidoMap.get(targetJidoId).add(jido);
            }
        }

        return relatedTaishoJidoMap;
    }

    /**
     * 不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
     */
    private Map<Id, DV_NinteiSeikyu__c> setNinteiSeikyuFubiRenrakuzumi(Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                       Map<Id, DV_TaishoJido__c> newTaishoJidoMap,
                                                                       Map<Id, DV_TaishoJido__c> oldTaishoJidoMap,
                                                                       Map<Id, List<DV_TaishoJido__c>> relatedTaishoJidoMap) {

        for(DV_TaishoJido__c jido :newTaishoJidoMap.values()) {
            if( String.isNotBlank(jido.HubiStatus__c)
             && jido.HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI)
             && ( String.isBlank(oldTaishoJidoMap.get(jido.Id).HubiStatus__c)
               || !oldTaishoJidoMap.get(jido.Id).HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI))
            ) {
                // 関連の請求者で不備ステータスに「不備未連絡」が入っていたら処理を行わない
                if(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) != null) {
                    if(String.isNotBlank(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).Seikyusya__r.HubiStatus__c)
                    && relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).Seikyusya__r.HubiStatus__c.equals(FUBI_STATUS_STR_MIRENRAKU)) {
                        continue;
                    }
                }

                // 関連の対象児童で不備ステータスに「不備未連絡」が入っていたら処理を行わない
                Boolean hasMirenrakuFubi = false;
                List<DV_TaishoJido__c> relatedTaishoJidoList = relatedTaishoJidoMap.get(jido.Id);
                for(DV_TaishoJido__c taishoJido :relatedTaishoJidoList) {
                    if(String.isNotBlank(taishoJido.HubiStatus__c) && taishoJido.HubiStatus__c.equals(FUBI_STATUS_STR_MIRENRAKU)) {
                        hasMirenrakuFubi = true;
                    }
                }
                if(hasMirenrakuFubi) {
                    continue;
                }

                if(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) != null) {
                    relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).ShinsaStatus__c = STATUS_STR_MISHINSEI;
                    updateNinteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
                    targetFubiTsuchiTaishoJidoIdSet.add(jido.Id);
                }
            }
        }

        return relatedNinteiSeikyuMap;
    }

    /**
     * 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
     */
    private Map<Id, List<DV_FubiTsuchi__c>> setSaishinseiFubiTsuchi(Set<Id> targetFubiTsuchiTaishoJidoIdSet,
                                                                    Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                    Map<Id, DV_TaishoJido__c> newTaishoJidoMap,
                                                                    Map<Id, List<DV_TaishoJido__c>> relatedTaishoJidoMap) {
                                                                    
        // 対象の不備通知を取得
        Set<Id> targetNinteiSeikyuIdSet = new Set<Id>();
        Set<Id> targetTaishoJidoIdSet   = new Set<Id>();
        for(Id taishoJidoId :targetFubiTsuchiTaishoJidoIdSet) {
            targetNinteiSeikyuIdSet.add(newTaishoJidoMap.get(taishoJidoId).NinteiSeikyu__c);
            targetTaishoJidoIdSet.add(taishoJidoId);
            if(relatedTaishoJidoMap.containsKey(taishoJidoId)) {
                for(DV_TaishoJido__c relatedJido :relatedTaishoJidoMap.get(taishoJidoId)) {
                    targetTaishoJidoIdSet.add(relatedJido.Id);
                }
            }
        }
        List<DV_FubiTsuchi__c> fubiTsuchiList = [SELECT Id,
                                                        NinteiSeikyu__c,
                                                        NinteiSeikyu__r.Seikyusya__c,
                                                        TaishoJido__c,
                                                        TaishoJido__r.NinteiSeikyu__r.Seikyusya__c,
                                                        IsSaishinseiRiyozumi__c,
                                                        HonninKakuninShoruiSaiteishutsu__c
                                                   FROM DV_FubiTsuchi__c
                                                  WHERE (
                                                            NinteiSeikyu__c IN :targetNinteiSeikyuIdSet
                                                         OR TaishoJido__c   IN :targetTaishoJidoIdSet
                                                        )
                                                    AND IsSaishinseiRiyozumi__c = false];
        Map<Id, List<DV_FubiTsuchi__c>> seikyushaIdFubiTsuchiMap = new Map<Id, List<DV_FubiTsuchi__c>>();
        for(DV_FubiTsuchi__c tsuchi :fubiTsuchiList) {
            // 更新する不備通知の値設定
            tsuchi.IsSaishinseiRiyozumi__c = true; // 再申請利用済みフラグをtrueに更新

            Id tsuchiSeikyushaId = null;
            if(tsuchi.NinteiSeikyu__r.Seikyusya__c != null) {
                tsuchiSeikyushaId = tsuchi.NinteiSeikyu__r.Seikyusya__c;
            } else if (tsuchi.TaishoJido__r.NinteiSeikyu__r.Seikyusya__c != null) {
                tsuchiSeikyushaId = tsuchi.TaishoJido__r.NinteiSeikyu__r.Seikyusya__c;
            }

            if(tsuchiSeikyushaId != null) {
                if(!seikyushaIdFubiTsuchiMap.containsKey(tsuchiSeikyushaId)) {
                    seikyushaIdFubiTsuchiMap.put(tsuchiSeikyushaId, new List<DV_FubiTsuchi__c>());
                }
                seikyushaIdFubiTsuchiMap.get(tsuchiSeikyushaId).add(tsuchi);
            }
        }

        return seikyushaIdFubiTsuchiMap;
    }

    /**
     * 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
     */
    private List<DV_Seikyusha__c> setClearKakuninHohoSeikyusha(Map<Id, List<DV_FubiTsuchi__c>> fubiTsuchiMap,
                                                               Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap) {

        Set<Id> updateSeikyushaIdSet              = new Set<Id>();
        List<DV_Seikyusha__c> updateSeikyushaList = new List<DV_Seikyusha__c>();

        Map<Id, DV_NinteiSeikyu__c> ninteiSeikyuSeikyushaIdMap = new Map<Id, DV_NinteiSeikyu__c>();
        for(DV_NinteiSeikyu__c ninteiSeikyu :relatedNinteiSeikyuMap.values()) {
            ninteiSeikyuSeikyushaIdMap.put(ninteiSeikyu.Seikyusya__c, ninteiSeikyu);
        }

        for(Id seikyushaId :fubiTsuchiMap.keySet()) {
            // 上記「再申請利用済みフラグ」をONにしたレコード（今回の審査ST戻しで利用した不備通知）の中に、
            // 新規項目「本人確認書類再提出」がONのレコードがあった場合、請求者objの「本人確認方法」が券面アップロードだったらクリアする
            for(DV_FubiTsuchi__c tsuchi :fubiTsuchiMap.get(seikyushaId)) {
                if(tsuchi.HonninKakuninShoruiSaiteishutsu__c
                && KAKUNIN_HOHO_KENMEN.equals(ninteiSeikyuSeikyushaIdMap.get(seikyushaId).Seikyusya__r.HonninKakuninHoho__c)) {
                    updateSeikyushaIdSet.add(seikyushaId);
                }
            }
        }
        for(Id seikyushaId :updateSeikyushaIdSet) {
            DV_Seikyusha__c record = new DV_Seikyusha__c();
            record.Id                   = seikyushaId;
            record.HonninKakuninHoho__c = '';

            updateSeikyushaList.add(record);
        }

        return updateSeikyushaList;
    }

    /**
     * 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」、いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
     */
    private Map<Id, DV_NinteiSeikyu__c> setStatusShinsaKanryo(Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                              Map<Id, DV_TaishoJido__c> newTaishoJidoMap,
                                                              Map<Id, DV_TaishoJido__c> oldTaishoJidoMap,
                                                              Map<Id, List<DV_TaishoJido__c>> relatedTaishoJidoMap) {
        
        for(DV_TaishoJido__c jido :newTaishoJidoMap.values()) {

            if(!relatedNinteiSeikyuMap.containsKey(jido.NinteiSeikyu__c) || relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) == null) {
                continue;
            }

            // 処理対象の対象児童の審査結果(最終)が入った時に処理を実行
            Boolean shinsaSaishu = String.isNotBlank(jido.ShinsaKekkaSaishu__c)
                                && jido.ShinsaKekkaSaishu__c != oldTaishoJidoMap.get(jido.Id).ShinsaKekkaSaishu__c;
            if(shinsaSaishu) {
                Boolean ShinsaKanryo = true;

                // 関連する請求者についてチェック
                if(String.isBlank(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).Seikyusya__r.ShinsaKekkaSaishu__c)) {
                    ShinsaKanryo = false;
                }

                // 関連する認定請求に紐付く対象児童についてチェック
                if(relatedTaishoJidoMap.containsKey(jido.Id) && relatedTaishoJidoMap.get(jido.Id).size() > 0) {
                    for(DV_TaishoJido__c relatedJido :relatedTaishoJidoMap.get(jido.Id)) {
                        if(String.isBlank(relatedJido.ShinsaKekkaSaishu__c)) {
                            ShinsaKanryo = false;
                        }
                    }
                }

                // 認定請求に設定する値を決める
                if(ShinsaKanryo) {
                    // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」にする
                    relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).ShinsaJyokyo__c = SHINSA_JYOKYO_STR_SUBETE;
                } else {
                    // 認定請求に紐付く請求者・対象児童のいずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
                    relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).ShinsaJyokyo__c = SHINSA_JYOKYO_STR_ICHIBU;
                }
                updateNinteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
            }
        }

        return relatedNinteiSeikyuMap;
    }

    /**
     * 同じ認定請求の対象児童の承認結果が全て入っている場合、認定請求の承認状況を「すべて完了」にする
     * 同じ認定請求の対象児童のいずれかに承認結果が入っている場合、認定請求の承認状況を「一部完了」にする
     */
    private Map<Id, DV_NinteiSeikyu__c> setShoninJyokyoSubeteKanryo(Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                    Map<Id, DV_TaishoJido__c> newTaishoJidoMap,
                                                                    Map<Id, DV_TaishoJido__c> oldTaishoJidoMap,
                                                                    Map<Id, List<DV_TaishoJido__c>> relatedTaishoJidoMap) {

        for(DV_TaishoJido__c jido :newTaishoJidoMap.values()) {

            // 処理対象の対象児童の承認結果に値が入った時に処理を実行
            Boolean shonin = String.isNotBlank(jido.ShoninKekka__c) && jido.ShoninKekka__c != oldTaishoJidoMap.get(jido.Id).ShoninKekka__c;
            if(shonin) {

                if(!relatedNinteiSeikyuMap.containsKey(jido.NinteiSeikyu__c) || relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) == null) {
                    continue;
                }

                Boolean subeteKanryo = true;

                // 関連する認定請求に紐付く対象児童をチェック
                if(relatedTaishoJidoMap.containsKey(jido.Id) && relatedTaishoJidoMap.get(jido.Id).size() > 0) {
                    for(DV_TaishoJido__c relatedJido :relatedTaishoJidoMap.get(jido.Id)) {
                        if(String.isBlank(relatedJido.ShoninKekka__c)) {
                            subeteKanryo = false;
                        }
                    }
                }

                // 同じ認定請求の対象児童の承認結果が全て入っている場合、認定請求の承認状況を「すべて完了」にする
                // 同じ認定請求の対象児童のいずれかに承認結果が入っている場合、認定請求の承認状況を「一部完了」にする
                if(subeteKanryo) {
                    relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).ShoninJyokyo__c = SHONIN_JYOKYO_STR_SUBETE;
                    updateNinteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
                } else {
                    relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).ShoninJyokyo__c = SHONIN_JYOKYO_STR_ICHIBU;
                    updateNinteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
                }
            }
        }

        return relatedNinteiSeikyuMap;
    }

    /**
     * 認定請求を更新
     */
    private void updateNinteiSeikyu(Map<Id, DV_NinteiSeikyu__c> relatedNinteiSeikyuMap) {

        List<DV_NinteiSeikyu__c> updateNinteiSeikyuList = new List<DV_NinteiSeikyu__c>();
        for(DV_NinteiSeikyu__c ninteiSeikyu :relatedNinteiSeikyuMap.values()) {
            if(updateNinteiSeikyuIdSet.contains(ninteiSeikyu.Id)) {
                updateNinteiSeikyuList.add(ninteiSeikyu);
            }
        }

        if(updateNinteiSeikyuList.size() > 0) {
            update updateNinteiSeikyuList;
        }
    }

    /**
     * 不備通知を更新
     */
    private void updateFubiTsuchi(Map<Id, List<DV_FubiTsuchi__c>> fubiTsuchiMap) {
        List<DV_FubiTsuchi__c> updateFubiTsuchiList = new List<DV_FubiTsuchi__c>();
        if(!fubiTsuchiMap.isEmpty()) {
            for(List<DV_FubiTsuchi__c> tsuchiList :fubiTsuchiMap.values()) {
                updateFubiTsuchiList.addAll(tsuchiList);
            }
        }

        if(updateFubiTsuchiList.size() > 0) {
            update updateFubiTsuchiList;
        }
    }

    /**
     * 請求者を更新
     */
    private void updateSeikyusha(List<DV_Seikyusha__c> seikyushaList) {
        if(seikyushaList.size() > 0) {
            update seikyushaList;
        }
    }
}