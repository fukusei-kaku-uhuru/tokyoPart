public with sharing class ExFileUploadController {

    @TestVisible private static final String YOTO_FILE_UPLOAD = '本人確認';

    @TestVisible private static final String HOHO_FILE_UPLOAD = '券面アップロード';

    @TestVisible private static final String SHUBETSU_FILE_UPLOAD = 'Web';

    private static String siteMode = ExLwcUtil.getSiteMode();

    // アップロード必要なファイル数
    private static Integer minimum = siteMode == ExLwcUtil.MODE_SATOYA ? 1 : 2;

    // ファイル種別一覧取得
    @AuraEnabled(cacheable=true)
    public static FileTypeWrapper getFileType() {
        List<ShinseiShoruiTeigi__c> defineFileList = ExShinseiShoruiTeigiUtil.getListByKojinNinsho();

        List<FileType> tmpList = new List<FileType>();
        for (ShinseiShoruiTeigi__c defineFile:defineFileList) {
            FileType tmp = new FileType();
            tmp.fileTeigiId = defineFile.Id;
            tmp.fileTeigiName = defineFile.Name;
            tmp.fileViewTeigiName = defineFile.Name;
            tmp.isMyNumber = defineFile.IsMyNumber__c;
            tmp.isKenkoHoken = defineFile.IsKenkoHoken__c;
            tmp.isJuminHyo = defineFile.IsJuminHyo__c;
            tmp.fileTeigiSetsumei = defineFile.ShoruiSetsumei__c;
            tmpList.add(tmp);
        }

        FileTypeWrapper wrapper = new FileTypeWrapper();
        wrapper.fileTypeList = tmpList;
        return wrapper;
    }

    // 添付ファイル一覧取得
    @AuraEnabled(cacheable=false)
    public static FileDetailWrapper getDocument(String recordId, String dummy) {
        if (String.isEmpty(recordId)) {
            return null;
        }

        List<ShinseiShoruiTeigi__c> defineFileList = ExShinseiShoruiTeigiUtil.getListByKojinNinsho();

        List<FileDetail> fileList = getFileList(recordId);

        FileDetailWrapper wrapper = new FileDetailWrapper();
        wrapper.fileList = fileList;
        wrapper.checkOK = validationDocument(fileList, defineFileList);
        return wrapper;
    }

    // 券面アップロードチェック
    private static Boolean validationDocument(List<FileDetail> fileList, List<ShinseiShoruiTeigi__c> defineFileList){

        // 申請書類定義を基に、アップロードされてるファイルを確認
        Map<String, FileTypeCheck> singleMap = new Map<String, FileTypeCheck>();
        Map<String, Map<String, FileTypeCheck>> multiMap = new Map<String, Map<String, FileTypeCheck>>();
        for (ShinseiShoruiTeigi__c defineFile:defineFileList) {
            String fileTeigiKey = defineFile.ShoruiTeigiKey__c;
            String fileTeigiId = defineFile.Id;

            Boolean isInclude = false;
            for (FileDetail fileDetail:fileList) {
                if (fileDetail.fileTeigiId == fileTeigiId) {
                    isInclude = true;
                    break;
                }
            }
            // キーなし
            if (String.isEmpty(fileTeigiKey)) {
                FileTypeCheck tmp = new FileTypeCheck();
                tmp.fileTeigiId = fileTeigiId;
                tmp.isInclude = isInclude;
                singleMap.put(fileTeigiId, tmp);
            }
            // キーあり
            else {
                if (!multiMap.containsKey(fileTeigiKey)) {
                    multiMap.put(fileTeigiKey, new Map<String, FileTypeCheck>());
                }
                Map<String, FileTypeCheck> tmpMap = multiMap.get(fileTeigiKey);
                FileTypeCheck tmp = new FileTypeCheck();
                tmp.fileTeigiId = fileTeigiId;
                tmp.isInclude = isInclude;
                tmpMap.put(fileTeigiId, tmp);
            }
        }

        // ファイルのカウント取得
        Integer count = 0;
        // キーなしファイルのカウント
        for (FileTypeCheck tmp:singleMap.values()) {
            if (!tmp.isInclude) {
                continue;
            }

            count++;
        }
        // キーありファイルのカウント
        for (Map<String, FileTypeCheck> tmpMap:multiMap.values()) {
            Boolean isInclude = true;
            String fileKubun = '';
            for (FileTypeCheck tmp:tmpMap.values()) {
                fileKubun = tmp.fileKubun;
                if (!tmp.isInclude) {
                    isInclude = false;
                    break;
                }
            }

            if (!isInclude) {
                continue;
            }

            count++;
        }

        return count >= minimum;
    }

    // ContentVersion：付随情報更新
    @AuraEnabled
    public static void updateContentVersion(String contentVersionId, String fileTeigiId, Boolean myNumberOmote, Boolean kenkoHokenMask) {

        List<ContentVersion> contentVersionList = [SELECT Id FROM ContentVersion WHERE Id=:contentVersionId];
        if (contentVersionList.size() > 0) {
            ContentVersion contentVersion = contentVersionList.get(0);
            contentVersion.ShinseiShoruiTeigiId__c = fileTeigiId;
            contentVersion.HoninKakuninShoruiMyNumberOmote__c = myNumberOmote;
            contentVersion.HoninKakuninShoruiMaskKenkoHoken__c = kenkoHokenMask;
            contentVersion.Yoto__c = YOTO_FILE_UPLOAD;
            contentVersion.Shubetsu__c = SHUBETSU_FILE_UPLOAD;

            // 申請書類定義名、本人確認書類区分はトリガで設定
            update contentVersion;
        }
        return;
    }

    // 認定請求：マスク設定更新
    @AuraEnabled
    public static void updateNinteiSeikyu(String recordId) {

        Boolean myNumberOmote = false;
        Boolean kenkoHokenMask = false;
        List<ContentDocumentLink> documentLinkList = getContentDocumentLinkList(recordId);
        for (ContentDocumentLink documentLink:documentLinkList) {
            if (documentLink.ContentDocument.LatestPublishedVersion.HoninKakuninShoruiMyNumberOmote__c) {
                myNumberOmote = true;
            }
            if (documentLink.ContentDocument.LatestPublishedVersion.HoninKakuninShoruiMaskKenkoHoken__c) {
                kenkoHokenMask = true;
            }
        }

        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<NinteiSeikyu__c> objList = [SELECT Id FROM NinteiSeikyu__c WHERE Id=:recordId];
            if (objList.size() == 0) {
                return;
            }
            NinteiSeikyu__c updateObj = objList.get(0);
            updateObj.TempuShitanohaHyomenNomi__c = myNumberOmote;
            updateObj.MaskingCheck_02__c = kenkoHokenMask;
            update updateObj;

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV・里親
            List<DV_NinteiSeikyu__c> objList = [SELECT Id FROM DV_NinteiSeikyu__c WHERE Id=:recordId];
            if (objList.size() == 0) {
                return;
            }
            DV_NinteiSeikyu__c updateObj = objList.get(0);
            updateObj.TempuShitanohaHyomenNomi__c = myNumberOmote;
            updateObj.MaskingCheck_02__c = kenkoHokenMask;
            update updateObj;

        }

        return;
    }

    // 請求者：本人確認選択更新
    @AuraEnabled
    public static void updateSeikyusha(String recordId) {
        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<NinteiSeikyu__c> seikyuList = [SELECT Id,Seikyusha__c FROM NinteiSeikyu__c WHERE Id = :recordId];
            NinteiSeikyu__c seikyu = seikyuList.get(0);

            Seikyusha__c updateObj = new Seikyusha__c();
            updateObj.Id = seikyu.Seikyusha__c;
            updateObj.HonninKakuninHoho__c = HOHO_FILE_UPLOAD;
            update updateObj;

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV・里親
            List<DV_NinteiSeikyu__c> seikyuList = [SELECT Id,Seikyusya__c FROM DV_NinteiSeikyu__c WHERE Id = :recordId];
            DV_NinteiSeikyu__c seikyu = seikyuList.get(0);

            DV_Seikyusha__c updateObj = new DV_Seikyusha__c();
            updateObj.Id = seikyu.Seikyusya__c;
            updateObj.HonninKakuninHoho__c = HOHO_FILE_UPLOAD;
            update updateObj;

        }

        return;
    }

    // 本人確認の添付ファイル取得
    private static List<ContentDocumentLink> getContentDocumentLinkList(String recordId) {
        List<ContentDocumentLink> documentLinkList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersionId
                ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
                ,ContentDocument.LatestPublishedVersion.HoninKakuninShoruiMyNumberOmote__c
                ,ContentDocument.LatestPublishedVersion.HoninKakuninShoruiMaskKenkoHoken__c
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :recordId
            AND
                ContentDocument.LatestPublishedVersion.Yoto__c = :YOTO_FILE_UPLOAD
            AND
                ContentDocument.LatestPublishedVersion.Shubetsu__c = :SHUBETSU_FILE_UPLOAD
            ORDER BY
                ContentDocument.LatestPublishedVersion.Title
        ];
        return documentLinkList;
    }

    // ファイル一覧取得
    private static List<FileDetail> getFileList(String recordId){
        List<ContentDocumentLink> documentLinkList = getContentDocumentLinkList(recordId);

        // ファイル一覧設定
        List<String> contentVersionIdList = new List<String>();
        List<FileDetail> fileList = new List<FileDetail>();
        for (ContentDocumentLink documentLink:documentLinkList) {
            contentVersionIdList.add(documentLink.ContentDocument.LatestPublishedVersionId);
            FileDetail fileDetail = new FileDetail();
            fileDetail.contentVersionId = documentLink.ContentDocument.LatestPublishedVersionId;
            fileDetail.fileTeigiId = documentLink.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c;
            fileList.add(fileDetail);
        }
        return fileList;
    }

    public class FileTypeWrapper {
        @AuraEnabled public List<FileType> fileTypeList {get; set;}
    }
    public class FileType {
        @AuraEnabled public String fileTeigiId {get; set;}
        @AuraEnabled public String fileTeigiName {get; set;}
        @AuraEnabled public String fileViewTeigiName {get; set;}
        @AuraEnabled public Boolean isMyNumber {get; set;}
        @AuraEnabled public Boolean isKenkoHoken {get; set;}
        @AuraEnabled public Boolean isJuminHyo {get; set;}
        @AuraEnabled public String fileTeigiSetsumei {get; set;}
    }

    public class FileDetailWrapper {
        @AuraEnabled public List<FileDetail> fileList {get; set;}
        @AuraEnabled public Boolean checkOK {get; set;}
    }
    public class FileDetail {
        @AuraEnabled public String contentVersionId {get; set;}
        @AuraEnabled public String fileTeigiId {get; set;}
    }

    class FileTypeCheck {
        public String fileKubun;
        public String fileTeigiId;
        public Boolean isInclude;
    }
}