@isTest
private class ExFileKitControllerTest {

    @TestSetup
    private static void setUp(){
        String uniqueKey = ExTestUtil.getUniqueKey();

        String generalName = ExTestUtil.GENERAL_PREFIX + uniqueKey;

        Account generalAcc = ExTestUtil.getPersonAccount(generalName);
        insert generalAcc;

        User generalUser = ExTestUtil.getGeneralUser(generalName, generalAcc.Id);
        insert generalUser;

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;
    }

    private static TaishoJido__c getTaishoJido(NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new TaishoJido__c(
            TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
        );
    }

    /**
     * ファイル情報を更新
     */
    @isTest
    private static void updateContentVersionGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            // ファイル追加
            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (Integer i = 0; i < 2; i++) {
                ContentVersion cv = ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID);
                cv.IsDeletable__c = false;
                cvList.add(cv);
            }
            insert cvList;

            // ファイル情報を更新
            Test.startTest();
            ExFileKitController.updateContentVersion(cvList[0].Id, sst.Id, true);
            Test.stopTest();

            ContentVersion result = [
                SELECT
                    Id
                    ,ShinseiShoruiTeigiId__c
                    ,HoninKakuninShoruiMaskKenkoHoken__c
                    ,IsDeletable__c
                    ,Shubetsu__c
                FROM ContentVersion
                WHERE Id = :cvList[0].Id
            ];

            Assert.areEqual(sst.Id, result.ShinseiShoruiTeigiId__c);
            Assert.isTrue(result.HoninKakuninShoruiMaskKenkoHoken__c);
            Assert.isTrue(result.IsDeletable__c);
            Assert.areEqual('Web', result.Shubetsu__c);
        }
    }
}