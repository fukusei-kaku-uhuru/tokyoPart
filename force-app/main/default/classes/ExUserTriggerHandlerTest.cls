@isTest
private class ExUserTriggerHandlerTest {

    // エクスペリエンスユーザの更新テスト用
    @TestSetup
    private static void setUp(){
        // テストデータの作成
        Account acc1 = ExTestUtil.getPersonAccount('cdetest');
        Account acc2 = ExTestUtil.getPersonAccount('cdeatest');
        Account acc3 = ExTestUtil.getPersonAccount('cdebtest');
        insert new List<Account>{acc1, acc2, acc3};

        // 管理者側のユーザ
        String profileId = userinfo.getProfileId();
        User systemUser = new User(
            ProfileId = profileId,
            Email = 'cdetest' + ExTestUtil.TEST_DOMAIN,
            UserName = 'cdetests' + ExTestUtil.TEST_DOMAIN,
            LastName = 'cdetest',
            Alias = '0',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );

        // エクスペリエンスユーザ
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id,
            Email = 'cdetest' + ExTestUtil.TEST_DOMAIN,
            UserName = 'cdetest' + ExTestUtil.TEST_DOMAIN,
            LastName = 'cdetest',
            Alias = '1',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ContactId = ExTestUtil.getContactId(acc1.Id)
        );

