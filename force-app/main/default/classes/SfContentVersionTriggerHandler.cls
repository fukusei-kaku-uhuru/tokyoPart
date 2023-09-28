public without sharing class SfContentVersionTriggerHandler {

    /**
     * 必要書類がアップロードによりS3へバックアップするTrigger10MB/ファイルが制限。
     */
    public static void backupFile(List<ContentVersion> cvList) {

        List<String> contentVersionBackupListIds = new List<String>();
        for (ContentVersion ver : cvList) {
            contentVersionBackupListIds.add(ver.Id);
        }

        // S3へバックアップする処理を行う
        if(!System.isFuture() && !System.isBatch()){
            // コメントアウト by ogata
            // fileUpload(contentVersionBackupListIds);
        }
    }

    /**
     * S3へバックアップする処理を行う
     * @param recordIds
     */
    @future(callout=true)
    public static void fileUpload(List<String> recordIds){
        // コメントアウト by ogata start
        // AWSFileService service=new AWSFileService();
        // List<ContentVersion> cvlist = service.uploadDocuments(recordIds);
        // コメントアウト by ogata end
    }

    /**
     * 郵送申請の際にスキャンしたデータを取り込む場合、
     * ファイル名に含まれるIDをキーに郵送申請のレコードを取得して、ContentDocumentLinkに登録する
     */
    public static void insertContentDocumentLink(List<ContentVersion> cvList) {

        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        Map<String,String> ShinseiShoruiTeigiMap = new Map<String,String>();
        // 申請書類定義のレコードを取得
        List<ShinseiShoruiTeigi__c> ShinseiShoruiTeigiList = [SELECT id,ShoruiSetsumeiForSearch__c FROM ShinseiShoruiTeigi__c WHERE  ShoruiSetsumeiForSearch__c IN ('A','B','C','D','E','F')];
        for (ShinseiShoruiTeigi__c ShinseiShoruiTeigi : ShinseiShoruiTeigiList) {
            ShinseiShoruiTeigiMap.put(ShinseiShoruiTeigi.ShoruiSetsumeiForSearch__c, ShinseiShoruiTeigi.Id);
        }

        Set<String> yusoShinseiIds = new Set<String>();
        Map<String,ContentVersion> hasJobKanriIdCvMaps = new Map<String,ContentVersion>();
        List<ContentVersion> ContentVersionListForUpdate = new List<ContentVersion>();
        // キー；ContentVersionId、値：郵送申請のId
        Map<String,String> contentVersionMap = new Map<String,String>();
        for (ContentVersion cv : cvList) {
            // ファイル名が18桁以上の場合、ファイルの18桁を取得
            String titleID = getID(cv.Title);
            if(titleID != null && cv.Shubetsu__c == '郵送') {
                contentVersionMap.put(cv.Id, titleID);
                // 郵送申請のIdをセットする
                yusoShinseiIds.add(titleID);

                String shoruiSetsumei = cv.Title.subString(cv.Title.length() -1);
                if(shoruiSetsumei == 'A' || shoruiSetsumei == 'B' || shoruiSetsumei == 'C' || shoruiSetsumei == 'D' || shoruiSetsumei == 'E' || shoruiSetsumei == 'F') {
                    // 郵送申請の場合、申請書類定義IDを取得する
                    ContentVersion contentVersionForUpdate = new ContentVersion(Id = cv.Id);
                    contentVersionForUpdate.ShinseiShoruiTeigiId__c = ShinseiShoruiTeigiMap.get(shoruiSetsumei);
                    ContentVersionListForUpdate.add(contentVersionForUpdate);
                }
            }

            if(String.isNotBlank(cv.JobKanriId__c)) {
                hasJobKanriIdCvMaps.put(cv.Id,cv);
            }
        }
        // 郵送申請のIdが存在する場合
        if(yusoShinseiIds.size() > 0) {
            // 認定請求のレコードを取得
            List<NinteiSeikyu__c> ninteiSeikyuList = [SELECT Id,YusoShinsei__c FROM NinteiSeikyu__c WHERE YusoShinsei__c =:yusoShinseiIds ORDER BY lastmodifiedDate ASC];

            Map<String,NinteiSeikyu__c> ninteiSeikyuMap = new Map<String,NinteiSeikyu__c>();
            for (NinteiSeikyu__c ninteiSeikyu : ninteiSeikyuList) {
                ninteiSeikyuMap.put(ninteiSeikyu.YusoShinsei__c, ninteiSeikyu);  
            }

            // 郵送申請のレコードを取得（チェック用）
            List<YusoShinsei__c> yusoShinseiList = [SELECT Id FROM YusoShinsei__c WHERE Id =:yusoShinseiIds];
            Map<String,YusoShinsei__c> yusoShinseiMap = new Map<String,YusoShinsei__c>();
            for (YusoShinsei__c yusoShinsei : yusoShinseiList) {
                yusoShinseiMap.put(yusoShinsei.Id, yusoShinsei);    
            }

            for (ContentVersion cv : cvList) {
                if(ninteiSeikyuMap.get(contentVersionMap.get(cv.Id)) != null
                    && yusoShinseiMap.get(contentVersionMap.get(cv.Id)) != null ) {
                    // ContentDocumentLinkを作成する
                    ContentDocumentLink link = new ContentDocumentLink(
                        ContentDocumentId = cv.ContentDocumentId,
                        // LinkedEntityIdは、認定請求のId
                        LinkedEntityId = ninteiSeikyuMap.get(contentVersionMap.get(cv.Id)).Id,
                        // Visibilityは、'AllUsers'（ファイルを参照する権限を持つすべてのユーザが使用できる）
                        Visibility = 'AllUsers',
                        // ShareTypeは、'V'（共有）
                        ShareType = 'V'
                    );
                    contentDocumentLinkList.add(link);
                }
            }

            // ジョブ管理IDを入っているContentVersionの場合
            // ジョブ管理で呼ばれたLambdaの処理結果として、ContentVersionが登録される。
            // 紐づけがされていないため、ContentDocumentLinkに登録をする。
            if(hasJobKanriIdCvMaps.Values().size() > 0) {
                for(ContentVersion cv:hasJobKanriIdCvMaps.Values()) {
                    // ContentDocumentLinkを作成する
                    ContentDocumentLink link = new ContentDocumentLink(
                        ContentDocumentId = cv.ContentDocumentId,
                        // LinkedEntityIdは、ジョブ管理のId
                        LinkedEntityId = cv.JobKanriId__c,
                        // Visibilityは、'AllUsers'（ファイルを参照する権限を持つすべてのユーザが使用できる）
                        Visibility = 'AllUsers',
                        // ShareTypeは、'V'（共有）
                        ShareType = 'V'
                    );
                    contentDocumentLinkList.add(link);
                }
            }
            
            if(ContentVersionListForUpdate.size() > 0) {
                update ContentVersionListForUpdate;
            }

            if(contentDocumentLinkList.size() > 0) {
                insert contentDocumentLinkList;
            }
        }
    }

    /**
     * 郵送申請がアップロードされたらOCRを起動するTrigger（OPROARTSアクション）
     */
    public static void startOrcServiceAPIForYusou(List<ContentVersion> cvList) {
        System.debug('OCR 郵送を起動するTrigger');
        Set<String> yusoShinseiIds = new Set<String>();
        for (ContentVersion cv : cvList) {  
            if(cv.Shubetsu__c == '郵送'){
                String yusoShinseiId = getID(cv.Title);
                if(yusoShinseiId != null){
                    yusoShinseiIds.add(yusoShinseiId);
                }
            }
        }
        
        Map<String,YusoShinsei__c> yusoShinseiMap = new Map<String,YusoShinsei__c>();
        Map<String,NinteiSeikyu__c> ninteiSeikyuMap = new Map<String,NinteiSeikyu__c>();

        // 郵送申請にLinkedEntityIdと一致するレコードがあるかを確認する
        if(yusoShinseiIds.size() > 0){
            List<YusoShinsei__c> yusoShinseiList = [SELECT Id FROM YusoShinsei__c WHERE Id in:yusoShinseiIds];
            for (YusoShinsei__c yusoShinsei : yusoShinseiList) {
                yusoShinseiMap.put(yusoShinsei.Id, yusoShinsei);
            }
            // 認定請求のレコードを取得
            List<NinteiSeikyu__c> ninteiSeikyuList = [SELECT Id,YusoShinsei__c,Seikyusha__c FROM NinteiSeikyu__c WHERE YusoShinsei__c in:yusoShinseiIds ORDER BY lastmodifiedDate ASC];
            for (NinteiSeikyu__c ninteiSeikyu : ninteiSeikyuList) {
                ninteiSeikyuMap.put(ninteiSeikyu.YusoShinsei__c, ninteiSeikyu);  
            }
        }
            
        // 郵送申請登録用OPROARTSアクションリスト
        List<oproarts1__OproartsAction__c> oprYusoList = new List<oproarts1__OproartsAction__c>();
    
        oproarts1__OproartsAction__c oprObj;
 
        for (ContentVersion cv : cvList) {
            if(getSerialNo(cv.Title) == '1'){
                oprObj = new oproarts1__OproartsAction__c();
                // 郵送申請の場合
                if(cv.Shubetsu__c == '郵送' && ninteiSeikyuMap.get(getID(cv.Title)) != null){
                    System.debug('郵送');
                    // 有効
                    oprObj.oproarts1__IsActive__c = true;
                    // サービス
                    oprObj.oproarts1__Service__c = 'sf0234_tokyo';
                    // 名前空間プレフィックス
                    oprObj.oproarts1__NamespacePrefix__c = 'oproarts1';
                    // ステータス
                    oprObj.oproarts1__Status__c = 'Unprocessed';
                    // タイプ
                    oprObj.oproarts1__Type__c = 'ocr_ninteiseikyu';
                    // レコードID
                    oprObj.oproarts1__RecordIds__c = ninteiSeikyuMap.get(getID(cv.Title)).Id;
                    // 追加のパラメーター
                    oprObj.oproarts1__AdditionalParameters__c = 
                    '{SeikyushaID: "'+ ninteiSeikyuMap.get(getID(cv.Title)).Seikyusha__c + '"}';
                    oprObj.oproarts1__OproartsKey__c = System.Label.OproartsKey;

                    // 郵送申請リストに追加
                    oprYusoList.add(oprObj);
                }
            }    
        }
        System.debug(oprYusoList);
        if(oprYusoList.size() > 0){
            delayInsert(oprYusoList);
        }
    }

   /**
     * 請求者/対象児童の必要書類がアップロードされたらOCRを起動するTrigger（OPROARTSアクション）
     */
    // public static void startOrcServiceAPIForWeb(List<ContentVersion> cvOldList, List<ContentVersion> cvNewList) {
    //     System.debug('OCR Webを起動するTrigger');
    //     Set<String> cvDocIds = new Set<String>();
    //     List<ContentVersion> targetCvList = new List<ContentVersion>();
    //     for (ContentVersion cvNew : cvNewList) {  
    //         for (ContentVersion cvOld : cvOldList) {  
    //             if(cvNew.Id == cvOld.Id && cvNew.Shubetsu__c == 'Web' && String.isBlank(cvOld.Shubetsu__c)) {
    //                 cvDocIds.add(cvNew.ContentDocumentId);
    //                 targetCvList.add(cvNew);
    //                 break;
    //             }
    //         }
    //     }
        
    //     Set<String> linkedEntityIds = new Set<String>();
    //     Map<String,String> contentVersionMap = new Map<String,String>();
    //     Map<String,TaishoJido__c> taishoJidoMap = new Map<String,TaishoJido__c>();
    //     Map<String,DV_TaishoJido__c> dvTaishoJidoMap = new Map<String,DV_TaishoJido__c>();
        
    //     // ContentDocumentLinkからLinkedEntityIdを取得する。
    //     if(cvDocIds.size() > 0){
    //         List<ContentDocumentLink> cdLinkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId in:cvDocIds];
    //         for (ContentDocumentLink cdLink : cdLinkList) {
    //             linkedEntityIds.add(cdLink.LinkedEntityId);
    //             contentVersionMap.put(cdLink.ContentDocumentId, cdLink.LinkedEntityId);
    //         }

    //         // 対象児童にLinkedEntityIdと一致するレコードがあるかを確認する
    //         List<TaishoJido__c> taishoJidoList = [SELECT Id FROM TaishoJido__c WHERE Id in:linkedEntityIds];
    //         for (TaishoJido__c taishoJido : taishoJidoList) {
    //             taishoJidoMap.put(taishoJido.Id, taishoJido);
    //         }

    //         // 対象児童（DV被害者・里親）にLinkedEntityIdと一致するレコードがあるかを確認する
    //         List<DV_TaishoJido__c> dvTaishoJidoList = [SELECT Id FROM DV_TaishoJido__c WHERE Id in:linkedEntityIds];
    //         for (DV_TaishoJido__c dvTaishoJido : dvTaishoJidoList) {
    //             dvTaishoJidoMap.put(dvTaishoJido.Id, dvTaishoJido);
    //         }
    //     }
            
    //     // WEB登録用OPROARTSアクションリスト
    //     List<oproarts1__OproartsAction__c> oprWebList = new List<oproarts1__OproartsAction__c>();
    
    //     oproarts1__OproartsAction__c oprObj;
 
    //     for (ContentVersion cv : targetCvList) {
    //         System.debug('WEB');
    //         oprObj = new oproarts1__OproartsAction__c();

    //         System.debug('OCR_Syoruisyubetu__c:'+cv.OCR_Syoruisyubetu__c);
    //         // WEBの場合
    //         if(cv.OCR_Syoruisyubetu__c == 'ocr_ininjo'){
    //             System.debug('委任状OCR');
    //             // 委任状OCR
    //             // 対象児童IDの存在チェック
    //             if(taishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null
    //                 || dvTaishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null) {
    //                 // 有効
    //                 oprObj.oproarts1__IsActive__c = true;
    //                 // サービス
    //                 oprObj.oproarts1__Service__c = 'sf0234_tokyo';
    //                 // 名前空間プレフィックス
    //                 oprObj.oproarts1__NamespacePrefix__c = 'oproarts1';
    //                 // ステータス
    //                 oprObj.oproarts1__Status__c = 'Unprocessed';
    //                 // タイプ
    //                 oprObj.oproarts1__Type__c = 'ocr_ininjo';
    //                 // レコードID
    //                 oprObj.oproarts1__RecordIds__c = cv.Id;
    //                 if(taishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null) {
    //                     // 追加のパラメーター
    //                     oprObj.oproarts1__AdditionalParameters__c = 
    //                     '{TaishoJidoID: "'+ taishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)).id + '"}'; 
    //                 } else if (dvTaishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null) {
    //                     // 追加のパラメーター
    //                     oprObj.oproarts1__AdditionalParameters__c = 
    //                     '{TaishoJidoID: "'+ dvTaishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)).id + '"}'; 
    //                 }
    //                 oprObj.oproarts1__OproartsKey__c = System.Label.OproartsKey;
    //             }
    //         }else if(cv.OCR_Syoruisyubetu__c == 'ocr_fuboshitei'){
    //             System.debug('父母指定者指定届OCR');
    //             // 父母指定者指定届OCR
    //             // 対象児童IDの存在チェック
    //             if(taishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null
    //                 || dvTaishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null) {
    //                 // 有効
    //                 oprObj.oproarts1__IsActive__c = true;
    //                 // サービス
    //                 oprObj.oproarts1__Service__c = 'sf0234_tokyo';
    //                 // 名前空間プレフィックス
    //                 oprObj.oproarts1__NamespacePrefix__c = 'oproarts1';
    //                 // ステータス
    //                 oprObj.oproarts1__Status__c = 'Unprocessed';
    //                 // タイプ
    //                 oprObj.oproarts1__Type__c = 'ocr_fuboshitei';
    //                 // レコードID
    //                 oprObj.oproarts1__RecordIds__c = cv.Id;
                    
    //                 if(taishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null) {
    //                     // 追加のパラメーター
    //                     oprObj.oproarts1__AdditionalParameters__c = 
    //                     '{TaishoJidoID: "'+ taishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)).id + '"}'; 
    //                 } else if (dvTaishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)) != null) {
    //                     // 追加のパラメーター
    //                     oprObj.oproarts1__AdditionalParameters__c = 
    //                     '{TaishoJidoID: "'+ dvTaishoJidoMap.get(contentVersionMap.get(cv.ContentDocumentId)).id + '"}'; 
    //                 }
    //                 oprObj.oproarts1__OproartsKey__c = System.Label.OproartsKey;
    //             }     
    //         }else{
    //             System.debug('本人確認書類OCR');
    //             // 本人確認書類OCR
    //             // 有効
    //             oprObj.oproarts1__IsActive__c = true;
    //             // サービス
    //             oprObj.oproarts1__Service__c = 'sf0234_tokyo';
    //             // 名前空間プレフィックス
    //             oprObj.oproarts1__NamespacePrefix__c = 'oproarts1';
    //             // ステータス
    //             oprObj.oproarts1__Status__c = 'Unprocessed';
    //             // タイプ
    //             oprObj.oproarts1__Type__c = 'ocr_honninkakunin';
    //             // レコードID
    //             oprObj.oproarts1__RecordIds__c = cv.Id;
    //             // 追加のパラメーター
    //             oprObj.oproarts1__AdditionalParameters__c = 
    //             '{ShinseiShoruiTeigiName: "'+ cv.OCR_Syoruisyubetu__c + '"}';
    //             oprObj.oproarts1__OproartsKey__c = System.Label.OproartsKey;
    //         }
    //         oprWebList.add(oprObj);
    //     }
    //     System.debug(oprWebList);
    //     if(oprWebList.size() > 0){
    //         insert oprWebList;
    //     }
    // }

    /**
     * ファイル名からIDを取得する
     * ファイル名ルール：${ID}-${連番}-$(種別).jpg
     */
    public static String getID(String filename) {
        String id = null;

        Pattern pattern = Pattern.compile('^([^-]+)-[0-9]+-');
        Matcher matcher = pattern.matcher(filename);

        if (matcher.find()) {
            id = matcher.group(1);
        }
        return id;
    }

    /**
     * ファイル名から連番を取得する
     * ファイル名ルール：${ID}-${連番}-$(種別).jpg
     */
    public static String getSerialNo(String filename) {
        String serialNo = null;

        Pattern pattern = Pattern.compile('-([0-9]+)-');
        Matcher matcher = pattern.matcher(filename);

        if (matcher.find()) {
            serialNo = String.isNotBlank(matcher.group(1)) == true ? Integer.valueOf(matcher.group(1)) + '' : '';
        }
        return serialNo;
    }

    /**
     * 郵送申請の場合、遅延実行
     */
    public static void delayInsert(List<oproarts1__OproartsAction__c> oproartsList){

        // 5分後に起動指定
        Datetime dtNow = Datetime.now();
        Datetime dtSchedule = dtNow.addMinutes(Integer.valueOf(System.Label.JobDelayExecTime));
        String cronString = dtSchedule.second() + ' ' +
            + dtSchedule.minute() + ' '
            + dtSchedule.hour() + ' '
            + dtSchedule.day() + ' '
            + dtSchedule.month() + ' '
            + '? '
            + dtSchedule.year();
        System.debug('cronString:' + cronString);
        String jobName = 'YusoShinseidelayExec ' + cronString + ' ' + oproartsList[0].Id;
        
        if (!Test.isRunningTest()){
            YusoShinseiOproartsInsertSchedule oproartsSchedule= new YusoShinseiOproartsInsertSchedule(oproartsList,jobName);
            String jobID = System.schedule(jobName, cronString, oproartsSchedule);
        }
    }
}