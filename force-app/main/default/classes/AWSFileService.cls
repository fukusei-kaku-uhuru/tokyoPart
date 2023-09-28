/**
 * AWS S3連携
 * @date 2023/07/14
 */
public class AWSFileService { 
    
    /**
     * 添付ファイルをAWS S3にアップロードする
     * @param recordIds
     * @return List<ContentVersion> 連携成功の添付ファイル
     */
    public List<ContentVersion> uploadDocuments(List<String> recordIds)
    {

        List<ContentVersion> versions = [SELECT VersionData,Title,ContentDocumentId,FileExtension,Description  FROM ContentVersion WHERE Id = :recordIds AND IsLatest = true];
        List<ContentVersion> returnVersions = new List<ContentVersion>();

        if(versions.size() == 0){
            return null;
        }
        
        Set<String> cvIds = new Set<String>();
        for (ContentVersion cv : versions) {
            cvIds.add(cv.ContentDocumentId);
        }
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :cvIds];
        
        Set<String> userIds = new Set<String>();
        for (ContentDocumentLink cvlink : contentDocumentLinkList) {
            userIds.add(cvlink.LinkedEntityId);
        }
        
        Map<String,User> userMap = new Map<String,User>();
        List<User> userList = [SELECT Id,Name FROM User WHERE Id=:userIds];
        for (User user : userList) {
            userMap.put(user.Id,user);
        }

        // キー：ContentDocumentId、値：LinkedEntityId
        Map<String,String> cvLinkMap = new Map<String,String>();
        for (ContentDocumentLink cvlink : contentDocumentLinkList) {
            if(userMap.get(cvlink.LinkedEntityId) == null) {
                cvLinkMap.put(cvlink.ContentDocumentId,cvlink.LinkedEntityId);
            }
        }

        // Salesforceの指定ログイン情報 (Named Credential) からEndPointUrlを取得する
        NamedCredential named=[SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='AWS_S3'];

        System.debug('named:'+named);
        
        for(ContentVersion attach:versions)
        {
            try
            {
                // 添付ファイルのデータを取得する
                String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');

                // 日付フォルダを作成する
                String dateStr = Datetime.now().format('yyyyMMdd');

                // ファイル名を取得する
                String fileName = attach.Title.toLowerCase();

                // ファイルの拡張子を取得する
                String fileExtension = String.isNotBlank(attach.FileExtension)== true?attach.FileExtension.toLowerCase():'';

                // linkedEntityIdを取得する
                String linkedEntityId = cvLinkMap.get(attach.ContentDocumentId);

                String path = 'callout:AWS_S3' + '/' + dateStr + '/' + (String.isNotBlank(linkedEntityId)==true?(linkedEntityId+'/'+ linkedEntityId+ '_'+ fileName):fileName) + (String.isNotBlank(fileExtension)== true?('.'+fileExtension) :'' );

                HttpRequest req = new HttpRequest();
                req.setMethod('PUT');
                req.setEndpoint(path);

                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
                req.setBodyAsBlob(pdfBlob);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug('res:'+res);
                if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
                {
                    System.debug(fileName + fileExtension + 'ファイルはAWS S3へバックアップしました。');
                    returnVersions.add(attach);
                } else 
                {
                    attach.addError('AWS S3へバックアップできませんでした。');
                    System.debug('AWS S3へバックアップできませんでした。');
                    continue;
                }
            }
            catch(Exception ex)
            {
                attach.addError('AWS S3へバックアップできませんでした。');
                System.debug('AWS S3へバックアップできませんでした。' + ex.getStackTraceString());
            }
        }
        return returnVersions;
    }

     /**
     * 添付ファイルをAWS S3にアップロードする
     * @return List<ContentVersion> 連携成功の添付ファイル
     */
    // public void backUpEventlogFiles()
    // {
    //     // Salesforceの指定ログイン情報 (Named Credential) からEndPointUrlを取得する
    //     NamedCredential named=[SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='AWS_S3'];

    //     System.debug('named:'+named);
        
    //     try
    //     {
    //         // 添付ファイルのデータを取得する
    //         String attachmentBody = 'test';
    //         String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');

    //         // 日付フォルダを作成する
    //         String dateStr = Datetime.now().format('yyyyMMdd');

    //         // ファイル名を取得する
    //         String fileName = 'test.txt';

    //         HttpRequest req = new HttpRequest();
    //         req.setMethod('PUT');
    //         req.setEndpoint('callout:AWS_S3' +'/' + dateStr + '/' + fileName);

    //         req.setBody(attachmentBody);
            
    //         Http http = new Http();
    //         HTTPResponse res = http.send(req);
    //         System.debug('res:'+res);
    //         if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
    //         {
    //             // System.debug(fileName + fileExtension + 'ファイルはAWS S3へバックアップしました。');
    //             // returnVersions.add(attach);
    //         } else 
    //         {
    //         }
    //     }
    //     catch(Exception ex)
    //     {
    //         // attach.addError('AWS S3へバックアップできませんでした。');
    //         System.debug('AWS S3へバックアップできませんでした。' + ex.getStackTraceString());
    //     }
    // }
}