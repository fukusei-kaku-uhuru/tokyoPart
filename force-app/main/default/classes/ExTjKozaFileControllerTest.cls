@isTest
private class ExTjKozaFileControllerTest {
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

        insert ExTestUtil.getTaishoshaKubun();
        insert ExTestUtil.getSstKozaKakunin();
    }

    private static TaishoJido__c getTaishoJido(NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new TaishoJido__c(
            TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
        );
    }

    private static DV_TaishoJido__c getTaishoJidoDv(DV_NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new DV_TaishoJido__c(
            RecordTypeId = ExTestUtil.DV_JIDO_ID
            ,TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
        );
    }

    private static DV_TaishoJido__c getTaishoJidoSatoya(DV_NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new DV_TaishoJido__c(
            RecordTypeId = ExTestUtil.SATOYA_JIDO_ID
            ,TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
        );
    }


    /**
     * 口座ファイル情報を取得
     */
    @isTest
    private static void getKozaDataGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID);

            Test.startTest();
            ExTjKozaFileController.KozaWrapper kw = ExTjKozaFileController.getKozaData(tj.Id);
            Test.stopTest();

            Assert.areEqual('対象者', kw.Shimei);
            Assert.isFalse(kw.isDisabled);

            Assert.areEqual(1, kw.KozaOption.size());
            Assert.areEqual('書類定義', kw.KozaOption[0].get('label'));

            Assert.areEqual(1, kw.KozaShoruiList.size());
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void getKozaDataGeneral2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID);

            Test.startTest();
            ExTjKozaFileController.KozaWrapper kw = ExTjKozaFileController.getKozaData(tj.Id);
            Test.stopTest();

            Assert.isTrue(kw.isDisabled);
        }
    }

    /**
     * 口座ファイル情報を取得
     */
    @isTest
    private static void getKozaDataDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.DV_NETWORK_ID);

            Test.startTest();
            ExTjKozaFileController.KozaWrapper kw = ExTjKozaFileController.getKozaData(tj.Id);
            Test.stopTest();

            Assert.areEqual('対象者', kw.Shimei);
            Assert.isFalse(kw.isDisabled);

            Assert.areEqual(1, kw.KozaOption.size());
            Assert.areEqual('書類定義', kw.KozaOption[0].get('label'));

            Assert.areEqual(1, kw.KozaShoruiList.size());
        }
    }

    /**
     * 口座ファイル情報を取得
     */
    @isTest
    private static void getKozaDataSatoya2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            tj.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.SATOYA_NETWORK_ID);

            Test.startTest();
            ExTjKozaFileController.KozaWrapper kw = ExTjKozaFileController.getKozaData(tj.Id);
            Test.stopTest();

            Assert.isTrue(kw.isDisabled);
        }
    }

    /**
     * 口座確認書類が提出されているかをチェックする
     */
    @isTest
    private static void needUploadShinseiShoruiGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID);

            Test.startTest();
            List<String> results = ExTjKozaFileController.needUploadShinseiShorui(tj.Id);
            Test.stopTest();

            Assert.areEqual(0, results.size());
        }
    }
}