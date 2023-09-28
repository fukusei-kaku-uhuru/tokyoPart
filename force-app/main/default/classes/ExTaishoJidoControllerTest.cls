@isTest
private class ExTaishoJidoControllerTest {

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

        insert ExTestUtil.getSstListMoushitate(10);
        insert ExTestUtil.getSstKozaKakunin();
    }

    /**
     * getTaishoJidoList
     * empty
     * general
     */
    @isTest
    private static void getTaishoJidoList_IsEmpty_General() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            // 対象児童一覧が空だったときの動作確認
            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.isTrue(results.isEmpty());
    }

    /**
     * getTaishoJidoList
     * details
     * general
     */
    @isTest
    private static void getTaishoJidoList_Details_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.Shimei__c = '東京　花子';
            tj.ShimeiFurigana__c = 'トウキョウ　ハナコ';
            tj.SeinenGappiDate__c = Date.newInstance(2020, 1, 1);
            tj.SeikyushaKubun_Dairinin__c = true;
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.areEqual(tj.Id, results[0].Id);
        Assert.areEqual(tk.Name, results[0].TaishoshaKubun);
        Assert.areEqual(tk.Id, results[0].TaishoshaKubunId);
        Assert.areEqual('東京　花子', results[0].Shimei);
        Assert.areEqual('トウキョウ　ハナコ', results[0].ShimeiFurigana);
        Assert.isTrue(results[0].IsDairinin);
        Assert.isTrue(results[0].IsKokennin);
        Assert.isTrue(results[0].IsBekkyo);
        Assert.isTrue(results[0].IsRyugaku);
        Assert.isTrue(results[0].IsRikon);
        Assert.isTrue(results[0].IsFuboSitei);
    }

    /**
     * getTaishoJidoList
     * KouzaShubetsu
     * general
     */
    @isTest
    private static void getTaishoJidoList_KouzaShubetsu_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj1;
        TaishoJido__c tj2;
        TaishoJido__c tj3;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj1 = getTaishoJido(ns);
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.UketoriKouzaKubun_Taishosha__c = false;
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJido(ns);
            tj2.UketoriKouzaKubun_Seikyusha__c = false;
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJido(ns);
            tj3.UketoriKouzaKubun_Seikyusha__c = false;
            tj3.UketoriKouzaKubun_Taishosha__c = false;
            tj3.TaishoshaKubun__c = tk.Id;

            insert new List<TaishoJido__c>{tj1, tj2, tj3};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Map<String, String> labels = ExLwcUtil.getColumnLabels('TaishoJido__c', new List<String>{'UketoriKouzaKubun_Seikyusha__c', 'UketoriKouzaKubun_Taishosha__c'});

        Assert.areEqual(3, results.size());

        Assert.isFalse(results[0].isSelectedTaishosha);
        Assert.isTrue(results[1].isSelectedTaishosha);
        Assert.isNull(results[2].isSelectedTaishosha);
    }

    /**
     * getTaishoJidoList
     * Yucho
     * general
     */
    @isTest
    private static void getTaishoJidoList_Yucho_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.TJ_Yucho_Shumoku01__c = true;
            tj.TJ_Yucho_Shumoku02__c = false;
            tj.TJ_Yucho_Shumoku03__c = false;
            tj.TJ_Yucho_Shumoku04__c = false;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'TOKYO HANAKO';
            tj.TaishoshaKubun__c = tk.Id;

            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].isYucho);
    }

    /**
     * getTaishoJidoList
     * Not Yucho
     * general
     */
    @isTest
    private static void getTaishoJidoList_NotYucho_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.KinyuKikanMei__c = 'TEST銀行';
            tj.KinyuKikanCode__c = '1234';
            tj.ShitenMei__c = 'TEST支店';
            tj.ShitenCode__c = '123';
            tj.TJ_Shumoku01__c = true;
            tj.TJ_Shumoku02__c = false;
            tj.TJ_Shumoku03__c = false;
            tj.KouzaBangou__c = '1234567';
            tj.KouzaMeigi__c = 'TOKYO HANAKO';
            tj.TaishoshaKubun__c = tk.Id;

            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isFalse(results[0].isYucho);
        Assert.areEqual('TEST銀行（1234）', results[0].KinyuKikan);
        Assert.areEqual('TEST支店（123）', results[0].Shiten);
    }

    /**
     * getTaishoJidoList
     * mousitate
     * general
     */
    @isTest
    private static void getTaishoJidoList_Mousitate_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk1 = ExTestUtil.getTaishoshaKubun();
        TaishoshaKubun__c tk2 = ExTestUtil.getTaishoshaKubun();
        tk2.IsMoushitate__c =false;
        insert new List<TaishoshaKubun__c>{tk1, tk2};

        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk1, sstList);
        kbssList.addAll(ExTestUtil.getKbssList(tk2, sstList));
        insert kbssList;

        TaishoJido__c tj1;
        TaishoJido__c tj2;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj1 = getTaishoJido(ns);
            tj1.TaishoshaKubun__c = tk1.Id;
            tj1.Moushitate_KokenninCheck__c = true;
            tj1.MoushitateCheck__c = false;
            tj1.KouzaJohoCheck__c = false;
            tj2 = getTaishoJido(ns);
            tj2.TaishoshaKubun__c = tk2.Id;
            tj2.Moushitate_KokenninCheck__c = true;
            tj2.KouzaJohoCheck__c = true;

            insert new List<TaishoJido__c>{tj1, tj2};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(2, results.size());

        Assert.isTrue(results[0].needMoushitate);
        Assert.isTrue(results[0].isNotMoushitateFinished);
        Assert.isTrue(results[0].needMoushitateFile);
        Assert.isTrue(results[0].isNotKozaJohoFinished);

        Assert.isFalse(results[1].needMoushitate);
        Assert.isFalse(results[1].isNotMoushitateFinished);
        Assert.isFalse(results[1].needMoushitateFile);
        Assert.isFalse(results[1].isNotKozaJohoFinished);
    }

    /**
     * getTaishoJidoList
     * 未申請
     * general
     */
    @isTest
    private static void getTaishoJidoList_Mishinsei_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj1;
        TaishoJido__c tj2;
        TaishoJido__c tj3;
        TaishoJido__c tj4;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.ShinsaStatus__c = '未申請';
            insert ns;

            tj1 = getTaishoJido(ns);
            tj1.ShinsaKekkaSaishu__c = '不備';
            tj1.HubiStatus__c = '不備連絡済み';
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJido(ns);
            tj2.ShinsaKekkaSaishu__c = 'OK';
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJido(ns);
            tj3.ShinsaKekkaSaishu__c = 'NG';
            tj3.TaishoshaKubun__c = tk.Id;
            tj4 = getTaishoJido(ns);
            tj4.ShinsaKekkaSaishu__c = '不備';
            tj4.HubiStatus__c = '不備未連絡';
            tj4.TaishoshaKubun__c = tk.Id;

            insert new List<TaishoJido__c>{tj1, tj2, tj3, tj4};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(4, results.size());

        Assert.isFalse(results[0].isDisabled);
        Assert.isFalse(results[0].isDeletable);
        Assert.isTrue(results[1].isDisabled);
        Assert.isFalse(results[1].isDeletable);
        Assert.isTrue(results[2].isDisabled);
        Assert.isFalse(results[2].isDeletable);
        Assert.isFalse(results[3].isDisabled);
        Assert.isTrue(results[3].isDeletable);
    }

    /**
     * getTaishoJidoList
     * 申請済
     * general
     */
    @isTest
    private static void getTaishoJidoList_ShinseiZumi_General() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj1;
        TaishoJido__c tj2;
        TaishoJido__c tj3;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.ShinsaStatus__c = '0次審査待ち';
            insert ns;

            tj1 = getTaishoJido(ns);
            tj1.ShinsaKekkaSaishu__c = '不備';
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJido(ns);
            tj2.ShinsaKekkaSaishu__c = 'OK';
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJido(ns);
            tj3.ShinsaKekkaSaishu__c = 'NG';
            tj3.TaishoshaKubun__c = tk.Id;

            insert new List<TaishoJido__c>{tj1, tj2, tj3};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(3, results.size());

        Assert.isTrue(results[0].isDisabled);
        Assert.isFalse(results[0].isDeletable);
        Assert.isTrue(results[1].isDisabled);
        Assert.isFalse(results[1].isDeletable);
        Assert.isTrue(results[2].isDisabled);
        Assert.isFalse(results[2].isDeletable);
    }

    /**
     * getTaishoJidoList
     * files empty
     * general
     */
    @isTest
    private static void getTaishoJidoList_FilesEmpty_General(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.UketoriKouzaKubun_Taishosha__c = true;
            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isTrue(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * kazokuKakuninShorui
     * general
     */
    @isTest
    private static void getTaishoJidoList_KazokuKakuninShorui_General(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isFalse(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * moushitateFile
     * general
     */
    @isTest
    private static void getTaishoJidoList_MoushitateFile_General(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].needMoushitate);
        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isFalse(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * kozaKakuninFile
     * general
     */
    @isTest
    private static void getTaishoJidoList_KozaKakuninFile_General(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.UketoriKouzaKubun_Taishosha__c = true;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isTrue(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * empty
     * dv
     */
    @isTest
    private static void getTaishoJidoList_IsEmpty_Dv() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            // 対象児童一覧が空だったときの動作確認
            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.isTrue(results.isEmpty());
    }

    /**
     * getTaishoJidoList
     * details
     * dv
     */
    @isTest
    private static void getTaishoJidoList_Details_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.Shimei__c = '東京　花子';
            tj.ShimeiFurigana__c = 'トウキョウ　ハナコ';
            tj.SeinenGappiDate__c = Date.newInstance(2020, 1, 1);
            tj.SeikyushaKubun_Dairinin__c = true;
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            tj.Moushitate_BetsuJushoCheck__c = true;
            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.areEqual(tj.Id, results[0].Id);
        Assert.areEqual(tk.Name, results[0].TaishoshaKubun);
        Assert.areEqual(tk.Id, results[0].TaishoshaKubunId);
        Assert.areEqual('東京　花子', results[0].Shimei);
        Assert.areEqual('トウキョウ　ハナコ', results[0].ShimeiFurigana);
        Assert.isTrue(results[0].IsDairinin);
        Assert.isTrue(results[0].IsKokennin);
        Assert.isTrue(results[0].IsBekkyo);
        Assert.isTrue(results[0].IsRyugaku);
        Assert.isTrue(results[0].IsRikon);
        Assert.isTrue(results[0].IsFuboSitei);
        Assert.isTrue(results[0].IsBetsuJusho);
    }

    /**
     * getTaishoJidoList
     * KouzaShubetsu
     * dv
     */
    @isTest
    private static void getTaishoJidoList_KouzaShubetsu_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;
        DV_TaishoJido__c tj3;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj1 = getTaishoJidoDv(ns);
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.UketoriKouzaKubun_Taishosha__c = false;
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJidoDv(ns);
            tj2.UketoriKouzaKubun_Seikyusha__c = false;
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJidoDv(ns);
            tj3.UketoriKouzaKubun_Seikyusha__c = false;
            tj3.UketoriKouzaKubun_Taishosha__c = false;
            tj3.TaishoshaKubun__c = tk.Id;

            insert new List<DV_TaishoJido__c>{tj1, tj2, tj3};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Map<String, String> labels = ExLwcUtil.getColumnLabels('DV_TaishoJido__c', new List<String>{'UketoriKouzaKubun_Seikyusha__c', 'UketoriKouzaKubun_Taishosha__c'});

        Assert.areEqual(3, results.size());

        Assert.isFalse(results[0].isSelectedTaishosha);
        Assert.isTrue(results[1].isSelectedTaishosha);
        Assert.isNull(results[2].isSelectedTaishosha);
    }

    /**
     * getTaishoJidoList
     * Yucho
     * dv
     */
    @isTest
    private static void getTaishoJidoList_Yucho_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.TJ_Yucho_Shumoku01__c = true;
            tj.TJ_Yucho_Shumoku02__c = false;
            tj.TJ_Yucho_Shumoku03__c = false;
            tj.TJ_Yucho_Shumoku04__c = false;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'TOKYO HANAKO';
            tj.TaishoshaKubun__c = tk.Id;

            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].isYucho);
    }

    /**
     * getTaishoJidoList
     * Not Yucho
     * dv
     */
    @isTest
    private static void getTaishoJidoList_NotYucho_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.KinyuKikanMei__c = 'TEST銀行';
            tj.KinyuKikanCode__c = '1234';
            tj.ShitenMei__c = 'TEST支店';
            tj.ShitenCode__c = '123';
            tj.TJ_Shumoku01__c = true;
            tj.TJ_Shumoku02__c = false;
            tj.TJ_Shumoku03__c = false;
            tj.KouzaBangou__c = '1234567';
            tj.KouzaMeigi__c = 'TOKYO HANAKO';
            tj.TaishoshaKubun__c = tk.Id;

            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isFalse(results[0].isYucho);
        Assert.areEqual('TEST銀行（1234）', results[0].KinyuKikan);
        Assert.areEqual('TEST支店（123）', results[0].Shiten);
    }

    /**
     * getTaishoJidoList
     * mousitate
     * dv
     */
    @isTest
    private static void getTaishoJidoList_Mousitate_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk1 = ExTestUtil.getTaishoshaKubun();
        TaishoshaKubun__c tk2 = ExTestUtil.getTaishoshaKubun();
        tk2.IsMoushitate__c =false;
        insert new List<TaishoshaKubun__c>{tk1, tk2};

        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk1, sstList);
        kbssList.addAll(ExTestUtil.getKbssList(tk2, sstList));
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj1 = getTaishoJidoDv(ns);
            tj1.TaishoshaKubun__c = tk1.Id;
            tj1.Moushitate_KokenninCheck__c = true;
            tj1.MoushitateCheck__c = false;
            tj1.KouzaJohoCheck__c = false;
            tj2 = getTaishoJidoDv(ns);
            tj2.TaishoshaKubun__c = tk2.Id;
            tj2.Moushitate_KokenninCheck__c = true;
            tj2.KouzaJohoCheck__c = true;

            insert new List<DV_TaishoJido__c>{tj1, tj2};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(2, results.size());

        Assert.isTrue(results[0].needMoushitate);
        Assert.isTrue(results[0].isNotMoushitateFinished);
        Assert.isTrue(results[0].needMoushitateFile);
        Assert.isTrue(results[0].isNotKozaJohoFinished);

        Assert.isFalse(results[1].needMoushitate);
        Assert.isFalse(results[1].isNotMoushitateFinished);
        Assert.isFalse(results[1].needMoushitateFile);
        Assert.isFalse(results[1].isNotKozaJohoFinished);
    }

    /**
     * getTaishoJidoList
     * 未申請
     * dv
     */
    @isTest
    private static void getTaishoJidoList_Mishinsei_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;
        DV_TaishoJido__c tj3;
        DV_TaishoJido__c tj4;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.ShinsaStatus__c = '未申請';
            insert ns;

            tj1 = getTaishoJidoDv(ns);
            tj1.ShinsaKekkaSaishu__c = '不備';
            tj1.HubiStatus__c = '不備連絡済み';
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJidoDv(ns);
            tj2.ShinsaKekkaSaishu__c = 'OK';
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJidoDv(ns);
            tj3.ShinsaKekkaSaishu__c = 'NG';
            tj3.TaishoshaKubun__c = tk.Id;
            tj4 = getTaishoJidoDv(ns);
            tj4.ShinsaKekkaSaishu__c = '不備';
            tj4.HubiStatus__c = '不備未連絡';
            tj4.TaishoshaKubun__c = tk.Id;

            insert new List<DV_TaishoJido__c>{tj1, tj2, tj3, tj4};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(4, results.size());

        Assert.isFalse(results[0].isDisabled);
        Assert.isFalse(results[0].isDeletable);
        Assert.isTrue(results[1].isDisabled);
        Assert.isFalse(results[1].isDeletable);
        Assert.isTrue(results[2].isDisabled);
        Assert.isFalse(results[2].isDeletable);
        Assert.isFalse(results[3].isDisabled);
        Assert.isTrue(results[3].isDeletable);
    }

    /**
     * getTaishoJidoList
     * 申請済
     * dv
     */
    @isTest
    private static void getTaishoJidoList_ShinseiZumi_Dv() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;
        DV_TaishoJido__c tj3;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.ShinsaStatus__c = '0次審査待ち';
            insert ns;

            tj1 = getTaishoJidoDv(ns);
            tj1.ShinsaKekkaSaishu__c = '不備';
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJidoDv(ns);
            tj2.ShinsaKekkaSaishu__c = 'OK';
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJidoDv(ns);
            tj3.ShinsaKekkaSaishu__c = 'NG';
            tj3.TaishoshaKubun__c = tk.Id;

            insert new List<DV_TaishoJido__c>{tj1, tj2, tj3};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(3, results.size());

        Assert.isTrue(results[0].isDisabled);
        Assert.isFalse(results[0].isDeletable);
        Assert.isTrue(results[1].isDisabled);
        Assert.isFalse(results[1].isDeletable);
        Assert.isTrue(results[2].isDisabled);
        Assert.isFalse(results[2].isDeletable);
    }

    /**
     * getTaishoJidoList
     * files empty
     * dv
     */
    @isTest
    private static void getTaishoJidoList_FilesEmpty_Dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.UketoriKouzaKubun_Taishosha__c = true;
            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isTrue(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * kazokuKakuninShorui
     * dv
     */
    @isTest
    private static void getTaishoJidoList_KazokuKakuninShorui_Dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isFalse(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * moushitateFile
     * dv
     */
    @isTest
    private static void getTaishoJidoList_MoushitateFile_Dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].needMoushitate);
        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isFalse(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * kozaKakuninFile
     * dv
     */
    @isTest
    private static void getTaishoJidoList_KozaKakuninFile_Dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.UketoriKouzaKubun_Taishosha__c = true;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isTrue(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * empty
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_IsEmpty_Satoya() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            // 対象児童一覧が空だったときの動作確認
            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.isTrue(results.isEmpty());
    }

    /**
     * getTaishoJidoList
     * details
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_Details_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.Shimei__c = '東京　花子';
            tj.ShimeiFurigana__c = 'トウキョウ　ハナコ';
            tj.SeinenGappiDate__c = Date.newInstance(2020, 1, 1);
            tj.SeikyushaKubun_Dairinin__c = true;
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.areEqual(tj.Id, results[0].Id);
        Assert.areEqual(tk.Name, results[0].TaishoshaKubun);
        Assert.areEqual(tk.Id, results[0].TaishoshaKubunId);
        Assert.areEqual('東京　花子', results[0].Shimei);
        Assert.areEqual('トウキョウ　ハナコ', results[0].ShimeiFurigana);
        Assert.isTrue(results[0].IsDairinin);
        Assert.isTrue(results[0].IsKokennin);
        Assert.isTrue(results[0].IsBekkyo);
        Assert.isTrue(results[0].IsRyugaku);
        Assert.isTrue(results[0].IsRikon);
        Assert.isTrue(results[0].IsFuboSitei);
    }

    /**
     * getTaishoJidoList
     * KouzaShubetsu
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_KouzaShubetsu_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;
        DV_TaishoJido__c tj3;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj1 = getTaishoJidoSatoya(ns);
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.UketoriKouzaKubun_Taishosha__c = false;
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJidoSatoya(ns);
            tj2.UketoriKouzaKubun_Seikyusha__c = false;
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJidoSatoya(ns);
            tj3.UketoriKouzaKubun_Seikyusha__c = false;
            tj3.UketoriKouzaKubun_Taishosha__c = false;
            tj3.TaishoshaKubun__c = tk.Id;

            insert new List<DV_TaishoJido__c>{tj1, tj2, tj3};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }


        Assert.areEqual(3, results.size());

        Assert.isFalse(results[0].isSelectedTaishosha);
        Assert.isTrue(results[1].isSelectedTaishosha);
        Assert.isNull(results[2].isSelectedTaishosha);
    }

    /**
     * getTaishoJidoList
     * Yucho
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_Yucho_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.TJ_Yucho_Shumoku01__c = true;
            tj.TJ_Yucho_Shumoku02__c = false;
            tj.TJ_Yucho_Shumoku03__c = false;
            tj.TJ_Yucho_Shumoku04__c = false;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'TOKYO HANAKO';
            tj.TaishoshaKubun__c = tk.Id;

            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].isYucho);
    }

    /**
     * getTaishoJidoList
     * Not Yucho
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_NotYucho_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.KinyuKikanMei__c = 'TEST銀行';
            tj.KinyuKikanCode__c = '1234';
            tj.ShitenMei__c = 'TEST支店';
            tj.ShitenCode__c = '123';
            tj.TJ_Shumoku01__c = true;
            tj.TJ_Shumoku02__c = false;
            tj.TJ_Shumoku03__c = false;
            tj.KouzaBangou__c = '1234567';
            tj.KouzaMeigi__c = 'TOKYO HANAKO';
            tj.TaishoshaKubun__c = tk.Id;

            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isFalse(results[0].isYucho);
        Assert.areEqual('TEST銀行（1234）', results[0].KinyuKikan);
        Assert.areEqual('TEST支店（123）', results[0].Shiten);
    }

    /**
     * getTaishoJidoList
     * mousitate
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_Mousitate_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk1 = ExTestUtil.getTaishoshaKubun();
        TaishoshaKubun__c tk2 = ExTestUtil.getTaishoshaKubun();
        tk2.IsMoushitate__c =false;
        insert new List<TaishoshaKubun__c>{tk1, tk2};

        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk1, sstList);
        kbssList.addAll(ExTestUtil.getKbssList(tk2, sstList));
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj1 = getTaishoJidoSatoya(ns);
            tj1.TaishoshaKubun__c = tk1.Id;
            tj1.Moushitate_KokenninCheck__c = true;
            tj1.MoushitateCheck__c = false;
            tj1.KouzaJohoCheck__c = false;
            tj2 = getTaishoJidoSatoya(ns);
            tj2.TaishoshaKubun__c = tk2.Id;
            tj2.Moushitate_KokenninCheck__c = true;
            tj2.KouzaJohoCheck__c = true;

            insert new List<DV_TaishoJido__c>{tj1, tj2};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(2, results.size());

        Assert.isTrue(results[0].needMoushitate);
        Assert.isTrue(results[0].isNotMoushitateFinished);
        Assert.isTrue(results[0].needMoushitateFile);
        Assert.isTrue(results[0].isNotKozaJohoFinished);

        Assert.isFalse(results[1].needMoushitate);
        Assert.isFalse(results[1].isNotMoushitateFinished);
        Assert.isFalse(results[1].needMoushitateFile);
        Assert.isFalse(results[1].isNotKozaJohoFinished);
    }

    /**
     * getTaishoJidoList
     * 未申請
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_Mishinsei_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;
        DV_TaishoJido__c tj3;
        DV_TaishoJido__c tj4;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.ShinsaStatus__c = '未申請';
            insert ns;

            tj1 = getTaishoJidoSatoya(ns);
            tj1.ShinsaKekkaSaishu__c = '不備';
            tj1.HubiStatus__c = '不備連絡済み';
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJidoSatoya(ns);
            tj2.ShinsaKekkaSaishu__c = 'OK';
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJidoSatoya(ns);
            tj3.ShinsaKekkaSaishu__c = 'NG';
            tj3.TaishoshaKubun__c = tk.Id;
            tj4 = getTaishoJidoSatoya(ns);
            tj4.ShinsaKekkaSaishu__c = '不備';
            tj4.HubiStatus__c = '不備未連絡';
            tj4.TaishoshaKubun__c = tk.Id;

            insert new List<DV_TaishoJido__c>{tj1, tj2, tj3, tj4};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(4, results.size());

        Assert.isFalse(results[0].isDisabled);
        Assert.isFalse(results[0].isDeletable);
        Assert.isTrue(results[1].isDisabled);
        Assert.isFalse(results[1].isDeletable);
        Assert.isTrue(results[2].isDisabled);
        Assert.isFalse(results[2].isDeletable);
        Assert.isFalse(results[3].isDisabled);
        Assert.isTrue(results[3].isDeletable);
    }

    /**
     * getTaishoJidoList
     * 申請済
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_ShinseiZumi_Satoya() {
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj1;
        DV_TaishoJido__c tj2;
        DV_TaishoJido__c tj3;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.ShinsaStatus__c = '0次審査待ち';
            insert ns;

            tj1 = getTaishoJidoSatoya(ns);
            tj1.ShinsaKekkaSaishu__c = '不備';
            tj1.TaishoshaKubun__c = tk.Id;
            tj2 = getTaishoJidoSatoya(ns);
            tj2.ShinsaKekkaSaishu__c = 'OK';
            tj2.TaishoshaKubun__c = tk.Id;
            tj3 = getTaishoJidoSatoya(ns);
            tj3.ShinsaKekkaSaishu__c = 'NG';
            tj3.TaishoshaKubun__c = tk.Id;

            insert new List<DV_TaishoJido__c>{tj1, tj2, tj3};

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(3, results.size());

        Assert.isTrue(results[0].isDisabled);
        Assert.isFalse(results[0].isDeletable);
        Assert.isTrue(results[1].isDisabled);
        Assert.isFalse(results[1].isDeletable);
        Assert.isTrue(results[2].isDisabled);
        Assert.isFalse(results[2].isDeletable);
    }

    /**
     * getTaishoJidoList
     * files empty
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_FilesEmpty_Satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.UketoriKouzaKubun_Taishosha__c = true;
            insert tj;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isTrue(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * kazokuKakuninShorui
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_KazokuKakuninShorui_Satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isFalse(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * moushitateFile
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_MoushitateFile_Satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.areEqual(1, results.size());

        Assert.isTrue(results[0].needMoushitate);
        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isFalse(results[0].needKozaKakuninFile);
    }

    /**
     * getTaishoJidoList
     * kozaKakuninFile
     * satoya
     */
    @isTest
    private static void getTaishoJidoList_KozaKakuninFile_Satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
        insert kbssList;

        DV_TaishoJido__c tj;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        List<ExTaishoJidoController.TaishoJidoWrapper> results;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            tj.UketoriKouzaKubun_Taishosha__c = true;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            Test.startTest();
            results = ExTaishoJidoController.getTaishoJidoList(ns.Id);
            Test.stopTest();
        }

        Assert.isFalse(results[0].needKazokuKakuninFile);
        Assert.isFalse(results[0].needMoushitateFile);
        Assert.isTrue(results[0].needKozaKakuninFile);
    }

    /**
     * deleteTaishoJido
     * general
     */
    @isTest
    private static void deleteTaishoJido_General(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Id cdId;
        TaishoJido__c tj;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;
            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

            Test.startTest();
            ExTaishoJidoController.deleteTaishoJido(ns.Id, tj.Id);
            Test.stopTest();
        }

        List<TaishoJido__c> tjs = [
            SELECT
                Id
            FROM
                TaishoJido__c
            WHERE
                Id = :tj.Id
        ];
        Assert.areEqual(0, tjs.size());

        List<ContentDocument> cds = [
            SELECT
                Id
            FROM
                ContentDocument
            WHERE
                Id = :cdId
        ];
        Assert.areEqual(0, cds.size());
    }


    /**
     * deleteTaishoJido
     * notStatusMishinsei
     * general
     */
    @isTest
    private static void deleteTaishoJido_NotStatusMishinsei_General(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Id cdId;
        TaishoJido__c tj;

        Boolean isException = false;
        System.runAs(u) {

            // テストデータ作成
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            ns.ShinsaStatus__c = '無効';
            insert ns;
            tj = getTaishoJido(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

            Test.startTest();
            try{
                ExTaishoJidoController.deleteTaishoJido(ns.Id, tj.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);

        List<TaishoJido__c> tjs = [
            SELECT
                Id
            FROM
                TaishoJido__c
            WHERE
                Id = :tj.Id
        ];
        Assert.areEqual(1, tjs.size());

        List<ContentDocument> cds = [
            SELECT
                Id
            FROM
                ContentDocument
            WHERE
                Id = :cdId
        ];
        Assert.areEqual(1, cds.size());
    }

    /**
     * deleteTaishoJido
     * dv
     */
    @isTest
    private static void deleteTaishoJido_Dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Id cdId;
        DV_TaishoJido__c tj;

        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;
            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

            Test.startTest();
            ExTaishoJidoController.deleteTaishoJido(ns.Id, tj.Id);
            Test.stopTest();
        }

        List<DV_TaishoJido__c> tjs = [
            SELECT
                Id
            FROM
                DV_TaishoJido__c
            WHERE
                Id = :tj.Id
        ];
        Assert.areEqual(0, tjs.size());

        List<ContentDocument> cds = [
            SELECT
                Id
            FROM
                ContentDocument
            WHERE
                Id = :cdId
        ];
        Assert.areEqual(0, cds.size());
    }


    /**
     * deleteTaishoJido
     * notStatusMishinsei
     * dv
     */
    @isTest
    private static void deleteTaishoJido_NotStatusMishinsei_Dv(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Id cdId;
        DV_TaishoJido__c tj;

        Boolean isException = false;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.ShinsaStatus__c = '無効';
            insert ns;
            tj = getTaishoJidoDv(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

            Test.startTest();
            try{
                ExTaishoJidoController.deleteTaishoJido(ns.Id, tj.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);

        List<DV_TaishoJido__c> tjs = [
            SELECT
                Id
            FROM
                DV_TaishoJido__c
            WHERE
                Id = :tj.Id
        ];
        Assert.areEqual(1, tjs.size());

        List<ContentDocument> cds = [
            SELECT
                Id
            FROM
                ContentDocument
            WHERE
                Id = :cdId
        ];
        Assert.areEqual(1, cds.size());
    }

    /**
     * deleteTaishoJido
     * 里親
     */
    @isTest
    private static void deleteTaishoJido_Satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Id cdId;
        DV_TaishoJido__c tj;

        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;
            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

            Test.startTest();
            ExTaishoJidoController.deleteTaishoJido(ns.Id, tj.Id);
            Test.stopTest();
        }

        List<DV_TaishoJido__c> tjs = [
            SELECT
                Id
            FROM
                DV_TaishoJido__c
            WHERE
                Id = :tj.Id
        ];
        Assert.areEqual(0, tjs.size());

        List<ContentDocument> cds = [
            SELECT
                Id
            FROM
                ContentDocument
            WHERE
                Id = :cdId
        ];
        Assert.areEqual(0, cds.size());
    }

    /**
     * deleteTaishoJido
     * notStatusMishinsei
     * 里親
     */
    @isTest
    private static void deleteTaishoJido_NotStatusMishinsei_Satoya(){
        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        TaishoshaKubun__c tk = ExTestUtil.getTaishoshaKubun();
        tk.IsMoushitate__c = false;
        insert tk;
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(1);
        insert sstList;

        Test.setMock(HttpCalloutMock.class, new MockAWSS3(false));

        Id cdId;
        DV_TaishoJido__c tj;

        Boolean isException = false;
        System.runAs(u) {

            // テストデータ作成
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            ns.ShinsaStatus__c = '無効';
            insert ns;
            tj = getTaishoJidoSatoya(ns);
            tj.TaishoshaKubun__c = tk.Id;
            insert tj;

            ContentVersion cv = ExTestUtil.getContentVersion(sstList[0], tj.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

            Test.startTest();
            try{
                ExTaishoJidoController.deleteTaishoJido(ns.Id, tj.Id);
            }catch(AuraHandledException e){
                isException = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(isException);

        List<DV_TaishoJido__c> tjs = [
            SELECT
                Id
            FROM
                DV_TaishoJido__c
            WHERE
                Id = :tj.Id
        ];
        Assert.areEqual(1, tjs.size());

        List<ContentDocument> cds = [
            SELECT
                Id
            FROM
                ContentDocument
            WHERE
                Id = :cdId
        ];
        Assert.areEqual(1, cds.size());
    }

    /**
     * 対象児童を取得
     */
    private static TaishoJido__c getTaishoJido(NinteiSeikyu__c ns) {
        return new TaishoJido__c(
            NinteiSeikyu__c = ns.Id
        );
    }

    /**
     * 対象児童（DV）を取得
     */
    private static DV_TaishoJido__c getTaishoJidoDv(DV_NinteiSeikyu__c ns) {
        return new DV_TaishoJido__c(
            NinteiSeikyu__c = ns.Id
            ,RecordTypeId = ExTestUtil.DV_JIDO_ID
        );
    }

    /**
     * 対象児童（里親）を取得
     */
    private static DV_TaishoJido__c getTaishoJidoSatoya(DV_NinteiSeikyu__c ns) {
        return new DV_TaishoJido__c(
            NinteiSeikyu__c = ns.Id
            ,RecordTypeId = ExTestUtil.SATOYA_JIDO_ID
        );
    }
}