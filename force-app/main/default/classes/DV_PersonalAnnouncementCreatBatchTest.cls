@IsTest
public without sharing class DV_PersonalAnnouncementCreatBatchTest {

    @isTest
    public static void testNo01(){
        Profile padmin = [SELECT Id FROM Profile WHERE Name='システム管理者_カスタム'];
        User uadmin = [Select id, name, userroleid from user where ProfileId = :padmin.Id and isactive = true limit 1 ];

        userrole us =  [Select id, name from userrole where name = '事務局'];

        if (uadmin.userroleid == null) {
            uadmin.userroleid = us.Id;
            update uadmin;
        }
        
        User u;
        System.runAs(uadmin) {
            Profile p = [SELECT Id FROM Profile WHERE Name='認定請求者'];
            u = new User(Alias = 'testuser', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
            
            insert u;
        }

        System.runAs(u) {
            Test.startTest();
            // // 郵送申請
            // YusoShinsei__c yusoShinsei = new YusoShinsei__c();
            // insert yusoShinsei;
            // 認定請求
            DV_NinteiSeikyu__c ninteiSeikyu = new DV_NinteiSeikyu__c();
            // ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
            insert ninteiSeikyu;
            // 対象児童
            DV_TaishoJido__c taishoJido = new DV_TaishoJido__c();
            taishoJido.ShinsaKekkaSaishu__c = 'OK';
            taishoJido.Jusho__c = '東京都中央区';
            taishoJido.YuchoKigo__c = '123';
            taishoJido.YuchoBango__c = '456';
            taishoJido.NinteiTsuchishoHakkoDate__c = Date.valueOf('2022-08-01');
            taishoJido.IsNinteiTsushiOshiraseZumi__c = false;
            taishoJido.NinteiSeikyu__c = ninteiSeikyu.id;
            insert taishoJido;
            DV_PersonalAnnouncementCreatBatch bt= new DV_PersonalAnnouncementCreatBatch();
            Database.executebatch(bt);
            Test.stopTest();
            DV_TaishoJido__c updtj = [select id, IsNinteiTsushiOshiraseZumi__c from DV_TaishoJido__c where id = :taishoJido.Id ];
            System.assertEquals(true, updtj.IsNinteiTsushiOshiraseZumi__c);
        }
    }

    @isTest
    public static void testNo02(){
        Profile padmin = [SELECT Id FROM Profile WHERE Name='システム管理者_カスタム'];
        User uadmin = [Select id, name, userroleid from user where ProfileId = :padmin.Id and isactive = true limit 1 ];

        userrole us =  [Select id, name from userrole where name = '事務局'];

        if (uadmin.userroleid == null) {
            uadmin.userroleid = us.Id;
            update uadmin;
        }
        
        User u;
        System.runAs(uadmin) {
            Profile p = [SELECT Id FROM Profile WHERE Name='認定請求者'];
            u = new User(Alias = 'testuser', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
            
            insert u;
        }

        System.runAs(u) {
            Test.startTest();
            // // 郵送申請
            // YusoShinsei__c yusoShinsei = new YusoShinsei__c();
            // insert yusoShinsei;
            // 認定請求
            DV_NinteiSeikyu__c ninteiSeikyu = new DV_NinteiSeikyu__c();
            // ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
            insert ninteiSeikyu;
            // 対象児童
            DV_TaishoJido__c taishoJido = new DV_TaishoJido__c();
            taishoJido.ShinsaKekkaSaishu__c = 'OK';
            taishoJido.Jusho__c = '東京都中央区';
            taishoJido.YuchoKigo__c = '123';
            taishoJido.YuchoBango__c = '456';
            taishoJido.NinteiKyakkaTsuchishoHakkoDate__c = Date.valueOf('2022-08-01');
            taishoJido.IsNinteiKyakkaTsushiOshiraseZumi__c = false;
            taishoJido.NinteiSeikyu__c = ninteiSeikyu.id;
            insert taishoJido;
            DV_PersonalAnnouncementCreatBatch bt= new DV_PersonalAnnouncementCreatBatch();
            Database.executebatch(bt);
            Test.stopTest();
            DV_TaishoJido__c updtj = [select id, IsNinteiKyakkaTsushiOshiraseZumi__c from DV_TaishoJido__c where id = :taishoJido.Id ];
            System.assertEquals(true, updtj.IsNinteiKyakkaTsushiOshiraseZumi__c);
        }
    }

    @isTest
    public static void testNo03(){
        Profile padmin = [SELECT Id FROM Profile WHERE Name='システム管理者_カスタム'];
        User uadmin = [Select id, name, userroleid from user where ProfileId = :padmin.Id and isactive = true limit 1 ];

        userrole us =  [Select id, name from userrole where name = '事務局'];

        if (uadmin.userroleid == null) {
            uadmin.userroleid = us.Id;
            update uadmin;
        }
        
        User u;
        System.runAs(uadmin) {
            Profile p = [SELECT Id FROM Profile WHERE Name='認定請求者'];
            u = new User(Alias = 'testuser', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
            
            insert u;
        }

        System.runAs(u) {
            Test.startTest();
            // // 郵送申請
            // YusoShinsei__c yusoShinsei = new YusoShinsei__c();
            // insert yusoShinsei;
            // 認定請求
            DV_NinteiSeikyu__c ninteiSeikyu = new DV_NinteiSeikyu__c();
            // ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
            insert ninteiSeikyu;
            // 対象児童
            DV_TaishoJido__c taishoJido = new DV_TaishoJido__c();
            taishoJido.ShinsaKekkaSaishu__c = 'OK';
            taishoJido.Jusho__c = '東京都中央区';
            taishoJido.YuchoKigo__c = '123';
            taishoJido.YuchoBango__c = '456';
            taishoJido.JukyuShikakuShometsuTsuchishoHakkoDate__c = Date.valueOf('2022-08-01');
            taishoJido.IsJukyuShikakuShometsuOshiraseZumi__c = false;
            taishoJido.NinteiSeikyu__c = ninteiSeikyu.id;
            insert taishoJido;
            DV_PersonalAnnouncementCreatBatch bt= new DV_PersonalAnnouncementCreatBatch();
            Database.executebatch(bt);
            Test.stopTest();
            DV_TaishoJido__c updtj = [select id, IsJukyuShikakuShometsuOshiraseZumi__c from DV_TaishoJido__c where id = :taishoJido.Id ];
            System.assertEquals(true, updtj.IsJukyuShikakuShometsuOshiraseZumi__c);
        }
    }

    @isTest
    public static void testNo04(){
        Profile padmin = [SELECT Id FROM Profile WHERE Name='システム管理者_カスタム'];
        User uadmin = [Select id, name, userroleid from user where ProfileId = :padmin.Id and isactive = true limit 1 ];

        userrole us =  [Select id, name from userrole where name = '事務局'];

        if (uadmin.userroleid == null) {
            uadmin.userroleid = us.Id;
            update uadmin;
        }
        
        User u;
        System.runAs(uadmin) {
            Profile p = [SELECT Id FROM Profile WHERE Name='認定請求者'];
            u = new User(Alias = 'testuser', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
            
            insert u;
        }

        System.runAs(u) {
            Test.startTest();
            // // 郵送申請
            // YusoShinsei__c yusoShinsei = new YusoShinsei__c();
            // insert yusoShinsei;
            // 認定請求
            DV_NinteiSeikyu__c ninteiSeikyu = new DV_NinteiSeikyu__c();
            // ninteiSeikyu.YusoShinsei__c = yusoShinsei.id;
            insert ninteiSeikyu;
            // 対象児童
            DV_TaishoJido__c taishoJido = new DV_TaishoJido__c();
            taishoJido.ShinsaKekkaSaishu__c = 'OK';
            taishoJido.Jusho__c = '東京都中央区';
            taishoJido.YuchoKigo__c = '123';
            taishoJido.YuchoBango__c = '456';
            taishoJido.ShikyuNinteiTorikeshiTsuchiHakkoDate__c = Date.valueOf('2022-08-01');
            taishoJido.IsShikyuNinteiTorikeshiOshiraseZumi__c = false;
            taishoJido.NinteiSeikyu__c = ninteiSeikyu.id;
            insert taishoJido;
            DV_PersonalAnnouncementCreatBatch bt= new DV_PersonalAnnouncementCreatBatch();
            Database.executebatch(bt);
            Test.stopTest();
            DV_TaishoJido__c updtj = [select id, IsShikyuNinteiTorikeshiOshiraseZumi__c from DV_TaishoJido__c where id = :taishoJido.Id ];
            System.assertEquals(true, updtj.IsShikyuNinteiTorikeshiOshiraseZumi__c);
        }
    }
}