@isTest
private class ExTjMoushitateFileControllerTest {
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
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListMoushitate(10);
        sstList[0].IsNiniTeisyutsu__c = true;
        insert sstList;
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
     * 申立書ファイルアップロード画面用の情報を取得する
     */
    @isTest
    private static void getMoushitateDataGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.isTrue(mw.IsKokennin);
            Assert.isTrue(mw.IsBekkyo);
            Assert.isTrue(mw.IsRyugaku);
            Assert.isTrue(mw.IsRikon);
            Assert.isTrue(mw.IsFuboSitei);
            Assert.areEqual(2, mw.KokenninShoruiOptions.size());
            Assert.areEqual('書類定義1', mw.KokenninShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.BekkyoShoruiOptions.size());
            Assert.areEqual('* 書類定義2', mw.BekkyoShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.RyugakuShoruiOptions.size());
            Assert.areEqual('* 書類定義3', mw.RyugakuShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.RikonShoruiOptions.size());
            Assert.areEqual('* 書類定義4', mw.RikonShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.FuboShoruiOptions.size());
            Assert.areEqual('* 書類定義5', mw.FuboShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.KokenninShoruiList.size());
            Assert.areEqual(2, mw.BekkyoShoruiList.size());
            Assert.areEqual(2, mw.RyugakuShoruiList.size());
            Assert.areEqual(2, mw.RikonShoruiList.size());
            Assert.areEqual(2, mw.FuboShoruiList.size());
            Assert.isFalse(mw.isDisabled);
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void getMoushitateDataGeneral2() {

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

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.isTrue(mw.isDisabled);
        }
    }

    /**
     * 申立書ファイルアップロード画面用の情報を取得する
     */
    @isTest
    private static void getMoushitateDataDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.DV_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.isTrue(mw.IsKokennin);
            Assert.isTrue(mw.IsBekkyo);
            Assert.isTrue(mw.IsRyugaku);
            Assert.isTrue(mw.IsRikon);
            Assert.isTrue(mw.IsFuboSitei);
            Assert.areEqual(2, mw.KokenninShoruiOptions.size());
            Assert.areEqual('書類定義1', mw.KokenninShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.BekkyoShoruiOptions.size());
            Assert.areEqual('* 書類定義2', mw.BekkyoShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.RyugakuShoruiOptions.size());
            Assert.areEqual('* 書類定義3', mw.RyugakuShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.RikonShoruiOptions.size());
            Assert.areEqual('* 書類定義4', mw.RikonShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.FuboShoruiOptions.size());
            Assert.areEqual('* 書類定義5', mw.FuboShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.KokenninShoruiList.size());
            Assert.areEqual(2, mw.BekkyoShoruiList.size());
            Assert.areEqual(2, mw.RyugakuShoruiList.size());
            Assert.areEqual(2, mw.RikonShoruiList.size());
            Assert.areEqual(2, mw.FuboShoruiList.size());
            Assert.isFalse(mw.isDisabled);
        }
    }

/**
     * 申立書ファイルアップロード画面用の情報を取得する
     */
    @isTest
    private static void getMoushitateDataSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.ShinsaKekkaSaishu__c = 'OK';
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.DV_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.isTrue(mw.IsKokennin);
            Assert.isTrue(mw.IsBekkyo);
            Assert.isTrue(mw.IsRyugaku);
            Assert.isTrue(mw.IsRikon);
            Assert.isTrue(mw.IsFuboSitei);
            Assert.areEqual(2, mw.KokenninShoruiOptions.size());
            Assert.areEqual('書類定義1', mw.KokenninShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.BekkyoShoruiOptions.size());
            Assert.areEqual('* 書類定義2', mw.BekkyoShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.RyugakuShoruiOptions.size());
            Assert.areEqual('* 書類定義3', mw.RyugakuShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.RikonShoruiOptions.size());
            Assert.areEqual('* 書類定義4', mw.RikonShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.FuboShoruiOptions.size());
            Assert.areEqual('* 書類定義5', mw.FuboShoruiOptions[0].get('label'));
            Assert.areEqual(2, mw.KokenninShoruiList.size());
            Assert.areEqual(2, mw.BekkyoShoruiList.size());
            Assert.areEqual(2, mw.RyugakuShoruiList.size());
            Assert.areEqual(2, mw.RikonShoruiList.size());
            Assert.areEqual(2, mw.FuboShoruiList.size());
            Assert.isTrue(mw.isDisabled);
        }
    }

    /**
     * 渡された区分に紐づく提出済み書類を取得する
     */
    @isTest
    private static void getMoushitateShoruiListGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            List<String> resultCvList = ExTjMoushitateFileController.getMoushitateShoruiList(tj.Id, '1');
            Test.stopTest();

            Assert.areEqual(2, resultCvList.size());
        }
    }

    /**
     * 渡された区分に紐づく提出済み書類を取得する
     */
    @isTest
    private static void getMoushitateShoruiListDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.DV_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            List<String> resultCvList = ExTjMoushitateFileController.getMoushitateShoruiList(tj.Id, '1');
            Test.stopTest();

            Assert.areEqual(2, resultCvList.size());
        }
    }

    /**
     * 渡された区分に紐づく提出済み書類を取得する
     */
    @isTest
    private static void getMoushitateShoruiListSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sst : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.SATOYA_NETWORK_ID));
            }
            insert cvList;

            // 申立書ファイルアップロード画面用の情報を取得する
            Test.startTest();
            List<String> resultCvList = ExTjMoushitateFileController.getMoushitateShoruiList(tj.Id, '1');
            Test.stopTest();

            Assert.areEqual(2, resultCvList.size());
        }
    }

    /**
     * 提出が必要な申請書類の一覧を返す
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
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);

            // 提出が必要な申請書類の一覧を返す
            Test.startTest();
            List<String> results = ExTjMoushitateFileController.needUploadShinseiShorui(mw);
            Test.stopTest();

            Assert.areEqual(9, results.size());
        }
    }

    /**
     * 提出が必要な申請書類の一覧を返す
     */
    @isTest
    private static void needUploadShinseiShoruiDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);

            // 提出が必要な申請書類の一覧を返す
            Test.startTest();
            List<String> results = ExTjMoushitateFileController.needUploadShinseiShorui(mw);
            Test.stopTest();

            Assert.areEqual(9, results.size());
        }
    }

    /**
     * 提出が必要な申請書類の一覧を返す
     */
    @isTest
    private static void needUploadShinseiShoruiSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            ExTjMoushitateFileController.MoushitateWrapper mw = ExTjMoushitateFileController.getMoushitateData(tj.Id);

            // 提出が必要な申請書類の一覧を返す
            Test.startTest();
            List<String> results = ExTjMoushitateFileController.needUploadShinseiShorui(mw);
            Test.stopTest();

            Assert.areEqual(9, results.size());
        }
    }
}