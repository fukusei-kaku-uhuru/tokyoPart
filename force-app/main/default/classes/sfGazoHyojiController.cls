public without sharing class sfGazoHyojiController {

    private static final String NENGO_STR_REIWA  = '令和';
    private static final String NENGO_STR_HEISEI = '平成';
    private static final String NENGO_STR_SHOWA  = '昭和';
    private static final String NENGO_STR_TAISHO = '大正';
    private static final String NENGO_STR_NEN    = '年';
    private static final String NENGO_STR_GANNEN = '元年';

    private static final String MONTH_STR = '月';
    private static final String DAY_STR   = '日';

    private static final String ENGLISH_MONTH_SHORT_01 = 'JAN';
    private static final String ENGLISH_MONTH_SHORT_02 = 'FEB';
    private static final String ENGLISH_MONTH_SHORT_03 = 'MAR';
    private static final String ENGLISH_MONTH_SHORT_04 = 'APR';
    private static final String ENGLISH_MONTH_SHORT_05 = 'MAY';
    private static final String ENGLISH_MONTH_SHORT_06 = 'JUN';
    private static final String ENGLISH_MONTH_SHORT_07 = 'JUL';
    private static final String ENGLISH_MONTH_SHORT_08 = 'AUG';
    private static final String ENGLISH_MONTH_SHORT_09 = 'SEP';
    private static final String ENGLISH_MONTH_SHORT_10 = 'OCT';
    private static final String ENGLISH_MONTH_SHORT_11 = 'NOV';
    private static final String ENGLISH_MONTH_SHORT_12 = 'DEC';

    private static final String TEIGI_RECORDTYPE_NAME_STR_KOJIN_NINSHO  = 'KojinNinsho';
    private static final String TEIGI_RECORDTYPE_NAME_STR_KOZA_KAKUNIN  = 'KozaKakunin';
    private static final String TEIGI_RECORDTYPE_NAME_STR_TAISHO_JIDO   = 'TaishoJido';
    private static final String TEIGI_RECORDTYPE_NAME_STR_MOUSHITATE    = 'Moushitate';
    private static final String TEIGI_RECORDTYPE_NAME_STR_YUUSOUSHINSEI = 'Yuusoushinsei';

    public sfGazoHyojiController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getContentVersion(Id currentRecordId) {

        // 請求者に紐付く口座情報の書類表示の処理に必要な請求者のIDを保持
        Id seikyushaId = null;
        // 郵送申請の場合に認定請求に紐付く書類を対象児童に表示するために必要な認定請求のIDを保持
        Id ninteiSeikyuId = null;
        // 対象児童詳細画面の場合は請求者に紐付く口座情報の書類を表示する
        Schema.sObjectType entityType = currentRecordId.getSObjectType();
        // 口座情報の申請書類定義IDのセット（対象児童詳細画面の場合に設定される）
        Set<Id> kozaShoruiTeigiIdSet = new Set<Id>();

        // currentRecordIdが対象児童のIDの場合
        if(entityType == TaishoJido__c.sObjectType) {
            TaishoJido__c taishoJido = [SELECT Id,
                                               NinteiSeikyu__r.Seikyusha__c,
                                               NinteiSeikyu__c,
                                               NinteiSeikyu__r.IsYusoShinsei__c
                                          FROM TaishoJido__c
                                         WHERE Id = :currentRecordId];
            seikyushaId = taishoJido.NinteiSeikyu__r.Seikyusha__c;

            // 郵送申請の場合のみ認定請求に紐付く書類を対象児童詳細画面に表示する
            if(taishoJido.NinteiSeikyu__r.IsYusoShinsei__c) {
                ninteiSeikyuId = taishoJido.NinteiSeikyu__c;
            }
            
            List<ShinseiShoruiTeigi__c> kozaShoruiTeigiList = [SELECT Id
                                                                 FROM ShinseiShoruiTeigi__c
                                                                WHERE RecordType.DeveloperName = :TEIGI_RECORDTYPE_NAME_STR_KOZA_KAKUNIN];
            for(ShinseiShoruiTeigi__c teigi :kozaShoruiTeigiList) {
                kozaShoruiTeigiIdSet.add(teigi.Id);
            }
        }

        // recordIdからContentDocumentLink取得
        // 対象児童詳細画面の場合は請求者に紐付く書類も取得
        Set<Id> seikyushaContentDocumentIdSet = new Set<Id>();
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        if(seikyushaId != null) {
            // 郵送申請の場合（=ninteiSeikyuIdを設定している場合）
            if(ninteiSeikyuId != null) {
                linkList = [SELECT Id,
                                   ContentDocumentId,
                                   LinkedEntityId
                              FROM ContentDocumentLink
                             WHERE LinkedEntityId = :currentRecordId
                                OR LinkedEntityId = :seikyushaId
                                OR LinkedEntityId = :ninteiSeikyuId];
            } else {
                linkList = [SELECT Id,
                                   ContentDocumentId,
                                   LinkedEntityId
                              FROM ContentDocumentLink
                             WHERE LinkedEntityId = :currentRecordId OR LinkedEntityId = :seikyushaId];
            }
            
            for(ContentDocumentLink link :linkList) {
                if(link.LinkedEntityId == seikyushaId) {
                    seikyushaContentDocumentIdSet.add(link.ContentDocumentId);
                }
            }
        } else {
            linkList = [SELECT Id,
                               ContentDocumentId
                          FROM ContentDocumentLink
                         WHERE LinkedEntityId = :currentRecordId];
        }

        Set<Id> ContentDocumentIdSet = new Set<Id>();
        for(ContentDocumentLink link :linkList) {
            ContentDocumentIdSet.add(link.ContentDocumentId);
        }

        // ContentDocumentIdからContentVersionを取得
        List<ContentVersion> contentVersionList = [SELECT Id,
                                                          VersionDataUrl,
                                                          ShinseiShoruiTeigiId__c,             // 申請書類定義ID
                                                          ShinseiShoruiTeigiName__c,           // 申請書類定義名
                                                          Yoto__c,                             // 用途
                                                          IsDeletable__c,                      // 削除可能フラグ
                                                          MaskingFubi__c,                      // マスキング不備
                                                          OCR_Shimei__c,                       // 氏名（OCR結果）
                                                          OCR_SeinenGappi__c,                  // 生年月日（OCR結果）
                                                          OCR_Jusho__c,                        // 住所（OCR結果）
                                                          OCR_YukoKigen__c,                    // 有効期限（OCR結果）
                                                          OCR_TextZembun__c,                   // テキスト全文（OCR結果）
                                                          ShudoCheck_Shimei__c,                // 手動チェック：氏名
                                                          ShudoCheck_SeinenGappi__c,           // 手動チェック：生年月日
                                                          ShudoCheck_Jusho__c,                 // 手動チェック：住所
                                                          ShudoCheck_YukoKigen__c,             // 手動チェック：有効期限
                                                          ShudoCheck_TextZembun__c,            // 手動チェック：テキスト全文
                                                          Hantei_Shimei__c,                    // 判定：氏名
                                                          Hantei_SeinenGappi__c,               // 判定：生年月日
                                                          Hantei_Jusho__c,                     // 判定：住所
                                                          Hantei_YukoKigen__c,                 // 判定：有効期限
                                                          CreatedDate,
                                                          ContentDocumentId
                                                     FROM ContentVersion
                                                    WHERE ContentDocumentId IN :ContentDocumentIdSet
                                                      AND ChohyoShutsuryokuShubetsu__c = NULL // 帳票出力種別に値が入っているContentVersionは取得しない
                                                      AND IsLatest = true];                   // それぞれのファイルの最新版のみ取得

		// 申請書類定義名が長すぎると画面の提出書類タブが崩れる為、14文字以上の場合13文字に丸める
        // 請求者に紐付く書類のうち口座情報のものでないものは表示対象にしない
        List<ContentVersion> returnContentVersionList = new List<ContentVersion>();
		for(ContentVersion content : contentVersionList){
			String conVerName = content.ShinseiShoruiTeigiName__c != null ? content.ShinseiShoruiTeigiName__c : '';
    		if(conVerName.length() >= 14){
				content.ShinseiShoruiTeigiName__c = conVerName.left(12) + '～';
			}

            if(seikyushaId == null
            || !seikyushaContentDocumentIdSet.contains(content.ContentDocumentId)
            || kozaShoruiTeigiIdSet.contains(content.ShinseiShoruiTeigiId__c)) {
                returnContentVersionList.add(content);
            }
		}        

		return returnContentVersionList;
    }

    @AuraEnabled(cacheable=true)
    public static String getShinseiShoruiTeigiPickList() {

        List<ShinseiShoruiTeigi__c> tmpTeigiList = [SELECT Id, Name, RecordType.DeveloperName, Order__c FROM ShinseiShoruiTeigi__c ORDER BY Order__c ASC];
        Map<String, List<ShinseiShoruiTeigi__c>> teigiListMap = new Map<String, List<ShinseiShoruiTeigi__c>>();
        for(ShinseiShoruiTeigi__c teigi :tmpTeigiList) {
            if(!teigiListMap.containsKey(teigi.RecordType.DeveloperName)) {
                teigiListMap.put(teigi.RecordType.DeveloperName, new List<ShinseiShoruiTeigi__c>());
            }
            teigiListMap.get(teigi.RecordType.DeveloperName).add(teigi);
        }

        List<ShinseiShoruiTeigi__c> teigiList = new List<ShinseiShoruiTeigi__c>();
        if(teigiListMap.containsKey(TEIGI_RECORDTYPE_NAME_STR_KOJIN_NINSHO )) { teigiList.addAll(teigiListMap.get(TEIGI_RECORDTYPE_NAME_STR_KOJIN_NINSHO)); }
        if(teigiListMap.containsKey(TEIGI_RECORDTYPE_NAME_STR_KOZA_KAKUNIN )) { teigiList.addAll(teigiListMap.get(TEIGI_RECORDTYPE_NAME_STR_KOZA_KAKUNIN)); }
        if(teigiListMap.containsKey(TEIGI_RECORDTYPE_NAME_STR_TAISHO_JIDO  )) { teigiList.addAll(teigiListMap.get(TEIGI_RECORDTYPE_NAME_STR_TAISHO_JIDO)); }
        if(teigiListMap.containsKey(TEIGI_RECORDTYPE_NAME_STR_MOUSHITATE   )) { teigiList.addAll(teigiListMap.get(TEIGI_RECORDTYPE_NAME_STR_MOUSHITATE)); }
        if(teigiListMap.containsKey(TEIGI_RECORDTYPE_NAME_STR_YUUSOUSHINSEI)) { teigiList.addAll(teigiListMap.get(TEIGI_RECORDTYPE_NAME_STR_YUUSOUSHINSEI)); }
        
        List<sfGazoHyojiController.pickListWrapper> teigiSentakuList = new List<sfGazoHyojiController.pickListWrapper>();
        for(ShinseiShoruiTeigi__c teigi :teigiList) {
            sfGazoHyojiController.pickListWrapper wrapper = new sfGazoHyojiController.pickListWrapper();
            wrapper.label = teigi.Name;
            wrapper.value = teigi.Id;

            teigiSentakuList.add(wrapper);
        }

        return JSON.serialize(teigiSentakuList);
    }

    @AuraEnabled(cacheable=true)
    public static String setJidoHanteiKekka(Id currentRecordId, String hikakuNaiyoJson) {

        String shimei;
        Date seinenGappiDate;
        String jusho;
        Date shinsaKanryoDate;
        String shinsaStatus;

        Schema.sObjectType entityType = currentRecordId.getSObjectType();

        // currentRecordIdが認定請求のIDの場合
        if(entityType == NinteiSeikyu__c.sObjectType) {
            // 認定請求と請求者の情報を取得
            NinteiSeikyu__c ninteiSeikyu = [SELECT Id,
                                                   Seikyusha__r.Shimei__c,
                                                   Seikyusha__r.SeinenGappiDate__c,
                                                   Seikyusha__r.Jusho__c,
                                                   ShinseiKanryoDate__c,
                                                   ShinsaStatus__c
                                              FROM NinteiSeikyu__c
                                             WHERE Id = :currentRecordId
                                             LIMIT 1];
            
            shimei           = ninteiSeikyu.Seikyusha__r.Shimei__c;
            seinenGappiDate  = ninteiSeikyu.Seikyusha__r.SeinenGappiDate__c;
            jusho            = ninteiSeikyu.Seikyusha__r.Jusho__c;
            shinsaKanryoDate = ninteiSeikyu.ShinseiKanryoDate__c;
            shinsaStatus     = ninteiSeikyu.ShinsaStatus__c;
        // currentRecordIdが対象児童のIDの場合
        } else if(entityType == TaishoJido__c.sObjectType) {
            // 対象児童の情報を取得
            TaishoJido__c taishoJido = [SELECT Id,
                                               Shimei__c,
                                               SeinenGappiDate__c,
                                               Jusho__c,
                                               NinteiSeikyu__r.ShinseiKanryoDate__c,
                                               NinteiSeikyu__r.ShinsaStatus__c
                                          FROM TaishoJido__c
                                         WHERE Id = :currentRecordId
                                         LIMIT 1];

            shimei           = taishoJido.Shimei__c;
            seinenGappiDate  = taishoJido.SeinenGappiDate__c;
            jusho            = taishoJido.Jusho__c;
            shinsaKanryoDate = taishoJido.NinteiSeikyu__r.ShinseiKanryoDate__c;
            shinsaStatus     = taishoJido.NinteiSeikyu__r.ShinsaStatus__c;
        }
        

        List<Object> hikakuNaiyoList = (List<Object>)JSON.deserializeUntyped(hikakuNaiyoJson);
        List<sfGazoHyojiController.hikakuNaiyoWrapper> wrapperList = new List<sfGazoHyojiController.hikakuNaiyoWrapper>();

        for(Object hikakuNaiyo :hikakuNaiyoList) {
            Map<String, Object> hikakuNaiyoMap = (Map<String, Object>)hikakuNaiyo;
    
            sfGazoHyojiController.hikakuNaiyoWrapper wrapper = new sfGazoHyojiController.hikakuNaiyoWrapper();
            wrapper.id                 = (String)hikakuNaiyoMap.get('id');
                
            String shimeiOcr          = (String)hikakuNaiyoMap.get('shimeiOcr');
            String seinenGappiDateOcr = (String)hikakuNaiyoMap.get('seinenGappiDateOcr');
            String jushoOcr           = (String)hikakuNaiyoMap.get('jushoOcr');
            String yukoKigenDateOcr   = (String)hikakuNaiyoMap.get('yukoKigenDateOcr');
    
            try{
                wrapper.shimeiKekka = checkStringField(shimei, shimeiOcr, true);
            } catch(Exception e) {
                System.debug('error:' + e.getMessage());
                wrapper.shimeiKekka = false;
            }

            try{
                wrapper.seinenGappiDateKekka = checkDateToString(seinenGappiDate, seinenGappiDateOcr);
            } catch(Exception e) {
                System.debug('error:' + e.getMessage());
                wrapper.seinenGappiDateKekka = false;
            }

            try{
                wrapper.jushoKekka = checkStringField(jusho, jushoOcr, false);
            } catch(Exception e) {
                System.debug('error:' + e.getMessage());
                wrapper.jushoKekka = false;
            }

            try{
                wrapper.yukokigenDateKekka = checkYukokigen(shinsaKanryoDate, yukoKigenDateOcr);
            } catch(Exception e) {
                System.debug('error:' + e.getMessage());
                wrapper.yukokigenDateKekka = false;
            }
    
            wrapper.shinsaStatus = shinsaStatus;
    
            wrapperList.add(wrapper);
        }        

        return JSON.serialize(wrapperList);
    }

    @AuraEnabled
    public static String updateContentVersionTeigi(String setTeigiJson) {

        List<Object> setTeigiList         = (List<Object>) JSON.deserializeUntyped(setTeigiJson);
        List<ContentVersion> updateCVList = new List<ContentVersion>();

        for(Object setTeigi :setTeigiList) {
            Map<String, Object> setTeigiMap = (Map<String, Object>) setTeigi;

            ContentVersion updateCV = new ContentVersion();
            updateCV.id                      = (String)setTeigiMap.get('id');
            updateCV.ShinseiShoruiTeigiId__c = (String)setTeigiMap.get('shinseiShoruiTeigiId');

            updateCVList.add(updateCV);
        }

        // ContentVersionを更新
        String errorMessage = '';
        Savepoint sp = Database.setSavepoint();
        try {
            List<Database.SaveResult> srList = Database.update(updateCVList);
            for(Database.SaveResult sr :srList) {
                if(!sr.isSuccess()) {
                    for(Database.Error error : sr.getErrors()) {
                        errorMessage += error.getMessage() + ':';
                    }
                }
            } 
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }

        if(String.isNotBlank(errorMessage)) {
            Database.rollback(sp);
        }

        return errorMessage;
    }

    @AuraEnabled
    public static String updateContentVersionCheck(String checkKekkaJson){

        List<Object> checkKekkaList       = (List<Object>)JSON.deserializeUntyped(checkKekkaJson);
        List<ContentVersion> updateCVList = new List<ContentVersion>();

        for(Object checkKekka :checkKekkaList) {
            Map<String, Object> checkKekkaMap = (Map<String, Object>)checkKekka;

            ContentVersion updateCV = new ContentVersion();
            updateCV.id                                  = (String)checkKekkaMap.get('id');
            updateCV.ShudoCheck_Shimei__c                = (Boolean)checkKekkaMap.get('shimeiCheck');
            updateCV.ShudoCheck_SeinenGappi__c           = (Boolean)checkKekkaMap.get('seinenGappiCheck');
            updateCV.ShudoCheck_Jusho__c                 = (Boolean)checkKekkaMap.get('jushoCheck');
            updateCV.ShudoCheck_YukoKigen__c             = (Boolean)checkKekkaMap.get('yukokigenDateCheck');
            updateCV.ShudoCheck_TextZembun__c            = (Boolean)checkKekkaMap.get('textZembunCheck');
            updateCV.MaskingFubi__c                      = (Boolean)checkKekkaMap.get('maskingFubiCheck');

            updateCVList.add(updateCV);
        }

        // ContentVersionを更新
        String errorMessage = '';
        Savepoint sp = Database.setSavepoint();
        try {
            List<Database.SaveResult> srList = Database.update(updateCVList);
            for(Database.SaveResult sr :srList) {
                if(!sr.isSuccess()) {
                    for(Database.Error error : sr.getErrors()) {
                        errorMessage += error.getMessage() + ':';
                    }
                }
            } 
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }

        if(String.isNotBlank(errorMessage)) {
            Database.rollback(sp);
        }

        return errorMessage;
    }

    @AuraEnabled
    public static String updateContentVersionHantei(String checkKekkaJson) {

        List<Object> checkKekkaList       = (List<Object>)JSON.deserializeUntyped(checkKekkaJson);
        List<ContentVersion> updateCVList = new List<ContentVersion>();
        List<sfGazoHyojiController.hanteiKekkaWrapper> kekkaWrapperList   = new List<sfGazoHyojiController.hanteiKekkaWrapper>();

        for(Object checkKekka :checkKekkaList) {
            Map<String, Object> checkKekkaMap = (Map<String, Object>)checkKekka;

            ContentVersion updateCV = new ContentVersion();

            sfGazoHyojiController.hanteiWrapper wrapper = new sfGazoHyojiController.hanteiWrapper();
            wrapper.id                         = (String)checkKekkaMap.get('id');
            wrapper.shimeiKekkaAuto            = (Boolean)checkKekkaMap.get('shimeiKekkaAuto');
            wrapper.seinenGappiDateKekkaAuto   = (Boolean)checkKekkaMap.get('seinenGappiDateKekkaAuto');
            wrapper.jushoKekkaAuto             = (Boolean)checkKekkaMap.get('jushoKekkaAuto');
            wrapper.yukokigenDateKekkaAuto     = (Boolean)checkKekkaMap.get('yukokigenDateKekkaAuto');
            wrapper.shimeiKekkaManual          = (Boolean)checkKekkaMap.get('shimeiKekkaManual');
            wrapper.seinenGappiDateKekkaManual = (Boolean)checkKekkaMap.get('seinenGappiDateKekkaManual');
            wrapper.jushoKekkaManual           = (Boolean)checkKekkaMap.get('jushoKekkaManual');
            wrapper.yukokigenDateKekkaManual   = (Boolean)checkKekkaMap.get('yukokigenDateKekkaManual');

            updateCV.Id = wrapper.id;
            updateCV.Hantei_Shimei__c      = wrapper.getShimeiHantei()        ? 'OK' : '';
            updateCV.Hantei_SeinenGappi__c = wrapper.getSeinenGappiHantei()   ? 'OK' : '';
            updateCV.Hantei_Jusho__c       = wrapper.getJushoHantei()         ? 'OK' : '';
            updateCV.Hantei_YukoKigen__c   = wrapper.getYukokigenDateHantei() ? 'OK' : '';

            updateCVList.add(updateCV);

            sfGazoHyojiController.hanteiKekkaWrapper kekkaWrapper = new sfGazoHyojiController.hanteiKekkaWrapper();
            kekkaWrapper.id                 = wrapper.id;
            kekkaWrapper.Hantei_Shimei      = wrapper.getShimeiHantei();
            kekkaWrapper.Hantei_SeinenGappi = wrapper.getSeinenGappiHantei();
            kekkaWrapper.Hantei_Jusho       = wrapper.getJushoHantei();
            kekkaWrapper.Hantei_YukoKigen   = wrapper.getYukokigenDateHantei();

            kekkaWrapperList.add(kekkaWrapper);
        }

        // ContentVersionを更新
        Map<String, String> errorMessageMap = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            List<Database.SaveResult> srList = Database.update(updateCVList);
            for(Database.SaveResult sr :srList) {
                if(!sr.isSuccess()) {
                    String errorMessage = '';
                    for(Database.Error error : sr.getErrors()) {
                        errorMessage += error.getMessage() + ':';
                    }
                    errorMessageMap.put(sr.getId(), errorMessage);
                }
            } 
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }

        if(!errorMessageMap.isEmpty()) {
            Database.rollback(sp);
        }

        for(sfGazoHyojiController.hanteiKekkaWrapper w :kekkaWrapperList) {
            if(errorMessageMap.containsKey(w.id)) {
                w.errorMessage = errorMessageMap.get(w.id);
            }
        }

        return JSON.serialize(kekkaWrapperList);
    }

    private static Boolean checkStringField(String field1, String field2, Boolean hasClearBlank) {
        
        if(String.isBlank(field1) || String.isBlank(field2)) {
            return false;
        }

        String checkField1 = convertHankakuToZenkaku(field1);
        String checkField2 = convertHankakuToZenkaku(field2);
        if(String.isBlank(checkField1) || String.isBlank(checkField2)) {
            return false;
        }
        if(hasClearBlank) {
            checkField1 = checkField1.replace(' ', '').replace('　', '');
            checkField2 = checkField2.replace(' ', '').replace('　', '');
        }

        return checkField1.equals(checkField2);
    }

    private static Boolean checkDateToString(Date dateField, String stringField) {

        if(dateField == null || String.isBlank(stringField)) {
            return false;
        }

        Date checkDate = SfTriggerUtil.convertStringToDate(stringField);
        if(checkDate == null) {
            return false;
        }
        

        return dateField.isSameDay(checkDate);
    }

    private static Boolean checkYukokigen(Date shinsaKanryoDate, String YukokigenStr) {

        if(shinsaKanryoDate == null ||String.isBlank(YukokigenStr)) {
            return false;
        }

        Date checkDate = SfTriggerUtil.convertStringToDate(YukokigenStr);
        if(checkDate == null) {
            return false;
        }

        // 審査完了日が有効期限内であればtrue
        if(shinsaKanryoDate.daysBetween(checkDate) >= 0) {
            return true;
        }

        return false;
    }

    private class pickListWrapper {

        public String label {get; set;}
        public String value {get; set;}

        pickListWrapper() {
        }
    }

    private class hikakuNaiyoWrapper {

        public String id {get; set;}

        public Boolean shimeiKekka          {get; set;}
        public Boolean seinenGappiDateKekka {get; set;}
        public Boolean jushoKekka           {get; set;}
        public Boolean yukokigenDateKekka   {get; set;}
        
        public String shinsaStatus {get; set;}

        public hikakuNaiyoWrapper() {
        }
    }

    private class hanteiWrapper {

        public String id {get; set;}

        public Boolean shimeiKekkaAuto            {get; set;}
        public Boolean seinenGappiDateKekkaAuto   {get; set;}
        public Boolean jushoKekkaAuto             {get; set;}
        public Boolean yukokigenDateKekkaAuto     {get; set;}
        public Boolean shimeiKekkaManual          {get; set;}
        public Boolean seinenGappiDateKekkaManual {get; set;}
        public Boolean jushoKekkaManual           {get; set;}
        public Boolean yukokigenDateKekkaManual   {get; set;}

        public hanteiWrapper() {
        }

        public Boolean getShimeiHantei() {
            return shimeiKekkaAuto || shimeiKekkaManual;
        }

        public Boolean getSeinenGappiHantei() {
            return seinenGappiDateKekkaAuto || seinenGappiDateKekkaManual;
        }

        public Boolean getJushoHantei() {
            return jushoKekkaAuto || jushoKekkaManual;
        }

        public Boolean getYukokigenDateHantei() {
            return yukokigenDateKekkaAuto || yukokigenDateKekkaManual;
        }
    }

    private class hanteiKekkaWrapper {
        public String id {get; set;}

        public Boolean Hantei_Shimei      {get; set;}
        public Boolean Hantei_SeinenGappi {get; set;}
        public Boolean Hantei_Jusho       {get; set;}
        public Boolean Hantei_YukoKigen   {get; set;}

        public String errorMessage {get; set;}

        hanteiKekkaWrapper() {
        }
    }

    private static String convertHankakuToZenkaku(String targetStr) {

        // 空なら処理しない
        if(String.isBlank(targetStr)) {
            return '';
        }

        // 全角文字のみなら処理しない
        if(Pattern.matches('[^ -~｡-ﾟ]+', targetStr)) {
            return targetStr;
        }

        Map<String, String> henkanMap1 = new Map<String, String>();

        // 濁音、半濁音は2文字で1文字に変換するため先に処理する
        henkanMap1.put('ｶﾞ' , 'ガ');
        henkanMap1.put('ｷﾞ' , 'ギ');
        henkanMap1.put('ｸﾞ' , 'グ');
        henkanMap1.put('ｹﾞ' , 'ゲ');
        henkanMap1.put('ｺﾞ' , 'ゴ');
        henkanMap1.put('ｻﾞ' , 'ザ');
        henkanMap1.put('ｼﾞ' , 'ジ');
        henkanMap1.put('ｽﾞ' , 'ズ');
        henkanMap1.put('ｾﾞ' , 'ゼ');
        henkanMap1.put('ｿﾞ' , 'ゾ');
        henkanMap1.put('ﾀﾞ' , 'ダ');
        henkanMap1.put('ﾁﾞ' , 'ヂ');
        henkanMap1.put('ﾂﾞ' , 'ヅ');
        henkanMap1.put('ﾃﾞ' , 'デ');
        henkanMap1.put('ﾄﾞ' , 'ド');
        henkanMap1.put('ﾊﾞ' , 'バ');
        henkanMap1.put('ﾋﾞ' , 'ビ');
        henkanMap1.put('ﾌﾞ' , 'ブ');
        henkanMap1.put('ﾍﾞ' , 'ベ');
        henkanMap1.put('ﾎﾞ' , 'ボ');
        henkanMap1.put('ﾊﾟ' , 'パ');
        henkanMap1.put('ﾋﾟ' , 'ピ');
        henkanMap1.put('ﾌﾟ' , 'プ');
        henkanMap1.put('ﾍﾟ' , 'ペ');
        henkanMap1.put('ﾎﾟ' , 'ポ');
        henkanMap1.put('ｳﾞ' , 'ヴ');
        
        for(String key : henkanMap1.keySet()) {
            if(targetStr.contains(key)) {
                targetStr = targetStr.replaceAll(key, henkanMap1.get(key));
            }
        }


        Map<String, String> henkanMap2 = new Map<String, String>();
        henkanMap2.put('!' , '！');
        henkanMap2.put('"' , '”');
        henkanMap2.put('#' , '＃');
        henkanMap2.put('$' , '＄');
        henkanMap2.put('%' , '％');
        henkanMap2.put('&' , '＆');
        henkanMap2.put('\'' , '’');
        henkanMap2.put('(' , '（');
        henkanMap2.put(')' , '）');
        henkanMap2.put('*' , '＊');
        henkanMap2.put('+' , '＋');
        henkanMap2.put('' , '，');
        henkanMap2.put('-' , '−');
        henkanMap2.put('.' , '．');
        henkanMap2.put('/' , '／');
        henkanMap2.put('0' , '０');
        henkanMap2.put('1' , '１');
        henkanMap2.put('2' , '２');
        henkanMap2.put('3' , '３');
        henkanMap2.put('4' , '４');
        henkanMap2.put('5' , '５');
        henkanMap2.put('6' , '６');
        henkanMap2.put('7' , '７');
        henkanMap2.put('8' , '８');
        henkanMap2.put('9' , '９');
        henkanMap2.put(':' , '：');
        henkanMap2.put(';' , '；');
        henkanMap2.put('<' , '＜');
        henkanMap2.put('=' , '＝');
        henkanMap2.put('>' , '＞');
        henkanMap2.put('?' , '？');
        henkanMap2.put('@' , '＠');
        henkanMap2.put('A' , 'Ａ');
        henkanMap2.put('B' , 'Ｂ');
        henkanMap2.put('C' , 'Ｃ');
        henkanMap2.put('D' , 'Ｄ');
        henkanMap2.put('E' , 'Ｅ');
        henkanMap2.put('F' , 'Ｆ');
        henkanMap2.put('G' , 'Ｇ');
        henkanMap2.put('H' , 'Ｈ');
        henkanMap2.put('I' , 'Ｉ');
        henkanMap2.put('J' , 'Ｊ');
        henkanMap2.put('K' , 'Ｋ');
        henkanMap2.put('L' , 'Ｌ');
        henkanMap2.put('M' , 'Ｍ');
        henkanMap2.put('N' , 'Ｎ');
        henkanMap2.put('O' , 'Ｏ');
        henkanMap2.put('P' , 'Ｐ');
        henkanMap2.put('Q' , 'Ｑ');
        henkanMap2.put('R' , 'Ｒ');
        henkanMap2.put('S' , 'Ｓ');
        henkanMap2.put('T' , 'Ｔ');
        henkanMap2.put('U' , 'Ｕ');
        henkanMap2.put('V' , 'Ｖ');
        henkanMap2.put('W' , 'Ｗ');
        henkanMap2.put('X' , 'Ｘ');
        henkanMap2.put('Y' , 'Ｙ');
        henkanMap2.put('Z' , 'Ｚ');
        henkanMap2.put('[' , '［');
        henkanMap2.put('\\' , '￥');
        henkanMap2.put(']' , '］');
        henkanMap2.put('^' , '＾');
        henkanMap2.put('_' , '＿');
        henkanMap2.put('`' , '‘');
        henkanMap2.put('a' , 'ａ');
        henkanMap2.put('b' , 'ｂ');
        henkanMap2.put('c' , 'ｃ');
        henkanMap2.put('d' , 'ｄ');
        henkanMap2.put('e' , 'ｅ');
        henkanMap2.put('f' , 'ｆ');
        henkanMap2.put('g' , 'ｇ');
        henkanMap2.put('h' , 'ｈ');
        henkanMap2.put('i' , 'ｉ');
        henkanMap2.put('j' , 'ｊ');
        henkanMap2.put('k' , 'ｋ');
        henkanMap2.put('l' , 'ｌ');
        henkanMap2.put('m' , 'ｍ');
        henkanMap2.put('n' , 'ｎ');
        henkanMap2.put('o' , 'ｏ');
        henkanMap2.put('p' , 'ｐ');
        henkanMap2.put('q' , 'ｑ');
        henkanMap2.put('r' , 'ｒ');
        henkanMap2.put('s' , 'ｓ');
        henkanMap2.put('t' , 'ｔ');
        henkanMap2.put('u' , 'ｕ');
        henkanMap2.put('v' , 'ｖ');
        henkanMap2.put('w' , 'ｗ');
        henkanMap2.put('x' , 'ｘ');
        henkanMap2.put('y' , 'ｙ');
        henkanMap2.put('z' , 'ｚ');
        henkanMap2.put('{' , '｛');
        henkanMap2.put('|' , '｜');
        henkanMap2.put('}' , '｝');
        henkanMap2.put('~' , '〜');
        henkanMap2.put(' ' , '　');
        henkanMap2.put('｡' , '。');
        henkanMap2.put('｢' , '「');
        henkanMap2.put('｣' , '」');
        henkanMap2.put('､' , '、');
        henkanMap2.put('･' , '・');
        henkanMap2.put('ｦ' , 'ヲ');
        henkanMap2.put('ｧ' , 'ァ');
        henkanMap2.put('ｨ' , 'ィ');
        henkanMap2.put('ｩ' , 'ゥ');
        henkanMap2.put('ｪ' , 'ェ');
        henkanMap2.put('ｫ' , 'ォ');
        henkanMap2.put('ｬ' , 'ャ');
        henkanMap2.put('ｭ' , 'ュ');
        henkanMap2.put('ｮ' , 'ョ');
        henkanMap2.put('ｯ' , 'ッ');
        henkanMap2.put('ｰ' , 'ー');
        henkanMap2.put('ｱ' , 'ア');
        henkanMap2.put('ｲ' , 'イ');
        henkanMap2.put('ｳ' , 'ウ');
        henkanMap2.put('ｴ' , 'エ');
        henkanMap2.put('ｵ' , 'オ');
        henkanMap2.put('ｶ' , 'カ');
        henkanMap2.put('ｷ' , 'キ');
        henkanMap2.put('ｸ' , 'ク');
        henkanMap2.put('ｹ' , 'ケ');
        henkanMap2.put('ｺ' , 'コ');
        henkanMap2.put('ｻ' , 'サ');
        henkanMap2.put('ｼ' , 'シ');
        henkanMap2.put('ｽ' , 'ス');
        henkanMap2.put('ｾ' , 'セ');
        henkanMap2.put('ｿ' , 'ソ');
        henkanMap2.put('ﾀ' , 'タ');
        henkanMap2.put('ﾁ' , 'チ');
        henkanMap2.put('ﾂ' , 'ツ');
        henkanMap2.put('ﾃ' , 'テ');
        henkanMap2.put('ﾄ' , 'ト');
        henkanMap2.put('ﾅ' , 'ナ');
        henkanMap2.put('ﾆ' , 'ニ');
        henkanMap2.put('ﾇ' , 'ヌ');
        henkanMap2.put('ﾈ' , 'ネ');
        henkanMap2.put('ﾉ' , 'ノ');
        henkanMap2.put('ﾊ' , 'ハ');
        henkanMap2.put('ﾋ' , 'ヒ');
        henkanMap2.put('ﾌ' , 'フ');
        henkanMap2.put('ﾍ' , 'ヘ');
        henkanMap2.put('ﾎ' , 'ホ');
        henkanMap2.put('ﾏ' , 'マ');
        henkanMap2.put('ﾐ' , 'ミ');
        henkanMap2.put('ﾑ' , 'ム');
        henkanMap2.put('ﾒ' , 'メ');
        henkanMap2.put('ﾓ' , 'モ');
        henkanMap2.put('ﾔ' , 'ヤ');
        henkanMap2.put('ﾕ' , 'ユ');
        henkanMap2.put('ﾖ' , 'ヨ');
        henkanMap2.put('ﾗ' , 'ラ');
        henkanMap2.put('ﾘ' , 'リ');
        henkanMap2.put('ﾙ' , 'ル');
        henkanMap2.put('ﾚ' , 'レ');
        henkanMap2.put('ﾛ' , 'ロ');
        henkanMap2.put('ﾜ' , 'ワ');
        henkanMap2.put('ﾝ' , 'ン');
        henkanMap2.put('ﾞ' , '゛');
        henkanMap2.put('ﾟ' , '゜');

        // エスケープが必要な文字
        Set<String> escapeChars = new Set<String>();
        escapeChars.add('\\');
        escapeChars.add('*');
        escapeChars.add('+');
        escapeChars.add('.');
        escapeChars.add('?');
        escapeChars.add('{');
        escapeChars.add('}');
        escapeChars.add('(');
        escapeChars.add(')');
        escapeChars.add('[');
        escapeChars.add(']');
        escapeChars.add('^');
        escapeChars.add('$');
        escapeChars.add('|');
        escapeChars.add('/');

        for(String key : henkanMap2.keySet()) {
            if(targetStr.contains(key)) {
                String tempKey = key;
                if(escapeChars.contains(key)) {
                    tempKey = '\\' + tempKey;
                }
                targetStr = targetStr.replaceAll(tempKey, henkanMap2.get(key));
            }
        }
        String comma = '，';
        if(targetStr.contains(comma)) {
            targetStr = targetStr.replaceAll(comma, '');
        }

        return targetStr;
    }
}