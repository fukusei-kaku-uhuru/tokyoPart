public with sharing class SfDVEscalationTriggerHandler {
    
    private final String ESCALATION_STATUS_STR_KAKUNINCHU           = '事務局内確認中';
    private final String ESCALATION_STATUS_STR_ESCALATION_JIMUKYOKU = 'エスカレーション中(事務局内)';
    private final String ESCALATION_STATUS_STR_ESCALATION_TOCHO     = 'エスカレーション中(都庁様)';
    private final String ESCALATION_STATUS_STR_KAIKETSU             = 'エスカレーション解決';

    private final String STATUS_STR_JIMUKYOKU_KAKUNINCHU = '事務局内確認中';
    private final String STATUS_STR_JIMUKYOKU_KAITOMACHI = '事務局内回答待ち';
    private final String STATUS_STR_TOCHO_KAITOMACHI     = '都庁様回答待ち';
    private final String STATUS_STR_TOCHO_KAITOZUMI      = '都庁様回答済み';
    private final String STATUS_STR_KANRYO               = '完了';

    Savepoint sp;

    public SfDVEscalationTriggerHandler() {

    }

    public void afterInsert(List<DV_Escalation__c> newEscalationList) {

        sp = Database.setSavepoint();

        // エスカレーションのステータス更新に合わせて関連する請求者または対象児童のエスカレーションステータスを更新する
        updateRelatedEscalationStatus(newEscalationList);
    }

    public void afterUpdate(Map<Id, DV_Escalation__c> newEscalationMap, Map<Id, DV_Escalation__c> oldEscalationMap) {

        sp = Database.setSavepoint();

        // エスカレーションのステータス更新に合わせて関連する請求者または対象児童のエスカレーションステータスを更新する
        updateRelatedEscalationStatus(newEscalationMap, oldEscalationMap);
    }

    /**
     * エスカレーションのステータス更新に合わせて関連する請求者または対象児童のエスカレーションステータスを更新する(insertの場合)
     */
    private void updateRelatedEscalationStatus(List<DV_Escalation__c> newEscalationList) {

        // 認定請求に紐付いているエスカレーションか対象児童に紐付いているエスカレーションか振り分ける
        List<DV_Escalation__c> seikyushaEscalationList = new List<DV_Escalation__c>();
        List<DV_Escalation__c> taishoJidoEscataionList = new List<DV_Escalation__c>();
        for(DV_Escalation__c escalation :newEscalationList) {
            if(escalation.NinteiSeikyuBango__c != null) {
                seikyushaEscalationList.add(escalation);
            }
            if(escalation.TaishoJido__c != null) {
                taishoJidoEscataionList.add(escalation);
            }
        }

        // 請求者のエスカレーションステータスを更新
        if(seikyushaEscalationList.size() > 0) {
            // エスカレーションのステータスが更新されているものについて、関連の認定請求IDを取得
            Set<Id> relatedNinteiSeikyuIdSet = getRelatedNinteiSeikyuIdSet(seikyushaEscalationList);
            // 続きの処理はsetRelatedEscalationStatusメソッドに記載
            setRelatedEscalationStatus(relatedNinteiSeikyuIdSet);
        }
        
        // 対象児童のエスカレーションステータスを更新
        if(taishoJidoEscataionList.size() > 0) {
            // エスカレーションのステータスが更新されているものについて、関連の対象児童IDを取得
            Set<Id> relatedTaishoJidoIdSet = getRelatedTaishoJidoIdSet(taishoJidoEscataionList);
            // 続きの処理はsetRelatedEscalationStatusメソッドに記載
            setRelatedJidoEscalationStatus(relatedTaishoJidoIdSet);
        }
    }

    /**
     * エスカレーションのステータス更新に合わせて関連する請求者または対象児童のエスカレーションステータスを更新する(updateの場合)
     */
    private void updateRelatedEscalationStatus(Map<Id, DV_Escalation__c> newEscalationMap, Map<Id, DV_Escalation__c> oldEscalationMap) {

        // 認定請求に紐付いているエスカレーションか対象児童に紐付いているエスカレーションか振り分ける
        Map<Id, DV_Escalation__c> seikyushaEscalationMap = new Map<Id, DV_Escalation__c>();
        Map<Id, DV_Escalation__c> taishoJidoEscataionMap = new Map<Id, DV_Escalation__c>();
        for(DV_Escalation__c escalation :newEscalationMap.values()) {
            if(escalation.NinteiSeikyuBango__c != null) {
                seikyushaEscalationMap.put(escalation.Id, escalation);
            }
            if(escalation.TaishoJido__c != null) {
                taishoJidoEscataionMap.put(escalation.Id, escalation);
            }
        }

        // 請求者のエスカレーションステータスを更新
        if(seikyushaEscalationMap.size() > 0) {
            // エスカレーションのステータスが更新されているものについて、関連の認定請求IDを取得
            Set<Id> relatedNinteiSeikyuIdSet = getRelatedNinteiSeikyuIdSet(seikyushaEscalationMap, oldEscalationMap);
            // 続きの処理はsetRelatedEscalationStatusメソッドに記載
            setRelatedEscalationStatus(relatedNinteiSeikyuIdSet);
        }
        
        // 対象児童のエスカレーションステータスを更新
        if(taishoJidoEscataionMap.size() > 0) {
            // エスカレーションのステータスが更新されているものについて、関連の対象児童IDを取得
            Set<Id> relatedTaishoJidoIdSet = getRelatedTaishoJidoIdSet(taishoJidoEscataionMap, oldEscalationMap);
            // 続きの処理はsetRelatedJidoEscalationStatusメソッドに記載
            setRelatedJidoEscalationStatus(relatedTaishoJidoIdSet);
        }
    }

    /**
     * エスカレーションのステータス更新に合わせて関連する請求者のエスカレーションステータスを更新する
     */
    private void setRelatedEscalationStatus(Set<Id> relatedNinteiSeikyuIdSet) {

        Map<Id, List<DV_Escalation__c>> relatedEscalationMap = getRelatedEscalationMap(relatedNinteiSeikyuIdSet);

        // 更新する請求者のMapを取得
        Map<Id, Id> seikyushaNinteiSeikyuIdMap = new Map<Id, Id>();
        for(List<DV_Escalation__c> escalationList :relatedEscalationMap.values()) {
            for(DV_Escalation__c escalation :escalationList) {
                seikyushaNinteiSeikyuIdMap.put(escalation.NinteiSeikyuBango__r.Seikyusya__c, escalation.NinteiSeikyuBango__c);
            }
        }
        Map<Id, DV_Seikyusha__c> updateSeikyushaMap = getUpdateSeikyushaMap(seikyushaNinteiSeikyuIdMap);

        List<DV_Seikyusha__c> updateSeikyushaList   = new List<DV_Seikyusha__c>();

        // 認定請求ごとに設定すべきエスカレーションステータスを判定
        for(Id ninteiSeikyuId :relatedNinteiSeikyuIdSet) {
            List<DV_Escalation__c> escalationList = relatedEscalationMap.get(ninteiSeikyuId);
            
            String updateStatus = getEscalationStatus(escalationList);

            // 関連する請求者のエスカレーションステータスを更新
            if(updateSeikyushaMap.containsKey(ninteiSeikyuId)) {
                DV_Seikyusha__c updateSeikyusha     = new DV_Seikyusha__c();
                updateSeikyusha.Id                  = updateSeikyushaMap.get(ninteiSeikyuId).Id;
                updateSeikyusha.EscalationStatus__c = updateStatus;

                updateSeikyushaList.add(updateSeikyusha);
            }
        }

        // 請求者を更新
        try{
            // 請求者を更新
            if(updateSeikyushaList.size() > 0) {
                update updateSeikyushaList;
            }
        }catch(Exception e){
            Database.rollback(sp);
            throw new DmlException(e.getMessage());
        }
    }

    /**
     * エスカレーションのステータス更新に合わせて関連する対象児童のエスカレーションステータスを更新する
     */
    private void setRelatedJidoEscalationStatus(Set<Id> relatedTaishoJidoIdSet) {

        Map<Id, List<DV_Escalation__c>> relatedEscalationMap = getRelatedJidoEscalationMap(relatedTaishoJidoIdSet);

        // 更新する対象児童のMapを取得
        Map<Id, DV_TaishoJido__c> updateTaishoJidoMap = getUpdateTaishoJidoMap(relatedTaishoJidoIdSet);

        List<DV_TaishoJido__c> updateTaishoJidoList = new List<DV_TaishoJido__c>();

        // 対象児童ごとに設定すべきエスカレーションステータスを判定
        for(Id taishoJidoId :relatedTaishoJidoIdSet) {

            List<DV_Escalation__c> escalationList = relatedEscalationMap.get(taishoJidoId);

            String updateStatus = getEscalationStatus(escalationList);

            // 関連する対象児童のエスカレーションステータスを更新
            if(updateTaishoJidoMap.containsKey(taishoJidoId)) {
                DV_TaishoJido__c updateTaishoJido    = new DV_TaishoJido__c();
                updateTaishoJido.Id                  = updateTaishoJidoMap.get(taishoJidoId).Id;
                updateTaishoJido.EscalationStatus__c = updateStatus;

                updateTaishoJidoList.add(updateTaishoJido);
            }
        }

        // 対象児童を更新
        try{
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
     * エスカレーションのステータスが更新されているものについて、関連の認定請求IDを取得
     */
    private Set<Id> getRelatedNinteiSeikyuIdSet(List<DV_Escalation__c> escalationList) {
        Set<Id> relatedNinteiSeikyuIdSet = new Set<Id>();
        for(DV_Escalation__c escalation :escalationList) {
            if(String.isNotBlank(escalation.Status__c)) {
                relatedNinteiSeikyuIdSet.add(escalation.NinteiSeikyuBango__c);
            } 
        }

        return relatedNinteiSeikyuIdSet;
    }

    private Set<Id> getRelatedNinteiSeikyuIdSet(Map<Id, DV_Escalation__c> newEscalationMap, Map<Id, DV_Escalation__c> oldEscalationMap) {
        Set<Id> relatedNinteiSeikyuIdSet = new Set<Id>();
        for(DV_Escalation__c escalation :newEscalationMap.values()) {
            if(String.isNotBlank(escalation.Status__c) && !escalation.Status__c.equals(oldEscalationMap.get(escalation.Id).Status__c)) {
                relatedNinteiSeikyuIdSet.add(escalation.NinteiSeikyuBango__c);
            }
        }

        return relatedNinteiSeikyuIdSet;
    }

    /**
     * エスカレーションのステータスが更新されているものについて、関連の対象児童IDを取得
     */
    private Set<Id> getRelatedTaishoJidoIdSet(List<DV_Escalation__c> escalationList) {
        Set<Id> relatedTaishoJidoIdSet = new Set<Id>();
        for(DV_Escalation__c escalation :escalationList) {
            if(String.isNotBlank(escalation.Status__c)) {
                relatedTaishoJidoIdSet.add(escalation.TaishoJido__c);
            } 
        }

        return relatedTaishoJidoIdSet;
    }
    
    private Set<Id> getRelatedTaishoJidoIdSet(Map<Id, DV_Escalation__c> newEscalationMap, Map<Id, DV_Escalation__c> oldEscalationMap) {
        Set<Id> relatedTaishoJidoIdSet = new Set<Id>();
        for(DV_Escalation__c escalation :newEscalationMap.values()) {
            if(String.isNotBlank(escalation.Status__c) && !escalation.Status__c.equals(oldEscalationMap.get(escalation.Id).Status__c)) {
                relatedTaishoJidoIdSet.add(escalation.TaishoJido__c);
            }
        }

        return relatedTaishoJidoIdSet;
    }

    /**
     * エスカレーションのステータスから設定すべきエスカレーションステータスを返す
     */
    private String getEscalationStatus(List<DV_Escalation__c> escalationList) {

        String updateStatus = '';

        // updateStatusIntを用意しそれぞれのエスカレーションのステータスを調べる
        // 下記のなるべく若い番号のエスカレーションステータスに更新
        // 1.「東京都様回答待ち」または「東京都様回答済み」
        // 2.「事務局内回答待ち」
        // 3.「事務局内確認中」
        // 4.「完了」
        // 5.未入力またはレコードなし
        Integer updateStatusInt = 5;
        for(DV_Escalation__c escalation :escalationList) {
            if(String.isBlank(escalation.Status__c)) {
                continue;
            }
            // 「東京都様回答待ち」「東京都様回答済み」がぶら下がっていたらエスカレーション中(都庁様)
            if(escalation.Status__c.equals(STATUS_STR_TOCHO_KAITOMACHI) || escalation.Status__c.equals(STATUS_STR_TOCHO_KAITOZUMI)) {
                updateStatusInt = 1;
            // 上記じゃなくて「事務局内回答待ち」がぶら下がっていたらエスカレーション中(都庁様)
            } else if(escalation.Status__c.equals(STATUS_STR_JIMUKYOKU_KAITOMACHI) && updateStatusInt > 2) {
                updateStatusInt = 2;
            // 上記じゃなくて「事務局内確認中」がぶら下がっていたら事務局内確認中
            } else if(escalation.Status__c.equals(STATUS_STR_JIMUKYOKU_KAKUNINCHU) && updateStatusInt > 3) {
                updateStatusInt = 3;
            // 上記じゃなくて「完了」がぶら下がっていたらエスカレーション解決
            } else if(escalation.Status__c.equals(STATUS_STR_KANRYO) && updateStatusInt > 4) {
                updateStatusInt = 4;
            }
        }
        System.debug('確認updateStatusInt：' + updateStatusInt);

        switch on updateStatusInt {
            when 1 {updateStatus = ESCALATION_STATUS_STR_ESCALATION_TOCHO;}
            when 2 {updateStatus = ESCALATION_STATUS_STR_ESCALATION_JIMUKYOKU;}
            when 3 {updateStatus = ESCALATION_STATUS_STR_KAKUNINCHU;}
            when 4 {updateStatus = ESCALATION_STATUS_STR_KAIKETSU;}
        }

        return updateStatus;
    }

    // 認定請求IDをキーとする処理対象のエスカレーションのListのMapを取得
    private Map<Id, List<DV_Escalation__c>> getRelatedEscalationMap(Set<Id> ninteiSeikyuIdSet) {
        List<DV_Escalation__c> escalationList = [SELECT Id,
                                                        Status__c,
                                                        NinteiSeikyuBango__c,
                                                        NinteiSeikyuBango__r.Seikyusya__c
                                                   FROM DV_Escalation__c
                                                  WHERE NinteiSeikyuBango__c IN :ninteiSeikyuIdSet];
        Map<Id, List<DV_Escalation__c>> returnMap = new Map<Id, List<DV_Escalation__c>>();
        for(DV_Escalation__c escalation :escalationList) {
            if(!returnMap.containsKey(escalation.NinteiSeikyuBango__c)) {
                returnMap.put(escalation.NinteiSeikyuBango__c, new List<DV_Escalation__c>());
            }
            returnMap.get(escalation.NinteiSeikyuBango__c).add(escalation);
        }

        return returnMap;
    }

    // 認定請求IDをキーとする更新対象の請求者のMapを取得
    private Map<Id, DV_Seikyusha__c> getUpdateSeikyushaMap(Map<Id, Id> seikyushaNinteiSeikyuIdMap) {
        Set<Id> seikyushaIdSet = seikyushaNinteiSeikyuIdMap.keySet();
        List<DV_Seikyusha__c> seikyushaList = [SELECT Id,
                                                      EscalationStatus__c
                                                 FROM DV_Seikyusha__c
                                                WHERE Id IN :seikyushaIdSet];
        Map<Id, DV_Seikyusha__c> returnMap = new Map<Id, DV_Seikyusha__c>();
        for(DV_Seikyusha__c seikyusha :seikyushaList) {
            returnMap.put(seikyushaNinteiSeikyuIdMap.get(seikyusha.Id), seikyusha);
        }

        return returnMap;
    }

    // 対象児童IDをキーとする処理対象のエスカレーションのListのMapを取得
    private Map<Id, List<DV_Escalation__c>> getRelatedJidoEscalationMap(Set<Id> taishoJidoIdSet) {
        List<DV_Escalation__c> escalationList = [SELECT Id,
                                                        Status__c,
                                                        TaishoJido__c
                                                   FROM DV_Escalation__c
                                                  WHERE TaishoJido__c IN :taishoJidoIdSet];
        Map<Id, List<DV_Escalation__c>> returnMap = new Map<Id, List<DV_Escalation__c>>();
        for(DV_Escalation__c escalation :escalationList) {
            if(!returnMap.containsKey(escalation.TaishoJido__c)) {
                returnMap.put(escalation.TaishoJido__c, new List<DV_Escalation__c>());
            }
            returnMap.get(escalation.TaishoJido__c).add(escalation);
        }

        return returnMap;
    }

    // 対象児童IDをキーとする更新対象の対象児童のMapを取得
    private Map<Id, DV_TaishoJido__c> getUpdateTaishoJidoMap(Set<Id> taishoJidoIdSet) {
        List<DV_TaishoJido__c> taishoJidoList = [SELECT Id,
                                                        EscalationStatus__c
                                                   FROM DV_TaishoJido__c
                                                  WHERE Id IN :taishoJidoIdSet];
        Map<Id, DV_TaishoJido__c> returnMap = new Map<Id, DV_TaishoJido__c>(taishoJidoList);

        return returnMap;
    }
}