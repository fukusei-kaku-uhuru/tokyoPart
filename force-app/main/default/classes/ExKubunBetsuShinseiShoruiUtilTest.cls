@isTest
private class ExKubunBetsuShinseiShoruiUtilTest {

    @TestSetup
    private static void setUp() {

        // 対象者区分を取得
        List<TaishoshaKubun__c> tkList = ExTestUtil.getTaishoshaKubuns(2);
        insert tkList;


        // 申請書類定義（対象児童用）を取得
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;

        List<KubunBetsuShinseiShorui__c> kbssList1 = ExTestUtil.getKbssList(tkList.get(0), sstList);
        List<KubunBetsuShinseiShorui__c> kbssList2 = ExTestUtil.getKbssList(tkList.get(1), sstList);
        List<KubunBetsuShinseiShorui__c> kbssList = new List<KubunBetsuShinseiShorui__c>();
        kbssList.addAll(kbssList1);
        kbssList.addAll(kbssList2);
        insert kbssList;

    }

    /**
     * 2件の対象者区分、3件の申請書類定義を用意し、対象者区分1件分の区分別申請書類一覧を取得する
     */
    @isTest
    private static void getKubunBetsuShinseiShoruiListTest1() {

        List<TaishoshaKubun__c> tkList = [SELECT Id FROM TaishoshaKubun__c];
        TaishoshaKubun__c tk1 = tkList.get(0);

        Test.startTest();
        List<KubunBetsuShinseiShorui__c> result = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiList(tk1.Id);
        Test.stopTest();

        Assert.areEqual(3, result.size());

        Assert.areEqual('書類定義1', result.get(0).ShinseiShoruiTeigi__r.Name);
        Assert.areEqual('書類定義2', result.get(1).ShinseiShoruiTeigi__r.Name);
        Assert.areEqual('書類定義3', result.get(2).ShinseiShoruiTeigi__r.Name);

    }

    /**
     * 該当する区分別申請書類定義が存在しない場合の確認（空文字を引数として渡す）
     */
    @isTest
    private static void getKubunBetsuShinseiShoruiListTest2() {

        //テストの実行
        Test.startTest();
        List<KubunBetsuShinseiShorui__c> result = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiList(' ');
        Test.stopTest();

        //結果の確認
        Assert.areEqual(0, result.size());
    }

    /**
     * 2件の対象者区分、3件の申請書類定義を用意し、それぞれの対象者区分の区分別申請書類一覧を取得する
     */
    @isTest
    private static void getKubunBetsuShinseiShoruiMapTest1() {

        //テストデータを準備
        List<TaishoshaKubun__c> tkList = [SELECT Id FROM TaishoshaKubun__c];
        TaishoshaKubun__c tk1 = tkList.get(0);
        TaishoshaKubun__c tk2 = tkList.get(1);

        //テストの実行
        Set<Id> tkIds = new Set<Id>();
        tkIds.add(tk1.Id);
        tkIds.add(tk2.Id);
        Test.startTest();
        Map<Id, List<KubunBetsuShinseiShorui__c>> result = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiMap(tkIds);
        Test.stopTest();

        //結果の確認
        //結果に対象者区分が2件分含まれること
        Assert.areEqual(2, result.size());
        //1件目の対象者区分に対し区分別申請書類が3件含まれること
        Assert.areEqual(3, result.get(tk1.Id).size());
        //1件目の対象者区分の区分別申請書類の並び方が正しいこと
        Assert.areEqual('書類定義1', result.get(tk1.Id).get(0).ShinseiShoruiTeigi__r.Name);
        Assert.areEqual('書類定義2', result.get(tk1.Id).get(1).ShinseiShoruiTeigi__r.Name);
        Assert.areEqual('書類定義3', result.get(tk1.Id).get(2).ShinseiShoruiTeigi__r.Name);
        //2件目の対象者区分に対し区分別申請書類が3件含まれること
        Assert.areEqual(3, result.get(tk2.Id).size());
        //2件目の対象者区分の区分別申請書類の並び方が正しいこと
        Assert.areEqual('書類定義1', result.get(tk2.Id).get(0).ShinseiShoruiTeigi__r.Name);
        Assert.areEqual('書類定義2', result.get(tk2.Id).get(1).ShinseiShoruiTeigi__r.Name);
        Assert.areEqual('書類定義3', result.get(tk2.Id).get(2).ShinseiShoruiTeigi__r.Name);
    }

    /**
     * 該当する区分別申請書類定義が存在しない場合の確認（中身が空のsetを渡す）
     */
    @isTest
    private static void getKubunBetsuShinseiShoruiMapTest2() {

        //テストの実行
        Set<Id> tkIds = new Set<Id>();
        Test.startTest();
        Map<Id, List<KubunBetsuShinseiShorui__c>> result = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiMap(tkIds);
        Test.stopTest();

        //結果の確認
        //結果に対象者区分が1件分も含まれないこと
        Assert.areEqual(0, result.size());
    }
}