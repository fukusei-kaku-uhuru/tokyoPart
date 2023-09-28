@isTest
public with sharing class SfDVFubiTsuchiTriggerHandlerTest {
    
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
        DV_Seikyusha__c seikyusha = SfTestUtil.getSeikyushaDV();
        insert seikyusha;

        // 認定請求
        DV_NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyuDV(seikyusha.Id);
        insert ninteiSeikyu;

        // 対象児童
        DV_TaishoJido__c taishoJido = SfTestUtil.getTaishoJidoDV(ninteiSeikyu.Id);
        insert taishoJido;
    }



    @isTest
    static void updateHubiStatus(){
        DV_Seikyusha__c seikyusha = [SELECT Id FROM DV_Seikyusha__c LIMIT 1];
        seikyusha.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update seikyusha;

        DV_NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        
        DV_TaishoJido__c taishoJido = [SELECT Id FROM DV_TaishoJido__c LIMIT 1];
        taishoJido.HubiStatus__c = HUBI_STATUS_STR_MIRENRAKU;
        update taishoJido;

        DV_FubiTsuchi__c ft1 = new DV_FubiTsuchi__c();
        ft1.NinteiSeikyu__c  = ninteiSeikyu.Id;
        insert ft1;

        DV_FubiTsuchi__c ft2 = new DV_FubiTsuchi__c();
        ft2.TaishoJido__c    = taishoJido.Id;
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

        DV_Seikyusha__c assertSeikyusha = [SELECT Id, HubiStatus__c FROM DV_Seikyusha__c LIMIT 1];
        DV_TaishoJido__c assertTaishoJido = [SELECT Id, HubiStatus__c FROM DV_TaishoJido__c LIMIT 1];

        assert.areEqual(assertSeikyusha.HubiStatus__c, HUBI_STATUS_STR_RENRAKUZUMI);
        assert.areEqual(assertTaishoJido.HubiStatus__c, HUBI_STATUS_STR_RENRAKUZUMI);

    }
}