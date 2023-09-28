@isTest
public with sharing class SfKojinOshiraseSendEmailTest {

    // ユーザ作成時の接頭辞
    public static final String GENERAL_PREFIX = 'general';

    // ユーザ作成時のドメイン
    public static final String TEST_DOMAIN = '@example.com';

    // System.runAsで使用するユーザ取得用の検索語
    public static final String GENERAL_QUERY_STRING = GENERAL_PREFIX + '%' + TEST_DOMAIN;
    
    @TestSetup
    private static void setUp(){

        String uniqueKey = getUniqueKey();

        String generalName = GENERAL_PREFIX + uniqueKey;

        Account generalAcc = getPersonAccount(generalName);
        insert generalAcc;

        User generalUser = getGeneralUser(generalName, generalAcc.Id);
        insert generalUser;

    }


    @isTest
    private static void test_normal01(){

        
        User u = [SELECT Id, contactId FROM User WHERE UserName LIKE :GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {

            Test.startTest();

            //  個人お知らせレコード作成
            KojinOshirase__c KojinOshirase = new KojinOshirase__c(
                TorihikisakiSekininsyaId__c = u.contactId
            );
            Database.insert(KojinOshirase);

            List<SfKojinOshiraseSendEmail.RequestParam> RequestList = new List<SfKojinOshiraseSendEmail.RequestParam>();
            SfKojinOshiraseSendEmail.RequestParam request = new SfKojinOshiraseSendEmail.RequestParam();
            request.KojinOshiraseId = KojinOshirase.id;
            request.contactId = u.contactId;
            request.tempDeveloperName = 'KojinOshirase';
            RequestList.add(request);
            
            SfKojinOshiraseSendEmail.sendEmail(RequestList);
            Integer emailInvocationCount = Limits.getEmailInvocations();
            Test.stopTest();   
            
            System.assertNotEquals(0, emailInvocationCount, 'メール送信成功');
        }
    }
    
    /**
     * 取引先責任者IDの取得
     */
    public static Id getContactId(Id accId){
        return [SELECT Id FROM Contact WHERE AccountId = :accId LIMIT 1].Id;
    }

    /**
     * 個人取引先の取得
     */
    public static Account getPersonAccount(String uniqueName){
        Account acc = new Account(
            LastName = uniqueName,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        return acc;
    }

    /**
     * 一般ユーザの取得
     */
    public static User getGeneralUser(String uniqueName, Id accId){
        User u = new User(
            Alias = uniqueName.substring(0,8),
            ContactId = getContactId(accId),
            Email = uniqueName + TEST_DOMAIN,
            EmailEncodingKey='UTF-8',
            LastName = uniqueName,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName = uniqueName + TEST_DOMAIN
        );
        return u;
    }

    /**
     * 重複回避のためのユニークキー取得
     */
    public static String getUniqueKey(){
        return String.valueOf(DateTime.now().getTime());
    }
}