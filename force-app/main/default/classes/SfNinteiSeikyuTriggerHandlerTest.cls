@isTest
public with sharing class SfNinteiSeikyuTriggerHandlerTest {

    public static final String USER_NAME_STR_SHINSA   = 'ShinsaTest';
    public static final String USER_NAME_STR_SHINSA_2 = 'ShinsaTest2';

    public static final String STATUS_STR_MISHINSEI            = '未申請';
    public static final String STATUS_STR_OCR_SHORICHU         = 'OCR処理中';
    public static final String STATUS_STR_SHINSAKANRYO         = '審査完了';
    public static final String STATUS_STR_MUKO                 = '無効';
    public static final String FUBI_STATUS_STR_MIRENRAKU       = '不備未連絡';
    public static final String FUBI_STATUS_STR_RENRAKUZUMI     = '不備連絡済み';
    public static final String SHINSAKEKKA_STR_OK              = 'OK';
    public static final String SHINSAKEKKA_STR_NG              = 'NG';
    public static final String SHINSAKEKKA_STR_FUBI            = '不備';

    public static final String TEST_COMMENT_STR = 'テストコメントです。';

    public static final String TEST_DATE_STR = '2023/08/17';
    public static final Date TEST_DATE       = Date.newInstance(2023, 8, 17);

    @TestSetup
    static void makeData(){
        // 審査ユーザを準備
        List<User> shinsaUserList = new List<User>();

        User shinsaUser1 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        shinsaUserList.add(shinsaUser1);

        User shinsaUser2 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA_2);
        shinsaUserList.add(shinsaUser2);

        insert shinsaUserList;

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

    // 審査ステータスが未申請以外に変更された場合処理が起動しない
    @isTest
    static void updateStatusNotMishinsei() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {
            Seikyusha__c seikyusha = [SELECT Id, Shimei__c FROM Seikyusha__c LIMIT 1];
            seikyusha.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
            seikyusha.ShinsaKekka_00__c = SHINSAKEKKA_STR_NG;
            update seikyusha;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaTantousha_00__c = u.Id;
            update ninteiSeikyu;

            TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
            taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
            taishoJido.ShinsaKekka_00__c = SHINSAKEKKA_STR_NG;
            update taishoJido;

            Test.startTest();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_OCR_SHORICHU;
            update ninteiSeikyu;

            Seikyusha__c assertSeikyusha = [SELECT Id, Shimei__c, ShinsaKekka_00__c FROM Seikyusha__c LIMIT 1];
            NinteiSeikyu__c assertNinteiSeikyu = [SELECT Id, Seikyusha__c, ShinsaTantousha_00__c FROM NinteiSeikyu__c LIMIT 1];
            TaishoJido__c assertTaishoJido = [SELECT Id, NinteiSeikyu__c, ShinsaKekka_00__c FROM TaishoJido__c LIMIT 1];

            Test.stopTest();

            Assert.isNotNull(assertSeikyusha.ShinsaKekka_00__c);
            Assert.isNotNull(assertNinteiSeikyu.ShinsaTantousha_00__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_00__c);
        }
    }

    // 審査ステータスが審査中または審査完了でなかった場合処理が起動しない
    @isTest
    static void updateStatusFromNotShinsachu() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];
        System.runAs(u) {
            Seikyusha__c seikyusha = [SELECT Id, Shimei__c FROM Seikyusha__c LIMIT 1];
            seikyusha.HubiStatus__c     = FUBI_STATUS_STR_RENRAKUZUMI;
            seikyusha.ShinsaKekka_00__c = SHINSAKEKKA_STR_NG;
            update seikyusha;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaTantousha_00__c = u.Id;
            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_MUKO;
            update ninteiSeikyu;

            TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
            taishoJido.HubiStatus__c     = FUBI_STATUS_STR_RENRAKUZUMI;
            taishoJido.ShinsaKekka_00__c = SHINSAKEKKA_STR_NG;
            update taishoJido;

            Test.startTest();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_MISHINSEI;
            update ninteiSeikyu;

            Seikyusha__c assertSeikyusha = [SELECT Id, Shimei__c, ShinsaKekka_00__c FROM Seikyusha__c LIMIT 1];
            NinteiSeikyu__c assertNinteiSeikyu = [SELECT Id, Seikyusha__c, ShinsaTantousha_00__c FROM NinteiSeikyu__c LIMIT 1];
            TaishoJido__c assertTaishoJido = [SELECT Id, NinteiSeikyu__c, ShinsaKekka_00__c FROM TaishoJido__c LIMIT 1];

            Test.stopTest();

            Assert.isNotNull(assertSeikyusha.ShinsaKekka_00__c);
            Assert.isNotNull(assertNinteiSeikyu.ShinsaTantousha_00__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_00__c);
        }
    }

    // 再審査で審査ステータスに未申請が設定された場合、認定請求の情報をクリアする
    // 再審査で審査ステータスに未申請が設定された場合、不備の請求者/対象児童の審査結果をクリアする
    @isTest
    static void updateStatusWithFubi() {
        String userName1 = USER_NAME_STR_SHINSA   + SfTestUtil.TEST_DOMAIN;
        String userName2 = USER_NAME_STR_SHINSA_2 + SfTestUtil.TEST_DOMAIN;
        List<User> uList = [SELECT Id, UserName FROM User WHERE UserName = :userName1 OR UserName = :userName2];
        System.runAs(uList.get(0)) {
            Seikyusha__c seikyusha = [SELECT Id, Shimei__c FROM Seikyusha__c LIMIT 1];

            seikyusha.ShinsaKekka_00__c            = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_00__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekka_01__c            = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_01__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekka_02__c            = SHINSAKEKKA_STR_NG;
            seikyusha.ShinsaKekkaComment_02__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekkaSaishu__c         = SHINSAKEKKA_STR_FUBI;
            seikyusha.ShinsaKekkaComment_Saishu__c = TEST_COMMENT_STR;
            update seikyusha;

            seikyusha.HubiStatus__c     = FUBI_STATUS_STR_RENRAKUZUMI;
            update seikyusha;

            TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
            
            taishoJido.ShinsaKekka_00__c            = SHINSAKEKKA_STR_OK;
            taishoJido.ShinsaKekkaComment_00__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekka_01__c            = SHINSAKEKKA_STR_OK;
            taishoJido.ShinsaKekkaComment_01__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekka_02__c            = SHINSAKEKKA_STR_NG;
            taishoJido.ShinsaKekkaComment_02__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekkaSaishu__c         = SHINSAKEKKA_STR_FUBI;
            taishoJido.ShinsaKekkaComment_Saishu__c = TEST_COMMENT_STR;
            update taishoJido;

            taishoJido.HubiStatus__c     = FUBI_STATUS_STR_RENRAKUZUMI;
            update taishoJido;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaTantousha_00__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_00__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_00__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_01__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_01__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_01__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_02__c      = uList.get(1).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_02__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_02__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_Saishu__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_Saishu__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_Saishu__c = Datetime.now();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_SHINSAKANRYO;

            update ninteiSeikyu;

            Test.startTest();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_MISHINSEI;
            update ninteiSeikyu;

            Seikyusha__c assertSeikyusha = [SELECT Id,
                                                   Shimei__c,
                                                   ShinsaKekka_00__c,
                                                   ShinsaKekkaComment_00__c,
                                                   ShinsaKekka_01__c,
                                                   ShinsaKekkaComment_01__c,
                                                   ShinsaKekka_02__c,
                                                   ShinsaKekkaComment_02__c,
                                                   ShinsaKekkaSaishu__c,
                                                   ShinsaKekkaComment_Saishu__c
                                              FROM Seikyusha__c LIMIT 1];
            NinteiSeikyu__c assertNinteiSeikyu = [SELECT Id,
                                                         Seikyusha__c,
                                                         ShinsaTantousha_00__c,
                                                         ShinsaKaishiDateTime_00__c,
                                                         ShinsaKanryoDateTime_00__c,
                                                         ShinsaTantousha_01__c,
                                                         ShinsaKaishiDateTime_01__c,
                                                         ShinsaKanryoDateTime_01__c,
                                                         ShinsaTantousha_02__c,
                                                         ShinsaKaishiDateTime_02__c,
                                                         ShinsaKanryoDateTime_02__c,
                                                         ShinsaTantousha_Saishu__c,
                                                         ShinsaKaishiDateTime_Saishu__c,
                                                         ShinsaKanryoDateTime_Saishu__c
                                                    FROM NinteiSeikyu__c LIMIT 1];
            TaishoJido__c assertTaishoJido = [SELECT Id,
                                                     NinteiSeikyu__c,
                                                     ShinsaKekka_00__c,
                                                     ShinsaKekkaComment_00__c,
                                                     ShinsaKekka_01__c,
                                                     ShinsaKekkaComment_01__c,
                                                     ShinsaKekka_02__c,
                                                     ShinsaKekkaComment_02__c,
                                                     ShinsaKekkaSaishu__c,
                                                     ShinsaKekkaComment_Saishu__c
                                                FROM TaishoJido__c LIMIT 1];

            Test.stopTest();

            Assert.isNull(assertSeikyusha.ShinsaKekka_00__c);
            Assert.isNull(assertSeikyusha.ShinsaKekkaComment_00__c);
            Assert.isNull(assertSeikyusha.ShinsaKekka_01__c);
            Assert.isNull(assertSeikyusha.ShinsaKekkaComment_01__c);
            Assert.isNull(assertSeikyusha.ShinsaKekka_02__c);
            Assert.isNull(assertSeikyusha.ShinsaKekkaComment_02__c);
            Assert.isNull(assertSeikyusha.ShinsaKekkaSaishu__c);
            Assert.isNull(assertSeikyusha.ShinsaKekkaComment_Saishu__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_00__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_00__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_00__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_01__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_01__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_01__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_02__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_02__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_02__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_Saishu__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_Saishu__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_Saishu__c);
            
            Assert.isNull(assertTaishoJido.ShinsaKekka_00__c);
            Assert.isNull(assertTaishoJido.ShinsaKekkaComment_00__c);
            Assert.isNull(assertTaishoJido.ShinsaKekka_01__c);
            Assert.isNull(assertTaishoJido.ShinsaKekkaComment_01__c);
            Assert.isNull(assertTaishoJido.ShinsaKekka_02__c);
            Assert.isNull(assertTaishoJido.ShinsaKekkaComment_02__c);
            Assert.isNull(assertTaishoJido.ShinsaKekkaSaishu__c);
            Assert.isNull(assertTaishoJido.ShinsaKekkaComment_Saishu__c);
        }
    }

    // 再審査で審査ステータスに未申請が設定された場合、認定請求の情報をクリアする
    // 不備未連絡の請求者の場合も処理が正常に終了する（審査結果はクリアされない）
    @isTest
    static void updateStatusWithoutFubi() {
        String userName1 = USER_NAME_STR_SHINSA   + SfTestUtil.TEST_DOMAIN;
        String userName2 = USER_NAME_STR_SHINSA_2 + SfTestUtil.TEST_DOMAIN;
        List<User> uList = [SELECT Id, UserName FROM User WHERE UserName = :userName1 OR UserName = :userName2];
        System.runAs(uList.get(0)) {
            Seikyusha__c seikyusha = [SELECT Id, Shimei__c FROM Seikyusha__c LIMIT 1];

            seikyusha.ShinsaKekka_00__c            = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_00__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekka_01__c            = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_01__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekka_02__c            = SHINSAKEKKA_STR_NG;
            seikyusha.ShinsaKekkaComment_02__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekkaSaishu__c         = SHINSAKEKKA_STR_FUBI;
            seikyusha.ShinsaKekkaComment_Saishu__c = TEST_COMMENT_STR;

            seikyusha.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;

            update seikyusha;

            TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
            
            taishoJido.ShinsaKekka_00__c            = SHINSAKEKKA_STR_OK;
            taishoJido.ShinsaKekkaComment_00__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekka_01__c            = SHINSAKEKKA_STR_OK;
            taishoJido.ShinsaKekkaComment_01__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekka_02__c            = SHINSAKEKKA_STR_NG;
            taishoJido.ShinsaKekkaComment_02__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekkaSaishu__c         = SHINSAKEKKA_STR_FUBI;
            taishoJido.ShinsaKekkaComment_Saishu__c = TEST_COMMENT_STR;

            taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;

            update taishoJido;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaTantousha_00__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_00__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_00__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_01__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_01__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_01__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_02__c      = uList.get(1).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_02__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_02__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_Saishu__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_Saishu__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_Saishu__c = Datetime.now();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_SHINSAKANRYO;

            update ninteiSeikyu;

            Test.startTest();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_MISHINSEI;
            update ninteiSeikyu;

            Seikyusha__c assertSeikyusha = [SELECT Id,
                                                   Shimei__c,
                                                   ShinsaKekka_00__c,
                                                   ShinsaKekkaComment_00__c,
                                                   ShinsaKekka_01__c,
                                                   ShinsaKekkaComment_01__c,
                                                   ShinsaKekka_02__c,
                                                   ShinsaKekkaComment_02__c,
                                                   ShinsaKekkaSaishu__c,
                                                   ShinsaKekkaComment_Saishu__c
                                              FROM Seikyusha__c LIMIT 1];
            NinteiSeikyu__c assertNinteiSeikyu = [SELECT Id,
                                                         Seikyusha__c,
                                                         ShinsaTantousha_00__c,
                                                         ShinsaKaishiDateTime_00__c,
                                                         ShinsaKanryoDateTime_00__c,
                                                         ShinsaTantousha_01__c,
                                                         ShinsaKaishiDateTime_01__c,
                                                         ShinsaKanryoDateTime_01__c,
                                                         ShinsaTantousha_02__c,
                                                         ShinsaKaishiDateTime_02__c,
                                                         ShinsaKanryoDateTime_02__c,
                                                         ShinsaTantousha_Saishu__c,
                                                         ShinsaKaishiDateTime_Saishu__c,
                                                         ShinsaKanryoDateTime_Saishu__c
                                                    FROM NinteiSeikyu__c LIMIT 1];
            TaishoJido__c assertTaishoJido = [SELECT Id,
                                                     NinteiSeikyu__c,
                                                     ShinsaKekka_00__c,
                                                     ShinsaKekkaComment_00__c,
                                                     ShinsaKekka_01__c,
                                                     ShinsaKekkaComment_01__c,
                                                     ShinsaKekka_02__c,
                                                     ShinsaKekkaComment_02__c,
                                                     ShinsaKekkaSaishu__c,
                                                     ShinsaKekkaComment_Saishu__c
                                                FROM TaishoJido__c LIMIT 1];

            Test.stopTest();

            Assert.isNotNull(assertSeikyusha.ShinsaKekka_00__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_00__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekka_01__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_01__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekka_02__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_02__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaSaishu__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_Saishu__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_00__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_00__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_00__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_01__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_01__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_01__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_02__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_02__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_02__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_Saishu__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_Saishu__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_Saishu__c);
            
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_00__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_00__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_01__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_01__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_02__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_02__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaSaishu__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_Saishu__c);
        }
    }

    // 再審査で審査ステータスに未申請が設定された場合、認定請求の情報をクリアする
    // 不備未連絡の対象児童の場合も処理が正常に終了する（審査結果はクリアされない）
    @isTest
    static void updateStatusWithoutFubi2() {
        String userName1 = USER_NAME_STR_SHINSA   + SfTestUtil.TEST_DOMAIN;
        String userName2 = USER_NAME_STR_SHINSA_2 + SfTestUtil.TEST_DOMAIN;
        List<User> uList = [SELECT Id, UserName FROM User WHERE UserName = :userName1 OR UserName = :userName2];
        System.runAs(uList.get(0)) {
            Seikyusha__c seikyusha = [SELECT Id, Shimei__c FROM Seikyusha__c LIMIT 1];

            seikyusha.ShinsaKekka_00__c            = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_00__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekka_01__c            = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_01__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekka_02__c            = SHINSAKEKKA_STR_NG;
            seikyusha.ShinsaKekkaComment_02__c     = TEST_COMMENT_STR;
            seikyusha.ShinsaKekkaSaishu__c         = SHINSAKEKKA_STR_OK;
            seikyusha.ShinsaKekkaComment_Saishu__c = TEST_COMMENT_STR;

            update seikyusha;

            TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
            
            taishoJido.ShinsaKekka_00__c            = SHINSAKEKKA_STR_OK;
            taishoJido.ShinsaKekkaComment_00__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekka_01__c            = SHINSAKEKKA_STR_OK;
            taishoJido.ShinsaKekkaComment_01__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekka_02__c            = SHINSAKEKKA_STR_NG;
            taishoJido.ShinsaKekkaComment_02__c     = TEST_COMMENT_STR;
            taishoJido.ShinsaKekkaSaishu__c         = SHINSAKEKKA_STR_FUBI;
            taishoJido.ShinsaKekkaComment_Saishu__c = TEST_COMMENT_STR;

            taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;

            update taishoJido;

            NinteiSeikyu__c ninteiSeikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
            ninteiSeikyu.ShinsaTantousha_00__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_00__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_00__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_01__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_01__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_01__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_02__c      = uList.get(1).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_02__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_02__c = Datetime.now();

            ninteiSeikyu.ShinsaTantousha_Saishu__c      = uList.get(0).Id;
            ninteiSeikyu.ShinsaKaishiDateTime_Saishu__c = Datetime.now();
            ninteiSeikyu.ShinsaKanryoDateTime_Saishu__c = Datetime.now();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_SHINSAKANRYO;

            update ninteiSeikyu;

            Test.startTest();

            ninteiSeikyu.ShinsaStatus__c = STATUS_STR_MISHINSEI;
            update ninteiSeikyu;

            Seikyusha__c assertSeikyusha = [SELECT Id,
                                                   Shimei__c,
                                                   ShinsaKekka_00__c,
                                                   ShinsaKekkaComment_00__c,
                                                   ShinsaKekka_01__c,
                                                   ShinsaKekkaComment_01__c,
                                                   ShinsaKekka_02__c,
                                                   ShinsaKekkaComment_02__c,
                                                   ShinsaKekkaSaishu__c,
                                                   ShinsaKekkaComment_Saishu__c
                                              FROM Seikyusha__c LIMIT 1];
            NinteiSeikyu__c assertNinteiSeikyu = [SELECT Id,
                                                         Seikyusha__c,
                                                         ShinsaTantousha_00__c,
                                                         ShinsaKaishiDateTime_00__c,
                                                         ShinsaKanryoDateTime_00__c,
                                                         ShinsaTantousha_01__c,
                                                         ShinsaKaishiDateTime_01__c,
                                                         ShinsaKanryoDateTime_01__c,
                                                         ShinsaTantousha_02__c,
                                                         ShinsaKaishiDateTime_02__c,
                                                         ShinsaKanryoDateTime_02__c,
                                                         ShinsaTantousha_Saishu__c,
                                                         ShinsaKaishiDateTime_Saishu__c,
                                                         ShinsaKanryoDateTime_Saishu__c
                                                    FROM NinteiSeikyu__c LIMIT 1];
            TaishoJido__c assertTaishoJido = [SELECT Id,
                                                     NinteiSeikyu__c,
                                                     ShinsaKekka_00__c,
                                                     ShinsaKekkaComment_00__c,
                                                     ShinsaKekka_01__c,
                                                     ShinsaKekkaComment_01__c,
                                                     ShinsaKekka_02__c,
                                                     ShinsaKekkaComment_02__c,
                                                     ShinsaKekkaSaishu__c,
                                                     ShinsaKekkaComment_Saishu__c
                                                FROM TaishoJido__c LIMIT 1];

            Test.stopTest();

            Assert.isNotNull(assertSeikyusha.ShinsaKekka_00__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_00__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekka_01__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_01__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekka_02__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_02__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaSaishu__c);
            Assert.isNotNull(assertSeikyusha.ShinsaKekkaComment_Saishu__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_00__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_00__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_00__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_01__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_01__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_01__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_02__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_02__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_02__c);

            Assert.isNull(assertNinteiSeikyu.ShinsaTantousha_Saishu__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKaishiDateTime_Saishu__c);
            Assert.isNull(assertNinteiSeikyu.ShinsaKanryoDateTime_Saishu__c);
            
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_00__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_00__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_01__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_01__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekka_02__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_02__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaSaishu__c);
            Assert.isNotNull(assertTaishoJido.ShinsaKekkaComment_Saishu__c);
        }
    }

    // OCR連携項目で日付型やメールアドレス型に変換する必要がある項目について連携する
    @isTest
    static void updateOCRField() {

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.OCR_ShinseiDateOCR__c = TEST_DATE_STR;
        ninteiSeikyu.IninDateOCR__c        = TEST_DATE_STR;

        Test.startTest();
        
        update ninteiSeikyu;

        Test.stopTest();

        NinteiSeikyu__c checkNinteiSeikyu =  [SELECT Id, OCR_ShinseiDate__c, IninDate__c FROM NinteiSeikyu__c LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.OCR_ShinseiDate__c, TEST_DATE);
        Assert.areEqual(checkNinteiSeikyu.IninDate__c, TEST_DATE);
    }
}