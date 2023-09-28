@isTest
private class ExValidationUtilTest {

    @TestSetup
    private static void setUp(){
        // 申請書類定義
        insert ExTestUtil.getSstListTaishoJido(3);
        insert ExTestUtil.getSstKozaKakunin();

        // 紐づけ先のオブジェクトのデータ
        insert ExTestUtil.getSeikyusha();
    }

    /**
     * 入力された項目・メッセージが正しくListに格納されているか確認
     */
    @isTest
    private static void ErrorLogsAddTest() {
        ExValidationUtil.ErrorLogs elTest = new ExValidationUtil.ErrorLogs();
        elTest.add('name', '名前が未入力です');
        elTest.add('address', '住所が未入力です');
        Assert.areEqual('name', elTest.errorLogs.get(0).field);
        Assert.areEqual('名前が未入力です', elTest.errorLogs.get(0).message);
        Assert.areEqual('address', elTest.errorLogs.get(1).field);
        Assert.areEqual('住所が未入力です', elTest.errorLogs.get(1).message);
    }

    /**
     * 必要書類が全て提出されているパターン
     */
    @isTest
    private static void needUploadShinseiShoruiTest1() {

        List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();

        Seikyusha__c s = [SELECT Id FROM Seikyusha__c];

        List<ContentVersion> cvList = new List<ContentVersion>();
        for (ShinseiShoruiTeigi__c sst : sstList) {
            cvList.add(ExTestUtil.getContentVersion(sst, s.Id, null));
        }
        insert cvList;

        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :s.Id
        ];

        Test.startTest();
        List<String> result = ExValidationUtil.needUploadShinseiShorui(cdlList, sstList);
        Test.stopTest();

        Assert.areEqual(0, result.size());
    }

    /**
     * 必要書類が1つだけ提出されているパターン
     */
    @isTest
    private static void needUploadShinseiShoruiTest2() {

        List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();

        Seikyusha__c s = [SELECT Id FROM Seikyusha__c];

        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(ExTestUtil.getContentVersion(sstList.get(0), s.Id, null));
        insert cvList;

        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :s.Id
        ];

        Test.startTest();
        List<String> result = ExValidationUtil.needUploadShinseiShorui(cdlList, sstList);
        Test.stopTest();

        Assert.areEqual(2, result.size());
        Assert.areEqual('書類定義2', result.get(0));
        Assert.areEqual('書類定義3', result.get(1));
    }

    /**
     * 必要書類が1つも提出されていないパターン
     */
    @isTest
    private static void needUploadShinseiShoruiTest3() {

        List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();

        Seikyusha__c s = [SELECT Id FROM Seikyusha__c];

        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :s.Id
        ];

        Test.startTest();
        List<String> result = ExValidationUtil.needUploadShinseiShorui(cdlList, sstList);
        Test.stopTest();

        Assert.areEqual(3, result.size());
        Assert.areEqual('書類定義1', result.get(0));
        Assert.areEqual('書類定義2', result.get(1));
        Assert.areEqual('書類定義3', result.get(2));
    }

    /**
     * 任意提出のファイルが1つ存在し、必要書類を1つ提出した場合
     */
    @isTest
    private static void needUploadShinseiShoruiTest4() {

        List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();
        sstList.get(0).IsNiniTeisyutsu__c = true;
        update sstList;

        Seikyusha__c s = [SELECT Id FROM Seikyusha__c];

        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(ExTestUtil.getContentVersion(sstList.get(1), s.Id, null));
        insert cvList;

        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :s.Id
        ];

        Test.startTest();
        List<String> result = ExValidationUtil.needUploadShinseiShorui(cdlList, sstList);
        Test.stopTest();

        Assert.areEqual(1, result.size());
        Assert.areEqual('書類定義3', result.get(0));
    }
}