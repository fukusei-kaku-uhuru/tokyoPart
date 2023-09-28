public with sharing class SfNinteiSeikyuTriggerHandler {

    public final String STATUS_STR_MISHINSEI            = '未申請';
    public final String STATUS_STR_OCR_SHORICHU         = 'OCR処理中';
    public final String STATUS_STR_SHINSACHU_00         = '0次審査中';
    public final String STATUS_STR_SHINSACHU_01         = '1次審査中';
    public final String STATUS_STR_SHINSACHU_02         = '2次審査中';
    public final String STATUS_STR_SHINSAMACHI_00       = '0次審査待ち';
    public final String STATUS_STR_SHINSAMACHI_01       = '1次審査待ち';
    public final String STATUS_STR_SHINSAMACHI_02       = '2次審査待ち';
    public final String STATUS_STR_UNMATCH              = 'アンマッチ判定';
    public final String STATUS_STR_SHINSAKANRYO         = '審査完了';
    public final String STATUS_STR_SHONINKANRYO         = '承認完了';
    public final String STATUS_STR_MUKO                 = '無効';
    public final String SHINSAJYOKYO_STR_SUBETEKANRYO   = '全て完了';
    public final String SHONINJYOKYO_STR_SUBETEKANRYO   = '全て完了';
    public final String YUSOJYOKYO_STR_TORIKOMIKANRYO   = '取り込み完了';
    public final String FUBI_STATUS_STR_RENRAKUZUMI     = '不備連絡済み';
    public final String SHINSAKEKKA_STR_FUBI            = '不備';

    public final Set<String> STATUS_STR_SET_SHINSA = new Set<String>{STATUS_STR_OCR_SHORICHU,
                                                                     STATUS_STR_SHINSACHU_00,
                                                                     STATUS_STR_SHINSACHU_01,
                                                                     STATUS_STR_SHINSACHU_02,
                                                                     STATUS_STR_SHINSAMACHI_00,
                                                                     STATUS_STR_SHINSAMACHI_01,
                                                                     STATUS_STR_SHINSAMACHI_02,
                                                                     STATUS_STR_UNMATCH,
                                                                     STATUS_STR_SHINSAKANRYO,
                                                                     STATUS_STR_SHONINKANRYO};

    public SfNinteiSeikyuTriggerHandler() {

    }

    public void beforeInsert(List<NinteiSeikyu__c> newNinteiSeikyuList) {

    }

    public void afterInsert(List<NinteiSeikyu__c> newNinteiSeikyuList) {

        Map<Id, NinteiSeikyu__c> newNinteiSeikyuMap = new Map<Id, NinteiSeikyu__c>(newNinteiSeikyuList);
        // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
        updateNinteiSeikyuOCRRenkeiField(newNinteiSeikyuMap, null);
    }

    public void beforeUpdate(Map<Id, NinteiSeikyu__c> newNinteiSeikyuMap, Map<Id, NinteiSeikyu__c> oldNinteiSeikyuMap) {

        clearNinteiSeikyu(newNinteiSeikyuMap, oldNinteiSeikyuMap);
    }

    public void afterUpdate(Map<Id, NinteiSeikyu__c> newNinteiSeikyuMap, Map<Id, NinteiSeikyu__c> oldNinteiSeikyuMap) {
        
        clearFubiShinsaKekka(newNinteiSeikyuMap, oldNinteiSeikyuMap);

        // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
        updateNinteiSeikyuOCRRenkeiField(newNinteiSeikyuMap, oldNinteiSeikyuMap);
    }

    /**
     * 再審査で審査ステータスに未申請が設定された場合、認定請求の情報をクリアする
     */
    private void clearNinteiSeikyu(Map<Id, NinteiSeikyu__c> newNinteiSeikyuMap, Map<Id, NinteiSeikyu__c> oldNinteiSeikyuMap) {

        List<NinteiSeikyu__c> targetNinteiSeikyuList = new List<NinteiSeikyu__c>();

        for(NinteiSeikyu__c ninteiSeikyu :newNinteiSeikyuMap.values()) {
            
            // 審査ステータスが審査中または審査完了から未申請に変更された認定請求を対象とする
            NinteiSeikyu__c oldNinteiSeikyu = oldNinteiSeikyuMap.get(ninteiSeikyu.Id);
            if(String.isNotBlank(ninteiSeikyu.ShinsaStatus__c)
            && ninteiSeikyu.ShinsaStatus__c.equals(STATUS_STR_MISHINSEI)
            && STATUS_STR_SET_SHINSA.contains(oldNinteiSeikyu.ShinsaStatus__c)) {
                targetNinteiSeikyuList.add(ninteiSeikyu);
            }
        }

        // 対象の認定請求がない場合は処理を終了
        if(targetNinteiSeikyuList.size() == 0) {
            return;
        }

        // 対象の認定請求について値をクリア
        for(NinteiSeikyu__c ninteiSeikyu :newNinteiSeikyuMap.values()) {
            ninteiSeikyu.ShinsaTantousha_00__c      = null;
            ninteiSeikyu.ShinsaKaishiDateTime_00__c = null;
            ninteiSeikyu.ShinsaKanryoDateTime_00__c = null;

            ninteiSeikyu.ShinsaTantousha_01__c      = null;
            ninteiSeikyu.ShinsaKaishiDateTime_01__c = null;
            ninteiSeikyu.ShinsaKanryoDateTime_01__c = null;

            ninteiSeikyu.ShinsaTantousha_02__c      = null;
            ninteiSeikyu.ShinsaKaishiDateTime_02__c = null;
            ninteiSeikyu.ShinsaKanryoDateTime_02__c = null;

            ninteiSeikyu.ShinsaTantousha_Saishu__c      = null;
            ninteiSeikyu.ShinsaKaishiDateTime_Saishu__c = null;
            ninteiSeikyu.ShinsaKanryoDateTime_Saishu__c = null;
        }
    }

    /**
     * 再審査で審査ステータスに未申請が設定された場合、不備の請求者/対象児童の審査結果をクリアする
     */
    private void clearFubiShinsaKekka(Map<Id, NinteiSeikyu__c> newNinteiSeikyuMap, Map<Id, NinteiSeikyu__c> oldNinteiSeikyuMap) {

        List<NinteiSeikyu__c> targetNinteiSeikyuList = new List<NinteiSeikyu__c>();
        Set<Id> targetNinteiSeikyuIdSet              = new Set<Id>();
        Set<Id> targetSeikyushaIdSet                 = new Set<Id>();
        for(NinteiSeikyu__c ninteiSeikyu :newNinteiSeikyuMap.values()) {
            
            // 審査ステータスが審査中または審査完了から未申請に変更された認定請求を対象とする
            NinteiSeikyu__c oldNinteiSeikyu = oldNinteiSeikyuMap.get(ninteiSeikyu.Id);
            if(String.isNotBlank(ninteiSeikyu.ShinsaStatus__c)
            && ninteiSeikyu.ShinsaStatus__c.equals(STATUS_STR_MISHINSEI)
            && STATUS_STR_SET_SHINSA.contains(oldNinteiSeikyu.ShinsaStatus__c)) {
                targetNinteiSeikyuList.add(ninteiSeikyu);
                targetNinteiSeikyuIdSet.add(ninteiSeikyu.Id);
                targetSeikyushaIdSet.add(ninteiSeikyu.Seikyusha__c);
            }
        }

        // 対象の認定請求がない場合は処理を終了
        if(targetNinteiSeikyuList.size() == 0) {
            return;
        }

        // 関連する請求者・対象児童を取得
        List<Seikyusha__c> updateSeikyushaList   = new List<Seikyusha__c>();
        List<TaishoJido__c> updateTaishoJidoList = new List<TaishoJido__c>();

        List<Seikyusha__c> seikyushaList = [SELECT Id,
                                                   HubiStatus__c,
                                                   ShinsaKekka_00__c,
                                                   ShinsaKekkaComment_00__c,
                                                   ShinsaKekka_01__c,
                                                   ShinsaKekkaComment_01__c,
                                                   ShinsaKekka_02__c,
                                                   ShinsaKekkaComment_02__c,
                                                   ShinsaKekkaSaishu__c,
                                                   ShinsaKekkaComment_Saishu__c
                                              FROM Seikyusha__c
                                             WHERE Id IN :targetSeikyushaIdSet];
        Map<Id, Seikyusha__c> seiKyushaMap = new Map<Id, Seikyusha__c>(seikyushaList);

        List<TaishoJido__c> taishoJidoList = [SELECT Id,
                                                     HubiStatus__c,
                                                     ShinsaKekka_00__c,
                                                     ShinsaKekkaComment_00__c,
                                                     ShinsaKekka_01__c,
                                                     ShinsaKekkaComment_01__c,
                                                     ShinsaKekka_02__c,
                                                     ShinsaKekkaComment_02__c,
                                                     ShinsaKekkaSaishu__c,
                                                     ShinsaKekkaComment_Saishu__c,
                                                     NinteiSeikyu__c
                                                FROM TaishoJido__c
                                               WHERE NinteiSeikyu__c IN :targetNinteiSeikyuIdSet];
        Map<Id, List<TaishoJido__c>> taishoJidoNinteiIdMap = new Map<Id, List<TaishoJido__c>>();
        for(TaishoJido__c taishoJido :taishoJidoList) {
            if(!taishoJidoNinteiIdMap.containsKey(taishoJido.NinteiSeikyu__c)) {
                taishoJidoNinteiIdMap.put(taishoJido.NinteiSeikyu__c, new List<TaishoJido__c>());
            }
            taishoJidoNinteiIdMap.get(taishoJido.NinteiSeikyu__c).add(taishoJido);
        }

        for(NinteiSeikyu__c ninteiSeikyu :targetNinteiSeikyuList) {
            
            Seikyusha__c updateSeikyusha = seiKyushaMap.get(ninteiSeikyu.Seikyusha__c);
            // 不備のステータスになっている請求者の不備ステータスが不備連絡済みでない場合、関連の請求者/対象者に処理を行わない
            if((   (String.isNotBlank(updateSeikyusha.ShinsaKekka_00__c)    && updateSeikyusha.ShinsaKekka_00__c.equals(SHINSAKEKKA_STR_FUBI))
                || (String.isNotBlank(updateSeikyusha.ShinsaKekka_01__c)    && updateSeikyusha.ShinsaKekka_01__c.equals(SHINSAKEKKA_STR_FUBI))
                || (String.isNotBlank(updateSeikyusha.ShinsaKekka_02__c)    && updateSeikyusha.ShinsaKekka_02__c.equals(SHINSAKEKKA_STR_FUBI))
                || (String.isNotBlank(updateSeikyusha.ShinsaKekkaSaishu__c) && updateSeikyusha.ShinsaKekkaSaishu__c.equals(SHINSAKEKKA_STR_FUBI))
                )
            && (String.isBlank(updateSeikyusha.HubiStatus__c) || !updateSeikyusha.HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI))) {
                continue;
            }
            
            List<TaishoJido__c> relatedTaishoJidoList = taishoJidoNinteiIdMap.get(ninteiSeikyu.Id);
            Boolean isJidoFubiRenrakuzumi = true;
            for(TaishoJido__c jido :relatedTaishoJidoList) {
                // 不備のステータスになっている対象児童の不備ステータスが不備連絡済みでない場合、関連の請求者/対象者に処理を行わない
                if((   (String.isNotBlank(jido.ShinsaKekka_00__c)    && jido.ShinsaKekka_00__c.equals(SHINSAKEKKA_STR_FUBI))
                    || (String.isNotBlank(jido.ShinsaKekka_01__c)    && jido.ShinsaKekka_01__c.equals(SHINSAKEKKA_STR_FUBI))
                    || (String.isNotBlank(jido.ShinsaKekka_02__c)    && jido.ShinsaKekka_02__c.equals(SHINSAKEKKA_STR_FUBI))
                    || (String.isNotBlank(jido.ShinsaKekkaSaishu__c) && jido.ShinsaKekkaSaishu__c.equals(SHINSAKEKKA_STR_FUBI))
                    )
                && (String.isBlank(jido.HubiStatus__c) || !jido.HubiStatus__c.equals(FUBI_STATUS_STR_RENRAKUZUMI))) {
                    isJidoFubiRenrakuzumi = false;
                }
            }
            if(!isJidoFubiRenrakuzumi) {
                continue;
            }


            // 不備のステータスになっている請求者/対象児童に対して審査結果を空にする
            if(   (String.isNotBlank(updateSeikyusha.ShinsaKekka_00__c)    && updateSeikyusha.ShinsaKekka_00__c.equals(SHINSAKEKKA_STR_FUBI))
               || (String.isNotBlank(updateSeikyusha.ShinsaKekka_01__c)    && updateSeikyusha.ShinsaKekka_01__c.equals(SHINSAKEKKA_STR_FUBI))
               || (String.isNotBlank(updateSeikyusha.ShinsaKekka_02__c)    && updateSeikyusha.ShinsaKekka_02__c.equals(SHINSAKEKKA_STR_FUBI))
               || (String.isNotBlank(updateSeikyusha.ShinsaKekkaSaishu__c) && updateSeikyusha.ShinsaKekkaSaishu__c.equals(SHINSAKEKKA_STR_FUBI))
               ) {
                updateSeikyusha.ShinsaKekka_00__c            = '';
                updateSeikyusha.ShinsaKekkaComment_00__c     = '';
                updateSeikyusha.ShinsaKekka_01__c            = '';
                updateSeikyusha.ShinsaKekkaComment_01__c     = '';
                updateSeikyusha.ShinsaKekka_02__c            = '';
                updateSeikyusha.ShinsaKekkaComment_02__c     = '';
                updateSeikyusha.ShinsaKekkaSaishu__c         = '';
                updateSeikyusha.ShinsaKekkaComment_Saishu__c = '';
                updateSeikyushaList.add(updateSeikyusha);
            }

            for(TaishoJido__c jido :relatedTaishoJidoList) {
                if(   (String.isNotBlank(jido.ShinsaKekka_00__c)    && jido.ShinsaKekka_00__c.equals(SHINSAKEKKA_STR_FUBI))
                   || (String.isNotBlank(jido.ShinsaKekka_01__c)    && jido.ShinsaKekka_01__c.equals(SHINSAKEKKA_STR_FUBI))
                   || (String.isNotBlank(jido.ShinsaKekka_02__c)    && jido.ShinsaKekka_02__c.equals(SHINSAKEKKA_STR_FUBI))
                   || (String.isNotBlank(jido.ShinsaKekkaSaishu__c) && jido.ShinsaKekkaSaishu__c.equals(SHINSAKEKKA_STR_FUBI))
                   ) {
                    jido.ShinsaKekka_00__c            = '';
                    jido.ShinsaKekkaComment_00__c     = '';
                    jido.ShinsaKekka_01__c            = '';
                    jido.ShinsaKekkaComment_01__c     = '';
                    jido.ShinsaKekka_02__c            = '';
                    jido.ShinsaKekkaComment_02__c     = '';
                    jido.ShinsaKekkaSaishu__c         = '';
                    jido.ShinsaKekkaComment_Saishu__c = '';
                    updateTaishoJidoList.add(jido);
                }
            }
        }

        // 更新処理を実行
        Savepoint sp = Database.setSavepoint();
        try {
            if(updateSeikyushaList.size() > 0) {
                update updateSeikyushaList;
            }
            if(updateTaishoJidoList.size() > 0) {
                update updateTaishoJidoList;
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }

    /**
     * OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
     */
    private void updateNinteiSeikyuOCRRenkeiField(Map<Id, NinteiSeikyu__c> newNinteiSeikyuMap, Map<Id, NinteiSeikyu__c> oldNinteiSeikyuMap) {

        List<NinteiSeikyu__c> targetUpdateNinteiSeikyuList = new List<NinteiSeikyu__c>();
        for(NinteiSeikyu__c ninteiSeikyu :newNinteiSeikyuMap.values()) {
            NinteiSeikyu__c updateNinteiSeikyu = new NinteiSeikyu__c(Id = ninteiSeikyu.Id);
            Boolean isTargetUpdate = false;

            // 申請日
            if(String.isNotBlank(ninteiSeikyu.OCR_ShinseiDateOCR__c)
            && (    oldNinteiSeikyuMap == null 
                ||  !ninteiSeikyu.OCR_ShinseiDateOCR__c.equals(oldNinteiSeikyuMap.get(ninteiSeikyu.Id).OCR_ShinseiDateOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(ninteiSeikyu.OCR_ShinseiDateOCR__c);
                if(tmpDate != null) {
                    updateNinteiSeikyu.OCR_ShinseiDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            // 委任日
            if(String.isNotBlank(ninteiSeikyu.IninDateOCR__c)
            && (    oldNinteiSeikyuMap == null 
                ||  !ninteiSeikyu.IninDateOCR__c.equals(oldNinteiSeikyuMap.get(ninteiSeikyu.Id).IninDateOCR__c))) {
                Date tmpDate = SfTriggerUtil.convertStringToDate(ninteiSeikyu.IninDateOCR__c);
                if(tmpDate != null) {
                    updateNinteiSeikyu.IninDate__c = tmpDate;
                    isTargetUpdate = true;
                }
            }

            if(isTargetUpdate) {
                targetUpdateNinteiSeikyuList.add(updateNinteiSeikyu);
            }
        }

        if(targetUpdateNinteiSeikyuList.size() > 0) {
            try{
                update targetUpdateNinteiSeikyuList;
            }catch(Exception e){
                System.debug('Exception:' + e.getMessage());
            }
        }
    }
}