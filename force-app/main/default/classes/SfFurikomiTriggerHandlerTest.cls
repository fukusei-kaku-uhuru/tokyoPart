@isTest
public with sharing class SfFurikomiTriggerHandlerTest {
    public static final String USER_NAME_STR_SHINSA        = 'ShinsaTest';

    private static final String FURIKOMI_STATUS_STR_SHISHUTSUKANRYO = '支出完了';
    private static final String FURIKOMI_STATUS_STR_SHISHUTSUERROR  = '支出エラー';

    private static final String SHISHUTSU_JYOKYO_STR_SUBETEKANRYO = '全て完了';
    private static final String SHISHUTSU_JYOKYO_STR_ICHIBUKANRYO = '一部完了';

    private static final String HUBI_STATUS_STR_MIRENRAKU = '不備未連絡';

    @TestSetup
    static void makeData(){
        
        // 審査ユーザを準備
        List<User> shinsaUserList = new List<User>();

        User shinsaUser1 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        shinsaUserList.add(shinsaUser1);

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

        // 請求者(DV被害者)
        DV_Seikyusha__c seikyushaDV = SfTestUtil.getSeikyushaDV();
        insert seikyushaDV;

        // 認定請求(DV被害者)
        DV_NinteiSeikyu__c ninteiSeikyuDV = SfTestUtil.getNinteiSeikyuDV(seikyushaDV.Id);
        insert ninteiSeikyuDV;

        // 対象児童(DV被害者)
        DV_TaishoJido__c taishoJidoDV = SfTestUtil.getTaishoJidoDV(ninteiSeikyuDV.Id);
        insert taishoJidoDV;
    }

    // 対象の認定請求に関連するすべての振込の振込ステータスに支出完了が入ったら認定請求の支出状況を「全て完了」に更新
    @isTest
    static void updateShishutsuJokyoSubeteKanryo() {

        Furikomi__c furikomi = new Furikomi__c();
        insert furikomi;

        TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
        taishoJido.FurikomiId__c = furikomi.Id;
        update taishoJido;

        Test.startTest();

        furikomi.FurikomiStatus__c = FURIKOMI_STATUS_STR_SHISHUTSUKANRYO;
        update furikomi;

        Test.stopTest();

        NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShishutsuJyokyo__c FROM NinteiSeikyu__c WHERE Id = :taishoJido.NinteiSeikyu__c LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShishutsuJyokyo__c, SHISHUTSU_JYOKYO_STR_SUBETEKANRYO);
    }

    // 対象の認定請求に関連するいずれかの振込の振込ステータスに支出完了が入ったら認定請求の支出状況を「一部完了」に更新
    @isTest
    static void updateShishutsuJokyoIchibuKanryo() {

        Furikomi__c furikomi = new Furikomi__c();
        insert furikomi;

        TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
        taishoJido.FurikomiId__c = furikomi.Id;
        update taishoJido;

        Furikomi__c addFurikomi = new Furikomi__c();
        insert addFurikomi;

        TaishoJido__c addTaishoJido = new TaishoJido__c(
            NinteiSeikyu__c    = taishoJido.NinteiSeikyu__c,
            ShimeiFurigana__c  = 'テストジロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1),
            FurikomiId__c      = addFurikomi.Id
        );
        insert addTaishoJido;

        Test.startTest();

        furikomi.FurikomiStatus__c = FURIKOMI_STATUS_STR_SHISHUTSUKANRYO;
        update furikomi;

        Test.stopTest();

        NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShishutsuJyokyo__c FROM NinteiSeikyu__c WHERE Id = :taishoJido.NinteiSeikyu__c LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShishutsuJyokyo__c, SHISHUTSU_JYOKYO_STR_ICHIBUKANRYO);
    }

    // 振込ステータスに口座紹介エラーまたは支出エラーが入ったら対象児童の不備ステータスを「不備未連絡」に更新
    @isTest
    static void updateHubiStatusMirenraku() {

        Furikomi__c furikomi = new Furikomi__c();
        insert furikomi;

        TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM TaishoJido__c LIMIT 1];
        taishoJido.FurikomiId__c = furikomi.Id;
        update taishoJido;

        Test.startTest();

        furikomi.FurikomiStatus__c = FURIKOMI_STATUS_STR_SHISHUTSUERROR;
        update furikomi;

        Test.stopTest();

        TaishoJido__c checkTaishoJido = [SELECT Id, HubiStatus__c FROM TaishoJido__c LIMIT 1];
        Assert.areEqual(checkTaishoJido.HubiStatus__c, HUBI_STATUS_STR_MIRENRAKU);
    }

    // 対象の認定請求(DV被害者)に関連するすべての振込の振込ステータスに支出完了が入ったら認定請求(DV被害者)の支出状況を「全て完了」に更新
    @isTest
    static void updateShishutsuJokyoSubeteKanryoDV() {

        Furikomi__c furikomi = new Furikomi__c();
        insert furikomi;

        DV_TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.FurikomiId__c = furikomi.Id;
        update taishoJido;

        Test.startTest();

        furikomi.FurikomiStatus__c = FURIKOMI_STATUS_STR_SHISHUTSUKANRYO;
        update furikomi;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShishutsuJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :taishoJido.NinteiSeikyu__c LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShishutsuJyokyo__c, SHISHUTSU_JYOKYO_STR_SUBETEKANRYO);
    }

    // 対象の認定請求(DV被害者)に関連するいずれかの振込の振込ステータスに支出完了が入ったら認定請求(DV被害者)の支出状況を「一部完了」に更新
    @isTest
    static void updateShishutsuJokyoIchibuKanryoDV() {

        Furikomi__c furikomi = new Furikomi__c();
        insert furikomi;

        DV_TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.FurikomiId__c = furikomi.Id;
        update taishoJido;

        Furikomi__c addFurikomi = new Furikomi__c();
        insert addFurikomi;

        DV_TaishoJido__c addTaishoJido = new DV_TaishoJido__c(
            NinteiSeikyu__c    = taishoJido.NinteiSeikyu__c,
            ShimeiFurigana__c  = 'テストジロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1),
            FurikomiId__c      = addFurikomi.Id
        );
        insert addTaishoJido;

        Test.startTest();

        furikomi.FurikomiStatus__c = FURIKOMI_STATUS_STR_SHISHUTSUKANRYO;
        update furikomi;

        Test.stopTest();

        DV_NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShishutsuJyokyo__c FROM DV_NinteiSeikyu__c WHERE Id = :taishoJido.NinteiSeikyu__c LIMIT 1];
        Assert.areEqual(checkNinteiSeikyu.ShishutsuJyokyo__c, SHISHUTSU_JYOKYO_STR_ICHIBUKANRYO);
    }

    // 振込ステータスに口座紹介エラーまたは支出エラーが入ったら対象児童(DV被害者)の不備ステータスを「不備未連絡」に更新
    @isTest
    static void updateHubiStatusMirenrakuDV() {

        Furikomi__c furikomi = new Furikomi__c();
        insert furikomi;

        DV_TaishoJido__c taishoJido = [SELECT Id, NinteiSeikyu__c FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.FurikomiId__c = furikomi.Id;
        update taishoJido;

        Test.startTest();

        furikomi.FurikomiStatus__c = FURIKOMI_STATUS_STR_SHISHUTSUERROR;
        update furikomi;

        Test.stopTest();

        DV_TaishoJido__c checkTaishoJido = [SELECT Id, HubiStatus__c FROM DV_TaishoJido__c LIMIT 1];
        Assert.areEqual(checkTaishoJido.HubiStatus__c, HUBI_STATUS_STR_MIRENRAKU);
    }
}