@isTest
private class ExTaishoJidoUtilTest {

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

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;

        ShinseiShoruiTeigi__c sstKojinNinsho = new ShinseiShoruiTeigi__c(
            RecordTypeId = ExTestUtil.KOJIN_NINSHO_TEIGI_ID,
            Name = '住民票の写し',
            IsMyNumber__c = false,
            IsKenkoHoken__c = false,
            Order__c = 1
        );
        List<ShinseiShoruiTeigi__c> sstTaishoJidoList = ExTestUtil.getSstListTaishoJido(3);
        List<ShinseiShoruiTeigi__c> sstMoushitateList = ExTestUtil.getSstListMoushitate(10);
        ShinseiShoruiTeigi__c sstKozaKakunin = ExTestUtil.getSstKozaKakunin();

        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        sstList.add(sstKojinNinsho);
        sstList.addAll(sstTaishoJidoList);
        sstList.addAll(sstMoushitateList);
        sstList.add(sstKozaKakunin);
        insert sstList;

        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstTaishoJidoList);
        insert kbssList;
    }

    private static TaishoJido__c getTaishoJido(NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new TaishoJido__c(
            TaishoshaKubun__c = tk.Id
            ,Shimei__c = '対象者'
            ,ShimeiFurigana__c = 'タイショウシャ'
            ,SeinenGappiDate__c = date.newInstance(2020, 1, 1)
            ,SeikyushaDoukyoShubetsu_Doukyo__c = true
            ,SeikyushaTsudukigara_Chichi__c = true
            ,IsTochuTennyuShussei__c = true
            ,TennyuShusseiDate__c = date.newInstance(2020, 1, 15)
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2020, 2, 1)
            ,NinteiSeikyu__c = ns.Id
            ,SeikyushaKubun_Taishosha__c = true
        );
    }

    private static DV_TaishoJido__c getTaishoJidoDv(DV_NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new DV_TaishoJido__c(
            RecordTypeId = ExTestUtil.DV_JIDO_ID
            ,TaishoshaKubun__c = tk.Id
            ,Shimei__c = '対象者'
            ,ShimeiFurigana__c = 'タイショウシャ'
            ,SeinenGappiDate__c = date.newInstance(2020, 1, 1)
            ,SeikyushaDoukyoShubetsu_Doukyo__c = true
            ,SeikyushaTsudukigara_Chichi__c = true
            ,IsTochuTennyuShussei__c = true
            ,TennyuShusseiDate__c = date.newInstance(2020, 1, 15)
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2020, 2, 1)
            ,NinteiSeikyu__c = ns.Id
            ,SeikyushaKubun_Taishosha__c = true
        );
    }

    private static DV_TaishoJido__c getTaishoJidoSatoya(DV_NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new DV_TaishoJido__c(
            RecordTypeId = ExTestUtil.SATOYA_JIDO_ID
            ,TaishoshaKubun__c = tk.Id
            ,Shimei__c = '対象者'
            ,ShimeiFurigana__c = 'タイショウシャ'
            ,SeinenGappiDate__c = date.newInstance(2020, 1, 1)
            ,SeikyushaDoukyoShubetsu_Doukyo__c = true
            ,SeikyushaTsudukigara_Chichi__c = true
            ,IsTochuTennyuShussei__c = true
            ,TennyuShusseiDate__c = date.newInstance(2020, 1, 15)
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2020, 2, 1)
            ,NinteiSeikyu__c = ns.Id
            ,SeikyushaKubun_Taishosha__c = true
        );
    }

    /**
     * 代理人ではない場合
     */
    @isTest
    private static void getRequiredShinseiShorui1() {

        ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
        sst.IsRequiredDairinin__c = true;
        update sst;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];
            List<KubunBetsuShinseiShorui__c> kbssList = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiList(tk.Id);

            Test.startTest();
            List<KubunBetsuShinseiShorui__c> results = ExTaishoJidoUtil.getRequiredShinseiShorui(false, kbssList);
            Test.stopTest();

            Assert.areEqual(3, kbssList.size());
            Assert.areEqual(2, results.size());
            // 代理人時必須のファイルのみ省かれていること
            for (KubunBetsuShinseiShorui__c kbss : results) {
                Assert.areNotEqual(sst.Id, kbss.ShinseiShoruiTeigi__c);
            }
        }
    }

    /**
     * 代理人の場合
     */
    @isTest
    private static void getRequiredShinseiShorui2() {

        ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
        sst.IsRequiredDairinin__c = true;
        update sst;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];
            List<KubunBetsuShinseiShorui__c> kbssList = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiList(tk.Id);

            Test.startTest();
            List<KubunBetsuShinseiShorui__c> results = ExTaishoJidoUtil.getRequiredShinseiShorui(true, kbssList);
            Test.stopTest();

            Assert.areEqual(3, kbssList.size());
            Assert.areEqual(3, results.size());
        }
    }

    /**
     * 指定されたIdに紐づくファイル一覧を取得する
     */
    @isTest
    private static void getFileList1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            // ファイル登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            ShinseiShoruiTeigi__c sstKojin = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKojin, ns.Id, ExTestUtil.GENERAL_NETWORK_ID));
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            insert cvList;

            Test.startTest();
            List<ContentDocumentLink> results = ExTaishoJidoUtil.getFileList(tj.Id);
            Test.stopTest();

            Assert.areEqual(14, results.size());
        }
    }

    /**
     * 指定された書類区分のContentVersionIdを取得する
     */
    @isTest
    private static void getFilteringFileLists1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            TaishoJido__c tj3 = getTaishoJido(ns, tk);
            TaishoJido__c tj4 = getTaishoJido(ns, tk);
            insert new List<TaishoJido__c>{tj1, tj2, tj3, tj4};

            // ファイル登録
            List<ContentVersion> cvList = new List<ContentVersion>();

            List<ShinseiShoruiTeigi__c> sstKazokuList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();
            for (ShinseiShoruiTeigi__c sstKazoku : sstKazokuList) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            cvList.add(ExTestUtil.getContentVersion(sstKazokuList[0], tj2.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKazokuList[0], tj3.Id, ExTestUtil.GENERAL_NETWORK_ID));

            List<ShinseiShoruiTeigi__c> sstMoushitateList = ExShinseiShoruiTeigiUtil.getListByMoushitatesho();
            for (ShinseiShoruiTeigi__c sstMoushitate : sstMoushitateList) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            cvList.add(ExTestUtil.getContentVersion(sstMoushitateList[0], tj2.Id, ExTestUtil.GENERAL_NETWORK_ID));

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj2.Id, ExTestUtil.GENERAL_NETWORK_ID));
            insert cvList;

            Test.startTest();
            Set<String> idSet = new Set<String>();
            idSet.add(tj1.Id);
            idSet.add(tj2.Id);
            idSet.add(tj3.Id);
            idSet.add(tj4.Id);
            Map<String, Map<String, List<String>>> results = ExTaishoJidoUtil.getFilteringFileLists(idSet);
            Test.stopTest();

            { // 対象児童1
                Map<String, List<String>> cvIdLists = results.get(tj1.Id);
                Assert.isNotNull(cvIdLists);

                Assert.areEqual(3, cvIdLists.get('kazoku').size());
                Assert.areEqual(10, cvIdLists.get('moushitate').size());
                Assert.areEqual(2, cvIdLists.get('koza').size());
            }

            { // 対象児童2
                Map<String, List<String>> cvIdLists = results.get(tj2.Id);
                Assert.isNotNull(cvIdLists);

                Assert.areEqual(1, cvIdLists.get('kazoku').size());
                Assert.areEqual(1, cvIdLists.get('moushitate').size());
                Assert.areEqual(1, cvIdLists.get('koza').size());
            }

            { // 対象児童3
                Map<String, List<String>> cvIdLists = results.get(tj3.Id);
                Assert.isNotNull(cvIdLists);

                Assert.areEqual(1, cvIdLists.get('kazoku').size());
                Assert.areEqual(0, cvIdLists.get('moushitate').size());
                Assert.areEqual(0, cvIdLists.get('koza').size());
            }

            { // 対象児童4
                Map<String, List<String>> cvIdLists = results.get(tj4.Id);
                Assert.isNotNull(cvIdLists);

                Assert.areEqual(0, cvIdLists.get('kazoku').size());
                Assert.areEqual(0, cvIdLists.get('moushitate').size());
                Assert.areEqual(0, cvIdLists.get('koza').size());
            }
        }
    }

    /**
     * 指定された書類区分のContentVersionIdを取得する
     */
    @isTest
    private static void getFilteringFileList1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            TaishoJido__c tj3 = getTaishoJido(ns, tk);
            TaishoJido__c tj4 = getTaishoJido(ns, tk);
            insert new List<TaishoJido__c>{tj1, tj2, tj3, tj4};

            // ファイル登録
            List<ContentVersion> cvList = new List<ContentVersion>();

            List<ShinseiShoruiTeigi__c> sstKazokuList = ExShinseiShoruiTeigiUtil.getListByTaishoJido();
            for (ShinseiShoruiTeigi__c sstKazoku : sstKazokuList) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            cvList.add(ExTestUtil.getContentVersion(sstKazokuList[0], tj2.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKazokuList[0], tj3.Id, ExTestUtil.GENERAL_NETWORK_ID));

            List<ShinseiShoruiTeigi__c> sstMoushitateList = ExShinseiShoruiTeigiUtil.getListByMoushitatesho();
            for (ShinseiShoruiTeigi__c sstMoushitate : sstMoushitateList) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            cvList.add(ExTestUtil.getContentVersion(sstMoushitateList[0], tj2.Id, ExTestUtil.GENERAL_NETWORK_ID));

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj2.Id, ExTestUtil.GENERAL_NETWORK_ID));
            insert cvList;

            Test.startTest();
            Set<String> idSet = new Set<String>();
            idSet.add(tj1.Id);
            idSet.add(tj2.Id);
            idSet.add(tj3.Id);
            idSet.add(tj4.Id);
            Map<String, List<String>> cvIdLists = ExTaishoJidoUtil.getFilteringFileList(tj1.Id);
            Test.stopTest();

            Assert.isNotNull(cvIdLists);

            Assert.areEqual(3, cvIdLists.get('kazoku').size());
            Assert.areEqual(10, cvIdLists.get('moushitate').size());
            Assert.areEqual(2, cvIdLists.get('koza').size());
        }
    }

    /**
     * 対象児童が追加可能かチェックする 追加可能
     */
    @isTest
    private static void canAddTaishoJidoGeneral1() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>();
            for (Integer i = 1; i < limitSetting.Value__c; i++) {
                tjList.add(getTaishoJido(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id);
            Test.stopTest();

            Assert.isTrue(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 件数が上限に達している
     */
    @isTest
    private static void canAddTaishoJidoGeneral2() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>();
            for (Integer i = 1; i <= limitSetting.Value__c; i++) {
                tjList.add(getTaishoJido(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id, ExLwcUtil.getSiteMode());
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 件数が上限に達している
     */
    @isTest
    private static void canAddTaishoJidoGeneral3() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>();
            for (Integer i = 1; i <= limitSetting.Value__c + 1; i++) {
                tjList.add(getTaishoJido(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id, ExLwcUtil.getSiteMode());
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 認定請求が審査中
     */
    @isTest
    private static void canAddTaishoJidoGeneral4() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>();
            for (Integer i = 1; i < limitSetting.Value__c; i++) {
                tjList.add(getTaishoJido(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id, ExLwcUtil.getSiteMode());
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 追加可能
     */
    @isTest
    private static void canAddTaishoJidoDv1() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();
            for (Integer i = 1; i < limitSetting.Value__c; i++) {
                tjList.add(getTaishoJidoDv(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id);
            Test.stopTest();

            Assert.isTrue(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 件数が上限に達している
     */
    @isTest
    private static void canAddTaishoJidoDv2() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();
            for (Integer i = 1; i <= limitSetting.Value__c; i++) {
                tjList.add(getTaishoJidoDv(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id, ExLwcUtil.getSiteMode());
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 件数が上限に達している
     */
    @isTest
    private static void canAddTaishoJidoSatoya1() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();
            for (Integer i = 1; i <= limitSetting.Value__c + 1; i++) {
                tjList.add(getTaishoJidoSatoya(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id, ExLwcUtil.getSiteMode());
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 対象児童が追加可能かチェックする 認定請求が審査中
     */
    @isTest
    private static void canAddTaishoJidoSatoya2() {

        Limit__mdt limitSetting = Limit__mdt.getInstance('TaishoJido');

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.ShinsaStatus__c = 'OCR処理中';
            insert ns;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();
            for (Integer i = 1; i < limitSetting.Value__c; i++) {
                tjList.add(getTaishoJidoSatoya(ns, tk));
            }
            insert tjList;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.canAddTaishoJido(ns.Id, ExLwcUtil.getSiteMode());
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする ゆうちょ登録済
     */
    @isTest
    private static void isNotSeikyushaKozaFilledGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳｼﾔ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.GENERAL_NETWORK_ID);

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする その他登録済
     */
    @isTest
    private static void isNotSeikyushaKozaFilledGeneral2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            s.KouzaMeigi__c = 'ｾｲｷﾕｳｼﾔ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.GENERAL_NETWORK_ID);

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする 名義未登録
     */
    @isTest
    private static void isNotSeikyushaKozaFilledGeneral3() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.GENERAL_NETWORK_ID);

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isTrue(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする 書類未提出
     */
    @isTest
    private static void isNotSeikyushaKozaFilledGeneral4() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            s.KouzaMeigi__c = 'ｾｲｷﾕｳｼﾔ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isTrue(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする ゆうちょ登録済
     */
    @isTest
    private static void isNotSeikyushaKozaFilledDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳｼﾔ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.DV_NETWORK_ID);

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする その他登録済
     */
    @isTest
    private static void isNotSeikyushaKozaFilledDv2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            s.KouzaMeigi__c = 'ｾｲｷﾕｳｼﾔ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.DV_NETWORK_ID);

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isFalse(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする 名義未登録
     */
    @isTest
    private static void isNotSeikyushaKozaFilledSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.SATOYA_NETWORK_ID);

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isTrue(result);
        }
    }

    /**
     * 請求者の口座情報が設定されているかチェックする 書類未提出
     */
    @isTest
    private static void isNotSeikyushaKozaFilledSatoya2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            s.KouzaMeigi__c = 'ｾｲｷﾕｳｼﾔ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            Test.startTest();
            Boolean result = ExTaishoJidoUtil.isNotSeikyushaKozaFilled(ns.Id);
            Test.stopTest();

            Assert.isTrue(result);
        }
    }
}