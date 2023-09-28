@isTest
public with sharing class SfDVNinteiSeikyuShinsaCheckControlTest {
    
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

    @TestSetup
    static void makeData(){
        // 審査ユーザを準備
        User shinsaUser1 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        insert shinsaUser1;

        // 請求者
        DV_Seikyusha__c seikyusha = SfTestUtil.getSeikyushaDV();
        insert seikyusha;

        // 認定請求
        DV_NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyuDV(seikyusha.Id);
        insert ninteiSeikyu;

        // 対象児童
        DV_TaishoJido__c taishoJido = SfTestUtil.getTaishoJidoDV(ninteiSeikyu.Id);
        insert taishoJido;
    }

    // ユーザのプロファイルを取得
    @isTest
    static void getUserProfile() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            Test.startTest();

            Profile userProfile = SfDVNinteiSeikyuShinsaCheckController.getUserProfile(u.Id);

            Test.stopTest();

            Assert.areEqual(userProfile.Name, USER_PROFILE_SHINSA);
        }
    }

    // IDから認定請求を取得する
    @isTest
    static void getNinteiSeikyu() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
            seikyusha.ShinsaKekka_00__c    = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_01__c    = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_02__c    = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekkaSaishu__c = SHINSA_KEKKA_STR_OK;
            seikyusha.Shimei__c            = SEIKYUSHA_NAME_STR;
            update seikyusha;

            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSAKANRYO_02;
            update ninteiSeikyu;

            Test.startTest();

            DV_NinteiSeikyu__c controllerNinteiSeikyu = SfDVNinteiSeikyuShinsaCheckController.getNinteiSeikyu(ninteiSeikyu.Id);

            Test.stopTest();

            DV_NinteiSeikyu__c kakuninNinteiSeikyu = [SELECT Id,
                                                             ShinsaStatus__c,
                                                             Seikyusya__c,
                                                             Seikyusya__r.ShinsaKekka_00__c,
                                                             Seikyusya__r.ShinsaKekka_01__c,
                                                             Seikyusya__r.ShinsaKekka_02__c,
                                                             Seikyusya__r.ShinsaKekkaSaishu__c,
                                                             Seikyusya__r.Shimei__c
                                                        FROM DV_NinteiSeikyu__c
                                                       LIMIT 1];

            Assert.areEqual(kakuninNinteiSeikyu.ShinsaStatus__c                  , controllerNinteiSeikyu.ShinsaStatus__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusya__c                     , controllerNinteiSeikyu.Seikyusya__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusya__r.ShinsaKekka_00__c   , controllerNinteiSeikyu.Seikyusya__r.ShinsaKekka_00__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusya__r.ShinsaKekka_01__c   , controllerNinteiSeikyu.Seikyusya__r.ShinsaKekka_01__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusya__r.ShinsaKekka_02__c   , controllerNinteiSeikyu.Seikyusya__r.ShinsaKekka_02__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusya__r.ShinsaKekkaSaishu__c, controllerNinteiSeikyu.Seikyusya__r.ShinsaKekkaSaishu__c);
            Assert.areEqual(kakuninNinteiSeikyu.Seikyusya__r.Shimei__c           , controllerNinteiSeikyu.Seikyusya__r.Shimei__c);
        }
    }

    // 認定請求から関連する対象児童を取得する
    @isTest
    static void getTaishoJido() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {

            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            List<DV_TaishoJido__c> taishoJidoList = [SELECT Id
                                                       FROM DV_TaishoJido__c
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

            List<DV_TaishoJido__c> controllerTaishoJidoList = SfDVNinteiSeikyuShinsaCheckController.getTaishoJido(ninteiSeikyu.Id);

            Test.stopTest();

            Map<Id, DV_TaishoJido__c> controllerTaishoJidoMap = new Map<Id, DV_TaishoJido__c>();
            for(DV_TaishoJido__c jido :controllerTaishoJidoList) {
                controllerTaishoJidoMap.put(jido.Id, jido);
            }

            List<DV_TaishoJido__c> kakuninTaishoJidoList = [SELECT Id,
                                                                   Shimei__c,
                                                                   ShinsaKekka_00__c,
                                                                   ShinsaKekka_01__c,
                                                                   ShinsaKekka_02__c,
                                                                   ShinsaKekkaSaishu__c
                                                              FROM DV_TaishoJido__c
                                                             WHERE NinteiSeikyu__c = :ninteiSeikyu.Id];
            Map<Id, DV_TaishoJido__c> kakuninTaishoJidoMap = new Map<Id, DV_TaishoJido__c>();
            for(DV_TaishoJido__c jido :kakuninTaishoJidoList) {
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

            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfDVNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_00);

            Test.stopTest();

            DV_NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c LIMIT 1];

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
            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfDVNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_01);

            Test.stopTest();

            DV_NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c LIMIT 1];

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
            DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c];
            seikyusha.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_02__c = SHINSA_KEKKA_STR_OK;
            update seikyusha;

            DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c];
            taishoJido.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_02__c = SHINSA_KEKKA_STR_OK;
            update taishoJido;

            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfDVNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_02);

            Test.stopTest();

            DV_NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c LIMIT 1];

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
            DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c];
            seikyusha.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            seikyusha.ShinsaKekka_02__c = SHINSA_KEKKA_STR_NG;
            update seikyusha;

            DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c];
            taishoJido.ShinsaKekka_00__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_01__c = SHINSA_KEKKA_STR_OK;
            taishoJido.ShinsaKekka_02__c = SHINSA_KEKKA_STR_NG;
            update taishoJido;

            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfDVNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_SHINSACHU_02);

            Test.stopTest();

            DV_NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c LIMIT 1];

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

            DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            Test.startTest();

            String errorMessage = SfDVNinteiSeikyuShinsaCheckController.completeShinsa(ninteiSeikyu.Id, SHINSA_STATUS_STR_UNMATCH);

            Test.stopTest();

            DV_NinteiSeikyu__c sinsaKanryoNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c LIMIT 1];

            Assert.areEqual(errorMessage, '');
            Assert.areEqual(sinsaKanryoNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSAKANRYO_02);
        }
    }
}