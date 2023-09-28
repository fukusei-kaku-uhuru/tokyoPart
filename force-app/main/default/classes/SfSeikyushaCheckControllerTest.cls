@isTest
private class SfSeikyushaCheckControllerTest {

    public static final String USER_PROFILE_SHINSA = '審査';
    public static final String USER_NAME_STR_SHINSA = 'ShinsaTest';

    private static final String SHINSA_STATUS_STR_SHINSACHU_00     = '0次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_01     = '1次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_02     = '2次審査中';
    private static final String SHINSA_STATUS_STR_SHINSACHU_SAISHU = 'アンマッチ判定';

    private static final String PERMISSION_NAME_STR_LD = 'Shinsa_LD';

    private static final String ERROR_MESSAGE_STATUS_CHANGED = '対象の審査はすでに完了しています。';

    @TestSetup
    private static void setUp(){
        User shinsaUser = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        insert shinsaUser;

        // 請求者
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        // 認定請求
        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        // 対象児童
        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
        insert taishoJido;
    }

    @isTest
    static void getUserProfile() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName, ProfileId FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            Test.startTest();
            Profile assertProfile = SfSeikyushaCheckController.getUserProfile(u.Id);
            Test.stopTest();

            Assert.areEqual(u.ProfileId, assertProfile.Id);
        }
    }

    // ユーザの権限セットを取得
    @isTest
    static void getUserPermissionSetAssignment() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        PermissionSet permission = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_NAME_STR_LD];
        PermissionSetAssignment assignment = new PermissionSetAssignment(
            PermissionSetId = permission.Id,
            AssigneeId = u.Id
        );
        insert assignment;

        System.runAs(u) {

            Test.startTest();

            String permissionJsonStr = SfSeikyushaCheckController.getUserPermissionSetAssignment(u.Id);

            Test.stopTest();

            List<Object> permissionList = (List<Object>)JSON.deserializeUntyped(permissionJsonStr);

            Boolean hasLD = false;
            for(Object p :permissionList) {
                Map<String, Object> pMap = (Map<String, Object>)p;
                Map<String, Object> childPmap = (Map<String, Object>)pMap.get('PermissionSet');
                if(PERMISSION_NAME_STR_LD.equals((String)childPmap.get('Name'))) {
                    hasLD = true;
                }
            }
            Assert.isTrue(hasLD);
        }
    }

    @isTest
    static void getNinteiSeikyu() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            Test.startTest();
            Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];
            seikyusha.ShinsaKekka_00__c             = 'OK';
            seikyusha.ShinsaKekka_01__c             = 'OK';
            seikyusha.ShinsaKekka_02__c             = 'OK';
            seikyusha.ShinsaKekkaSaishu__c          = 'OK';
            seikyusha.ShinsaKekkaComment_00__c      = '';
            seikyusha.ShinsaKekkaComment_01__c      = '';
            seikyusha.ShinsaKekkaComment_02__c      = '';
            seikyusha.ShinsaKekkaComment_Saishu__c  = '';
            seikyusha.HonninKakuninHoho__c          = '公的個人認証';
            update seikyusha;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaStatus__c              = '0次審査中';
            ninteiSeikyu.ShinsaTantousha_00__c        = u.Id;
            ninteiSeikyu.ShinsaTantousha_01__c        = u.Id;
            ninteiSeikyu.ShinsaTantousha_02__c        = u.Id;
            ninteiSeikyu.ShinsaTantousha_Saishu__c    = u.Id;
            update ninteiSeikyu;

            NinteiSeikyu__c assertNinteiSeikyu = SfSeikyushaCheckController.getNinteiSeikyu(ninteiSeikyu.Id);
            Test.stopTest();

            Assert.areEqual(ninteiSeikyu.Id, assertNinteiSeikyu.Id);

        }
    }

    @isTest
    static void getContentVersion() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        ContentVersion contentVersion = SfTestUtil.getContentVersion();
        insert contentVersion;

        List<ContentDocument> contentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId    = NinteiSeikyu.Id;
        cdl.ContentDocumentId = contentDocument[0].Id;
        insert cdl;

        Test.startTest();
            List<ContentVersion> assertContentVersion = SfSeikyushaCheckController.getContentVersion(ninteiSeikyu.Id);
        Test.stopTest();

        Assert.areEqual(contentVersion.Id, assertContentVersion[0].Id);
    }

    @isTest
    static void updateSeikyushaShinsaKekka() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        Test.startTest();
        ninteiSeikyu.ShinsaStatus__c = '0次審査中';
        update ninteiSeikyu;
        SfSeikyushaCheckController.updateSeikyushaShinsaKekka(seikyusha.Id, 'OK', '0次審査テストコメント', '0次審査中');
        Seikyusha__c sk1 = [SELECT Id, ShinsaKekka_00__c, ShinsaKekkaComment_00__c FROM Seikyusha__c WHERE Id = :seikyusha.Id];

        ninteiSeikyu.ShinsaStatus__c = '1次審査中';
        update ninteiSeikyu;
        SfSeikyushaCheckController.updateSeikyushaShinsaKekka(seikyusha.Id, 'OK', '1次審査テストコメント', '1次審査中');
        Seikyusha__c sk2 = [SELECT Id, ShinsaKekka_01__c, ShinsaKekkaComment_01__c FROM Seikyusha__c WHERE Id = :seikyusha.Id];

        ninteiSeikyu.ShinsaStatus__c = '2次審査中';
        update ninteiSeikyu;
        SfSeikyushaCheckController.updateSeikyushaShinsaKekka(seikyusha.Id, 'OK', '2次審査テストコメント', '2次審査中');
        Seikyusha__c sk3 = [SELECT Id, ShinsaKekka_02__c, ShinsaKekkaComment_02__c FROM Seikyusha__c WHERE Id = :seikyusha.Id];

        ninteiSeikyu.ShinsaStatus__c = 'アンマッチ判定';
        update ninteiSeikyu;
        SfSeikyushaCheckController.updateSeikyushaShinsaKekka(seikyusha.Id, 'OK', '最終審査テストコメント', 'アンマッチ判定');
        Seikyusha__c sk4 = [SELECT Id, ShinsaKekkaSaishu__c, ShinsaKekkaComment_Saishu__c FROM Seikyusha__c WHERE Id = :seikyusha.Id];

        Test.stopTest();

        // テスト結果検証
        Assert.areEqual('OK', sk1.ShinsaKekka_00__c);
        Assert.areEqual('0次審査テストコメント', sk1.ShinsaKekkaComment_00__c);

        Assert.areEqual('OK', sk2.ShinsaKekka_01__c);
        Assert.areEqual('1次審査テストコメント', sk2.ShinsaKekkaComment_01__c);

        Assert.areEqual('OK', sk3.ShinsaKekka_02__c);
        Assert.areEqual('2次審査テストコメント', sk3.ShinsaKekkaComment_02__c);

        Assert.areEqual('OK', sk4.ShinsaKekkaSaishu__c);
        Assert.areEqual('最終審査テストコメント', sk4.ShinsaKekkaComment_Saishu__c);
    }

    @isTest
    static void updateSeikyushaShinsaKekkaError() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        Test.startTest();
        ninteiSeikyu.ShinsaStatus__c = '0次審査中';
        update ninteiSeikyu;
        
        String errorMessage = SfSeikyushaCheckController.updateSeikyushaShinsaKekka(seikyusha.Id, 'OK', '0次審査テストコメント', '1次審査中');

        Assert.areEqual(ERROR_MESSAGE_STATUS_CHANGED, errorMessage);
    }

    @isTest
    static void getTeikeiCommentOptions() {

        Schema.describeFieldResult fieldResult1 = Seikyusha__c.ShinsaKekkaTeikeiComment_Yuso_00__c.getDescribe();
        Schema.describeFieldResult fieldResult2 = Seikyusha__c.ShinsaKekkaTeikeiComment_Yuso_01__c.getDescribe();
        Schema.describeFieldResult fieldResult3 = Seikyusha__c.ShinsaKekkaTeikeiComment_Web_00__c.getDescribe();
        Schema.describeFieldResult fieldResult4 = Seikyusha__c.ShinsaKekkaTeikeiComment_Web_01__c.getDescribe();

        List<Schema.PicklistEntry> optionList1 = fieldResult1.getPicklistValues();
        List<Schema.PicklistEntry> optionList2 = fieldResult2.getPicklistValues();
        List<Schema.PicklistEntry> optionList3 = fieldResult3.getPicklistValues();
        List<Schema.PicklistEntry> optionList4 = fieldResult4.getPicklistValues();

        List<String> optionLabelList1 = new List<String>();
        for(Schema.PicklistEntry option :optionList1) {optionLabelList1.add(option.getLabel());}
        optionLabelList1.sort();

        List<String> optionLabelList2 = new List<String>();
        for(Schema.PicklistEntry option :optionList2) {optionLabelList2.add(option.getLabel());}
        optionLabelList2.sort();
        
        List<String> optionLabelList3 = new List<String>();
        for(Schema.PicklistEntry option :optionList3) {optionLabelList3.add(option.getLabel());}
        optionLabelList3.sort();

        List<String> optionLabelList4 = new List<String>();
        for(Schema.PicklistEntry option :optionList4) {optionLabelList4.add(option.getLabel());}
        optionLabelList4.sort();

        String teikeiCommentOptions1 = SfSeikyushaCheckController.getTeikeiCommentOptions(true, true);
        String teikeiCommentOptions2 = SfSeikyushaCheckController.getTeikeiCommentOptions(true, false);
        String teikeiCommentOptions3 = SfSeikyushaCheckController.getTeikeiCommentOptions(false, true);
        String teikeiCommentOptions4 = SfSeikyushaCheckController.getTeikeiCommentOptions(false, false);

        List<Object> teigiSentakuList1 = (List<Object>)JSON.deserializeUntyped(teikeiCommentOptions1);
        List<Object> teigiSentakuList2 = (List<Object>)JSON.deserializeUntyped(teikeiCommentOptions2);
        List<Object> teigiSentakuList3 = (List<Object>)JSON.deserializeUntyped(teikeiCommentOptions3);
        List<Object> teigiSentakuList4 = (List<Object>)JSON.deserializeUntyped(teikeiCommentOptions4);

        List<String> checkOptionLabelList1 = new List<String>();
        for(Object teigiSentaku :teigiSentakuList1) {
            Map<String, Object> teigiSentakuMap = (Map<String, Object>)teigiSentaku;
            checkOptionLabelList1.add((String)teigiSentakuMap.get('label'));
        }
        checkOptionLabelList1.sort();

        List<String> checkOptionLabelList2 = new List<String>();
        for(Object teigiSentaku :teigiSentakuList2) {
            Map<String, Object> teigiSentakuMap = (Map<String, Object>)teigiSentaku;
            checkOptionLabelList2.add((String)teigiSentakuMap.get('label'));
        }
        checkOptionLabelList2.sort();

        List<String> checkOptionLabelList3 = new List<String>();
        for(Object teigiSentaku :teigiSentakuList3) {
            Map<String, Object> teigiSentakuMap = (Map<String, Object>)teigiSentaku;
            checkOptionLabelList3.add((String)teigiSentakuMap.get('label'));
        }
        checkOptionLabelList3.sort();

        List<String> checkOptionLabelList4 = new List<String>();
        for(Object teigiSentaku :teigiSentakuList4) {
            Map<String, Object> teigiSentakuMap = (Map<String, Object>)teigiSentaku;
            checkOptionLabelList4.add((String)teigiSentakuMap.get('label'));
        }
        checkOptionLabelList4.sort();

        Assert.areEqual(checkOptionLabelList1.get(0), optionLabelList1.get(0));
        Assert.areEqual(checkOptionLabelList2.get(0), optionLabelList2.get(0));
        Assert.areEqual(checkOptionLabelList3.get(0), optionLabelList3.get(0));
        Assert.areEqual(checkOptionLabelList4.get(0), optionLabelList4.get(0));
    }

}