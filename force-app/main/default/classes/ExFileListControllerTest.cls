@isTest
private class ExFileListControllerTest {

    @TestSetup
    private static void setUp(){

        // 紐づけ先の作成
        Seikyusha__c s = ExTestUtil.getSeikyusha();
        insert s;
        NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
        insert ns;

        // 申請書類定義の作成
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListKojinNinsho(3);
        insert sstList;

        // ファイルの作成
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv1 = ExTestUtil.getContentVersion(sstList.get(0), ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
        cv1.Title = '1削除可能ファイル';
        cvList.add(cv1);
        ContentVersion cv2 = ExTestUtil.getContentVersion(sstList.get(1), ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
        cv2.IsDeletable__c = false;
        cv2.Title = '2削除不可ファイル';
        cvList.add(cv2);
        ContentVersion cv3 = ExTestUtil.getContentVersion(sstList.get(2), ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
        cv3.Title = '3' + cv3.Title;
        cvList.add(cv3);
        insert cvList;
    }

    /**
     * 取得0件
     * 引数が空のリスト
     */
    @isTest
    private static void getDocument_0_empty(){
        // 引数の準備
        List<String> contentVersionIdList = new List<String>();

        // テストの実行
        Test.startTest();
        ExFileListController.FileDetailWrapper result = ExFileListController.getDocument(contentVersionIdList);
        Test.stopTest();

        // 結果の確認
        // 取得件数の確認
        Assert.areEqual(0, result.fileList.size());
    }

    /**
     * 取得失敗
     * ContentVersionが1件存在しない
     */
    @isTest
    private static void getDocument_fileNotExist(){
        // データの準備
        List<ContentVersion> cvList = [
            SELECT
                Id
                ,ContentDocumentId
                ,ShinseiShoruiTeigiId__c
            FROM
                ContentVersion
            ORDER BY Title
        ];

        // 引数の準備
        List<String> contentVersionIdList = new List<String>{cvList.get(0).Id, cvList.get(1).Id};

        // ファイルのデータの削除
        delete new ContentDocument(Id = cvList.get(1).ContentDocumentId);

        // テストの実行
        Test.startTest();
        ExFileListController.FileDetailWrapper result = ExFileListController.getDocument(contentVersionIdList);
        Test.stopTest();

        // 結果の確認
        // 取得件数の確認
        Assert.areEqual(1, result.fileList.size());
        // 詰め替え結果の確認
        Assert.areEqual(cvList.get(0).Id, result.fileList.get(0).contentVersionId);
        Assert.areEqual(cvList.get(0).ContentDocumentId, result.fileList.get(0).contentDocumentId);
        Assert.areEqual('1削除可能ファイル', result.fileList.get(0).fileName);
        Assert.isTrue(result.fileList.get(0).isDeletable);
        Assert.areEqual(cvList.get(0).ShinseiShoruiTeigiId__c, result.fileList.get(0).fileTeigiId);
        Assert.areEqual('書類定義1', result.fileList.get(0).fileTeigiName);
    }

    /**
     * 取得失敗
     * ContentVersionが全件存在しない
     */
    @isTest
    private static void getDocument_filesNotExist(){
        // データの準備
        List<ContentVersion> cvList = [
            SELECT
                Id
                ,ContentDocumentId
                ,ShinseiShoruiTeigiId__c
            FROM
                ContentVersion
            ORDER BY Title
        ];

        // 引数の準備
        List<String> contentVersionIdList = new List<String>{cvList.get(0).Id, cvList.get(1).Id};

        // ファイルのデータの削除
        delete new List<ContentDocument>{
            new ContentDocument(Id = cvList.get(0).ContentDocumentId),
            new ContentDocument(Id = cvList.get(1).ContentDocumentId)
        };

        // テストの実行
        Test.startTest();
        ExFileListController.FileDetailWrapper result = ExFileListController.getDocument(contentVersionIdList);
        Test.stopTest();

        // 結果の確認
        // 取得件数の確認
        Assert.areEqual(0, result.fileList.size());
    }

    /**
     * 取得失敗
     * 申請書類定義が1件存在しない
     */
    @isTest
    private static void getDocument_teigiNotExist(){
        // データの準備
        List<ContentVersion> cvList = [
            SELECT
                Id
                ,ContentDocumentId
                ,ShinseiShoruiTeigiId__c
            FROM
                ContentVersion
            ORDER BY Title
        ];

        // 引数の準備
        List<String> contentVersionIdList = new List<String>{cvList.get(0).Id, cvList.get(1).Id};

        // 申請書類定義データの削除
        delete new ShinseiShoruiTeigi__c(Id = cvList.get(1).ShinseiShoruiTeigiId__c);

        // テストの実行
        Test.startTest();
        ExFileListController.FileDetailWrapper result = ExFileListController.getDocument(contentVersionIdList);
        Test.stopTest();

        // 結果の確認
        // 取得件数の確認
        Assert.areEqual(1, result.fileList.size());
        // 詰め替え結果の確認
        Assert.areEqual(cvList.get(0).Id, result.fileList.get(0).contentVersionId);
        Assert.areEqual(cvList.get(0).ContentDocumentId, result.fileList.get(0).contentDocumentId);
        Assert.areEqual('1削除可能ファイル', result.fileList.get(0).fileName);
        Assert.isTrue(result.fileList.get(0).isDeletable);
        Assert.areEqual(cvList.get(0).ShinseiShoruiTeigiId__c, result.fileList.get(0).fileTeigiId);
        Assert.areEqual('書類定義1', result.fileList.get(0).fileTeigiName);
    }

    /**
     * 取得失敗
     * 申請書類定義が全件存在しない
     */
    @isTest
    private static void getDocument_teigisNotExist(){
        // データの準備
        List<ContentVersion> cvList = [
            SELECT
                Id
                ,ContentDocumentId
                ,ShinseiShoruiTeigiId__c
            FROM
                ContentVersion
            ORDER BY Title
        ];

        // 引数の準備
        List<String> contentVersionIdList = new List<String>{cvList.get(0).Id, cvList.get(1).Id};

        // 申請書類定義のデータの削除
        delete new List<ShinseiShoruiTeigi__c>{
            new ShinseiShoruiTeigi__c(Id = cvList.get(0).ShinseiShoruiTeigiId__c),
            new ShinseiShoruiTeigi__c(Id = cvList.get(1).ShinseiShoruiTeigiId__c)
        };

        // テストの実行
        Test.startTest();
        ExFileListController.FileDetailWrapper result = ExFileListController.getDocument(contentVersionIdList);
        Test.stopTest();

        // 結果の確認
        // 取得件数の確認
        Assert.areEqual(0, result.fileList.size());
    }

    /**
     * 取得成功
     */
    @isTest
    private static void getDocument_success(){
        // データの準備
        List<ContentVersion> cvList = [
            SELECT
                Id
                ,ContentDocumentId
                ,ShinseiShoruiTeigiId__c
            FROM
                ContentVersion
            ORDER BY Title
        ];

        // 引数の準備
        List<String> contentVersionIdList = new List<String>{cvList.get(0).Id, cvList.get(1).Id};

        // テストの実行
        Test.startTest();
        ExFileListController.FileDetailWrapper result = ExFileListController.getDocument(contentVersionIdList);
        Test.stopTest();

        // 結果の確認
        // 取得件数の確認
        Assert.areEqual(2, result.fileList.size());
        // 詰め替え結果の確認
        Assert.areEqual(cvList.get(0).Id, result.fileList.get(0).contentVersionId);
        Assert.areEqual(cvList.get(0).ContentDocumentId, result.fileList.get(0).contentDocumentId);
        Assert.areEqual('1削除可能ファイル', result.fileList.get(0).fileName);
        Assert.isTrue(result.fileList.get(0).isDeletable);
        Assert.areEqual(cvList.get(0).ShinseiShoruiTeigiId__c, result.fileList.get(0).fileTeigiId);
        Assert.areEqual('書類定義1', result.fileList.get(0).fileTeigiName);

        Assert.areEqual(cvList.get(1).Id, result.fileList.get(1).contentVersionId);
        Assert.areEqual(cvList.get(1).ContentDocumentId, result.fileList.get(1).contentDocumentId);
        Assert.areEqual('2削除不可ファイル', result.fileList.get(1).fileName);
        Assert.isFalse(result.fileList.get(1).isDeletable);
        Assert.areEqual(cvList.get(1).ShinseiShoruiTeigiId__c, result.fileList.get(1).fileTeigiId);
        Assert.areEqual('書類定義2', result.fileList.get(1).fileTeigiName);
    }

    /**
     * 削除成功
     */
    @isTest
    private static void deleteContentDocument_Success(){
        // データの準備
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        // テストの実行
        Test.startTest();
        ExFileListController.deleteContentDocument(cv.ContentDocumentId);
        Test.stopTest();

        // 結果の確認
        List<ContentDocument> cdList =[SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        Assert.areEqual(0, cdList.size());
    }

    /**
     * 削除失敗
     */
    @isTest
    private static void deleteContentDocument_NotExist(){
        // データの準備
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion];

        Set<Id> cdIds = new Set<Id>{
            cvList.get(0).ContentDocumentId,
            cvList.get(1).ContentDocumentId,
            cvList.get(2).ContentDocumentId
        };

        // テストの実行
        Test.startTest();
        ExFileListController.deleteContentDocument(' ');
        Test.stopTest();

        // 結果の確認
        List<ContentDocument> cdList =[SELECT Id FROM ContentDocument WHERE Id in :cdIds];
        Assert.areEqual(3, cdList.size());
    }
}