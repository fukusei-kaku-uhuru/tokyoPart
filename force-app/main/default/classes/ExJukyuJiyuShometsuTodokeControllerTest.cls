@isTest
public with sharing class ExJukyuJiyuShometsuTodokeControllerTest {

    @TestSetup
    private static void setUp(){
        String uniqueKey = ExTestUtil.getUniqueKey();

        String generalName = ExTestUtil.GENERAL_PREFIX + uniqueKey;
        String dvName = ExTestUtil.DV_PREFIX + uniqueKey;
        String satoyaName = ExTestUtil.SATOYA_PREFIX + uniqueKey;

        Account generalAcc = ExTestUtil.getPersonAccount(generalName);
        Account dvAcc = ExTestUtil.getPersonAccount(dvName);
        Account satoyaAcc = ExTestUtil.getPersonAccount(satoyaName);
        insert new List<Account>{generalAcc, dvAcc, satoyaAcc};

        User generalUser = ExTestUtil.getGeneralUser(generalName, generalAcc.Id);
        User dvUser = ExTestUtil.getDvUser(dvName, dvAcc.Id);
        User satoyaUser = ExTestUtil.getSatoyaUser(satoyaName, satoyaAcc.Id);
        insert new List<User>{generalUser, dvUser, satoyaUser};
    }

    // 一般
    @isTest
    private static void getSiteModeForGeneral(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(platformUser){
            Test.startTest();
            String result = ExJukyuJiyuShometsuTodokeController.getSiteMode();
            Assert.areEqual('一般', result);
            Test.stopTest();
        }
    }

    // DV
    @isTest
    private static void getSiteModeForDV(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(platformUser){
            Test.startTest();
            String result = ExJukyuJiyuShometsuTodokeController.getSiteMode();
            Assert.areEqual('DV', result);
            Test.stopTest();
        }
    }

    // 里親
    @isTest
    private static void getSiteModeForSatooya(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(platformUser){
            Test.startTest();
            String result = ExJukyuJiyuShometsuTodokeController.getSiteMode();
            Assert.areEqual('里親', result);
            Test.stopTest();
        }
    }

    // シス管
    @isTest
    private static void getSiteModeForAdmin(){
        Test.startTest();
        String result = ExJukyuJiyuShometsuTodokeController.getSiteMode();
        Assert.areEqual('', result);
        Test.stopTest();
    }
}