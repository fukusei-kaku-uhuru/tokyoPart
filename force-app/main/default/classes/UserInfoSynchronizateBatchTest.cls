@IsTest public with sharing class UserInfoSynchronizateBatchTest {

    @testSetup
    static void setup() {
        // 各テストメソッドで使用できるテストデータを作成する
    }

    @isTest
    static void Test01() {

        Profile padmin = [SELECT Id FROM Profile WHERE Name='システム管理者_カスタム'];
        User uadmin = [Select id, name, userroleid from user where ProfileId = :padmin.Id and isactive = true limit 1 ];

        userrole us =  [Select id, name from userrole where name = '事務局'];

        if (uadmin.userroleid == null) {
            uadmin.userroleid = us.Id;
            update uadmin;
        }
        
        User u;
        User u2;
        User u3;
        System.runAs(uadmin) {
            Profile p = [SELECT Id FROM Profile WHERE Name='認定請求者'];
            u = new User(Alias = 'testuser', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
            
            insert u;

            u2 = new User(Alias = 'testuser', Email='standarduser2@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com');
            
            insert u2;

            u3 = new User(Alias = 'testuser', Email='standarduser3@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser10@testorg.com');
            
            insert u3;
        
            Test.StartTest();
            List<user> oriList = [SELECT id, Username, contactid, contact.name, contact.Email, name, email FROM user where contactid != null AND IsSameedUserNameAndEmail__c = false AND IsActive = true];
            System.debug(oriList);
            UserInfoSynchronizateBatch uisb = new UserInfoSynchronizateBatch();
            Database.executebatch(uisb);
            Test.stopTest();
        }

        User updedObj = [Select Id, name, username, email from user where id = :u.id];
        system.assertEquals(u.Email, updedObj.username, '');
        updedObj = [Select Id, name, username, email from user where id = :u2.id];
        system.assertEquals(u2.Email, updedObj.username, '');
        updedObj = [Select Id, name, username, email from user where id = :u3.id];
        system.assertEquals(u3.Email, updedObj.username, '');

    }

}