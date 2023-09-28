@isTest
public with sharing class SfYusoShinseiTriggerHandlerTest {
    
    private static final String YUSO_STATUS_STR_KAIFUZUMI   = '開封済み';
    private static final Date YUSO_KAIFU_UKETSUKE_DATE_TEST = Date.newInstance(2023, 9, 1);

    @TestSetup
    static void makeData(){
        // 郵送申請レコードを作成
        YusoShinsei__c yusoShinsei = SfTestUtil.getYusoShinsei();
        insert yusoShinsei;
    }

    @isTest
    static void setYusoShinseiKaifuzumi() {

        YusoShinsei__c yusoShinsei = [SELECT Id, KaifuUketsukeDate__c FROM YusoShinsei__c LIMIT 1];

        Test.startTest();

        yusoShinsei.KaifuUketsukeDate__c = YUSO_KAIFU_UKETSUKE_DATE_TEST;
        update yusoShinsei;

        Test.stopTest();

        YusoShinsei__c checkYusoShinse = [SELECT Id, Status__c FROM YusoShinsei__c LIMIT 1];
        Assert.areEqual(checkYusoShinse.Status__c, YUSO_STATUS_STR_KAIFUZUMI);
    }
}