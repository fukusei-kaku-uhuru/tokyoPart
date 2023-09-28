@isTest
public with sharing class LightningSelfRegisterControllerTest {

    private static String siteName = Site__mdt.getInstance('General').MasterLabel__c;
    private static String guestName = 'サイトゲストユーザ ' + siteName;

    @isTest
    static void testIsValidPassword() {
        Assert.isTrue(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334'));
        Assert.isFalse(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword'));
        Assert.isFalse(LightningSelfRegisterController.isValidPassword('password?@12334', null));
        Assert.isFalse(LightningSelfRegisterController.isValidPassword(null, 'fakePwd'));
    }

    @isTest
    static void testSiteAsContainerEnabled() {
        Assert.isNotNull(LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
    }

    @isTest
    static void testSetExperienceId(){
        Assert.isNotNull(LightningSelfRegisterController.setExperienceId('exampleId'));
    }

    @isTest
    static void testSelfRegistration() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        LightningSelfRegisterController.ResponseWrapper result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.selfRegister('sample@example.com', 'testLSCT0', 'testLSCT0');
        }
        
        Assert.isFalse(result.isError);
        Assert.isNull(result.message);
        Assert.isTrue(result.responseMap.containsKey('selfRegId'));
    }

    @isTest
    static void testSelfRegistration_emailBlank() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        LightningSelfRegisterController.ResponseWrapper result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.selfRegister(null, 'testLSCT0', 'testLSCT0');

            Assert.areEqual(Label.Site.email_is_required, result.message);
        }

        Assert.isTrue(result.isError);
        Assert.isNull(result.responseMap);
    }

    @isTest
    static void testSelfRegistration_emailInvalid() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        LightningSelfRegisterController.ResponseWrapper result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.selfRegister('sample@example.00', 'testLSCT0', 'testLSCT0');
        }

        Assert.isTrue(result.isError);
        Assert.areEqual('メールアドレスが無効です。', result.message);
        Assert.isNull(result.responseMap);
    }

    @isTest
    static void testSelfRegistration_emailWithin8() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        LightningSelfRegisterController.ResponseWrapper result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.selfRegister('x@y.com', 'testLSCT0', 'testLSCT0');
        }

        Assert.isFalse(result.isError);
        Assert.isNull(result.message);
        Assert.isTrue(result.responseMap.containsKey('selfRegId'));
    }

    @isTest
    static void testSelfRegistration_passwordIncorrect() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        LightningSelfRegisterController.ResponseWrapper result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.selfRegister('x@y.com', 'testLSCT0', 'wrongPassword1');
        }
        
        // Assert.areEqual('パスワードが一致しません。', result.message);
        Assert.isTrue(result.isError);
        Assert.isNull(result.responseMap);
    }

    @isTest
    static void testVerifyUser() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        LightningSelfRegisterController.ResponseWrapper result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.verifyUser(null, null, 'sample@example.com', 'testLSCT0');
        }

        Assert.isTrue(result.isError);
    }

    @isTest
    static void testIsAlreadyExists() {
        User guestUser = [SELECT Id FROM User WHERE Name = :guestName];

        User user = [SELECT Id, Email FROM User LIMIT 1];

        Boolean result;
        System.runAs(guestUser){
            result = LightningSelfRegisterController.isAlreadyExists(user.Email);
        }

        Assert.isTrue(result);
    }
}