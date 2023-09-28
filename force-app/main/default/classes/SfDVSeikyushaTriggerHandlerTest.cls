@isTest
public with sharing class SfDVSeikyushaTriggerHandlerTest {
    
    public static final String USER_NAME_STR_SHINSA   = 'ShinsaTest';

    public static final String SHINSAKEKKA_STR_OK   = 'OK';
    public static final String SHINSAKEKKA_STR_NG   = 'NG';
    public static final String SHINSAKEKKA_STR_FUBI = '不備';

    public static final String HUBI_STATUS_STR_MIRENRAKU   = '不備未連絡';
    public static final String HUBI_STATUS_STR_RENRAKUZUMI = '不備連絡済み';

    public static final String STATUS_STR_MISHINSEI            = '未申請';
    public static final String STATUS_STR_OCR_SHORICHU         = 'OCR処理中';
    public static final String STATUS_STR_SHINSAKANRYO         = '審査完了';
    public static final String STATUS_STR_MUKO                 = '無効';
    public static final String FUBI_STATUS_STR_MIRENRAKU       = '不備未連絡';
    public static final String FUBI_STATUS_STR_RENRAKUZUMI     = '不備連絡済み';

    public static final String KAKUNIN_HOHO_KENMEN = '券面アップロード';

    public static final String SHINSA_JYOKYO_STR_SUBETE = '全て完了';
    public static final String SHINSA_JYOKYO_STR_ICHIBU = '一部完了';

    public static final String TEST_DATE_STR    = '2023/08/17';
    public static final Date TEST_DATE          = Date.newInstance(2023, 8, 17);
    public static final String TEST_MAILADDRESS = 'test@example.com';

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

    // 審査結果(1次)および審査結果(2次)に同じ結果が入っていれば審査結果(最終)に反映する
    @isTest
    static void updateShinsaKekkaSaishu() {
        
        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c = SHINSAKEKKA_STR_OK;
        update seikyusha;

        Test.startTest();

        seikyusha.ShinsaKekka_02__c = SHINSAKEKKA_STR_OK;
        update seikyusha;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, ShinsaKekkaSaishu__c FROM DV_Seikyusha__c WHERE Id = :seikyusha.Id LIMIT 1];

        Assert.areEqual(checkSeikyusha.ShinsaKekkaSaishu__c, SHINSAKEKKA_STR_OK);
    }

    // 審査結果(0次)や審査結果(最終)に不備が入った場合不備ステータスを不備未連絡に更新
    @isTest
    static void updateShinsaKekkaFubi() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];

        Test.startTest();

        seikyusha.ShinsaKekka_00__c = SHINSAKEKKA_STR_FUBI;
        update seikyusha;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, HubiStatus__c FROM DV_Seikyusha__c WHERE Id = :seikyusha.Id LIMIT 1];

        Assert.areEqual(checkSeikyusha.HubiStatus__c, HUBI_STATUS_STR_MIRENRAKU);
    }

    // 不備ステータスが「不備連絡済み」に変更された際関連の対象児童で不備ステータスに「不備未連絡」が入っていたら処理を行わない
    @isTest
    static void setNinteiSeikyuFubiNotUpdate() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.ShinsaStatus__c = STATUS_STR_OCR_SHORICHU;
        update ninteiSeikyu;

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        Test.startTest();

        seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, STATUS_STR_OCR_SHORICHU);
    } 

    // 不備ステータスが「不備連絡済み」に変更された際認定請求のステータスを未申請にする
    @isTest
    static void setNinteiSeikyuFubiUpdate() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.ShinsaStatus__c = STATUS_STR_OCR_SHORICHU;
        update ninteiSeikyu;

        Test.startTest();

        seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, STATUS_STR_MISHINSEI);
    }

    // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する:不備通知が認定請求に紐付く場合
    @isTest
    static void setNinteiseikyuFubiTsuchiUpdate() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.ShinsaStatus__c = STATUS_STR_OCR_SHORICHU;
        update ninteiSeikyu;

        DV_FubiTsuchi__c fubiTsuchi = new DV_FubiTsuchi__c(
            NinteiSeikyu__c = ninteiSeikyu.Id
        );
        insert fubiTsuchi;

        Test.startTest();

        seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        Test.stopTest();

        DV_FubiTsuchi__c checkFubiTsuchi = [SELECT Id, IsSaishinseiRiyozumi__c FROM DV_FubiTsuchi__c WHERE Id = :fubiTsuchi.Id LIMIT 1];
        Assert.areEqual(checkFubiTsuchi.IsSaishinseiRiyozumi__c, true);
    }

    // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する:不備通知が対象児童に紐付く場合
    @isTest
    static void setTaishoJidoFubiTsuchiUpdate() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];

        DV_FubiTsuchi__c fubiTsuchi = new DV_FubiTsuchi__c(
            TaishoJido__c = taishoJido.Id
        );
        insert fubiTsuchi;

        Test.startTest();

        seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        Test.stopTest();

        DV_FubiTsuchi__c checkFubiTsuchi = [SELECT Id, IsSaishinseiRiyozumi__c FROM DV_FubiTsuchi__c WHERE Id = :fubiTsuchi.Id LIMIT 1];
        Assert.areEqual(checkFubiTsuchi.IsSaishinseiRiyozumi__c, true);
    }

    // 不備ステータスが「不備連絡済み」に変更された際本人確認書類再提出がtrueの不備通知に関連する本人確認方法が券面アップロードの請求者を更新する
    @isTest
    static void setFubiNinteiSeikyuHohoClear() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c        = HUBI_STATUS_STR_MIRENRAKU;
        seikyusha.HonninKakuninHoho__c = KAKUNIN_HOHO_KENMEN;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.ShinsaStatus__c = STATUS_STR_OCR_SHORICHU;
        update ninteiSeikyu;

        DV_FubiTsuchi__c fubiTsuchi = new DV_FubiTsuchi__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            HonninKakuninShoruiSaiteishutsu__c = true
        );
        insert fubiTsuchi;

        Test.startTest();

        seikyusha.HubiStatus__c = HUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, HonninKakuninHoho__c FROM DV_Seikyusha__c WHERE Id = :seikyusha.Id LIMIT 1];
        Assert.isNull(checkSeikyusha.HonninKakuninHoho__c);
    }

    // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」にする
    @isTest
    static void setShinsaJokyoSubeteKanryo() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekkaSaishu__c = SHINSAKEKKA_STR_OK;
        update taishoJido;

        Test.startTest();

        seikyusha.ShinsaKekkaSaishu__c = SHINSAKEKKA_STR_OK;
        update seikyusha;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShinsaJyokyo__c, SHINSA_JYOKYO_STR_SUBETE);
    }
    
    // 認定請求に紐付く請求者・対象児童のいずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
    @isTest
    static void setShinsaJokyoIchibuKanryo() {

        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];

        Test.startTest();

        seikyusha.ShinsaKekkaSaishu__c = SHINSAKEKKA_STR_OK;
        update seikyusha;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaJyokyo__c FROM DV_NinteiSeikyu__c LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShinsaJyokyo__c, SHINSA_JYOKYO_STR_ICHIBU);
    }
}