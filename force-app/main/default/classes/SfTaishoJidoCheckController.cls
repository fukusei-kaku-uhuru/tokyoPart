public with sharing class SfTaishoJidoCheckController {

    private static final String SHINSA_STATUS_STR_SHINSACHU_00 = '0次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_01 = '1次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_02 = '2次審査中';
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
    public static TaishoJido__c getTaishoJido(Id currentRecordId) {

        try {
            // recordIdから対象児童レコード取得
            TaishoJido__c record = getTaishoJidoRecord(currentRecordId);
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
            fieldResult = TaishoJido__c.ShinsaKekkaTeikeiComment_Web_00__c.getDescribe();
        // webの1次審査、2次審査の場合
        } else if(!isYuso && !is0th) {
            fieldResult = TaishoJido__c.ShinsaKekkaTeikeiComment_Web_01__c.getDescribe();
        // 郵送の0次審査の場合
        } else if(isYuso && is0th) {
            fieldResult = TaishoJido__c.ShinsaKekkaTeikeiComment_Yuso_00__c.getDescribe();
        // 郵送の1次審査、2次審査の場合
        } else {
            fieldResult = TaishoJido__c.ShinsaKekkaTeikeiComment_Yuso_01__c.getDescribe();
        }

        // 選択リスト値を取得
        List<Schema.PicklistEntry> optionList                        = fieldResult.getPicklistValues();
        List<SfTaishoJidoCheckController.pickListWrapper> wrapperList = new List<SfTaishoJidoCheckController.pickListWrapper>();
        for(Schema.PicklistEntry option :optionList) {
            SfTaishoJidoCheckController.pickListWrapper wrapper = new SfTaishoJidoCheckController.pickListWrapper();
            wrapper.label = option.getLabel();
            wrapper.value = option.getValue();
            wrapperList.add(wrapper);
        }

        return JSON.serialize(wrapperList);
    }

    @AuraEnabled
    public static string updateTaishoJidoShinsaKekka(Id jidoId, String shinsaKekka, String shinsaComment, String shinsaStatus) {

        String errorMessage = '';

        // 対象児童を取得
        TaishoJido__c currentRecord = getTaishoJidoRecord(jidoId);

        // 入力規則

        // 氏名及び氏名（フリガナ）に全角スペースが入っているかどうか確認
        Boolean hasZenkakuSpaceShimei = checkZenkakuSpace(currentRecord.Shimei__c);
        Boolean hasZenkakuSpaceKana   = checkZenkakuSpace(currentRecord.ShimeiFurigana__c);

        // 以下の条件でエラーメッセージを返す
        // 対象児童の氏名に全角スペースないor対象児童の氏名（フリガナ）に全角スペースない
        // 認定請求の郵送申請フラグがtrue
        // 対象児童の全角確認なしフラグがfalse
        if(!(hasZenkakuSpaceShimei && hasZenkakuSpaceKana)
          && currentRecord.NinteiSeikyu__r.IsYusoShinsei__c
          && !currentRecord.IsZenkakuKakuninNashi__c) {
            errorMessage = ERROR_MESSAGE_NO_ZENKAKU_SPACE;
            return errorMessage;
        }

        // すでにステータスが変更されている場合エラーメッセージを返す
        if(String.isNotBlank(shinsaStatus) && !shinsaStatus.equals(currentRecord.NinteiSeikyu__r.ShinsaStatus__c)) {
            errorMessage = ERROR_MESSAGE_STATUS_CHANGED;
            return errorMessage;
        }

        // 対象児童に値を設定する
        TaishoJido__c jido = new TaishoJido__c();

        jido.Id = jidoId;
        // 審査ステータスが0次審査中の場合
        if(SHINSA_STATUS_STR_SHINSACHU_00.equals(shinsaStatus)) {
            jido.ShinsaKekka_00__c        = shinsaKekka;
            jido.ShinsaKekkaComment_00__c = shinsaComment;
        // 審査ステータスが1次審査中の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_01.equals(shinsaStatus)) {
            jido.ShinsaKekka_01__c        = shinsaKekka;
            jido.ShinsaKekkaComment_01__c = shinsaComment;
        // 審査ステータスが2次審査中の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_02.equals(shinsaStatus)) {
            jido.ShinsaKekka_02__c        = shinsaKekka;
            jido.ShinsaKekkaComment_02__c = shinsaComment;
        // 審査ステータスがアンマッチ判定の場合
    } else if(SHINSA_STATUS_STR_SHINSACHU_SAISHU.equals(shinsaStatus)) {
            jido.ShinsaKekkaSaishu__c         = shinsaKekka;
            jido.ShinsaKekkaComment_Saishu__c = shinsaComment;
    }
        // 対象児童を更新する
        Savepoint sp = Database.setSavepoint();
        try {
            Database.SaveResult sr = Database.update(jido);
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

    private static TaishoJido__c getTaishoJidoRecord(Id currentRecordId) {

        TaishoJido__c record = [SELECT Id,
                                           ShinsaKekka_00__c,
                                           ShinsaKekka_01__c,
                                           ShinsaKekka_02__c,
                                           ShinsaKekkaSaishu__c,
                                           ShinsaKekkaComment_00__c,
                                           ShinsaKekkaComment_01__c,
                                           ShinsaKekkaComment_02__c,
                                           ShinsaKekkaComment_Saishu__c,
                                           UketoriKouzaKubun_Seikyusha__c,
                                           UketoriKouzaKubun_Taishosha__c,
                                           Moushitate_KokenninCheck__c,
                                           Moushitate_BekkyoKango__c,
                                           Moushitate_KaigaiRyugakuCheck__c,
                                           Moushitate_RikonKyogiCheck__c,
                                           Moushitate_FuboSiteishaCheck__c,
                                           Shimei__c,
                                           ShimeiFurigana__c,
                                           IsZenkakuKakuninNashi__c,
                                           NinteiSeikyu__r.ShinsaStatus__c,
                                           NinteiSeikyu__r.Is0thShinsasya__c,
                                           NinteiSeikyu__r.Is1stShinsasya__c,
                                           NinteiSeikyu__r.Is2ndShinsasya__c,
                                           NinteiSeikyu__r.IsSaishuShinsasya__c,
                                           NinteiSeikyu__r.IsYusoShinsei__c,
                                           NinteiSeikyu__r.SeikyushaKubun_Dairinin__c
                                      FROM TaishoJido__c
                                     WHERE Id = :currentRecordId
                                     LIMIT 1];

        return record;
    }

    // 対象の文字列に全角スペースが入っているか確認
    private static Boolean checkZenkakuSpace(String checkTargetStr) {
        
        if(String.isBlank(checkTargetStr)) {
            return false;
        }

        Pattern zenkakuSpacePattern = Pattern.compile('.*?[　]+.*?');
        Matcher zenkakuSpaceMatcher = zenkakuSpacePattern.matcher(checkTargetStr);

        return zenkakuSpaceMatcher.matches();
    }

    private class pickListWrapper {

        public String label {get; set;}
        public String value {get; set;}

        pickListWrapper() {
        }
    }
}