public with sharing class ExValidationUtil {

    /**
     * 画面に返却するエラーログ
     */
    public class ErrorLogs {
        public List<ErrorLog> errorLogs {get;set;}
        public ErrorLogs() {
            errorLogs = new List<ErrorLog>();
        }

        public void add(String field, String message) {
            ErrorLog el = new ErrorLog();
            el.field = field;
            el.message = message;
            errorLogs.add(el);
        }
    }
    public class ErrorLog {
        // 画面のキーとして設定されている値
        @AuraEnabled public String field {get;set;}
        // メッセージ内容
        @AuraEnabled public String message {get;set;}
    }

    /**
     * 必要書類の提出が必要かチェックする
     * 提出出来てないファイル名の一覧を返す
     */
    public static List<String> needUploadShinseiShorui(List<ContentDocumentLink> cdlList, List<ShinseiShoruiTeigi__c> requiredFiles) {

        // 必要なファイルIdをキーとしたmapを用意
        Map<String, Boolean> validationMap = new Map<String, Boolean>();
        for (ShinseiShoruiTeigi__c requiredFile : requiredFiles) {
            // 任意提出のファイルはチェックしない
            if (!requiredFile.IsNiniTeisyutsu__c) {
                validationMap.put(requiredFile.Id, false);
            }
        }

        // 登録済のファイルはtrueで上書きする
        for (ContentDocumentLink cdl : cdlList) {
            if (String.isNotEmpty(cdl.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c)) {
                validationMap.put(cdl.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c, true);
            }
        }

        // falseのままのファイルのId一覧を作成
        List<String> needUploadShoruiList = new List<String>();
        for (String key : validationMap.keySet()) {
            if (!validationMap.get(key)) {
                needUploadShoruiList.add(key);
            }
        }

        List<String> needUploadShoruiNameList = new List<String>();
        for (ShinseiShoruiTeigi__c requiredFile : requiredFiles) {
            if (needUploadShoruiList.contains(requiredFile.Id)) {
                needUploadShoruiNameList.add(requiredFile.Name);
            }
        }

        return needUploadShoruiNameList;
    }
}