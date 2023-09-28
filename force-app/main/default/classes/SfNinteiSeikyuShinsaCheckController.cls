public with sharing class SfNinteiSeikyuShinsaCheckController {

    private static final String SHINSA_STATUS_STR_SHINSACHU_00    = '0次審査中';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_00 = '1次審査待ち';
    private static final String SHINSA_STATUS_STR_SHINSACHU_01    = '1次審査中';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_01 = '2次審査待ち';
    private static final String SHINSA_STATUS_STR_SHINSACHU_02    = '2次審査中';
    private static final String SHINSA_STATUS_STR_UNMATCH         = 'アンマッチ判定';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_02 = '審査完了';

    private static final String KEKKA_CHECK_STR_FUICCHI = '不一致';

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

        try{
            // recordIdから認定請求レコードを取得
                NinteiSeikyu__c record = [SELECT Id,
                                                 ShinsaStatus__c,
                                                 Seikyusha__c,
                                                 Seikyusha__r.ShinsaKekka_00__c,
                                                 Seikyusha__r.ShinsaKekka_01__c,
                                                 Seikyusha__r.ShinsaKekka_02__c,
                                                 Seikyusha__r.ShinsaKekkaSaishu__c,
                                                 Seikyusha__r.Shimei__c
                                            FROM NinteiSeikyu__c
                                           WHERE Id = :currentRecordId
                                           LIMIT 1];
        return record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TaishoJido__c> getTaishoJido(Id currentRecordId) {
        try {
            // recordIdからレコードを取得
            List<TaishoJido__c> taishoJidoList = [SELECT Id,
                                                         Shimei__c,
                                                         ShinsaKekka_00__c,
                                                         ShinsaKekka_01__c,
                                                         ShinsaKekka_02__c,
                                                         ShinsaKekkaSaishu__c
                                                    FROM TaishoJido__c
                                                   WHERE NinteiSeikyu__c = :currentRecordId];
            return taishoJidoList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string completeShinsa(Id ninteiSeikyuId, String shinsaStatus){

        // 対象の認定請求を取得
        NinteiSeikyu__c ninteiSeikyu = [SELECT Id,
                                               ShinsaStatus__c,
                                               Seikyusha__r.ShinsaKekka_00__c,
                                               Seikyusha__r.ShinsaKekka_01__c,
                                               Seikyusha__r.ShinsaKekka_02__c,
                                               Seikyusha__r.ShinsaKekkaSaishu__c,
                                               Seikyusha__r.ShinsaKekkaSaiCheck__c
                                          FROM NinteiSeikyu__c
                                         WHERE Id = :ninteiSeikyuId
                                         LIMIT 1];

        // 対象の認定請求に関連する対象児童を取得
        List<TaishoJido__c> taishoJidoList = [SELECT Id,
                                                     Name,
                                                     Shimei__c,
                                                     NinteiSeikyu__c,
                                                     ShinsaKekka_00__c,
                                                     ShinsaKekka_01__c,
                                                     ShinsaKekka_02__c,
                                                     ShinsaKekkaSaishu__c,
                                                     ShinsaKekkaSaiCheck__c
                                                FROM TaishoJido__c
                                               WHERE NinteiSeikyu__c = :ninteiSeikyuId];

        // 入力チェック
        String errorMessage = '';

        // 認定請求のステータスを更新
        // 審査ステータスが0次審査中の場合
        if(SHINSA_STATUS_STR_SHINSACHU_00.equals(shinsaStatus)) {
            ninteiSeikyu.ShinsaStatus__c            = SHINSA_STATUS_STR_SHINSAKANRYO_00;
        // 審査ステータスが1次審査中の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_01.equals(shinsaStatus)) {
            ninteiSeikyu.ShinsaStatus__c            = SHINSA_STATUS_STR_SHINSAKANRYO_01;
        // 審査ステータスが2次審査中の場合
        } else if(SHINSA_STATUS_STR_SHINSACHU_02.equals(shinsaStatus)) {
            
            // 請求者や対象児童にアンマッチがないか確認
            Boolean hasUnmatch = false;
            if(String.isNotBlank(ninteiSeikyu.Seikyusha__r.ShinsaKekkaSaiCheck__c) && ninteiSeikyu.Seikyusha__r.ShinsaKekkaSaiCheck__c.equals(KEKKA_CHECK_STR_FUICCHI)) {
                hasUnmatch = true;
            }
            for(TaishoJido__c jido :taishoJidoList) {
                if(String.isNotBlank(jido.ShinsaKekkaSaiCheck__c) && jido.ShinsaKekkaSaiCheck__c.equals(KEKKA_CHECK_STR_FUICCHI)) {
                    hasUnmatch = true;
                }
            }

            // 1次審査と2次審査のアンマッチがあればアンマッチ判定、なければ審査完了とする
            if(hasUnmatch) {
                ninteiSeikyu.ShinsaStatus__c = SHINSA_STATUS_STR_UNMATCH;
            } else {
                ninteiSeikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSAKANRYO_02;
            }
        // 審査ステータスがアンマッチ判定の場合
        } else if(SHINSA_STATUS_STR_UNMATCH.equals(shinsaStatus)) {
            ninteiSeikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSAKANRYO_02;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Database.SaveResult sr = Database.update(ninteiSeikyu);
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
}