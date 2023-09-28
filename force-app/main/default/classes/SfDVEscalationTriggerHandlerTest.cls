@isTest
public with sharing class SfDVEscalationTriggerHandlerTest {
    
    public static final String USER_NAME_STR_SHINSA   = 'ShinsaTest';

    private static final String ESCALATION_STATUS_STR_KAKUNINCHU           = '事務局内確認中';
    private static final String ESCALATION_STATUS_STR_ESCALATION_JIMUKYOKU = 'エスカレーション中(事務局内)';
    private static final String ESCALATION_STATUS_STR_ESCALATION_TOCHO     = 'エスカレーション中(都庁様)';
    private static final String ESCALATION_STATUS_STR_KAIKETSU             = 'エスカレーション解決';

    private static final String STATUS_STR_JIMUKYOKU_KAKUNINCHU = '事務局内確認中';
    private static final String STATUS_STR_JIMUKYOKU_KAITOMACHI = '事務局内回答待ち';
    private static final String STATUS_STR_TOCHO_KAITOMACHI     = '都庁様回答待ち';
    private static final String STATUS_STR_TOCHO_KAITOZUMI      = '都庁様回答済み';
    private static final String STATUS_STR_KANRYO               = '完了';
    
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

    // 請求者に紐付くエスカレーション：「東京都様回答待ち」「東京都様回答済み」がぶら下がっていたらエスカレーション中(都庁様)
    @isTest
    static void updateSeikyushaEscalationChu() {

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_Escalation__c escalation = new DV_Escalation__c(
            NinteiSeikyuBango__c = ninteiSeikyu.Id
        );
        insert escalation;

        Test.startTest();

        escalation.Status__c = STATUS_STR_TOCHO_KAITOMACHI;
        update escalation;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, EscalationStatus__c FROM DV_Seikyusha__c LIMIT 1];
        Assert.areEqual(checkSeikyusha.EscalationStatus__c, ESCALATION_STATUS_STR_ESCALATION_TOCHO);
    }

    // 請求者に紐付くエスカレーション：「事務局内回答待ち」がぶら下がっていたらエスカレーション中(事務局内)
    @isTest
    static void updateSeikyushaEscalationChuJimukyoku() {

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_Escalation__c escalation = new DV_Escalation__c(
            NinteiSeikyuBango__c = ninteiSeikyu.Id,
            Status__c = STATUS_STR_JIMUKYOKU_KAITOMACHI
        );

        Test.startTest();

        insert escalation;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, EscalationStatus__c FROM DV_Seikyusha__c LIMIT 1];
        Assert.areEqual(checkSeikyusha.EscalationStatus__c, ESCALATION_STATUS_STR_ESCALATION_JIMUKYOKU);
    }

    // 請求者に紐付くエスカレーション：「事務局内確認中」がぶら下がっていたら事務局内確認中
    @isTest
    static void updateSeikyushaKakuninchu() {

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_Escalation__c escalation = new DV_Escalation__c(
            NinteiSeikyuBango__c = ninteiSeikyu.Id,
            Status__c = STATUS_STR_JIMUKYOKU_KAKUNINCHU
        );

        Test.startTest();

        insert escalation;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, EscalationStatus__c FROM DV_Seikyusha__c LIMIT 1];
        Assert.areEqual(checkSeikyusha.EscalationStatus__c, ESCALATION_STATUS_STR_KAKUNINCHU);
    }

    // 請求者に紐付くエスカレーション：「完了」がぶら下がっていたらエスカレーション解決
    @isTest
    static void updateSeikyushaKanryo() {

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_Escalation__c escalation = new DV_Escalation__c(
            NinteiSeikyuBango__c = ninteiSeikyu.Id,
            Status__c = STATUS_STR_KANRYO
        );

        Test.startTest();

        insert escalation;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, EscalationStatus__c FROM DV_Seikyusha__c LIMIT 1];
        Assert.areEqual(checkSeikyusha.EscalationStatus__c, ESCALATION_STATUS_STR_KAIKETSU);
    }

    // 請求者に紐付くエスカレーション：未入力またはレコードなし
    @isTest
    static void updateSeikyushaMinyuryoku() {

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_Escalation__c escalation = new DV_Escalation__c(
            NinteiSeikyuBango__c = ninteiSeikyu.Id
        );

        Test.startTest();

        insert escalation;

        Test.stopTest();

        DV_Seikyusha__c checkSeikyusha = [SELECT Id, EscalationStatus__c FROM DV_Seikyusha__c LIMIT 1];
        Assert.isNull(checkSeikyusha.EscalationStatus__c);
    }

    // 対象児童に紐付くエスカレーション
    @isTest
    static void updateTaishoJidoEscalationChu() {

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];

        DV_TaishoJido__c addTaishoJido = new DV_TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyu.Id,
            ShimeiFurigana__c  = 'テスト次郎',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
        insert addTaishoJido;

        DV_Escalation__c addEscalation = new DV_Escalation__c(
            TaishoJido__c = addTaishoJido.Id,
            Status__c = STATUS_STR_KANRYO
        );
        insert addEscalation;

        DV_Escalation__c escalation = new DV_Escalation__c(
            TaishoJido__c = taishoJido.Id
        );
        insert escalation;

        Test.startTest();

        escalation.Status__c = STATUS_STR_TOCHO_KAITOMACHI;
        update escalation;

        Test.stopTest();

        DV_TaishoJido__c checkTaishoJido = [SELECT Id, EscalationStatus__c FROM DV_TaishoJido__c LIMIT 1];
        Assert.areEqual(checkTaishoJido.EscalationStatus__c, ESCALATION_STATUS_STR_ESCALATION_TOCHO);
    }
}