public without sharing class ExLwcUtil {

    public static final String MODE_IPPAN = '1';
    public static final String MODE_DV = '2';
    public static final String MODE_SATOYA = '3';

    @TestVisible private static final String TYPE_NAME_DV = 'DvHigaisha';
    @TestVisible private static final String TYPE_NAME_SATOYA = 'Satooya';

    private static final String SITE_MODE = getSiteMode();

    // ファイルの添付数
    @TestVisible
    private static Decimal fileCountLimit {
        // テスト時に任意の値をセットする
        get{
            if(fileCountLimit == null){
                Limit__mdt limitSetting = Limit__mdt.getInstance('File');
                fileCountLimit = limitSetting?.Value__c;
            }
            return fileCountLimit;
        }
        set;
    }

    // ファイルのサイズ
    @TestVisible
    private static Decimal fileSizeLimit {
        // テスト時に任意の値をセットする
        get{
            if(fileSizeLimit == null){
                Limit__mdt limitSetting = Limit__mdt.getInstance('FileSizeMb');
                fileSizeLimit = limitSetting?.Value__c;
            }
            return fileSizeLimit;
        }
        set;
    }

    // ファイルの拡張子
    @TestVisible
    private static List<String> fileExtensions {
        // テスト時に任意の値をセットする
        get{
            if(fileExtensions == null){
                // 拡張子のメタデータ取得
                List<Extension__mdt> mdts = [
                    SELECT
                        DeveloperName // 拡張子名
                    FROM
                        Extension__mdt
                    ORDER BY
                        DeveloperName ASC
                ];

                fileExtensions = new List<String>();
                for(Extension__mdt mdt: mdts){
                    fileExtensions.add(mdt.DeveloperName);
                }
            }
            return fileExtensions;
        }
        set;
    }

    // ファイルの所有者
    @TestVisible
    private static String fileOwnerId {
        // テスト時に任意の値をセットする
        get{
            if(fileOwnerId == null){
                fileOwnerId = System.Label.EX_KUP1_FILE_OWNER;
            }
            return fileOwnerId;
        }
        set;
    }

    /**
     * 1:一般、2:DV、3:里親
     */
    public static String getSiteMode() {
        // ログインユーザ．プロファイルを取得してどのサイトかを判定する
        Profile p = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

        String siteMode;
        if(p.Name == '認定請求者'){
            siteMode = MODE_IPPAN;
        }else if(p.Name == '認定請求者（DV)'){
            siteMode = MODE_DV;
        }else if(p.Name == '認定請求者（里親・ファミリーホーム）'){
            siteMode = MODE_SATOYA;
        }

        return siteMode;
    }

    /**
     * 一般サイトかどうかを返す
     */
    @AuraEnabled
    public static Boolean isSiteModeIppan(){
        try {
            return getSiteMode() == MODE_IPPAN;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * DVサイトかどうかを返す
     */
    @AuraEnabled
    public static Boolean isSiteModeDv(){
        try {
            return getSiteMode() == MODE_DV;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 里親サイトかどうかを返す
     */
    @AuraEnabled
    public static Boolean isSiteModeSatoya(){
        try {
            return getSiteMode() == MODE_SATOYA;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * DV OR 里親のレコードタイプID取得
     */
    private static Id getRecordTypeId(String objName){
        Map<String, Schema.RecordTypeInfo> typeInfoByName = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName();

        Id recordTypeId;
        if(SITE_MODE == MODE_DV){ // DV
            recordTypeId = typeInfoByName.get(TYPE_NAME_DV).getRecordTypeId();
        }else if(SITE_MODE == MODE_SATOYA){ // 里親
            recordTypeId = typeInfoByName.get(TYPE_NAME_SATOYA).getRecordTypeId();
        }

        return recordTypeId;
    }

    /**
     * 認定請求のレコードタイプID取得
     */
    public static Id getSeikyuRecordTypeId(){
        return getRecordTypeId(Schema.SObjectType.DV_NinteiSeikyu__c.getLocalName());
    }

    /**
     * 請求者のレコードタイプID取得
     */
    public static Id getSeikyushaRecordTypeId(){
        return getRecordTypeId(Schema.SObjectType.DV_Seikyusha__c.getLocalName());
    }

    /**
     * 対象児童のレコードタイプID取得
     */
    public static Id getTaishoJidoRecordTypeId(){
        return getRecordTypeId(Schema.SObjectType.DV_TaishoJido__c.getLocalName());
    }

    /**
     * アップロードしたいファイル数が上限に達しているかをチェックする
     * アップロード可能ならばtrue
     */
    @AuraEnabled
    public static Boolean checkFileUploadLimit(Id linkedEntityId, String shoruiTeigiId) {
        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :linkedEntityId
            AND ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c = :shoruiTeigiId
        ];

        return cdlList.size() < fileCountLimit;
    }

    /**
     * 項目ラベル名を取得する
     */
    @AuraEnabled
    public static Map<String, String> getColumnLabels(String objectName, List<String> columnNames){
        try {
            Map<String, String> columnLabels = new Map<String, String>();

            Map<String, Schema.sObjectField> sofMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

            for (String columnName : columnNames) {
                columnLabels.put(columnName, sofMap.get(columnName).getDescribe().getLabel());
            }

            return columnLabels;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 項目ラベル名を取得する
     */
    @AuraEnabled
    public static String getColumnLabel(String objectName, String columnName){
        try {
            Map<String, Schema.sObjectField> sofMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            return sofMap.get(columnName).getDescribe().getLabel();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 指定された項目の選択リストを取得する
     */
    @AuraEnabled
    public static List<Map<String, String>> getPickList(String objectName, String columnName){
        try {
            List<Schema.PicklistEntry> pList = ObjectUtil.getPickList(objectName, columnName);

            List<Map<String, String>> options = new List<Map<String, String>>();
            for (Schema.PicklistEntry p : pList) {
                Map<String, String> option = new Map<String, String>{
                    'label' => p.getLabel()
                    ,'value' => p.getValue()
                };
                options.add(option);
            }

            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ProgressStep {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String id {get;set;}
    }

    /**
     * 編集フェーズを取得する
     */
    @AuraEnabled
    public static String getHensyuPhase(String ninteiSeikyuId){
        try {
            String phase = '';

            if (String.isEmpty(ninteiSeikyuId)) {
                return phase;
            }

            if (SITE_MODE == MODE_IPPAN) {
                phase = [SELECT Id, HensyuPhase__c FROM NinteiSeikyu__c WHERE Id = :ninteiSeikyuId].HensyuPhase__c;
            } else if (SITE_MODE == MODE_DV || SITE_MODE == MODE_SATOYA) {
                phase = [SELECT Id, HensyuPhase__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyuId].HensyuPhase__c;
            }

            return phase;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * 認定請求．編集フェーズを必要に応じて更新する
     */
    @AuraEnabled
    public static void updateHensyuPhase(String recordId, List<ProgressStep> steps, String displayTemplateId){
        try {

            // 遷移先の画面が編集フェーズに含まれるか確認
            Boolean isContain = false;
            for (ProgressStep step : steps) {
                System.debug(step);
                if (step.id == displayTemplateId) {
                    isContain = true;
                    break;
                }
            }

            // 含まれていない場合、処理を終了
            if (!isContain) {
                return;
            }

            String phase = getHensyuPhase(recordId);
            // 編集フェーズと遷移先の画面IDで、どちらが先にヒットするかを確認
            for (ProgressStep step : steps) {

                // 遷移先の画面の方が先であれば、更新せず処理を終了
                if (step.id == displayTemplateId) {
                    return;
                }

                // 編集フェーズの方が先であれば、更新するためループを抜ける
                if (step.id == phase) {
                    break;
                }
            }

            if (SITE_MODE == MODE_IPPAN) {
                update new NinteiSeikyu__c(
                    Id = recordId
                    ,HensyuPhase__c = displayTemplateId
                );
            } else if (SITE_MODE == MODE_DV || SITE_MODE == MODE_SATOYA) {
                update new DV_NinteiSeikyu__c(
                    Id = recordId
                    ,HensyuPhase__c = displayTemplateId
                );
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 認定請求が審査中かチェックする
     */
    @AuraEnabled
    public static Boolean isNinteiSeikyuDisabled(String recordId){
        try {

            String shinsaStatus = '';

            if (String.isBlank(recordId)) {
                return false;
            }

            if (SITE_MODE == MODE_IPPAN) {
                NinteiSeikyu__c ns = [
                    SELECT
                        Id
                        ,ShinsaStatus__c
                    FROM NinteiSeikyu__c
                    WHERE Id = :recordId
                ];

                shinsaStatus = ns.ShinsaStatus__c;

            } else if (SITE_MODE == MODE_DV || SITE_MODE == MODE_SATOYA) {
                DV_NinteiSeikyu__c ns = [
                    SELECT
                        Id
                        ,ShinsaStatus__c
                    FROM DV_NinteiSeikyu__c
                    WHERE Id = :recordId
                ];

                shinsaStatus = ns.ShinsaStatus__c;
            }

            return isNotStatusMishinsei(shinsaStatus);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Boolean isNotStatusMishinsei(String shinsaStatus){
        return shinsaStatus != '未申請';
    }

    public class FileLimitWrapper{
        @AuraEnabled public List<String> acceptExtensions {get;set;}
        @AuraEnabled public String extensionMessage {get;set;}

        @AuraEnabled public String sizeMessage {get;set;}

        public FileLimitWrapper(){
            acceptExtensions = new List<String>{};
        }
    }

    /**
     * ファイルの制限を取得する
     */
    @AuraEnabled
    public static FileLimitWrapper getFileLimit(){
        try {
            FileLimitWrapper result = new FileLimitWrapper();

            List<String> upperExtensionNames = new List<String>();
            for(String extension: fileExtensions){
                result.acceptExtensions.add('.' + extension); // ピリオド必要

                upperExtensionNames.add(extension.toUpperCase());
            }

            result.extensionMessage = '拡張子：' + String.join(upperExtensionNames, ' / ');

            // サイズ上限取得 表示のみ5MBとする(実際はカスタムメタデータの値)
            // result.sizeMessage = '1ファイルあたりのサイズ上限：' + String.valueOf(getFileSizeMbLimit()) + 'MB';
            result.sizeMessage = '1ファイルあたりのサイズ上限：5MB';

            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * サイズ上限(MB)取得
     */
    public static Decimal getFileSizeMbLimit(){
        return fileSizeLimit;
    }

    /**
     * コミュニティユーザ → システム管理者にファイルの所有者を変えて削除等の処理を出来ないようにする
     */
    @AuraEnabled
    public static void changeDocumentOwner(String versionId){
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versionId LIMIT 1];
        ContentDocument cd = [SELECT Id, OwnerId FROM ContentDocument WHERE Id = :cv.ContentDocumentId LIMIT 1];
        cd.OwnerId = fileOwnerId;
        update cd;
    }

    /**
     * 紐づくファイルの削除可能フラグをOFFに変更
     * 所有者権限が割り当てられていないため、withoutクラスにて定義
     */
    public static void updateFileDeletableFlg(Set<Id> linkedEntitySet) {

        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId in :linkedEntitySet
        ];

        List<ContentVersion> cvList = new List<ContentVersion>();
        for (ContentDocumentLink cdl : cdlList) {
            ContentVersion cv = new ContentVersion(
                Id = cdl.ContentDocument.LatestPublishedVersionId
                ,IsDeletable__c = false
            );
            cvList.add(cv);
        }

        update cvList;
    }
}