        // メアドが重複しているデータ
        User user2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id,
            Email = 'cdetest' + ExTestUtil.TEST_DOMAIN,
            UserName = 'cdetesta' + ExTestUtil.TEST_DOMAIN,
            LastName = 'cdetest',
            Alias = '2',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ContactId = ExTestUtil.getContactId(acc2.Id)
        );

        // 更新時メアド重複用データ
        User user3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id,
            Email = 'cdetestd' + ExTestUtil.TEST_DOMAIN,
            UserName = 'cdetestb' + ExTestUtil.TEST_DOMAIN,
            LastName = 'cdetest',
            Alias = '3',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ContactId = ExTestUtil.getContactId(acc3.Id)
        );
        insert new List<User>{systemUser, user1, user2, user3};
    }

    /**
     * エクスペリエンスユーザでない
     */
    @isTest
    private static void setContactId_internal(){
        String uniqueName = ExTestUtil.getUniqueKey();
        String uniqueMail = uniqueName + ExTestUtil.TEST_DOMAIN;

        User u = new User(
            ProfileId = UserInfo.getProfileId(),
            Email = uniqueMail,
            UserName = uniqueMail,
            LastName = uniqueName,
            Alias = uniqueName.substring(0,8),
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );

        Test.startTest();
        insert u;
        Test.stopTest();

        List<Account> accList = [SELECT Id FROM Account WHERE LastName = :uniqueMail];
        Assert.areEqual(0, accList.size());

        u = [SELECT ContactId FROM User WHERE Id = :u.Id LIMIT 1];
        Assert.areEqual(null, u.ContactId);
    }

    /**
     * エクスペリエンスユーザ
     */
    @isTest
    private static void setContactId_external(){
        String uniqueName = ExTestUtil.getUniqueKey();
        String uniqueMail = uniqueName + ExTestUtil.TEST_DOMAIN;

        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id,
            Email = uniqueMail,
            UserName = uniqueMail,
            LastName = uniqueName,
            Alias = uniqueName.substring(0,8),
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );

        Test.startTest();
        insert u;
        Test.stopTest();

        Account acc = [
            SELECT
                Id
                ,LastName
                ,PersonEmail
                ,RecordType.DeveloperName
            FROM
                Account
            WHERE
                LastName = :uniqueMail
            LIMIT 1
        ];
        Assert.areEqual(uniqueMail, acc.LastName);
        Assert.areEqual(uniqueMail, acc.PersonEmail);
        Assert.areEqual('PersonAccount', acc.RecordType.DeveloperName);

        u = [SELECT ContactId FROM User WHERE Id = :u.Id LIMIT 1];
        Assert.areEqual([SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id, u.ContactId);
    }

    /**
     * エクスペリエンスユーザ外1件、メアド更新あり、メアド重複あり
     */
    @isTest
    private static void checkDuplicateEmail_isInternal(){
        // ユーザデータの取得
        User systemUser = [SELECT Id, LastName FROM User WHERE UserName = :'cdetests' + ExTestUtil.TEST_DOMAIN];

        // メアドの更新
        systemUser.Email = 'cdetest' + ExTestUtil.TEST_DOMAIN;

        // テストの実行
        Test.startTest();
        System.runAs(systemUser){
            update systemUser;
        }
        Test.stopTest();

        // 結果の確認
        Assert.areEqual('cdetest' + ExTestUtil.TEST_DOMAIN, systemUser.Email);
    }

    /**
     * エクスペリエンスユーザ1件、メアド更新なし、メアド重複あり
     */
    @isTest
    private static void checkDuplicateEmail_notEmailUpdate(){

        // ユーザデータの取得
        User user1 = [SELECT Id, LastName FROM User WHERE UserName = :'cdetest' + ExTestUtil.TEST_DOMAIN];

        // メアド以外の項目(LastName)を更新
        user1.LastName = 'cdetest1';

        // テストの実行
        System.runAs(user1){
            Test.startTest();
            update user1;
            Test.stopTest();
        }

        // 結果の確認
        // 変更した項目の更新を確認
        Assert.areEqual('cdetest1', user1.LastName);
    }

    /**
     * エクスペリエンスユーザ1件、メアド更新あり、メアド重複なし
     */
    @isTest
    private static void checkDuplicateEmail_notEmailDuplication(){

        // ユーザデータの取得
        User user1 = [SELECT Id, Email FROM User WHERE UserName = :'cdetest' + ExTestUtil.TEST_DOMAIN];

        // メアドを更新
        user1.Email = 'cdetest1' + ExTestUtil.TEST_DOMAIN;

        // テストの実行
        System.runAs(user1){
            Test.startTest();
            update user1;
            Test.stopTest();
        }

        // 結果の確認
        Assert.areEqual('cdetest1' + ExTestUtil.TEST_DOMAIN, user1.Email);
    }

    /**
     * エクスペリエンスユーザ1件、メアド更新あり、メアド重複あり
     */
    @isTest
    private static void checkDuplicateEmai_emailUpdateWithDuplication(){

        // ユーザデータの取得
        User user1 = [SELECT Id, Email FROM User WHERE UserName = :'cdetest' + ExTestUtil.TEST_DOMAIN];

        // メアドを更新
        user1.Email = 'cdetestd' + ExTestUtil.TEST_DOMAIN;

        String message;
        try{
            System.runAs(user1){
                // テストの実行
                Test.startTest();
                update user1;
                Test.stopTest();
            }
        }catch(Exception e){
            message = e.getMessage();
        }
        Boolean expectedExceptionThrown = message.contains('既に登録されたメールアドレスです。');

        // ユーザデータの再取得
        User user1U = [SELECT Email FROM User WHERE UserName = :'cdetest' + ExTestUtil.TEST_DOMAIN];
        // 結果の確認
        Assert.isTrue(expectedExceptionThrown);
        Assert.areEqual('cdetest' + ExTestUtil.TEST_DOMAIN, user1U.Email);
    }

    /**
     * 認定請求者
     */
    @isTest
    private static void isExperienceUser_general(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id
        );

        Test.startTest();
        Boolean result = ExUserTriggerHandler.isExperienceUser(u);
        Test.stopTest();

        Assert.areEqual(true, result);
    }

    /**
     * 認定請求者（DV)
     */
    @isTest
    private static void isExperienceUser_dv(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者（DV)'].Id
        );

        Test.startTest();
        Boolean result = ExUserTriggerHandler.isExperienceUser(u);
        Test.stopTest();

        Assert.areEqual(true, result);
    }

    /**
     * 認定請求者（里親・ファミリーホーム）
     */
    @isTest
    private static void isExperienceUser_satoya(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者（里親・ファミリーホーム）'].Id
        );

        Test.startTest();
        Boolean result = ExUserTriggerHandler.isExperienceUser(u);
        Test.stopTest();

        Assert.areEqual(true, result);
    }

    /**
     * 実行ユーザ
     */
    @isTest
    private static void isExperienceUser_others(){
        User u = new User(
            ProfileId = UserInfo.getProfileId()
        );

        Test.startTest();
        Boolean result = ExUserTriggerHandler.isExperienceUser(u);
        Test.stopTest();

        Assert.areEqual(false, result);
    }
}