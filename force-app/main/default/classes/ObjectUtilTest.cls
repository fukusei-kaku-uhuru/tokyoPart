@isTest
private class ObjectUtilTest  {

    /**
     * 数値が入力された場合
     */
    @isTest
    private static void nvlTest1() {
        Object result = ObjectUtil.nvl(1, 2);
        Assert.areEqual(1, result);
    }

    /**
     * nullが入力された場合
     */
    @isTest
    private static void nvlTest2() {
        Object result = ObjectUtil.nvl(null, 3);
        Assert.areEqual(3, result);
    }

    /**
     * nullが入力されたかつ第二引数がnullの場合
     */
    @isTest
    private static void nvlTest3() {
        Object result = ObjectUtil.nvl(null, null);
        Assert.areEqual(null, result);
    }

    /**
     * 文字が入力された場合
     */
    @isTest
    private static void nvlTest4() {
        Object result = ObjectUtil.nvl('aaa', 'bbb');
        Assert.areEqual('aaa', result);
    }

    /**
     * nullが入力された場合
     */
    @isTest
    private static void nvlStrTest1() {
        String result = ObjectUtil.nvlStr(null);
        Assert.areEqual('', result);
    }

    /**
     * 文字が入力された場合
     */
    @isTest
    private static void nvlStrTest2() {
        String result = ObjectUtil.nvlStr('abc');
        Assert.areEqual('abc', result);
    }

    /**
     * 空文字が入力された場合
     */
    @isTest
    private static void nvlStrTest3() {
        String result = ObjectUtil.nvlStr('');
        Assert.areEqual('', result);
    }

    /**
     * nullが入力された場合
     */
    @isTest
    private static void nvlIntTest1() {
        Integer result = ObjectUtil.nvlInt(null);
        Assert.areEqual(0, result);
    }

    /**
     * 整数が入力された場合
     */
    @isTest
    private static void nvlIntTest2() {
        Integer result = ObjectUtil.nvlInt(1);
        Assert.areEqual(1, result);
    }

    /**
     * 0が入力された場合
     */
    @isTest
    private static void nvlIntTest3() {
        Integer result = ObjectUtil.nvlInt(0);
        Assert.areEqual(0, result);
    }

    /**
     * nullが入力された場合
     */
    @isTest
    private static void nvlDecimalTest1() {
        Decimal result = ObjectUtil.nvlDecimal(null);
        Assert.areEqual(0, result);
    }

    /**
     * 小数点を含む数値が入力された場合
     */
    @isTest
    private static void nvlDecimalTest2() {
        Decimal result = ObjectUtil.nvlDecimal(1.0);
        Assert.areEqual(1.0, result);
    }

    /**
     * 0が入力された場合
     */
    @isTest
    private static void nvlDecimalTest3() {
        Decimal result = ObjectUtil.nvlDecimal(0);
        Assert.areEqual(0, result);
    }

    /**
     * 指定された選択リストの値を確認
     */
    @isTest
    private static void getPickListTest1(){
        List<Schema.PicklistEntry> result = ObjectUtil.getPickList('Seikyusha__c', 'HonninKakuninHoho__c');
        Assert.areEqual(2, result.size());
        Assert.areEqual('公的個人認証', result.get(0).getValue());
        Assert.areEqual('券面アップロード', result.get(1).getValue());
    }

    /**
     * 指定された項目をキーとして作成されたListを確認
     */
    @isTest
    static void convertMapListTest1(){

        List<Account> accList = new List<Account>();
        accList.add(
            new Account(
                LastName = '一郎'
                ,PersonTitle = '一般'
            )
        );
        accList.add(
            new Account(
                LastName = '二郎'
                ,PersonTitle = '一般'
            )
        );
        accList.add(
            new Account(
                LastName = '三郎'
                ,PersonTitle = '課長'
            )
        );
        accList.add(
            new Account(
                LastName = '四郎'
                ,PersonTitle = ' '
            )
        );

        Test.startTest();
        Map<String, List<sObject>> objMap = ObjectUtil.convertMapList(accList, Schema.Account.PersonTitle);
        Test.stopTest();

        Assert.areEqual(2, objMap.size());

        List<Account> list1 = (List<Account>)objMap.get('一般');
        Assert.areEqual(2, list1.size());
        Assert.areEqual('一郎', list1.get(0).LastName);
        Assert.areEqual('二郎', list1.get(1).LastName);

        List<Account> list2 = (List<Account>)objMap.get('課長');
        Assert.areEqual(1, list2.size());
        Assert.areEqual('三郎', list2.get(0).LastName);

        Assert.areEqual(false, objMap.containsKey(' '));
    }

}