public with sharing class SfSeikyushaCheckController {

    private static final String SHINSA_STATUS_STR_SHINSACHU_00     = '0次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_01     = '1次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_02     = '2次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_SAISHU = 'アンマッチ判定';

    private static final String ERROR_MESSAGE_NO_ZENKAKU_SPACE = '氏名または氏名（フリガナ）に全角スペースが含まれていません。';
    private static final String ERROR_MESSAGE_STATUS_CHANGED   = '対象の審査はすでに完了しています。';


    @AuraEnabled(cacheable=true)
    public static Profile getUserProfile(Id userId) {
        User targetUser = [SELECT Id,
                                  ProfileId
                             FROM User
                            WHERE Id = :userId
                            LIMIT 1];
        Id profileId = targetUser.ProfileId;

        Profile returnProfile = [SELECT Id,
                                        Name
                                   FROM Profile
                                  WHERE Id = :profileId
                                  LIMIT 1];
        return returnProfile;
    }

    @AuraEnabled
    public static String getUserPermissionSetAssignment(Id userId) {
        List<PermissionSetAssignment> assignmentList = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId];
        return JSON.serialize(assignmentList);
    }

    @AuraEnabled(cacheable=true)
    public static NinteiSeikyu__c getNinteiSeikyu(Id currentRecordId) {

        try {
            // recordIdから認定請求レコード取得（請求者情報は参照関係項目経由で取得）
            NinteiSeikyu__c record = getNinteiSeikyuRecord(currentRecordId);

            return record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getContentVersion(Id currentRecordId) {

        // recordIdからContentDocumentLink取得
        List<ContentDocumentLink> linkList = [SELECT Id,
                                                     ContentDocumentId
                                                FROM ContentDocumentLink
                                               WHERE LinkedEntityId = :currentRecordId];
        Set<Id> ContentDocumentIdSet = new Set<Id>();
        for(ContentDocumentLink link :linkList) {
            ContentDocumentIdSet.add(link.ContentDocumentId);
        }

        // ContentDocumentIdからContentVersionを取得
        List<ContentVersion> contentVersionList = [SELECT Id,
                                                          ShinseiShoruiTeigiName__c,
                                                          ShudoCheck_Shimei__c,
                                                          ContentDocumentId
                                                     FROM ContentVersion
                                                    WHERE ContentDocumentId IN :ContentDocumentIdSet
                                                      AND ChohyoShutsuryokuShubetsu__c = NULL];

        return contentVersionList;
    }

    @AuraEnabled
    public static string getTeikeiCommentOptions(Boolean isYuso, Boolean is0th) {
        
        Schema.describeFieldResult fieldResult;
        // webの0次審査の場合
        if(!isYuso && is0th) {
            fieldResult = Seikyusha__c.ShinsaKekkaTeikeiComment_Web_00__c.getDescribe();
        // webの1次審査、2次審査の場合
        } else if(!isYuso && !is0th) {
            fieldResult = Seikyusha__c.ShinsaKekkaTeikeiComment_Web_01__c.getDescribe();
        // 郵送の0次審査の場合
        } else if(isYuso && is0th) {
            fieldResult = Seikyusha__c.ShinsaKekkaTeikeiComment_Yuso_00__c.getDescribe();
        // 郵送の1次審査、2次審査の場合
        } else {
            fieldResult = Seikyusha__c.ShinsaKekkaTeikeiComment_Yuso_01__c.getDescribe();
        }

        // 選択リスト値を取得
        List<Schema.PicklistEntry> optionList                        = fieldResult.getPicklistValues();
        List<SfSeikyushaCheckController.pickListWrapper> wrapperList = new List<SfSeikyushaCheckController.pickListWrapper>();
        for(Schema.PicklistEntry option :optionList) {
            SfSeikyushaCheckController.pickListWrapper wrapper = new SfSeikyushaCheckController.pickListWrapper();
            wrapper.label = option.getLabel();
            wrapper.value = option.getValue();
            wrapperList.add(wrapper);
        }

        return JSON.serialize(wrapperList);
    }

    @AuraEnabled
    public static string updateSeikyushaShinsaKekka(Id seikyushaId, String shinsaKekka, String shinsaComment, String shinsaStatus) {

        String errorMessage = '';

        // 認定請求を取得
        NinteiSeikyu__c ninteiSeikyu = [SELECT Id,
                                               Seikyusha__r.Shimei__c,
                                               Seikyusha__r.ShimeiFurigana__c,
                                               Seikyusha__r.IsZenkakuKakuninNashi__c,
                                               IsYusoShinsei__c,
                                               ShinsaStatus__c
                                          FROM NinteiSeikyu__c
                                         WHERE Seikyusha__c = :seikyushaId
                                         LIMIT 1];

        // 入力規則

        // すでにステータスが変更されている場合エラーメッセージを返す
        if(String.isNotBlank(shinsaStatus) && !shinsaStatus.equals(ninteiSeikyu.ShinsaStatus__c)) {
            errorMessage = ERROR_MESSAGE_STATUS_CHANGED;
            return errorMessage;
        }

        // 請求者に値を設定する
        Seikyusha__c seikyusha = new Seikyusha__c();

        seikyusha.Id = seikyushaId;
        // 審査ステータスが0次審査中の場合
        if(SHINSA_STATUS_STR_SHINSACHU_00.equals(shinsaStatus)) {
            seikyusha.ShinsaKekka_00__c        = shinsaKekka;
            seikyusha.ShinsaKekkaComment_00__c = shinsaComment;
        // 審査ステータスが1次審査中の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_01.equals(shinsaStatus)) {
            seikyusha.ShinsaKekka_01__c        = shinsaKekka;
            seikyusha.ShinsaKekkaComment_01__c = shinsaComment;
        // 審査ステータスが2次審査中の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_02.equals(shinsaStatus)) {
            seikyusha.ShinsaKekka_02__c        = shinsaKekka;
            seikyusha.ShinsaKekkaComment_02__c = shinsaComment;
        // 審査ステータスがアンマッチ判定の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_SAISHU.equals(shinsaStatus)) {
            seikyusha.ShinsaKekkaSaishu__c         = shinsaKekka;
            seikyusha.ShinsaKekkaComment_Saishu__c = shinsaComment;
        }

        // 対象児童を更新する
        Savepoint sp = Database.setSavepoint();
        try {
            Database.SaveResult sr = Database.update(seikyusha);
            if(!sr.isSuccess()) {
                for(Database.Error error : sr.getErrors()) {
                    errorMessage += error.getMessage() + ':';
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

    private static NinteiSeikyu__c getNinteiSeikyuRecord(Id currentRecordId) {
        // recordIdから認定請求レコード取得（請求者情報は参照関係項目経由で取得）
        NinteiSeikyu__c record = [SELECT Id,
                                         Seikyusha__c,
                                         Seikyusha__r.ShinsaKekka_00__c,
                                         Seikyusha__r.ShinsaKekka_01__c,
                                         Seikyusha__r.ShinsaKekka_02__c,
                                         Seikyusha__r.ShinsaKekkaSaishu__c,
                                         Seikyusha__r.ShinsaKekkaComment_00__c,
                                         Seikyusha__r.ShinsaKekkaComment_01__c,
                                         Seikyusha__r.ShinsaKekkaComment_02__c,
                                         Seikyusha__r.ShinsaKekkaComment_Saishu__c,
                                         Seikyusha__r.HonninKakuninHoho__c,
                                         Seikyusha__r.Shimei__c,
                                         Seikyusha__r.ShimeiFurigana__c,
                                         Seikyusha__r.IsZenkakuKakuninNashi__c,
                                         ShinsaStatus__c,
                                         IsYusoShinsei__c,
                                         Is0thShinsasya__c,
                                         Is1stShinsasya__c,
                                         Is2ndShinsasya__c,
                                         IsSaishuShinsasya__c
                                    FROM NinteiSeikyu__c
                                   WHERE Id = :currentRecordId
                                   LIMIT 1];

        return record;
    }

    private class pickListWrapper {

        public String label {get; set;}
        public String value {get; set;}

        pickListWrapper() {
        }
    }
}