@isTest
public class HirutaBatchTest {

    @TestSetup
    static void setup(){

        // 削除対象のContentVersionをisnert
        ContentVersion conVer1 = new ContentVersion(
            Title = 'TestContent'
            , PathOnClient = 'TestContent.txt'
            , VersionData = Blob.valueOf('TestContentData')
            , OwnerId = UserInfo.getUserId()
            , ShinseiShoruiTeigiId__c = '1111'
        );
        insert conVer1;

        // 削除対象外のContentVersionをisnert
        ContentVersion conVer2 = new ContentVersion(
            Title = 'TestContent'
            , PathOnClient = 'TestContent.txt'
            , VersionData = Blob.valueOf('TestContentData')
            , OwnerId = UserInfo.getUserId()
        );
        insert conVer2;
    }

    @isTest
    static void test(){

    Test.startTest();

    HirutaBatch b = new HirutaBatch();
    Database.executeBatch(b, 200);

    Test.stopTest();

    List<ContentDocument> conList = [SELECT Id FROM ContentDocument];
    Integer conCount = 0;
    for (ContentDocument con : conList) {
        conCount++;
    }

    System.assertEquals(1, conCount);

    }
}