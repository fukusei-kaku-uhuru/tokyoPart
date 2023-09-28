@isTest
private class ExJushoFormControllerTest {

    /**
     * キャッシュ済
     */
    @isTest
    private static void getAddressByPostalcode1() {

        YubinBango__c yb = new YubinBango__c(
            TodofukenKanji__c = '県'
            ,Gun1__c = '郡1'
            ,Gun2__c = '郡2'
            ,ShikuchosonKanji__c = '市区町村'
            ,ChoBanchi1__c = '町番地1'
            ,ChoBanchi2__c = '町番地2'
            ,ChoBanchi3__c = '町番地3'
            ,ChoBanchi4__c = '町番地4'
            ,ChoBanchi5__c = '町番地5'
            ,ChoBanchi6__c = '町番地6'
            ,YubinBango8__c = '000-0000'
        );
        insert yb;

        Test.startTest();
        Map<String, String> result = ExJushoFormController.getAddressByPostalcode('000-0000');
        Test.stopTest();

        Assert.areEqual('県', result.get('todoFuken'));
        Assert.areEqual('郡1郡2市区町村', result.get('shikuChoson'));
        Assert.areEqual('町番地1町番地2町番地3町番地4町番地5町番地6', result.get('chiban'));
    }

    /**
     * 未キャッシュ
     */
    @isTest
    private static void getAddressByPostalcode2() {

        YubinBango__c yb = new YubinBango__c(
            TodofukenKanji__c = '県'
            ,Gun1__c = '郡1'
            ,Gun2__c = '郡2'
            ,ShikuchosonKanji__c = '市区町村'
            ,ChoBanchi1__c = '町番地1'
            ,ChoBanchi2__c = '町番地2'
            ,ChoBanchi3__c = '町番地3'
            ,ChoBanchi4__c = '町番地4'
            ,ChoBanchi5__c = '町番地5'
            ,ChoBanchi6__c = '町番地6'
            ,YubinBango8__c = '000-0000'
        );

        Test.setMock(HttpCalloutMock.class, new MockGoogleGeoCode(true, yb));

        Test.startTest();
        Map<String, String> result = ExJushoFormController.getAddressByPostalcode('000-0000');
        Test.stopTest();

        Assert.areEqual('県', result.get('todoFuken'));
        Assert.areEqual('郡1郡2市区町村', result.get('shikuChoson'));
        Assert.areEqual('町番地1町番地2町番地3町番地4町番地5町番地6', result.get('chiban'));

        YubinBango__c insertedYb = [
            SELECT
                Id
                ,TodofukenKanji__c
                ,Gun1__c
                ,Gun2__c
                ,ShikuchosonKanji__c
                ,ChoBanchi1__c
                ,ChoBanchi2__c
                ,ChoBanchi3__c
                ,ChoBanchi4__c
                ,ChoBanchi5__c
                ,ChoBanchi6__c
            FROM YubinBango__c
            WHERE YubinBango8__c = '000-0000'
        ];

        Assert.areEqual('県', insertedYb.TodofukenKanji__c);
        Assert.areEqual('郡1', insertedYb.Gun1__c);
        Assert.areEqual('郡2', insertedYb.Gun2__c);
        Assert.areEqual('市区町村', insertedYb.ShikuchosonKanji__c);
        Assert.areEqual('町番地1', insertedYb.ChoBanchi1__c);
        Assert.areEqual('町番地2', insertedYb.ChoBanchi2__c);
        Assert.areEqual('町番地3', insertedYb.ChoBanchi3__c);
        Assert.areEqual('町番地4', insertedYb.ChoBanchi4__c);
        Assert.areEqual('町番地5', insertedYb.ChoBanchi5__c);
        Assert.areEqual('町番地6', insertedYb.ChoBanchi6__c);
    }

    /**
     * ヒットしない場合
     */
    @isTest
    private static void getAddressByPostalcode3() {

        YubinBango__c yb = new YubinBango__c();

        Test.setMock(HttpCalloutMock.class, new MockGoogleGeoCode(true, yb));

        Boolean isError = false;
        try {
            Test.startTest();
            Map<String, String> result = ExJushoFormController.getAddressByPostalcode('000-0000');
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        Assert.isTrue(isError);

        List<YubinBango__c> insertedYbList = [
            SELECT
                Id
            FROM YubinBango__c
        ];

        Assert.areEqual(0, insertedYbList.size());
    }
}