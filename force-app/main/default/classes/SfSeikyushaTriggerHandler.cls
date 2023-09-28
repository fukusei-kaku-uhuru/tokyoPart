public with sharing class SfSeikyushaTriggerHandler {

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

    public final String KAKUNIN_HOHO_KENMEN = '券面アップロード';

    public final Set<String> LOCK_TARGET_ESCALATION_STATUS = new Set<String>{'事務局内確認中', 'エスカレーション中(事務局内)', 'エスカレーション中(都庁様)'};
    public final Set<String> LOCK_TARGET_CHOSA_STATUS      = new Set<String>{'調査中'};

    public Set<Id> updateNinteiSeikyuSeikyushaIdSet; // 更新する認定請求に関連する請求者のIDを格納するSet

    public Set<Id> targetFubiTsuchiSeikyushaIdSet; // 関連する不備通知を更新するかどうか確認する対象の請求者のIdを格納するSet

    public SfSeikyushaTriggerHandler() {

    }

    public void beforeInsert(List<Seikyusha__c> newSeikyushaList) {

    }

    public void afterInsert(List<Seikyusha__c> newSeikyushaList) {

        Map<Id, Seikyusha__c> newSeikyushaMap = new Map<Id, Seikyusha__c>(newSeikyushaList);
        // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
        updateSeikyushaOCRRenkeiField(newSeikyushaMap, null);
        
    }

    public void beforeUpdate(Map<Id, Seikyusha__c> newSeikyushaMap, Map<Id, Seikyusha__c> oldSeikyushaMap) {

        // 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
        // 審査結果(最終)に不備が入った場合不備ステータスを不備未連絡に更新
        updateShinsaKekkaSaishu(newSeikyushaMap, oldSeikyushaMap);

        // 振込データ生成
        SfFurikomiUtil.createFurikomi(newSeikyushaMap, oldSeikyushaMap);
    }

    public void afterUpdate(Map<Id, Seikyusha__c> newSeikyushaMap, Map<Id, Seikyusha__c> oldSeikyushaMap) {

        // 20230707 審査チーム　ステータス制御関連処理見直しのためいったん既存処理をコメントアウト
        // 更新する認定請求に関連する請求者のIDを格納するSetを初期化
        updateNinteiSeikyuSeikyushaIdSet = new Set<Id>();

        targetFubiTsuchiSeikyushaIdSet   = new Set<Id>();
    
        // 関連する認定請求を格納するMap
        Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap = getRelatedNinteiSeikyuMap(newSeikyushaMap);

        // 関連する対象児童を格納するMap
        Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap = getRelatedTaishoJidoMap(relatedNinteiSeikyuMap);

        // 不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
        relatedNinteiSeikyuMap = setNinteiSeikyuFubiRenrakuzumi(relatedNinteiSeikyuMap, newSeikyushaMap, oldSeikyushaMap, relatedTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
        Map<Id, List<FubiTsuchi__c>> updateFubiTsuchiMap = setSaishinseiFubiTsuchi(targetFubiTsuchiSeikyushaIdSet, relatedNinteiSeikyuMap, newSeikyushaMap, relatedTaishoJidoMap);

        // 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
        List<Seikyusha__c> updateSeikyushaList = setClearKakuninHohoSeikyusha(updateFubiTsuchiMap, newSeikyushaMap);

        // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」、いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
        relatedNinteiSeikyuMap = setStatusShinsaKanryo(relatedNinteiSeikyuMap, newSeikyushaMap, oldSeikyushaMap, relatedTaishoJidoMap);

        // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
        updateSeikyushaOCRRenkeiField(newSeikyushaMap, oldSeikyushaMap);

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
    private void updateShinsaKekkaSaishu(Map<Id, Seikyusha__c> newSeikyushaMap, Map<Id, Seikyusha__c> oldSeikyushaMap) {

        for(Id seikyushaId :newSeikyushaMap.keySet()) {
            // 審査結果(2次)に値が入ったときのみ処理を実行
            if(String.isBlank(newSeikyushaMap.get(seikyushaId).ShinsaKekka_02__c)
            || newSeikyushaMap.get(seikyushaId).ShinsaKekka_02__c.equals(oldSeikyushaMap.get(seikyushaId).ShinsaKekka_02__c)) {
                continue;
            }
            
            // 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
            if(String.isNotBlank(newSeikyushaMap.get(seikyushaId).ShinsaKekka_01__c)
            && String.isNotBlank(newSeikyushaMap.get(seikyushaId).ShinsaKekka_02__c)
            && newSeikyushaMap.get(seikyushaId).ShinsaKekka_01__c.equals(newSeikyushaMap.get(seikyushaId).ShinsaKekka_02__c)) {
                newSeikyushaMap.get(seikyushaId).ShinsaKekkaSaishu__c = newSeikyushaMap.get(seikyushaId).ShinsaKekka_01__c;
            }
        }

        for(Id seikyushaId :newSeikyushaMap.keySet()) {
            // 審査結果(0次)や審査結果(最終)に不備が入った場合不備ステータスを不備未連絡に更新
            if((SHINSA_STATUS_STR_FUBI.equals(newSeikyushaMap.get(seikyushaId).ShinsaKekka_00__c)
                && !SHINSA_STATUS_STR_FUBI.equals(oldSeikyushaMap.get(seikyushaId).ShinsaKekka_00__c))
             ||
             (SHINSA_STATUS_STR_FUBI.equals(newSeikyushaMap.get(seikyushaId).ShinsaKekkaSaishu__c)
             && !SHINSA_STATUS_STR_FUBI.equals(oldSeikyushaMap.get(seikyushaId).ShinsaKekkaSaishu__c))) {
                newSeikyushaMap.get(seikyushaId).HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU;
            }
        }
    }

    /**
     * 関連する認定請求を格納するMapを取得
     */
    private Map<Id, NinteiSeikyu__c> getRelatedNinteiSeikyuMap(Map<Id, Seikyusha__c> newSeikyushaMap) {

        Set<Id> seikyushaIdSet = new Set<Id>();
        for(Seikyusha__c seikyusha :newSeikyushaMap.values()) {
            seikyushaIdSet.add(seikyusha.Id);
        }
        List<NinteiSeikyu__c> relatedNinteiSeikyuList = [SELECT Id,
                                                                Seikyusha__c,
                                                                ShinsaStatus__c,
                                                                ShinsaJyokyo__c
                                                           FROM NinteiSeikyu__c
                                                          WHERE Seikyusha__c IN :seikyushaIdSet];
        Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap = new Map<Id, NinteiSeikyu__c>();
        for(NinteiSeikyu__c ninteiSeikyu :relatedNinteiSeikyuList) {
            relatedNinteiSeikyuMap.put(ninteiSeikyu.Seikyusha__c, ninteiSeikyu);
        }

        return relatedNinteiSeikyuMap;
    }

    /**
     * 関連する対象児童を格納するMapを取得
     */
    private Map<Id, List<TaishoJido__c>> getRelatedTaishoJidoMap(Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap) {

        Set<Id> ninteiSeikyuIdSet              = new Set<Id>();
        Map<Id, Id> ninteiSeikyuSeikyushaIdMap = new Map<Id, Id>();
        for(NinteiSeikyu__c ninteiSeikyu :relatedNinteiSeikyuMap.values()) {
            ninteiSeikyuIdSet.add(ninteiSeikyu.Id);
            ninteiSeikyuSeikyushaIdMap.put(ninteiSeikyu.Id, ninteiSeikyu.Seikyusha__c);
        }
        List<TaishoJido__c> relatedTaishoJidoList = [SELECT Id,
                                                            NinteiSeikyu__c,
                                                            ShinsaKekka_00__c,
                                                            ShinsaKekka_01__c,
                                                            ShinsaKekkaSaishu__c,
                                                            HubiStatus__c,
                                                            EscalationStatus__c,
                                                            ChosaStatus__c
                                                       FROM TaishoJido__c
                                                      WHERE NinteiSeikyu__c IN :ninteiSeikyuIdSet];
        Map<Id, List<TaishoJido__c>> relatedTaishiJidoMap = new Map<Id, List<TaishoJido__c>>();
        for(TaishoJido__c taishoJido :relatedTaishoJidoList) {
            Id seikyushaId = ninteiSeikyuSeikyushaIdMap.get(taishoJido.NinteiSeikyu__c);
            if(!relatedTaishiJidoMap.containsKey(seikyushaId)) {
                relatedTaishiJidoMap.put(seikyushaId, new List<TaishoJido__c>());
            }
            relatedTaishiJidoMap.get(seikyushaId).add(taishoJido);
        }

        return relatedTaishiJidoMap;
    }

    /**
     * 不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
     */
    private Map<Id, NinteiSeikyu__c> setNinteiSeikyuFubiRenrakuzumi(Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                    Map<Id, Seikyusha__c> newSeikyushaMap,
                                                                    Map<Id, Seikyusha__c> oldSeikyushaMap,
                                                                    Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {
        
        for(Id seikyushaId :newSeikyushaMap.keySet()) {
            if( String.isNotBlank(newSeikyushaMap.get(seikyushaId).HubiStatus__c)
             && newSeikyushaMap.get(seikyushaId).HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI)
             && ( String.isBlank(oldSeikyushaMap.get(seikyushaId).HubiStatus__c)
               || !oldSeikyushaMap.get(seikyushaId).HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI))
            ) {
                // 関連の対象児童で不備ステータスに「不備未連絡」が入っていたら処理を行わない
                Boolean hasMirenrakuFubi = false;
                if(relatedTaishoJidoMap.containsKey(seikyushaId)) {
                    List<TaishoJido__c> relatedTaishoJidoList = relatedTaishoJidoMap.get(seikyushaId);
                    for(TaishoJido__c taishoJido :relatedTaishoJidoList) {
                        if(String.isNotBlank(taishoJido.HubiStatus__c) && taishoJido.HubiStatus__c.equals(FUBI_STATUS_STR_MIRENRAKU)) {
                            hasMirenrakuFubi = true;
                        }
                    }
                }
                
                if(hasMirenrakuFubi) {
                    continue;
                }

                // 認定請求のステータスを未申請に更新
                if(relatedNinteiSeikyuMap.get(seikyushaId) != null) {
                    relatedNinteiSeikyuMap.get(seikyushaId).ShinsaStatus__c = STATUS_STR_MISHINSEI;
                    updateNinteiSeikyuSeikyushaIdSet.add(seikyushaId);
                    targetFubiTsuchiSeikyushaIdSet.add(seikyushaId);
                }
            }
        }

        return relatedNinteiSeikyuMap;
    }

    /**
     * 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
     */
    private Map<Id, List<FubiTsuchi__c>> setSaishinseiFubiTsuchi(Set<Id> targetFubiTsuchiNinteiSeikyuIdSet,
                                                                 Map<Id, NinteiSeikyu__c> relatedNinteiSeikyuMap,
                                                                 Map<Id, Seikyusha__c> newSeikyushaMap,
                                                                 Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {

        // 対象の不備通知を取得
        Set<Id> targetNinteiSeikyuIdSet = new Set<Id>();
        Set<Id> targetTaishoJidoIdSet   = new Set<Id>();
        for(Id seikyushaId :targetFubiTsuchiNinteiSeikyuIdSet) {
            if(relatedNinteiSeikyuMap.containsKey(seikyushaId)) {
                targetNinteiSeikyuIdSet.add(relatedNinteiSeikyuMap.get(seikyushaId).Id);
            }
            if(relatedTaishoJidoMap.containsKey(seikyushaId)) {
                for(TaishoJido__c jido :relatedTaishoJidoMap.get(seikyushaId)) {
                    targetTaishoJidoIdSet.add(jido.Id);
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
                                                            Map<Id, Seikyusha__c> newSeikyushaMap) {

        Set<Id> updateSeikyushaIdSet           = new Set<Id>();
        List<Seikyusha__c> updateSeikyushaList = new List<Seikyusha__c>();

        for(Id seikyushaId :fubiTsuchiMap.keySet()) {
            // 上記「再申請利用済みフラグ」をONにしたレコード（今回の審査ST戻しで利用した不備通知）の中に、
            // 新規項目「本人確認書類再提出」がONのレコードがあった場合、請求者objの「本人確認方法」が券面アップロードだったらクリアする
            for(FubiTsuchi__c tsuchi :fubiTsuchiMap.get(seikyushaId)) {
                if(tsuchi.HonninKakuninShoruiSaiteishutsu__c
                && KAKUNIN_HOHO_KENMEN.equals(newSeikyushaMap.get(seikyushaId).HonninKakuninHoho__c)) {
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
                                                           Map<Id, Seikyusha__c> newSeikyushaMap,
                                                           Map<Id, Seikyusha__c> oldSeikyushaMap,
                                                           Map<Id, List<TaishoJido__c>> relatedTaishoJidoMap) {
        for(Id seikyushaId :newSeikyushaMap.keySet()) {

            if(!relatedNinteiSeikyuMap.containsKey(seikyushaId) || relatedNinteiSeikyuMap.get(seikyushaId) == null) {
                continue;
            }

            // 請求者の審査結果(最終)が入った時に処理を実行
            Boolean shinsaSaishu = String.isNotBlank(newSeikyushaMap.get(seikyushaId).ShinsaKekkaSaishu__c)
                                && newSeikyushaMap.get(seikyushaId).ShinsaKekkaSaishu__c != oldSeikyushaMap.get(seikyushaId).ShinsaKekkaSaishu__c;
            if(shinsaSaishu) {
                Boolean ShinsaKanryo = true;
                // 関連する対象児童についてチェック
                if(relatedTaishoJidoMap.containsKey(seikyushaId) && relatedTaishoJidoMap.get(seikyushaId).size() > 0) {
                    // 審査結果(最終)に結果が入っていない場合か、不備になっていた場合は審査状況は「一部完了」
                    for(TaishoJido__c taishoJido :relatedTaishoJidoMap.get(seikyushaId)) {
                        if(String.isBlank(taishoJido.ShinsaKekkaSaishu__c)) {
                            ShinsaKanryo = false;
                        }
                    }
                }

                // 認定請求に設定する値を決める
                if(ShinsaKanryo) {
                    // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」にする
                    relatedNinteiSeikyuMap.get(seikyushaId).ShinsaJyokyo__c = SHINSA_JYOKYO_STR_SUBETE;
                } else {
                    // 認定請求に紐付く請求者・対象児童のいずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
                    relatedNinteiSeikyuMap.get(seikyushaId).ShinsaJyokyo__c = SHINSA_JYOKYO_STR_ICHIBU;
                }
                updateNinteiSeikyuSeikyushaIdSet.add(seikyushaId);
            }
        }

        return relatedNinteiSeikyuMap;
    }

    /**
     * OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
     */
    private void updateSeikyushaOCRRenkeiField(Map<Id, Seikyusha__c> newSeikyushaMap,
                                               Map<Id, Seikyusha__c> oldSeikyushaMap) {

        List<Seikyusha__c> targetSeikyushaList = new List<Seikyusha__c>();
        for(Seikyusha__c seikyusha :newSeikyushaMap.values()) {
            Seikyusha__c updateSeikyusha = new Seikyusha__c(Id = seikyusha.Id);
            Boolean isTargetUpdate = false;

            // 生年月日
            if(String.isNotBlank(seikyusha.OCR_SeinenGappiDate__c)
            && (    oldSeikyushaMap == null 
                ||  !seikyusha.OCR_SeinenGappiDate__c.equals(oldSeikyushaMap.get(seikyusha.Id).OCR_SeinenGappiDate__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(seikyusha.OCR_SeinenGappiDate__c);
                if(tmpDate != null) {
                    updateSeikyusha.SeinenGappiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // メールアドレス
            if(String.isNotBlank(seikyusha.MailAddressOCR__c)
            && (    oldSeikyushaMap == null 
                ||  !seikyusha.MailAddressOCR__c.equals(oldSeikyushaMap.get(seikyusha.Id).MailAddressOCR__c))) {
                String tmpStr = SfTriggerUtil.convertToEmailAddressString(seikyusha.MailAddressOCR__c);
                if(String.isNotBlank(tmpStr)) {
                    updateSeikyusha.MailAddress__c = tmpStr;
                    isTargetUpdate = true;
                }
            }

            if(isTargetUpdate) {
                targetSeikyushaList.add(updateSeikyusha);
            }
        }

        if(targetSeikyushaList.size() > 0) {
            try{
                update targetSeikyushaList;
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
            if(updateNinteiSeikyuSeikyushaIdSet.contains(ninteiSeikyu.Seikyusha__c)) {
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
}