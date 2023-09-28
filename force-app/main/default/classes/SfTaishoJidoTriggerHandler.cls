public with sharing class SfTaishoJidoTriggerHandler {

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

    public SfTaishoJidoTriggerHandler() {

    }

    public void beforeInsert(List<TaishoJido__c> newTaishoJidoList) {
        // 金融機関コードマップ(KEY:金融機関コード,VALUE：金融機関オブジェクトID)
        Map<String,id> kinyuKikanCodeMap = getKinyuKikanMap();

        List<String> externalIdList = new List<String>();
        for (TaishoJido__c jido : newTaishoJidoList) {
            externalIdList.add(jido.KinyuKikanCode__c + '-' + jido.ShitenCode__c);
            externalIdList.add(jido.SK_KinyuKikanCode__c + '-' + jido.SK_ShitenCode__c);
        }
        // 支店コードマップ(KEY:店舗コード,VALUE：支店オブジェクトID)
        Map<String,id> tempoCodeMap = getShitenMap(externalIdList);
        // 郵送申請の際にスキャンしたデータを更新する
        yusoShinseiScanDataUpdate(newTaishoJidoList, kinyuKikanCodeMap, tempoCodeMap);
    }

    public void afterInsert(List<TaishoJido__c> newTaishoJidoList) {
        
        Map<Id, TaishoJido__c> newTaishoJidoMap = new Map<Id, TaishoJido__c>(newTaishoJidoList);
        // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
        updateTaishoJidoOCRRenkeiField(newTaishoJidoMap, null);
    }

    public void beforeUpdate(Map<Id, TaishoJido__c> newTaishoJidoMap, Map<Id, TaishoJido__c> oldTaishoJidoMap) {
        
        // 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
        // 審査結果(0次)および審査結果(最終)に「不備」が入っていれば不備ステータスを「不備未連絡」にする
        updateShinsaKekkaSaishu(newTaishoJidoMap, oldTaishoJidoMap);
        
        // 振込レコードを作成
        SfFurikomiUtil.createFurikomi(newTaishoJidoMap, oldTaishoJidoMap);

        // 金融機関コードマップ(KEY:金融機関コード,VALUE：金融機関オブジェクトID)
        Map<String,id> kinyuKikanCodeMap = getKinyuKikanMap();

        List<String> externalIdList = new List<String>();
        for (TaishoJido__c jido : newTaishoJidoMap.values()) {
            externalIdList.add(jido.KinyuKikanCode__c + '-' + jido.ShitenCode__c);
            externalIdList.add(jido.SK_KinyuKikanCode__c + '-' + jido.SK_ShitenCode__c);
        }
        // 支店コードマップ(KEY:店舗コード,VALUE：支店オブジェクトID)
        Map<String,id> tempoCodeMap = getShitenMap(externalIdList);
        // 郵送申請の際にスキャンしたデータを更新する
        yusoShinseiScanDataUpdate(newTaishoJidoMap.values(), kinyuKikanCodeMap, tempoCodeMap);
    }

    public void afterUpdate(Map<Id, TaishoJido__c> newTaishoJidoMap, Map<Id, TaishoJido__c> oldTaishoJidoMap) {

        // 更新する認定請求のIDを格納するSetを初期化
        updateNinteiSeikyuIdSet = new Set<Id>();

        targetFubiTsuchiTaishoJidoIdSet = new Set<Id>();
        
        // 関連する認定請求を格納するMap
        Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap = getRelatedNinteiSeikyuMap(newTaishoJidoMap);

        // 関連する認定請求に紐付く対象児童を格納するMap
        Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap = getRelatedTaishoJidoMap(newTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
        relatedNinteiSeikyuMap = setNinteiSeikyuFubiRenrakuzumi(relatedNinteiSeikyuMap, newTaishoJidoMap, oldTaishoJidoMap, relatedTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
        Map<Id, List<FubiTsuchi__c>> updateFubiTsuchiMap = setSaishinseiFubiTsuchi(targetFubiTsuchiTaishoJidoIdSet, relatedNinteiSeikyuMap, newTaishoJidoMap, relatedTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
        List<Seikyusha__c> updateSeikyushaList = setClearKakuninHohoSeikyusha(updateFubiTsuchiMap, relatedNinteiSeikyuMap);

        // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」、いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
        relatedNinteiSeikyuMap = setStatusShinsaKanryo(relatedNinteiSeikyuMap, newTaishoJidoMap, oldTaishoJidoMap, relatedTaishoJidoMap);

        // 同じ認定請求の対象児童の承認結果が全て入っている場合、認定請求の承認状況を「すべて完了」にする
        // 同じ認定請求の対象児童のいずれかに承認結果が入っている場合、認定請求の承認状況を「一部完了」にする
        relatedNinteiSeikyuMap = setShoninJyokyoSubeteKanryo(relatedNinteiSeikyuMap, newTaishoJidoMap, oldTaishoJidoMap, relatedTaishoJidoMap);

        // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
        updateTaishoJidoOCRRenkeiField(newTaishoJidoMap, oldTaishoJidoMap);

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
    private void updateShinsaKekkaSaishu(Map<Id, TaishoJido__c> newTaishoJidoMap, Map<Id, TaishoJido__c> oldTaishoJidoMap) {

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
    private Map<Id, NinteiSeikyu__c> getRelatedNinteiSeikyuMap(Map<Id, TaishoJido__c> newTaishoJidoMap) {

        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        for(TaishoJido__c jido :newTaishoJidoMap.values()) {
            ninteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
        }
        List<NinteiSeikyu__c> relatedNinteiSeikyuList = [SELECT Id,
                                                                Seikyusha__c,
                                                                ShinsaStatus__c,
                                                                ShinsaJyokyo__c,
                                                                Seikyusha__r.ShinsaKekka_00__c,
                                                                Seikyusha__r.ShinsaKekka_01__c,
                                                                Seikyusha__r.ShinsaKekkaSaishu__c,
                                                                Seikyusha__r.HubiStatus__c,
                                                                Seikyusha__r.EscalationStatus__c,
                                                                Seikyusha__r.ChosaStatus__c,
                                                                Seikyusha__r.HonninKakuninHoho__c
                                                           FROM NinteiSeikyu__c
                                                          WHERE Id IN :ninteiSeikyuIdSet];
        Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap = new Map<Id, NinteiSeikyu__c>(relatedNinteiSeikyuList);

        return relatedNinteiSeikyuMap;
    }

    /**
     * 関連する認定請求に紐付く対象児童を格納するMap
     */
    private Map<Id, List<TaishoJido__c>> getRelatedTaishoJidoMap(Map<Id, TaishoJido__c> newTaishoJidoMap) {

        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        Map<Id, Set<Id>> taishoJidoIdMap = new Map<Id, Set<Id>>(); // 認定請求IDから対象児童のIDのSetを取得するMap
        for(TaishoJido__c jido :newTaishoJidoMap.values()) {
            ninteiSeikyuIdSet.add(jido.NinteiSeikyu__c);
            if(!taishoJidoIdMap.containsKey(jido.NinteiSeikyu__c)) {
                taishoJidoIdMap.put(jido.NinteiSeikyu__c, new Set<Id>());
            }
            taishoJidoIdMap.get(jido.NinteiSeikyu__c).add(jido.Id);
        }
        List<TaishoJido__c> relatedTaishoJidoList = [SELECT Id,
                                                            NinteiSeikyu__c,
                                                            ShinsaKekka_00__c,
                                                            ShinsaKekka_01__c,
                                                            ShinsaKekkaSaishu__c,
                                                            HubiStatus__c,
                                                            EscalationStatus__c,
                                                            ChosaStatus__c,
                                                            ShoninKekka__c
                                                       FROM TaishoJido__c
                                                      WHERE NinteiSeikyu__c IN :ninteiSeikyuIdSet];
        Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap = new Map<Id, List<TaishoJido__c>>();
        for(TaishoJido__c jido :relatedTaishoJidoList) {
            if(!taishoJidoIdMap.containsKey(jido.NinteiSeikyu__c)) {
                continue;
            }

            Set<Id> targetJidoIdSet = taishoJidoIdMap.get(jido.NinteiSeikyu__c);
            for(Id targetJidoId :targetJidoIdSet) {

                if(!relatedTaishoJidoMap.containsKey(targetJidoId)) {
                    relatedTaishoJidoMap.put(targetJidoId, new List<TaishoJido__c>());
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
    private Map<Id, NinteiSeikyu__c> setNinteiSeikyuFubiRenrakuzumi(Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                    Map<Id, TaishoJido__c> newTaishoJidoMap,
                                                                    Map<Id, TaishoJido__c> oldTaishoJidoMap,
                                                                    Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {

        for(TaishoJido__c jido :newTaishoJidoMap.values()) {
            if( String.isNotBlank(jido.HubiStatus__c)
             && jido.HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI)
             && ( String.isBlank(oldTaishoJidoMap.get(jido.Id).HubiStatus__c)
               || !oldTaishoJidoMap.get(jido.Id).HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI))
            ) {
                // 関連の請求者で不備ステータスに「不備未連絡」が入っていたら処理を行わない
                if(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) != null) {
                    if(String.isNotBlank(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).Seikyusha__r.HubiStatus__c)
                    && relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).Seikyusha__r.HubiStatus__c.equals(FUBI_STATUS_STR_MIRENRAKU)) {
                        continue;
                    }
                }

                // 関連の対象児童で不備ステータスに「不備未連絡」が入っていたら処理を行わない
                Boolean hasMirenrakuFubi = false;
                List<TaishoJido__c> relatedTaishoJidoList = relatedTaishoJidoMap.get(jido.Id);
                for(TaishoJido__c taishoJido :relatedTaishoJidoList) {
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
    private Map<Id, List<FubiTsuchi__c>> setSaishinseiFubiTsuchi(Set<Id> targetFubiTsuchiTaishoJidoIdSet,
                                                                 Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                 Map<Id, TaishoJido__c> newTaishoJidoMap,
                                                                 Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {
                                                                    
        // 対象の不備通知を取得
        Set<Id> targetNinteiSeikyuIdSet = new Set<Id>();
        Set<Id> targetTaishoJidoIdSet   = new Set<Id>();
        for(Id taishoJidoId :targetFubiTsuchiTaishoJidoIdSet) {
            targetNinteiSeikyuIdSet.add(newTaishoJidoMap.get(taishoJidoId).NinteiSeikyu__c);
            targetTaishoJidoIdSet.add(taishoJidoId);
            if(relatedTaishoJidoMap.containsKey(taishoJidoId)) {
                for(TaishoJido__c relatedJido :relatedTaishoJidoMap.get(taishoJidoId)) {
                    targetTaishoJidoIdSet.add(relatedJido.Id);
                }
            }
        }
        List<FubiTsuchi__c> fubiTsuchiList = [SELECT Id,
                                                     NinteiSeikyu__c,
                                                     NinteiSeikyu__r.Seikyusha__c,
                                                     TaishoJido__c,
                                                     TaishoJido__r.NinteiSeikyu__r.Seikyusha__c,
                                                     IsSaishinseiRiyozumi__c,
                                                     HonninKakuninShoruiSaiteishutsu__c
                                                FROM FubiTsuchi__c
                                               WHERE (
                                                         NinteiSeikyu__c IN :targetNinteiSeikyuIdSet
                                                      OR TaishoJido__c   IN :targetTaishoJidoIdSet
                                                     )
                                                 AND IsSaishinseiRiyozumi__c = false];
        Map<Id, List<FubiTsuchi__c>> seikyushaIdFubiTsuchiMap = new Map<Id, List<FubiTsuchi__c>>();
        for(FubiTsuchi__c tsuchi :fubiTsuchiList) {
            // 更新する不備通知の値設定
            tsuchi.IsSaishinseiRiyozumi__c = true; // 再申請利用済みフラグをtrueに更新

            Id tsuchiSeikyushaId = null;
            if(tsuchi.NinteiSeikyu__r.Seikyusha__c != null) {
                tsuchiSeikyushaId = tsuchi.NinteiSeikyu__r.Seikyusha__c;
            } else if (tsuchi.TaishoJido__r.NinteiSeikyu__r.Seikyusha__c != null) {
                tsuchiSeikyushaId = tsuchi.TaishoJido__r.NinteiSeikyu__r.Seikyusha__c;
            }

            if(tsuchiSeikyushaId != null) {
                if(!seikyushaIdFubiTsuchiMap.containsKey(tsuchiSeikyushaId)) {
                    seikyushaIdFubiTsuchiMap.put(tsuchiSeikyushaId, new List<FubiTsuchi__c>());
                }
                seikyushaIdFubiTsuchiMap.get(tsuchiSeikyushaId).add(tsuchi);
            }
        }

        return seikyushaIdFubiTsuchiMap;
    }

    /**
     * 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
     */
    private List<Seikyusha__c> setClearKakuninHohoSeikyusha(Map<Id, List<FubiTsuchi__c>> fubiTsuchiMap,
                                                            Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap) {

        Set<Id> updateSeikyushaIdSet           = new Set<Id>();
        List<Seikyusha__c> updateSeikyushaList = new List<Seikyusha__c>();

        Map<Id, NinteiSeikyu__c> ninteiSeikyuSeikyushaIdMap = new Map<Id, NinteiSeikyu__c>();
        for(NinteiSeikyu__c ninteiSeikyu :relatedNinteiSeikyuMap.values()) {
            ninteiSeikyuSeikyushaIdMap.put(ninteiSeikyu.Seikyusha__c, ninteiSeikyu);
        }

        for(Id seikyushaId :fubiTsuchiMap.keySet()) {
            // 上記「再申請利用済みフラグ」をONにしたレコード（今回の審査ST戻しで利用した不備通知）の中に、
            // 新規項目「本人確認書類再提出」がONのレコードがあった場合、請求者objの「本人確認方法」が券面アップロードだったらクリアする
            for(FubiTsuchi__c tsuchi :fubiTsuchiMap.get(seikyushaId)) {
                if(tsuchi.HonninKakuninShoruiSaiteishutsu__c
                && KAKUNIN_HOHO_KENMEN.equals(ninteiSeikyuSeikyushaIdMap.get(seikyushaId).Seikyusha__r.HonninKakuninHoho__c)) {
                    updateSeikyushaIdSet.add(seikyushaId);
                }
            }
        }
        for(Id seikyushaId :updateSeikyushaIdSet) {
            Seikyusha__c record = new Seikyusha__c();
            record.Id                   = seikyushaId;
            record.HonninKakuninHoho__c = '';

            updateSeikyushaList.add(record);
        }

        return updateSeikyushaList;
    }

    /**
     * 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」、いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
     */
    private Map<Id, NinteiSeikyu__c> setStatusShinsaKanryo(Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                           Map<Id, TaishoJido__c> newTaishoJidoMap,
                                                           Map<Id, TaishoJido__c> oldTaishoJidoMap,
                                                           Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {
        
        for(TaishoJido__c jido :newTaishoJidoMap.values()) {

            if(!relatedNinteiSeikyuMap.containsKey(jido.NinteiSeikyu__c) || relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) == null) {
                continue;
            }

            // 処理対象の対象児童の審査結果(最終)が入った時に処理を実行
            Boolean shinsaSaishu = String.isNotBlank(jido.ShinsaKekkaSaishu__c)
                                && jido.ShinsaKekkaSaishu__c != oldTaishoJidoMap.get(jido.Id).ShinsaKekkaSaishu__c;
            if(shinsaSaishu) {
                Boolean ShinsaKanryo = true;

                // 関連する請求者についてチェック
                if(String.isBlank(relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c).Seikyusha__r.ShinsaKekkaSaishu__c)) {
                    ShinsaKanryo = false;
                }

                // 関連する認定請求に紐付く対象児童についてチェック
                if(relatedTaishoJidoMap.containsKey(jido.Id) && relatedTaishoJidoMap.get(jido.Id).size() > 0) {
                    for(TaishoJido__c relatedJido :relatedTaishoJidoMap.get(jido.Id)) {
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
    private Map<Id, NinteiSeikyu__c> setShoninJyokyoSubeteKanryo(Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                 Map<Id, TaishoJido__c> newTaishoJidoMap,
                                                                 Map<Id, TaishoJido__c> oldTaishoJidoMap,
                                                                 Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {

        for(TaishoJido__c jido :newTaishoJidoMap.values()) {

            // 処理対象の対象児童の承認結果に値が入った時に処理を実行
            Boolean shonin = String.isNotBlank(jido.ShoninKekka__c) && jido.ShoninKekka__c != oldTaishoJidoMap.get(jido.Id).ShoninKekka__c;
            if(shonin) {

                if(!relatedNinteiSeikyuMap.containsKey(jido.NinteiSeikyu__c) || relatedNinteiSeikyuMap.get(jido.NinteiSeikyu__c) == null) {
                    continue;
                }

                Boolean subeteKanryo = true;

                // 関連する認定請求に紐付く対象児童をチェック
                if(relatedTaishoJidoMap.containsKey(jido.Id) && relatedTaishoJidoMap.get(jido.Id).size() > 0) {
                    for(TaishoJido__c relatedJido :relatedTaishoJidoMap.get(jido.Id)) {
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
     * OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
     */
    private void updateTaishoJidoOCRRenkeiField(Map<Id, TaishoJido__c> newTaishoJidoMap,
                                                Map<Id, TaishoJido__c> oldTaishoJidoMap) {

        List<TaishoJido__c> targetTaishoJidoList = new List<TaishoJido__c>();
        for(TaishoJido__c taishoJido :newTaishoJidoMap.values()) {
            TaishoJido__c updateTaishoJido = new TaishoJido__c(Id = taishoJido.Id);
            Boolean isTargetUpdate = false;

            // 生年月日（委任者）
            if(String.isNotBlank(taishoJido.Seinengappi_IninshaOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.Seinengappi_IninshaOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).Seinengappi_IninshaOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.Seinengappi_IninshaOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Seinengappi_Ininsha__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 生年月日（代理人）
            if(String.isNotBlank(taishoJido.Seinengappi_DairininOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.Seinengappi_DairininOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).Seinengappi_DairininOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.Seinengappi_DairininOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Seinengappi_Dairinin__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 提出年月日
            if(String.isNotBlank(taishoJido.TeishutuDateOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.TeishutuDateOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).TeishutuDateOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.TeishutuDateOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.TeishutuDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 提出年月日（WEB）
            if(String.isNotBlank(taishoJido.TeishutuDate2OCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.TeishutuDate2OCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).TeishutuDate2OCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.TeishutuDate2OCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.TeishutuDateWEB__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 生年月日
            if(String.isNotBlank(taishoJido.OCR_SeinenGappiDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_SeinenGappiDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_SeinenGappiDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_SeinenGappiDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.SeinenGappiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 転入・出生日
            if(String.isNotBlank(taishoJido.OCR_TennyuShusseiDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_TennyuShusseiDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_TennyuShusseiDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_TennyuShusseiDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.TennyuShusseiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 転出(予定)日
            if(String.isNotBlank(taishoJido.OCR_TenshutsuDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_TenshutsuDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_TenshutsuDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_TenshutsuDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.TenshutsuDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 申出日
            if(String.isNotBlank(taishoJido.OCR_MoushideDate_c__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_MoushideDate_c__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_MoushideDate_c__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_MoushideDate_c__c);
                if(tmpDate != null) {
                    updateTaishoJido.MoushideDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者 生年月日
            if(String.isNotBlank(taishoJido.Moushitate_SeinenGappiDateOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.Moushitate_SeinenGappiDateOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).Moushitate_SeinenGappiDateOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.Moushitate_SeinenGappiDateOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_SeinenGappiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者の別居（留学）期間開始日
            if(String.isNotBlank(taishoJido.OCR_Moushitate_BekkyoKaishiDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_Moushitate_BekkyoKaishiDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_Moushitate_BekkyoKaishiDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_Moushitate_BekkyoKaishiDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_BekkyoKaishiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者の別居（留学）期間終了日
            if(String.isNotBlank(taishoJido.OCR_Moushitate_BekkyoShuryoDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_Moushitate_BekkyoShuryoDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_Moushitate_BekkyoShuryoDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_Moushitate_BekkyoShuryoDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_BekkyoShuryoDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者の留学前の国内居住状況期間開始日
            if(String.isNotBlank(taishoJido.OCR_Moushitate_RyugakumaeKyojuKaishiDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_Moushitate_RyugakumaeKyojuKaishiDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_Moushitate_RyugakumaeKyojuKaishiDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_Moushitate_RyugakumaeKyojuKaishiDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_RyugakumaeKyojuKaishiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者の留学前の国内居住状況期間開始日2
            if(String.isNotBlank(taishoJido.Moushitate_RyugakumaeKyojuKaishiDate2OCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.Moushitate_RyugakumaeKyojuKaishiDate2OCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).Moushitate_RyugakumaeKyojuKaishiDate2OCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.Moushitate_RyugakumaeKyojuKaishiDate2OCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_RyugakumaeKyojuKaishiDate2__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者の留学前の国内居住状況期間終了日
            if(String.isNotBlank(taishoJido.OCR_Moushitate_RyugakumaeKyojuShuryoDate__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.OCR_Moushitate_RyugakumaeKyojuShuryoDate__c.equals(oldTaishoJidoMap.get(taishoJido.Id).OCR_Moushitate_RyugakumaeKyojuShuryoDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.OCR_Moushitate_RyugakumaeKyojuShuryoDate__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_RyugakumaeKyojuShuryoDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者の留学前の国内居住状況期間終了日2
            if(String.isNotBlank(taishoJido.Moushitate_RyugakumaeKyojuShuryoDate2OCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.Moushitate_RyugakumaeKyojuShuryoDate2OCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).Moushitate_RyugakumaeKyojuShuryoDate2OCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.Moushitate_RyugakumaeKyojuShuryoDate2OCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_RyugakumaeKyojuShuryoDate2__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 父母指定者 生年月日
            if(String.isNotBlank(taishoJido.Moushitate_ShiteiSeinenGappiDateOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.Moushitate_ShiteiSeinenGappiDateOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).Moushitate_ShiteiSeinenGappiDateOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.Moushitate_ShiteiSeinenGappiDateOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Moushitate_ShiteiSeinenGappiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 対象者_生年月日
            if(String.isNotBlank(taishoJido.TaishoshaSeinegappinOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.TaishoshaSeinegappinOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).TaishoshaSeinegappinOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.TaishoshaSeinegappinOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Taishosha_SeinengappiWEB__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 都外在住の父母等_生年月日
            if(String.isNotBlank(taishoJido.FuboshiteishaSeinengappiOCR__c)
            && (    oldTaishoJidoMap == null 
                ||  !taishoJido.FuboshiteishaSeinengappiOCR__c.equals(oldTaishoJidoMap.get(taishoJido.Id).FuboshiteishaSeinengappiOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(taishoJido.FuboshiteishaSeinengappiOCR__c);
                if(tmpDate != null) {
                    updateTaishoJido.Togai_FuboSeinengappiWEB__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            if(isTargetUpdate) {
                targetTaishoJidoList.add(updateTaishoJido);
            }
        }

        if(targetTaishoJidoList.size() > 0) {
            try{
                update targetTaishoJidoList;
            }catch(Exception e){
                System.debug('Exception:' + e.getMessage());
            }
        }
    }

    /**
     * 認定請求を更新
     */
    private void updateNinteiSeikyu(Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap) {

        List<NinteiSeikyu__c> updateNinteiSeikyuList = new List<NinteiSeikyu__c>();
        for(NinteiSeikyu__c ninteiSeikyu :relatedNinteiSeikyuMap.values()) {
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
    private void updateFubiTsuchi(Map<Id, List<FubiTsuchi__c>> fubiTsuchiMap) {
        List<FubiTsuchi__c> updateFubiTsuchiList = new List<FubiTsuchi__c>();
        if(!fubiTsuchiMap.isEmpty()) {
            for(List<FubiTsuchi__c> tsuchiList :fubiTsuchiMap.values()) {
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
    private void updateSeikyusha(List<Seikyusha__c> seikyushaList) {
        if(seikyushaList.size() > 0) {
            update seikyushaList;
        }
    }

    /**
     * 金融機関コードマップを取得する
     * (KEY:金融機関コード,VALUE：金融機関オブジェクトID)
     */
    private Map<String, id> getKinyuKikanMap() {
        Map<String, id> kinyuKikanCodeMap = new  Map<String, id>();
        // 金融機関リスト取得
        List<KinyuKikan__c> kinyuKikanList = [select id, KinyuKikanCode__c from KinyuKikan__c];
        // 金融機関コードマップ設定
        for(KinyuKikan__c kinyuKikanObj : kinyuKikanList){
            kinyuKikanCodeMap.put(kinyuKikanObj.KinyuKikanCode__c, kinyuKikanObj.id);
        }
        system.debug(kinyuKikanCodeMap);
        return kinyuKikanCodeMap;
    }

    /**
     * 店舗コードマップを取得する
     * (KEY:店舗コード,VALUE：支店オブジェクトID)
     */
    private Map<String, id> getShitenMap(List<String> externalIdList)  {
        Map<String, id> tempoCodeMap = new  Map<String, id>();
        // 支店リスト取得
        List<Shiten__c> shitenList = [select id, ExternalId__c from Shiten__c where ExternalId__c in: externalIdList];
        // 店舗コードマップ設定
        for(Shiten__c shitenObj : shitenList){
            tempoCodeMap.put(shitenObj.ExternalId__c, shitenObj.id);
        }
        system.debug(tempoCodeMap);
        return tempoCodeMap;
    }

     /**
     * 郵送申請の際にスキャンしたデータを取り込む場合、
     * 「金融機関」、「支店」、「口座名義」を更新する
     */
    private void yusoShinseiScanDataUpdate(List<TaishoJido__c> taishoJidoList, Map<String,id> kinyuKikanCodeMap, Map<String,id> tempoCodeMap){

        for (TaishoJido__c jido : taishoJidoList) {
            // 対象児童の郵送申請フラグがTRUEの場合は更新対象
            if(jido.IsYusoShinsei__c ){
                if (kinyuKikanCodeMap.containsKey(jido.KinyuKikanCode__c)) {
                    // 対象者振込口座(金融機関)設定
                    jido.KinyuKikan__c = kinyuKikanCodeMap.get(jido.KinyuKikanCode__c);
                }
                if (tempoCodeMap.containsKey(jido.KinyuKikanCode__c + '-' + jido.ShitenCode__c)) {
                    // 対象者振込口座(支店)設定
                    jido.Shiten__c = tempoCodeMap.get(jido.KinyuKikanCode__c + '-' + jido.ShitenCode__c);
                }
                // 対象者振込口座(口座名義)設定
                jido.KouzaMeigi__c = CommonConvertString.convert(jido.KouzaMeigi__c);

                if (kinyuKikanCodeMap.containsKey(jido.SK_KinyuKikanCode__c)) {
                    // 請求者振込口座（金融機関）設定
                    jido.SK_KinyuKikan__c = kinyuKikanCodeMap.get(jido.SK_KinyuKikanCode__c);
                }
                if (tempoCodeMap.containsKey(jido.SK_KinyuKikanCode__c + '-' + jido.SK_ShitenCode__c)) {
                    // 請求者振込口座（支店）設定
                    jido.SK_Shiten__c = tempoCodeMap.get(jido.SK_KinyuKikanCode__c + '-' + jido.SK_ShitenCode__c);
                }
                // 請求者振込口座（口座名義）設定
                jido.SK_KouzaMeigi__c = CommonConvertString.convert(jido.SK_KouzaMeigi__c);
            }
        }

    }
}