@IsTest
public without sharing class SfSeikyushaUpdateNameTriggerHandlerTest {
    // @TestSetup
    // static void createTestData() {
    //     // 請求者
    //     Seikyusha__c seikyusha = new Seikyusha__c();
    //     seikyusha.Shimei__c = '変更前';
    //     insert seikyusha;
    // }

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
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current Role: ' + UserInfo.getUserRoleId());

            // 請求者
            Seikyusha__c seikyusha = new Seikyusha__c();
            seikyusha.Shimei__c = '変更前';
            insert seikyusha;
            System.debug('ID: ' + String.valueOf(seikyusha.Id));

            Test.startTest();
            Seikyusha__c obj = new Seikyusha__c();
            obj.Id = seikyusha.Id;
            obj.Shimei__c = '変更後';
            update obj;
            User user = [select id,contactID from User where id = :u.id Limit 1];
            Contact contacts = [select id,LastName from Contact where id =: user.contactID Limit 1];
            System.assertEquals('変更後', contacts.LastName, '');

            Test.stopTest();
        } 
    }
}