public with sharing class ExFileListController {
    
    @AuraEnabled(cacheable=true)
  	public static FileDetailWrapper getDocument(List<String> contentVersionIdList) {
        if (contentVersionIdList?.isEmpty()) {
            FileDetailWrapper wrapper = new FileDetailWrapper();
            wrapper.fileList = new List<FileDetail>();
            return wrapper;
        }

        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([
            SELECT Id, ContentDocumentId, Title, FileExtension, ShinseiShoruiTeigiId__c, IsDeletable__c
            FROM ContentVersion
            WHERE Id = :contentVersionIdList
        ]);
        Set<String> teigiIdSet = new Set<String>();
        for (ContentVersion contentVersion:contentVersionMap.values()) {
            teigiIdSet.add(contentVersion.ShinseiShoruiTeigiId__c);
        }
        
        Map<Id, ShinseiShoruiTeigi__c> teigiMap = new Map<Id, ShinseiShoruiTeigi__c>(ExShinseiShoruiTeigiUtil.getListByIdSet(teigiIdSet));
        

        List<FileDetail> fileDetailList = new List<FileDetail>();
        for (String contentVersionId:contentVersionIdList) {
            if (!contentVersionMap.containsKey(contentVersionId)) {
                continue;
            }

            FileDetail fileDetail = new FileDetail();
            ContentVersion version = contentVersionMap.get(contentVersionId);
            fileDetail.contentVersionId = version.Id;
            fileDetail.contentDocumentId = version.ContentDocumentId;
            fileDetail.fileName = version.Title;
            fileDetail.isDeletable = version.IsDeletable__c;

            if (!teigiMap.containsKey(version.ShinseiShoruiTeigiId__c)) {
                continue;
            }
            ShinseiShoruiTeigi__c teigi = teigiMap.get(version.ShinseiShoruiTeigiId__c);
            fileDetail.fileTeigiId = version.ShinseiShoruiTeigiId__c;
            fileDetail.fileTeigiName = teigi.Name;
            fileDetailList.add(fileDetail);
        }

        FileDetailWrapper wrapper = new FileDetailWrapper();
        wrapper.fileList = fileDetailList;
        return wrapper;
    }

    @AuraEnabled
  	public static void deleteContentDocument(String contentDocumentId) {
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Id=:contentDocumentId];
        delete contentDocumentList;
        return;
    }
    
    
    public class FileDetailWrapper {
        @AuraEnabled public List<FileDetail> fileList {get; set;}
    }
    public class FileDetail {
        @AuraEnabled public String contentDocumentId {get; set;}
        @AuraEnabled public String contentVersionId {get; set;}
        @AuraEnabled public String fileName {get; set;}
        @AuraEnabled public String fileTeigiId {get; set;}
        @AuraEnabled public Boolean isDeletable {get; set;}
        @AuraEnabled public String fileTeigiName {get; set;}
    }
}