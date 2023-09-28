@isTest
private class SfTaishoJidoCheckControllerTest {

    public static final String USER_PROFILE_SHINSA = '審査';
    public static final String USER_NAME_STR_SHINSA = 'ShinsaTest';

    private static final String ERROR_MESSAGE_NO_ZENKAKU_SPACE = '氏名または氏名（フリガナ）に全角スペースが含まれていません。';
    private static final String ERROR_MESSAGE_STATUS_CHANGED   = '対象の審査はすでに完了しています。';

    private static final String PERMISSION_NAME_STR_LD = 'Shinsa_LD';

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


    @isTest //ユーザプロファイルを取得
    static void getUserProfile() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            Test.startTest();
            Profile userProfile = SfTaishoJidoCheckController.getUserProfile(u.Id);
            Test.stopTest();

            Assert.areEqual(userProfile.Name, USER_PROFILE_SHINSA);
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

            String permissionJsonStr = SfTaishoJidoCheckController.getUserPermissionSetAssignment(u.Id);

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

    @isTest //対象児童レコードを取得
    static void getTaishoJido() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {
            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            NinteiSeikyu.ShinsaStatus__c              = '0次審査中';
            NinteiSeikyu.ShinsaTantousha_00__c        = u.Id;
            NinteiSeikyu.ShinsaTantousha_01__c        = u.Id;
            NinteiSeikyu.ShinsaTantousha_02__c        = u.Id;
            NinteiSeikyu.ShinsaTantousha_Saishu__c    = u.Id;
            NinteiSeikyu.SeikyushaKubun_Dairinin__c   = false;
            update ninteiSeikyu;

            TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
            taishoJido.ShinsaKekka_00__c                  = 'OK';
            taishoJido.ShinsaKekka_01__c                  = 'OK';
            taishoJido.ShinsaKekka_02__c                  = 'OK';
            taishoJido.ShinsaKekkaSaishu__c               = 'OK';
            taishoJido.ShinsaKekkaComment_00__c           = '';
            taishoJido.ShinsaKekkaComment_01__c           = '';
            taishoJido.ShinsaKekkaComment_02__c           = '';
            taishoJido.ShinsaKekkaComment_Saishu__c       = '';
            taishoJido.UketoriKouzaKubun_Seikyusha__c     = true;
            taishoJido.UketoriKouzaKubun_Taishosha__c     = false;
            taishoJido.Moushitate_KokenninCheck__c        = false;
            taishoJido.Moushitate_BekkyoKango__c          = false;
            taishoJido.Moushitate_KaigaiRyugakuCheck__c   = false;
            taishoJido.Moushitate_RikonKyogiCheck__c      = false;
            taishoJido.Moushitate_FuboSiteishaCheck__c    = false;
            update taishoJido;

            Test.startTest();
            TaishoJido__c assertTaishoJido = SfTaishoJidoCheckController.getTaishoJido(taishoJido.Id);
            Test.stopTest();

            Assert.areEqual(taishoJido.Id, assertTaishoJido.Id);
        }

    }


    @isTest //contentVersionレコードを取得
    static void getContentVersion() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
        insert taishoJido;

        ContentVersion contentVersion    = SfTestUtil.getContentVersion();
        insert contentVersion;

        List<ContentDocument> contentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId    = taishoJido.Id;
        cdl.ContentDocumentId = contentDocument[0].Id;
        insert cdl;

        Test.startTest();
            List<ContentVersion> assertContentVersion = SfTaishoJidoCheckController.getContentVersion(taishoJido.Id);
        Test.stopTest();

        Assert.areEqual(contentVersion.Id, assertContentVersion[0].Id);
    }


    @isTest//対象児童の審査結果をアップデート
    static void updateTaishoJidoShinsaKekka() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
        insert taishoJido;


        Test.startTest();
        ninteiSeikyu.ShinsaStatus__c = '0次審査中';
        update ninteiSeikyu;
        SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka(taishoJido.Id, 'OK', '0次審査テストコメント', '0次審査中');
        TaishoJido__c tj1 = [SELECT Id, ShinsaKekka_00__c, ShinsaKekkaComment_00__c FROM TaishoJido__c WHERE Id = :taishoJido.Id];

        ninteiSeikyu.ShinsaStatus__c = '1次審査中';
        update ninteiSeikyu;
        SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka(taishoJido.Id, 'OK', '1次審査テストコメント', '1次審査中');
        TaishoJido__c tj2 = [SELECT Id, ShinsaKekka_01__c, ShinsaKekkaComment_01__c FROM TaishoJido__c WHERE Id = :taishoJido.Id];

        ninteiSeikyu.ShinsaStatus__c = '2次審査中';
        update ninteiSeikyu;
        SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka(taishoJido.Id, 'OK', '2次審査テストコメント', '2次審査中');
        TaishoJido__c tj3 = [SELECT Id, ShinsaKekka_02__c, ShinsaKekkaComment_02__c FROM TaishoJido__c WHERE Id = :taishoJido.Id];

        ninteiSeikyu.ShinsaStatus__c = 'アンマッチ判定';
        update ninteiSeikyu;
        SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka(taishoJido.Id, 'OK', '最終審査テストコメント', 'アンマッチ判定');
        TaishoJido__c tj4 = [SELECT Id, ShinsaKekkaSaishu__c, ShinsaKekkaComment_Saishu__c FROM TaishoJido__c WHERE Id = :taishoJido.Id];
        Test.stopTest();


        Assert.areEqual('OK', tj1.ShinsaKekka_00__c);
        Assert.areEqual('0次審査テストコメント', tj1.ShinsaKekkaComment_00__c);

        Assert.areEqual('OK', tj2.ShinsaKekka_01__c);
        Assert.areEqual('1次審査テストコメント', tj2.ShinsaKekkaComment_01__c);

        Assert.areEqual('OK', tj3.ShinsaKekka_02__c);
        Assert.areEqual('2次審査テストコメント', tj3.ShinsaKekkaComment_02__c);

        Assert.areEqual('OK', tj4.ShinsaKekkaSaishu__c);
        Assert.areEqual('最終審査テストコメント', tj4.ShinsaKekkaComment_Saishu__c);
    }

    @isTest
    static void updateTaishoJidoShinsaKekkaStatusError() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
        insert taishoJido;

        Test.startTest();
        ninteiSeikyu.ShinsaStatus__c = '0次審査中';
        update ninteiSeikyu;
        
        String errorMessage = SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka(taishoJido.Id, 'OK', '0次審査テストコメント', '1次審査中');

        Assert.areEqual(ERROR_MESSAGE_STATUS_CHANGED, errorMessage);
    }

    //対象児童の審査結果をアップデートでエラー
    @isTest
    static void updateTaishoJidoShinsaKekkaZenkakuError() {
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        YusoShinsei__c yusoShinsei = new YusoShinsei__c();
        insert yusoShinsei;

        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        ninteiSeikyu.YusoShinsei__c = yusoShinsei.Id;
        insert ninteiSeikyu;

        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
        taishoJido.Shimei__c = 'テスト太郎';
        insert taishoJido;


        Test.startTest();
        String errorMessage = SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka(taishoJido.Id, 'OK', '0次審査テストコメント', '0次審査中');

        Test.stopTest();

        Assert.areEqual(errorMessage, ERROR_MESSAGE_NO_ZENKAKU_SPACE);
    }

    @isTest
    static void getTeikeiCommentOptions() {

        Schema.describeFieldResult fieldResult1 = TaishoJido__c.ShinsaKekkaTeikeiComment_Yuso_00__c.getDescribe();
        Schema.describeFieldResult fieldResult2 = TaishoJido__c.ShinsaKekkaTeikeiComment_Yuso_01__c.getDescribe();
        Schema.describeFieldResult fieldResult3 = TaishoJido__c.ShinsaKekkaTeikeiComment_Web_00__c.getDescribe();
        Schema.describeFieldResult fieldResult4 = TaishoJido__c.ShinsaKekkaTeikeiComment_Web_01__c.getDescribe();

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

        String teikeiCommentOptions1 = SfTaishoJidoCheckController.getTeikeiCommentOptions(true, true);
        String teikeiCommentOptions2 = SfTaishoJidoCheckController.getTeikeiCommentOptions(true, false);
        String teikeiCommentOptions3 = SfTaishoJidoCheckController.getTeikeiCommentOptions(false, true);
        String teikeiCommentOptions4 = SfTaishoJidoCheckController.getTeikeiCommentOptions(false, false);

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