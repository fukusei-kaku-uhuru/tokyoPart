@isTest
private class ExShinseiShoruiTeigiUtilTest {

    @TestSetup
    private static void setUp(){
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        sstList.addAll(ExTestUtil.getSstListKojinNinsho(3));
        sstList.addAll(ExTestUtil.getSstListTaishoJido(3));
        sstList.addAll(ExTestUtil.getSstListMoushitate(6));
        sstList.addAll(ExTestUtil.getSstListKozaKakunin(3));
        insert sstList;
    }

    /**
     * 申請書類定義（個人認証用）のリストを取得確認
     */
    @isTest
    private static void getListByKojinNinshoTest(){

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getListByKojinNinsho();
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(3, result.size());
        //取得順序の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義2', result.get(1).Name);
        Assert.areEqual('書類定義3', result.get(2).Name);
    }

    /**
     * 申請書類定義（対象児童用）のリストを取得確認
     */
    @isTest
    private static void getListByTaishoJidoTest(){

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getListByTaishoJido();
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(3, result.size());
        //取得順序の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義2', result.get(1).Name);
        Assert.areEqual('書類定義3', result.get(2).Name);
    }

    /**
     * 申請書類定義（申立書用）のリストを取得確認
     */
    @isTest
    private static void getListByMoushitateshoTest(){

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getListByMoushitatesho();
        Test.stopTest();

        // 結果の確認
        // 取得したデータ数の確認
        Assert.areEqual(6, result.size());
        // 取得順序の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義2', result.get(1).Name);
        Assert.areEqual('書類定義3', result.get(2).Name);
        Assert.areEqual('書類定義4', result.get(3).Name);
        Assert.areEqual('書類定義5', result.get(4).Name);
        Assert.areEqual('書類定義6', result.get(5).Name);
    }

    /**
     * 申請書類定義（銀行口座確認用）のリストを取得確認
     */
    @isTest
    private static void getKozaKakuninTest(){

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getKozaKakunin();
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(3, result.size());
        //取得順序の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義2', result.get(1).Name);
        Assert.areEqual('書類定義3', result.get(2).Name);
    }

    /**
     * 申請書類定義が取得できない場合の確認
     */
    @isTest
    private static void getListTest(){

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getList('Yuusoushinsei');
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(0, result.size());
    }

    /**
     * Idに一致する申請書類定義を取得の確認(レコードタイプ順)
     */
    @isTest
    private static void getListByIdSetTest1(){

        //テストデータの準備
        List<ShinseiShoruiTeigi__c> sstList = [
            SELECT
                Id
            FROM
                ShinseiShoruiTeigi__c
            WHERE
                Order__c = 1
            ORDER BY RecordTypeId
        ];
        // 取得順序の確認用
        sstList.get(0).ShoruiTeigiKey__c = '1';
        sstList.get(1).ShoruiTeigiKey__c = '2';
        sstList.get(2).ShoruiTeigiKey__c = '3';
        sstList.get(3).ShoruiTeigiKey__c = '4';
        update sstList;

        Set<String> idSet = new Set<String>();
        idSet.add(sstList.get(0).Id);
        idSet.add(sstList.get(1).Id);
        idSet.add(sstList.get(2).Id);
        idSet.add(sstList.get(3).Id);

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getListByIdSet(idSet);
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(4, result.size());
        // 取得順序の確認
        Assert.areEqual('1', result.get(0).ShoruiTeigiKey__c);
        Assert.areEqual('2', result.get(1).ShoruiTeigiKey__c);
        Assert.areEqual('3', result.get(2).ShoruiTeigiKey__c);
        Assert.areEqual('4', result.get(3).ShoruiTeigiKey__c);
    }

    /**
     * Idに一致する申請書類定義を取得の確認(名前順)
     */
    @isTest
    private static void getListByIdSetTest2(){

       //テストデータの準備
       List<ShinseiShoruiTeigi__c> sstList = [
            SELECT
                Id
            FROM
                ShinseiShoruiTeigi__c
            WHERE
                RecordTypeId = :ExTestUtil.KOJIN_NINSHO_TEIGI_ID
        ];

        Set<String> idSet = new Set<String>();
        idSet.add(sstList.get(0).Id);
        idSet.add(sstList.get(1).Id);
        idSet.add(sstList.get(2).Id);

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getListByIdSet(idSet);
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(3, result.size());
        // 取得順序の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義2', result.get(1).Name);
        Assert.areEqual('書類定義3', result.get(2).Name);
    }

    /**
     * Idに一致する申請書類定義が存在しない場合の確認
     */
    @isTest
    private static void getListByIdSetTest3(){

        //メソッドの実行
        Set<String> idSet = new Set<String>();
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getListByIdSet(idSet);
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(0, result.size());
    }

    /**
     * 指定した申立書区分の申請書類定義の取得の確認
     */
    @isTest
    private static void getRequiredMoushitateShoruiTest1(){

        //メソッドの実行
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getRequiredMoushitateShorui('1');
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(2, result.size());
        // 取得順の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義6', result.get(1).Name);
    }

    /**
     * 指定した申立書区分（複数件）の申請書類定義の取得の確認
     */
    @isTest
    private static void getRequiredMoushitateShoruiTest2(){

        //メソッドの実行
        List<String> moushitateKubun = new List<String>{'1', '2'};
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getRequiredMoushitateShorui(moushitateKubun);
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(3, result.size());
        // 取得順の確認
        Assert.areEqual('書類定義1', result.get(0).Name);
        Assert.areEqual('書類定義6', result.get(1).Name);
        Assert.areEqual('書類定義2', result.get(2).Name);
    }

    /**
     * 指定した申立書区分の申請書類定義が存在しない場合の確認
     */
    @isTest
    private static void getRequiredMoushitateShoruiTest3(){

        //メソッドの実行
        List<String> moushitateKubun = new List<String>{'6'};
        Test.startTest();
        List<ShinseiShoruiTeigi__c> result = ExShinseiShoruiTeigiUtil.getRequiredMoushitateShorui(moushitateKubun);
        Test.stopTest();

        //結果の確認
        //取得したデータの数の確認
        Assert.areEqual(0, result.size());
    }

    /**
     * 対象の申請書類定義の健康保険証項目の取得の確認
     */
    @isTest
    private static void isKenkoHokenTest(){

        List<ShinseiShoruiTeigi__c> sstList = [SELECT Id FROM ShinseiShoruiTeigi__c LIMIT 2];
        sstList[0].IsKenkoHoken__c = true;
        update sstList;

        //メソッドの実行
        Test.startTest();
        Boolean result0 = ExShinseiShoruiTeigiUtil.isKenkoHoken(sstList[0].Id);
        Boolean result1 = ExShinseiShoruiTeigiUtil.isKenkoHoken(sstList[1].Id);
        Test.stopTest();

        //結果の確認
        Assert.isTrue(result0);
        Assert.isFalse(result1);
    }

    /**
     * 対象の申請書類定義の健康保険証項目の取得の確認
     */
    @isTest
    private static void isJuminHyoTest(){

        List<ShinseiShoruiTeigi__c> sstList = [SELECT Id FROM ShinseiShoruiTeigi__c LIMIT 2];
        sstList[0].IsJuminHyo__c = true;
        update sstList;

        //メソッドの実行
        Test.startTest();
        Boolean result0 = ExShinseiShoruiTeigiUtil.isJuminHyo(sstList[0].Id);
        Boolean result1 = ExShinseiShoruiTeigiUtil.isJuminHyo(sstList[1].Id);
        Test.stopTest();

        //結果の確認
        Assert.isTrue(result0);
        Assert.isFalse(result1);
    }
}