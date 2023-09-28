@isTest
public with sharing class SfDVTaishoJidoTriggerHandlerShinsaTest {
    
    public static final String USER_NAME_STR_SHINSA        = 'ShinsaTest';
    public static final String USER_NAME_STR_SHINSA_2      = 'ShinsaTest2';


    public static final String  STATUS_STR_MISHINSEI              = '未申請';
    private static final String SHINSA_STATUS_STR_SHINSACHU_00    = '0次審査中';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_00 = '1次審査待ち';
    private static final String SHINSA_STATUS_STR_SHINSACHU_01    = '1次審査中';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_01 = '2次審査待ち';
    private static final String SHINSA_STATUS_STR_SHINSACHU_02    = '2次審査中';
    private static final String SHINSA_STATUS_STR_UNMATCH         = 'アンマッチ判定';
    private static final String SHINSA_STATUS_STR_SHINSAKANRYO_02 = '審査完了';

    public static final String SHINSA_STATUS_STR_OK        = 'OK';
    public static final String SHINSA_STATUS_STR_NG        = 'NG';
    public static final String SHINSA_STATUS_STR_FUBI      = '不備';
    public static final String FUBI_STATUS_STR_MIRENRAKU   = '不備未連絡';
    public static final String FUBI_STATUS_STR_RENRAKUZUMI = '不備連絡済み';
    public static final String SHINSA_JYOKYO_STR_SUBETE    = '全て完了';
    public static final String SHINSA_JYOKYO_STR_ICHIBU    = '一部完了';
    public static final String SHONIN_JYOKYO_STR_SUBETE    = '全て完了';
    public static final String SHONIN_JYOKYO_STR_ICHIBU    = '一部完了';
    
    public static final String SHINSA_KEKKA_STR_OK         = 'OK';
    public static final String SHONIN_KEKKA_STR_NINTEI     = '認定';

    public static final String KAKUNIN_HOHO_KENMEN = '券面アップロード';


    @TestSetup
    static void makeData(){
        // 審査ユーザを準備
        List<User> shinsaUserList = new List<User>();

        User shinsaUser1 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        shinsaUserList.add(shinsaUser1);

        insert shinsaUserList;

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


    //審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
    //関連する認定請求を格納するMapを取得
    // 関連する認定請求に紐付く対象児童を格納するMap
    //不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
    // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
    // 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
    // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」、いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
    // 同じ認定請求の対象児童の承認結果が全て入っている場合、認定請求の承認状況を「すべて完了」にする
    // 認定請求を更新
    // 不備通知を更新
    // 請求者を更新
    @isTest
    static void updateSaishuKekka(){

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.startTest();

        seikyusha.ShinsaKekka_02__c = SHINSA_STATUS_STR_OK;
        update seikyusha;

        taishoJido.ShinsaKekka_02__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.stopTest();

        DV_Seikyusha__c    checkSeikyusha    = [SELECT Id, ShinsaKekkaSaishu__c FROM DV_Seikyusha__c    WHERE Id = :seikyusha.Id    LIMIT 1];
        DV_NinteiSeikyu__c checkNinteiseikyu = [SELECT Id, ShinsaStatus__c      FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];
        DV_TaishoJido__c   checkTaishoJido   = [SELECT Id, ShinsaKekkaSaishu__c FROM DV_TaishoJido__c   WHERE Id = :taishoJido.Id   LIMIT 1];


        Assert.areEqual(checkSeikyusha.ShinsaKekkaSaishu__c, SHINSA_STATUS_STR_OK);
        Assert.areEqual(checkNinteiseikyu.ShinsaStatus__c,   SHINSA_STATUS_STR_SHINSACHU_00);
        Assert.areEqual(checkTaishoJido.ShinsaKekkaSaishu__c,   SHINSA_STATUS_STR_OK);
    }


    // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」にする
    @isTest
    static void updateShinsaJokyoSubeteKanryo(){

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c    = SHINSA_STATUS_STR_OK;
        seikyusha.ShinsaKekka_02__c    = SHINSA_STATUS_STR_OK;
        seikyusha.ShinsaKekkaSaishu__c = SHINSA_STATUS_STR_OK;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        taishoJido.ShinsaKekka_02__c = SHINSA_STATUS_STR_NG;
        update taishoJido;

        Test.startTest();

        taishoJido.ShinsaKekkaSaishu__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiseikyu = [SELECT Id, ShinsaJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShinsaJyokyo__c, SHINSA_JYOKYO_STR_SUBETE);
    }


    // 認定請求に紐付く請求者・対象児童いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
    @isTest
    static void updateShinsaJokyoIchibuKanryo(){

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c    = SHINSA_STATUS_STR_OK;
        seikyusha.ShinsaKekka_02__c    = SHINSA_STATUS_STR_NG;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        taishoJido.ShinsaKekka_02__c = SHINSA_STATUS_STR_NG;
        update taishoJido;

        DV_TaishoJido__c taishoJido2 = new DV_TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストジロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
        insert taishoJido2;

        Test.startTest();

        taishoJido.ShinsaKekkaSaishu__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.stopTest();
        
        DV_NinteiSeikyu__c checkNinteiseikyu = [SELECT Id, ShinsaJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShinsaJyokyo__c, SHINSA_JYOKYO_STR_ICHIBU);
    }


    // 認定請求に紐付く対象児童すべてに承認結果が入ったら認定請求の承認状況を「すべて完了」にする
    @isTest
    static void updateShoninJokyoSubeteKanryo(){

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        Test.startTest();

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.ShoninKekka__c = SHONIN_KEKKA_STR_NINTEI;
        update taishoJido;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiseikyu = [SELECT Id, ShoninJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShoninJyokyo__c, SHONIN_JYOKYO_STR_SUBETE);
    }


    // 認定請求に紐付く対象児童のいずれかに承認結果が入ったら認定請求の承認状況を「一部完了」にする
    @isTest
    static void updateShoninJokyoIchibuKanryo(){

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_TaishoJido__c taishoJido2 = new DV_TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストジロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
        insert taishoJido2;

        Test.startTest();

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.ShoninKekka__c = SHONIN_KEKKA_STR_NINTEI;
        update taishoJido;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiseikyu = [SELECT Id, ShoninJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShoninJyokyo__c, SHONIN_JYOKYO_STR_ICHIBU);
    }


    // 審査結果(0次)や審査結果(最終)に不備が入った場合不備ステータスを不備未連絡に更新
    @isTest
    static void updateShinsaKekkaSaishu(){

        DV_Seikyusha__c  seikyusha  = [SELECT Id FROM DV_Seikyusha__c  LIMIT 1];
        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];

        Test.startTest();

        seikyusha.ShinsaKekka_00__c  = SHINSA_STATUS_STR_FUBI;
        update seikyusha;

        taishoJido.ShinsaKekka_00__c = SHINSA_STATUS_STR_FUBI;
        update taishoJido;

        Test.stopTest();

        DV_Seikyusha__c  checkSeikyusha  = [SELECT Id, HubiStatus__c FROM DV_Seikyusha__c  WHERE Id = :seikyusha.Id  LIMIT 1];
        DV_TaishoJido__c checkTaishoJido = [SELECT Id, HubiStatus__c FROM DV_TaishoJido__c WHERE Id = :taishoJido.Id LIMIT 1];

        Assert.areEqual(checkSeikyusha.HubiStatus__c,  FUBI_STATUS_STR_MIRENRAKU);
        Assert.areEqual(checkTaishoJido.HubiStatus__c, FUBI_STATUS_STR_MIRENRAKU);
    }



    // 関連の請求者で不備ステータスに「不備未連絡」が入っていたら処理を行わない
    @isTest
    static void setSeikyushaNotUpdate(){

        Test.startTest();

        DV_Seikyusha__c seikyusha       = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido     = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Test.stopTest();


        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSACHU_01);

    }

    
    // 関連の対象児童で不備ステータスに「不備未連絡」が入っていたら処理を行わない
    @isTest
    static void setTaishoJidoNotUpdate(){

        Test.startTest();

        DV_Seikyusha__c seikyusha       = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido     = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        DV_TaishoJido__c taishoJido2    = new DV_TaishoJido__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストハナコ',
            SeinenGappiDate__c = Date.newInstance(2023, 1, 1),
            HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU
        );
        insert taishoJido2;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c  WHERE Id = :ninteiSeikyu.Id  LIMIT 1];

        Test.stopTest();

        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSACHU_01);
    }


    // 対象児童の不備ステータスに不備連絡済みが入ったとき認定請求の審査ステータスを未申請にする
    @isTest
    static void setTaishoJidoUpdateMishinsei(){

        Test.startTest();

        DV_Seikyusha__c seikyusha       = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido     = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        DV_TaishoJido__c taishoJido2    = new DV_TaishoJido__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストハナコ',
            SeinenGappiDate__c = Date.newInstance(2023, 1, 1),
            HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI
        );
        insert taishoJido2;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c  WHERE Id = :ninteiSeikyu.Id  LIMIT 1];

        Test.stopTest();

        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, STATUS_STR_MISHINSEI);
    }


    // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
    @isTest
    static void updateFubiTsuchi() {

        Test.startTest();

        DV_Seikyusha__c seikyusha       = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        seikyusha.HonninKakuninHoho__c = KAKUNIN_HOHO_KENMEN;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido     = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        List<DV_FubiTsuchi__c> fubiTsuchiList = new List<DV_FubiTsuchi__c>();

        DV_FubiTsuchi__c fubiTsuchi1 = new DV_FubiTsuchi__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            HonninKakuninShoruiSaiteishutsu__c = true
        );
        fubiTsuchiList.add(fubiTsuchi1);

        DV_FubiTsuchi__c fubiTsuchi2 = new DV_FubiTsuchi__c(
            TaishoJido__c = taishoJido.Id,
            HonninKakuninShoruiSaiteishutsu__c = true
        );
        fubiTsuchiList.add(fubiTsuchi2);

        insert fubiTsuchiList;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        Test.stopTest();

        List<DV_FubiTsuchi__c> checkFubiTsuchiList = [SELECT Id, IsSaishinseiRiyozumi__c FROM DV_FubiTsuchi__c];
        for(DV_FubiTsuchi__c tsuchi :checkFubiTsuchiList) {
            Assert.isTrue(tsuchi.IsSaishinseiRiyozumi__c);
        }

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, HonninKakuninHoho__c FROM DV_Seikyusha__c LIMIT 1];
        Assert.isNull(checkSeikyusha.HonninKakuninHoho__c);
    }
}