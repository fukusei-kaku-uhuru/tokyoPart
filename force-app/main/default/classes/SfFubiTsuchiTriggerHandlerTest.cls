@isTest
public with sharing class SfFubiTsuchiTriggerHandlerTest {
    public static final String USER_NAME_STR_SHINSA        = 'ShinsaTest';

    public static final String HUBI_STATUS_STR_MIRENRAKU   = '不備未連絡';
    public static final String HUBI_STATUS_STR_RENRAKUZUMI = '不備連絡済み';


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



    @isTest
    static void updateHubiStatus(){
        Seikyusha__c seikyusha = [SELECT Id FROM Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
        
        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        FubiTsuchi__c ft1 = new FubiTsuchi__c();
        ft1.NinteiSeikyu__c = ninteiSeikyu.Id;
        insert ft1;

        FubiTsuchi__c ft2 = new FubiTsuchi__c();
        ft2.TaishoJido__c = taishoJido.Id;
        insert ft2;

        Test.startTest();

        ft1.KyokudashiNengappiDate__c = Date.newInstance(2020, 1, 1);
        ft1.IsNinteiSeikyuPageKoukai__c = true;
        ft1.IsLeaderKakuninZumi__c = true;
        update ft1;

        ft2.IsNinteiSeikyuPageKoukai__c = true;
        ft2.IsLeaderKakuninZumi__c = true;
        update ft2;

        Test.stopTest();

        Seikyusha__c assertSeikyusha = [SELECT Id, HubiStatus__c FROM Seikyusha__c LIMIT 1];
        TaishoJido__c assertTaishoJido = [SELECT Id, HubiStatus__c FROM TaishoJido__c LIMIT 1];

        assert.areEqual(assertSeikyusha.HubiStatus__c, HUBI_STATUS_STR_RENRAKUZUMI);
        assert.areEqual(assertTaishoJido.HubiStatus__c, HUBI_STATUS_STR_RENRAKUZUMI);

    }

}