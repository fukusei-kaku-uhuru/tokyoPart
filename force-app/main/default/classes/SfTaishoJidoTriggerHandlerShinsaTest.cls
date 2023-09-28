@isTest
public with sharing class SfTaishoJidoTriggerHandlerShinsaTest {

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
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        insert seikyusha;

        // 認定請求
        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        insert ninteiSeikyu;

        // 対象児童
        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
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

        Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.startTest();

        seikyusha.ShinsaKekka_02__c = SHINSA_STATUS_STR_OK;
        update seikyusha;

        taishoJido.ShinsaKekka_02__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.stopTest();

        Seikyusha__c    checkSeikyusha    = [SELECT Id, ShinsaKekkaSaishu__c FROM Seikyusha__c    WHERE Id = :seikyusha.Id    LIMIT 1];
        Ninteiseikyu__c checkNinteiseikyu = [SELECT Id, ShinsaStatus__c      FROM Ninteiseikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];
        TaishoJido__c   checkTaishoJido   = [SELECT Id, ShinsaKekkaSaishu__c FROM TaishoJido__c   WHERE Id = :taishoJido.Id   LIMIT 1];


        Assert.areEqual(checkSeikyusha.ShinsaKekkaSaishu__c, SHINSA_STATUS_STR_OK);
        Assert.areEqual(checkNinteiseikyu.ShinsaStatus__c,   SHINSA_STATUS_STR_SHINSACHU_00);
        Assert.areEqual(checkTaishoJido.ShinsaKekkaSaishu__c,   SHINSA_STATUS_STR_OK);
    }


    // 認定請求に紐付く請求者・対象児童すべてに審査結果(最終)が入ったら認定請求の審査状況を「すべて完了」にする
    @isTest
    static void updateShinsaJokyoSubeteKanryo(){

        Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c    = SHINSA_STATUS_STR_OK;
        seikyusha.ShinsaKekka_02__c    = SHINSA_STATUS_STR_OK;
        seikyusha.ShinsaKekkaSaishu__c = SHINSA_STATUS_STR_OK;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        taishoJido.ShinsaKekka_02__c = SHINSA_STATUS_STR_NG;
        update taishoJido;

        Test.startTest();

        taishoJido.ShinsaKekkaSaishu__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.stopTest();

        Ninteiseikyu__c checkNinteiseikyu = [SELECT Id, ShinsaJyokyo__c FROM Ninteiseikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShinsaJyokyo__c, SHINSA_JYOKYO_STR_SUBETE);
    }


    // 認定請求に紐付く請求者・対象児童いずれかに審査結果（最終)が入ったら認定請求の審査状況を「一部完了」にする
    @isTest
    static void updateShinsaJokyoIchibuKanryo(){

        Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.ShinsaKekka_01__c    = SHINSA_STATUS_STR_OK;
        seikyusha.ShinsaKekka_02__c    = SHINSA_STATUS_STR_NG;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.ShinsaKekka_01__c = SHINSA_STATUS_STR_OK;
        taishoJido.ShinsaKekka_02__c = SHINSA_STATUS_STR_NG;
        update taishoJido;

        TaishoJido__c taishoJido2 = new TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストジロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
        insert taishoJido2;

        Test.startTest();

        taishoJido.ShinsaKekkaSaishu__c = SHINSA_STATUS_STR_OK;
        update taishoJido;

        Test.stopTest();
        
        Ninteiseikyu__c checkNinteiseikyu = [SELECT Id, ShinsaJyokyo__c FROM Ninteiseikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShinsaJyokyo__c, SHINSA_JYOKYO_STR_ICHIBU);
    }


    // 認定請求に紐付く対象児童すべてに承認結果が入ったら認定請求の承認状況を「すべて完了」にする
    @isTest
    static void updateShoninJokyoSubeteKanryo(){

        Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];

        Test.startTest();

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.ShoninKekka__c = SHONIN_KEKKA_STR_NINTEI;
        update taishoJido;

        Test.stopTest();

        Ninteiseikyu__c checkNinteiseikyu = [SELECT Id, ShoninJyokyo__c FROM Ninteiseikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShoninJyokyo__c, SHONIN_JYOKYO_STR_SUBETE);
    }


    // 認定請求に紐付く対象児童のいずれかに承認結果が入ったら認定請求の承認状況を「一部完了」にする
    @isTest
    static void updateShoninJokyoIchibuKanryo(){

        Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];

        TaishoJido__c taishoJido2 = new TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストジロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
        insert taishoJido2;

        Test.startTest();

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.ShoninKekka__c = SHONIN_KEKKA_STR_NINTEI;
        update taishoJido;

        Test.stopTest();

        Ninteiseikyu__c checkNinteiseikyu = [SELECT Id, ShoninJyokyo__c FROM Ninteiseikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Assert.areEqual(checkNinteiseikyu.ShoninJyokyo__c, SHONIN_JYOKYO_STR_ICHIBU);
    }


    // 審査結果(0次)や審査結果(最終)に不備が入った場合不備ステータスを不備未連絡に更新
    @isTest
    static void updateShinsaKekkaSaishu(){

        Seikyusha__c  seikyusha  = [SELECT Id FROM Seikyusha__c  LIMIT 1];
        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];

        Test.startTest();

        seikyusha.ShinsaKekka_00__c  = SHINSA_STATUS_STR_FUBI;
        update seikyusha;

        taishoJido.ShinsaKekka_00__c = SHINSA_STATUS_STR_FUBI;
        update taishoJido;

        Test.stopTest();

        Seikyusha__c  checkSeikyusha  = [SELECT Id, HubiStatus__c FROM Seikyusha__c  WHERE Id = :seikyusha.Id  LIMIT 1];
        TaishoJido__c checkTaishoJido = [SELECT Id, HubiStatus__c FROM TaishoJido__c WHERE Id = :taishoJido.Id LIMIT 1];

        Assert.areEqual(checkSeikyusha.HubiStatus__c,  FUBI_STATUS_STR_MIRENRAKU);
        Assert.areEqual(checkTaishoJido.HubiStatus__c, FUBI_STATUS_STR_MIRENRAKU);
    }



    // 関連の請求者で不備ステータスに「不備未連絡」が入っていたら処理を行わない
    @isTest
    static void setSeikyushaNotUpdate(){

        Test.startTest();

        Seikyusha__c seikyusha       = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        TaishoJido__c taishoJido     = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM Ninteiseikyu__c WHERE Id = :ninteiSeikyu.Id LIMIT 1];

        Test.stopTest();


        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSACHU_01);

    }

    
    // 関連の対象児童で不備ステータスに「不備未連絡」が入っていたら処理を行わない
    @isTest
    static void setTaishoJidoNotUpdate(){

        Test.startTest();

        Seikyusha__c seikyusha       = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        TaishoJido__c taishoJido     = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        TaishoJido__c taishoJido2    = new TaishoJido__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストハナコ',
            SeinenGappiDate__c = Date.newInstance(2023, 1, 1),
            HubiStatus__c = FUBI_STATUS_STR_MIRENRAKU
        );
        insert taishoJido2;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM Ninteiseikyu__c  WHERE Id = :ninteiSeikyu.Id  LIMIT 1];

        Test.stopTest();

        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, SHINSA_STATUS_STR_SHINSACHU_01);
    }


    // 対象児童の不備ステータスに不備連絡済みが入ったとき認定請求の審査ステータスを未申請にする
    @isTest
    static void setTaishoJidoUpdateMishinsei(){

        Test.startTest();

        Seikyusha__c seikyusha       = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        TaishoJido__c taishoJido     = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        TaishoJido__c taishoJido2    = new TaishoJido__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テストハナコ',
            SeinenGappiDate__c = Date.newInstance(2023, 1, 1),
            HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI
        );
        insert taishoJido2;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        NinteiSeikyu__c checkNinteiSeikyu = [SELECT Id, ShinsaStatus__c FROM Ninteiseikyu__c  WHERE Id = :ninteiSeikyu.Id  LIMIT 1];

        Test.stopTest();

        Assert.areEqual(checkNinteiSeikyu.ShinsaStatus__c, STATUS_STR_MISHINSEI);
    }


    // 不備ステータスが「不備連絡済み」に変更された際認定請求や関連の対象児童に紐付く不備通知を更新する
    @isTest
    static void updateFubiTsuchi() {

        Test.startTest();

        Seikyusha__c seikyusha       = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        seikyusha.HonninKakuninHoho__c = KAKUNIN_HOHO_KENMEN;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM Ninteiseikyu__c LIMIT 1];
        ninteiseikyu.ShinsaStatus__c = SHINSA_STATUS_STR_SHINSACHU_01;
        update ninteiSeikyu;

        TaishoJido__c taishoJido     = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c     = FUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        List<FubiTsuchi__c> fubiTsuchiList = new List<FubiTsuchi__c>();

        FubiTsuchi__c fubiTsuchi1 = new FubiTsuchi__c(
            NinteiSeikyu__c = ninteiSeikyu.Id,
            HonninKakuninShoruiSaiteishutsu__c = true
        );
        fubiTsuchiList.add(fubiTsuchi1);

        FubiTsuchi__c fubiTsuchi2 = new FubiTsuchi__c(
            TaishoJido__c = taishoJido.Id,
            HonninKakuninShoruiSaiteishutsu__c = true
        );
        fubiTsuchiList.add(fubiTsuchi2);

        insert fubiTsuchiList;

        taishoJido.HubiStatus__c = FUBI_STATUS_STR_RENRAKUZUMI;
        update taishoJido;

        Test.stopTest();

        List<FubiTsuchi__c> checkFubiTsuchiList = [SELECT Id, IsSaishinseiRiyozumi__c FROM FubiTsuchi__c];
        for(FubiTsuchi__c tsuchi :checkFubiTsuchiList) {
            Assert.isTrue(tsuchi.IsSaishinseiRiyozumi__c);
        }

        Seikyusha__c checkSeikyusha = [SELECT Id, HonninKakuninHoho__c FROM Seikyusha__c LIMIT 1];
        Assert.isNull(checkSeikyusha.HonninKakuninHoho__c);
    }

    //OCR連携項目にてテキスト型生年月日を日付型にする
    @isTest
    static void setTextToDate() {

        TaishoJido__c taishoJido     = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.Seinengappi_IninshaOCR__c                   = '2023/08/16';
        taishoJido.Seinengappi_DairininOCR__c                  = '2023/08/16';
        taishoJido.TeishutuDateOCR__c                          = '2023/08/16';
        taishoJido.TeishutuDate2OCR__c                         = '2023/08/16';
        taishoJido.OCR_SeinenGappiDate__c                      = '2023/08/16';
        taishoJido.OCR_TennyuShusseiDate__c                    = '2023/08/16';
        taishoJido.OCR_TenshutsuDate__c                        = '2023/08/16';
        taishoJido.OCR_MoushideDate_c__c                       = '2023/08/16';
        taishoJido.Moushitate_SeinenGappiDateOCR__c            = '2023/08/16';
        taishoJido.OCR_Moushitate_BekkyoKaishiDate__c          = '2023/08/16';
        taishoJido.OCR_Moushitate_BekkyoShuryoDate__c          = '2023/08/16';
        taishoJido.OCR_Moushitate_RyugakumaeKyojuKaishiDate__c = '2023/08/16';
        taishoJido.Moushitate_RyugakumaeKyojuKaishiDate2OCR__c = '2023/08/16';
        taishoJido.OCR_Moushitate_RyugakumaeKyojuShuryoDate__c = '2023/08/16';
        taishoJido.Moushitate_RyugakumaeKyojuShuryoDate2OCR__c = '2023/08/16';
        taishoJido.Moushitate_ShiteiSeinenGappiDateOCR__c      = '2023/08/16';
        taishoJido.TaishoshaSeinegappinOCR__c                  = '2023/08/16';
        taishoJido.FuboshiteishaSeinengappiOCR__c              = '2023/08/16';
        update taishoJido;
    } 


}