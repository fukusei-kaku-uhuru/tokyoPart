@isTest
private class ExCustomLookupControllerTest {

    @TestSetup
    private static void setUp(){
        insert ExTestUtil.getTaishoshaKubuns(6);

        List<KinyuKikan__c> kkList = new List<KinyuKikan__c>();
        for (Integer i = 1; i <= 6; i++) {
            kkList.add(new KinyuKikan__c(
                Name = '金融機関' + i
                ,KinyuKikanCode__c = 'X' + i
            ));
        }
        insert kkList;

        List<Shiten__c> stnList = new List<Shiten__c>();
        stnList.addAll(getStnList(6, kkList.get(0).Id));
        stnList.addAll(getStnList(6, kkList.get(1).Id));
        insert stnList;
    }

    private static List<Shiten__c> getStnList(Integer count, Id kkId){
        List<Shiten__c> stnList = new List<Shiten__c>();
        for (Integer i = 1; i <= count; i++) {
            stnList.add(new Shiten__c(
                Name = '支店' + i
                ,TempoCode__c = 'Y' + i
                ,KinyuKikan__c = kkId
            ));
        }
        return stnList;
    }

    /**
     * 対象者区分
     * 検索語なし
     */
    @isTest
    private static void search_TaishoshaKubun_NoTerm(){
        // 引数の用意
        String addField = null;
        String objectName = 'TaishoshaKubun__c';
        String filterName = null;
        Map<String, String> params = new Map<String, String>{'name' => null};

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(5, result.size());
        // 取得順の確認
        Assert.areEqual('A0', result.get(0).get('Name'));
        Assert.areEqual('A1', result.get(1).get('Name'));
        Assert.areEqual('A2', result.get(2).get('Name'));
        Assert.areEqual('A3', result.get(3).get('Name'));
        Assert.areEqual('A4', result.get(4).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        Assert.isNotNull(result.get(1).get('Id'));
        Assert.isNotNull(result.get(2).get('Id'));
        Assert.isNotNull(result.get(3).get('Id'));
        Assert.isNotNull(result.get(4).get('Id'));
        // 取得対象の確認
        Assert.areEqual('TaishoshaKubun__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 対象者区分
     * 検索語あり
     */
    @isTest
    private static void search_TaishoshaKubun_WithTerm(){
        // 引数の用意
        String addField = null;
        String objectName = 'TaishoshaKubun__c';
        String filterName = null;
        Map<String, String> params = new Map<String, String>{'name' => 'A0'};

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(1, result.size());
        // 取得順の確認
        Assert.areEqual('A0', result.get(0).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        // 取得対象の確認
        Assert.areEqual('TaishoshaKubun__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 金融機関
     * 検索語なし
     */
    @isTest
    private static void search_KinyuKikan_NoTerm(){
        // 引数の用意
        String addField = 'KinyuKikanCode__c';
        String objectName = 'KinyuKikan__c';
        String filterName = 'KinyuKikan';
        Map<String, String> params = new Map<String, String>{'name' => null};

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(5, result.size());
        // 取得順の確認
        Assert.areEqual('金融機関1', result.get(0).get('Name'));
        Assert.areEqual('金融機関2', result.get(1).get('Name'));
        Assert.areEqual('金融機関3', result.get(2).get('Name'));
        Assert.areEqual('金融機関4', result.get(3).get('Name'));
        Assert.areEqual('金融機関5', result.get(4).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        Assert.isNotNull(result.get(1).get('Id'));
        Assert.isNotNull(result.get(2).get('Id'));
        Assert.isNotNull(result.get(3).get('Id'));
        Assert.isNotNull(result.get(4).get('Id'));
        // 追加取得項目の確認
        Assert.isNotNull(result.get(0).get('KinyuKikanCode__c'));
        Assert.isNotNull(result.get(1).get('KinyuKikanCode__c'));
        Assert.isNotNull(result.get(2).get('KinyuKikanCode__c'));
        Assert.isNotNull(result.get(3).get('KinyuKikanCode__c'));
        Assert.isNotNull(result.get(4).get('KinyuKikanCode__c'));
        // 取得対象の確認
        Assert.areEqual('KinyuKikan__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 金融機関
     * 検索語あり
     * 名前が一致
     */
    @isTest
    private static void search_KinyuKikan_WithTerm_Name(){
        // 引数の用意
        String addField = 'KinyuKikanCode__c';
        String objectName = 'KinyuKikan__c';
        String filterName = 'KinyuKikan';
        Map<String, String> params = new Map<String, String>{'name' => '金融機関1'};

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(1, result.size());
        // 取得順の確認
        Assert.areEqual('金融機関1', result.get(0).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        // 追加取得項目の確認
        Assert.isNotNull(result.get(0).get('KinyuKikanCode__c'));
        // 取得対象の確認
        Assert.areEqual('KinyuKikan__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 金融機関
     * 検索語あり
     * 金融機関コードが一致
     */
    @isTest
    private static void search_KinyuKikan_WithTerm_KinyuKikanCode(){
        // 引数の用意
        String addField = 'KinyuKikanCode__c';
        String objectName = 'KinyuKikan__c';
        String filterName = 'KinyuKikan';
        Map<String, String> params = new Map<String, String>{'name' => 'X1'};

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(1, result.size());
        // 取得順の確認
        Assert.areEqual('金融機関1', result.get(0).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        // 追加取得項目の確認
        Assert.isNotNull(result.get(0).get('KinyuKikanCode__c'));
        // 取得対象の確認
        Assert.areEqual('KinyuKikan__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 支店
     * 検索語なし
     */
    @isTest
    private static void search_Shiten_NoTerm(){
        // 金融機関の取得
        List<KinyuKikan__c> kkList = [SELECT Id FROM KinyuKikan__c ORDER BY Name];

        // 引数の用意
        String addField = 'TempoCode__c';
        String objectName = 'Shiten__c';
        String filterName = 'Shiten';
        Map<String, String> params = new Map<String, String>{
            'name' => null,
            'kinyuKikan' => kkList.get(0).Id
        };

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(5, result.size());
        // 取得順の確認
        Assert.areEqual('支店1', result.get(0).get('Name'));
        Assert.areEqual('支店2', result.get(1).get('Name'));
        Assert.areEqual('支店3', result.get(2).get('Name'));
        Assert.areEqual('支店4', result.get(3).get('Name'));
        Assert.areEqual('支店5', result.get(4).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        Assert.isNotNull(result.get(1).get('Id'));
        Assert.isNotNull(result.get(2).get('Id'));
        Assert.isNotNull(result.get(3).get('Id'));
        Assert.isNotNull(result.get(4).get('Id'));
        // 追加取得項目の確認
        Assert.isNotNull(result.get(0).get('TempoCode__c'));
        Assert.isNotNull(result.get(1).get('TempoCode__c'));
        Assert.isNotNull(result.get(2).get('TempoCode__c'));
        Assert.isNotNull(result.get(3).get('TempoCode__c'));
        Assert.isNotNull(result.get(4).get('TempoCode__c'));
        // 取得対象の確認
        Assert.areEqual('Shiten__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 支店
     * 検索語あり
     * 名前が一致
     */
    @isTest
    private static void search_Shiten_WithTerm_Name(){
        // 金融機関の取得
        List<KinyuKikan__c> kkList = [SELECT Id FROM KinyuKikan__c ORDER BY Name];

        // 引数の用意
        String addField = 'TempoCode__c';
        String objectName = 'Shiten__c';
        String filterName = 'Shiten';
        Map<String, String> params = new Map<String, String>{
            'name' => '支店1',
            'kinyuKikan' => kkList.get(0).Id
        };

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(1, result.size());
        // 取得順の確認
        Assert.areEqual('支店1', result.get(0).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        // 追加取得項目の確認
        Assert.isNotNull(result.get(0).get('TempoCode__c'));
        // 取得対象の確認
        Assert.areEqual('Shiten__c', result.get(0).getSObjectType().getDescribe().getName());
    }

    /**
     * 支店
     * 検索語あり
     * 店舗コードが一致
     */
    @isTest
    private static void search_Shiten_WithTerm_TempoCode(){
        // 金融機関の取得
        List<KinyuKikan__c> kkList = [SELECT Id FROM KinyuKikan__c ORDER BY Name];

        // 引数の用意
        String addField = 'TempoCode__c';
        String objectName = 'Shiten__c';
        String filterName = 'Shiten';
        Map<String, String> params = new Map<String, String>{
            'name' => 'Y1',
            'kinyuKikan' => kkList.get(0).Id
        };

        // テストメソッドの実行
        Test.startTest();
        List<sObject> result = ExCustomLookupController.search(addField, objectName, filterName, params);
        Test.stopTest();

        // 結果の確認
        // 取得数の確認
        Assert.areEqual(1, result.size());
        // 取得順の確認
        Assert.areEqual('支店1', result.get(0).get('Name'));
        // 取得項目の確認
        Assert.isNotNull(result.get(0).get('Id'));
        // 追加取得項目の確認
        Assert.isNotNull(result.get(0).get('TempoCode__c'));
        // 取得対象の確認
        Assert.areEqual('Shiten__c', result.get(0).getSObjectType().getDescribe().getName());
    }
}