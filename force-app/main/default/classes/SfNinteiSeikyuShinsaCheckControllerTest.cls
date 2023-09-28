@isTest
public with sharing class SfNinteiSeikyuShinsaCheckControllerTest {

    public static final String USER_PROFILE_SHINSA = '審査';
    
    public static final String USER_NAME_STR_SHINSA = 'ShinsaTest';

    public static final String SEIKYUSHA_NAME_STR   = 'テスト　請求者';
    public static final String TAISHOJIDO_NAME_STR  = 'テスト対象児童1';

    private static final String SHINSA_STATUS_STR_SHINSACHU_00    = '0次審査中';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_00 = '1次審査待ち';
    private static final String SHINSA_STATUS_STR_SHINSACHU_01    = '1次審査中';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_01 = '2次審査待ち';
    private static final String SHINSA_STATUS_STR_SHINSACHU_02    = '2次審査中';
    private static final String SHINSA_STATUS_STR_UNMATCH         = 'アンマッチ判定';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_02 = '審査完了';

    private static final String SHINSA_KEKKA_STR_OK = 'OK';
    private static final String SHINSA_KEKKA_STR_NG = 'NG';

    private static final String PERMISSION_NAME_STR_LD = 'Shinsa_LD';

    @TestSetup
    static void makeData(){
        // 審査ユーザを準備
        User shinsaUser1 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        insert shinsaUser1;

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

    // ユーザのプロファイルを取得
    @isTest
    static void getUserProfile() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            Test.startTest();

            Profile userProfile = SfNinteiSeikyuShinsaCheckController.getUserProfile(u.Id);

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

            String permissionJsonStr = SfNinteiSeikyuShinsaCheckController.getUserPermissionSetAssignment(u.Id);

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

    // IDから認定請求を取得する
    @isTest
    static void getNinteiSeikyu() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];
            seikyusha.ShinsaKekka_00__c    = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_01__c    = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_02__c    = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekkaSaishu__c = SHINSA_KEKKA_STR_OK;
            seikyusha.Shimei__c            = SEIKYUSHA_NAME_STR;
            update seikyusha;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSAKANRYO_02;
            update ninteiSeikyu;

            Test.startTest();

            NinteiSeikyu__c controllerNinteiSeikyu = SfNinteiSeikyuShinsaCheckController.getNinteiSeikyu(ninteiSeikyu.Id);

            Test.stopTest();

            NinteiSeikyu__c kakuninNinteiSeikyu = [SELECT Id,
                                                   ShinsaStatus__c,
                                                   Seikyusha__c,
                                                   Seikyusha__r.ShinsaKekka_00__c,
                                                   Seikyusha__r.ShinsaKekka_01__c,
                                                   Seikyusha__r.ShinsaKekka_02__c,
                                                   Seikyusha__r.ShinsaKekkaSaishu__c,
                                                   Seikyusha__r.Shimei__c
                                              FROM NinteiSeikyu__c
                                             LIMIT 1];

            Assert.areEqual(kakuninNinteiSeikyu.ShinsaStatus__c                  , controllerNinteiSeikyu.ShinsaStatus__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusha__c                     , controllerNinteiSeikyu.Seikyusha__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusha__r.ShinsaKekka_00__c   , controllerNinteiSeikyu.Seikyusha__r.ShinsaKekka_00__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusha__r.ShinsaKekka_01__c   , controllerNinteiSeikyu.Seikyusha__r.ShinsaKekka_01__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusha__r.ShinsaKekka_02__c   , controllerNinteiSeikyu.Seikyusha__r.ShinsaKekka_02__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusha__r.ShinsaKekkaSaishu__c, controllerNinteiSeikyu.Seikyusha__r.ShinsaKekkaSaishu__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusha__r.Shimei__c           , controllerNinteiSeikyu.Seikyusha__r.Shimei__c);
        }
    }

    // 認定請求から関連する対象児童を取得する
    @isTest
    static void getTaishoJido() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

            List<TaishoJido__c> taishoJidoList = [SELECT Id
                                                    FROM TaishoJido__c
                                                   WHERE NinteiSeikyu__c = :ninteiSeikyu.Id];
            for(Integer i=0; i<taishoJidoList.size(); i++) {
                taishoJidoList[i].Shimei__c = TAISHOJIDO_NAME_STR;
                taishoJidoList[i].ShinsaKekka_00__c    = SHINSA_KEKKA_STR_OK;
                taishoJidoList[i].ShinsaKekka_01__c    = SHINSA_KEKKA_STR_OK;
                taishoJidoList[i].ShinsaKekka_02__c    = SHINSA_KEKKA_STR_OK;
                taishoJidoList[i].ShinsaKekkaSaishu__c = SHINSA_KEKKA_STR_OK;
            }
            update taishoJidoList;

            Test.startTest();

            List<TaishoJido__c> controllerTaishoJidoList = SfNinteiSeikyuShinsaCheckController.getTaishoJido(ninteiSeikyu.Id);

            Test.stopTest();

            Map<Id, TaishoJido__c> controllerTaishoJidoMap = new Map<Id, TaishoJido__c>();
            for(TaishoJido__c jido :controllerTaishoJidoList) {
                controllerTaishoJidoMap.put(jido.Id, jido);
            }

            List<TaishoJido__c> kakuninTaishoJidoList = [SELECT Id,
                                                         Shimei__c,
                                                         ShinsaKekka_00__c,
                                                         ShinsaKekka_01__c,
                                                         ShinsaKekka_02__c,
                                                         ShinsaKekkaSaishu__c
                                                    FROM TaishoJido__c
                                                   WHERE NinteiSeikyu__c = :ninteiSeikyu.Id];
            Map<Id, TaishoJido__c> kakuninTaishoJidoMap = new Map<Id, TaishoJido__c>();
            for(TaishoJido__c jido :kakuninTaishoJidoList) {
                kakuninTaishoJidoMap.put(jido.Id, jido);
            }

            Assert.areEqual(kakuninTaishoJidoList.size(), controllerTaishoJidoList.size());
            for(Id taishoJidoId :controllerTaishoJidoMap.keySet()) {
                Assert.isNotNull(controllerTaishoJidoMap.get(taishoJidoId));
                Assert.areEqual(kakuninTaishoJidoMap.get(taishoJidoId).Shimei__c           , controllerTaishoJidoMap.get(taishoJidoId).Shimei__c);
                Assert.areEqual(kakuninTaishoJidoMap.get(taishoJidoId).ShinsaKekka_00__c   , controllerTaishoJidoMap.get(taishoJidoId).ShinsaKekka_00__c);
                Assert.areEqual(kakuninTaishoJidoMap.get(taishoJidoId).ShinsaKekka_01__c   , controllerTaishoJidoMap.get(taishoJidoId).ShinsaKekka_01__c);
                Assert.areEqual(kakuninTaishoJidoMap.get(taishoJidoId).ShinsaKekka_02__c   , controllerTaishoJidoMap.get(taishoJidoId).ShinsaKekka_02__c);
                Assert.areEqual(kakuninTaishoJidoMap.get(taishoJidoId).ShinsaKekkaSaishu__c, controllerTaishoJidoMap.get(taishoJidoId).ShinsaKekkaSaishu__c);
            }
        }
    }

    // 0次審査完了処理を実行する
    @isTest
    static void complete0thShinsa() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_00);

            Test.stopTest();

            NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM NinteiSeikyu__c LIMIT 1];

            Assert.areEqual(errorMessage, '');
            Assert.areEqual(sinsaKanryoNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSAKANRYO_00);
        }
    }

    // 1次審査完了処理を実行する
    @isTest
    static void complete1stShinsa() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {
            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_01);

            Test.stopTest();

            NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM NinteiSeikyu__c LIMIT 1];

            Assert.areEqual(errorMessage, '');
            Assert.areEqual(sinsaKanryoNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSAKANRYO_01);
        }
    }

    // 2次審査完了処理を実行する
    // 請求者や対象児童にアンマッチがない場合
    @isTest
    static void complete2ndShinsaWithoutUnmatch() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {
            Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c];
            seikyusha.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_02__c = SHINSA_KEKKA_STR_OK;
            update seikyusha;

            TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c];
            taishoJido.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_02__c = SHINSA_KEKKA_STR_OK;
            update taishoJido;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_02);

            Test.stopTest();

            NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM NinteiSeikyu__c LIMIT 1];

            Assert.areEqual(errorMessage, '');
            Assert.areEqual(sinsaKanryoNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSAKANRYO_02);
        }
    }

    // 2次審査完了処理を実行する
    // 請求者や対象児童にアンマッチがある場合
    @isTest
    static void complete2ndShinsaWithUnmatch() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {
            Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c];
            seikyusha.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_02__c = SHINSA_KEKKA_STR_NG;
            update seikyusha;

            TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c];
            taishoJido.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_02__c = SHINSA_KEKKA_STR_NG;
            update taishoJido;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_02);

            Test.stopTest();

            NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM NinteiSeikyu__c LIMIT 1];

            Assert.areEqual(errorMessage, '');
            Assert.areEqual(sinsaKanryoNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_UNMATCH);
        }
    }

    // 最終審査完了処理を実行する
    @isTest
    static void completeSaishuShinsa() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_UNMATCH);

            Test.stopTest();

            NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM NinteiSeikyu__c LIMIT 1];

            Assert.areEqual(errorMessage, '');
            Assert.areEqual(sinsaKanryoNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSAKANRYO_02);
        }
    }
}