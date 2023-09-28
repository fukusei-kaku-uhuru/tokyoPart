@isTest
private class ExTjKozaControllerTest {
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
     * 口座情報を取得
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
            tj.UketoriKouzaKubun_Taishosha__c = true;
            tj.TJ_Yucho_Shumoku01__c = true;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ';
            TJ.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            // 口座情報を取得
            Test.startTest();
            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            Test.stopTest();

            Assert.areEqual(kw.KOUZAKUBUN_TAISHOSHA, kw.UketoriKouzaKubun);
            Assert.isTrue(kw.TaishoshaSelectable);
            Assert.isTrue(kw.DairininSelectable);
            Assert.areEqual(kw.kfw.GINKOKUBUN_YUCHO, kw.kfw.GinkoKubun);
            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_SOGO, kw.kfw.YuchoBunrui);
            Assert.areEqual('12345', kw.kfw.YuchoKigo);
            Assert.areEqual('12345678', kw.kfw.YuchoBango);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', kw.kfw.YuchoKouzaMeigi);
            Assert.isNull(kw.kfw.KinyuKikan);
            Assert.isNull(kw.kfw.KinyuKikanDispName);
            Assert.isNull(kw.kfw.Shiten);
            Assert.isNull(kw.kfw.ShitenDispName);
            Assert.isNull(kw.kfw.Bunrui);
            Assert.isNull(kw.kfw.KouzaBangou);
            Assert.isNull(kw.kfw.KouzaMeigi);
        }
    }

    /**
     * カバーできてないパターンを通す1
     */
    @isTest
    private static void getKozaDataGeneral2() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.UketoriKouzaKubun_Taishosha__c = true;
            tj.TJ_Yucho_Shumoku02__c = true;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ';
            TJ.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            // 口座情報を取得
            Test.startTest();
            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_TSUJYO, kw.kfw.YuchoBunrui);

            tj.TJ_Yucho_Shumoku02__c = false;
            tj.TJ_Yucho_Shumoku03__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_TYOCHIKU, kw.kfw.YuchoBunrui);

            tj.TJ_Yucho_Shumoku03__c = false;
            tj.TJ_Yucho_Shumoku04__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_FURIKAE, kw.kfw.YuchoBunrui);
            Test.stopTest();
        }
    }

    /**
     * カバーできてないパターンを通す2
     */
    @isTest
    private static void getKozaDataGeneral3() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.UketoriKouzaKubun_Seikyusha__c = true;
            tj.KinyuKikan__c = kk.Id;
            tj.Shiten__c = stn.Id;
            tj.TJ_Shumoku01__c = true;
            tj.KouzaBangou__c = '1234567';
            tj.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ';
            insert tj;

            // 口座情報を取得
            Test.startTest();
            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.KOUZAKUBUN_DAIRININ, kw.UketoriKouzaKubun);
            Assert.areEqual(kw.kfw.GINKOKUBUN_OTHER, kw.kfw.GinkoKubun);
            Assert.isNull(kw.kfw.YuchoBunrui);
            Assert.isNull(kw.kfw.YuchoKigo);
            Assert.isNull(kw.kfw.YuchoBango);
            Assert.areEqual(kk.Id, kw.kfw.KinyuKikan);
            Assert.areEqual('XXX：テスト金融機関', kw.kfw.KinyuKikanDispName);
            Assert.areEqual(stn.Id, kw.kfw.Shiten);
            Assert.areEqual('XYZ：テスト支店', kw.kfw.ShitenDispName);
            Assert.areEqual(kw.kfw.SHUMOKU_FUTSU, kw.kfw.Bunrui);
            Assert.areEqual('1234567', kw.kfw.KouzaBangou);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', kw.kfw.KouzaMeigi);

            tj.TJ_Shumoku01__c = false;
            tj.TJ_Shumoku02__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);

            tj.TJ_Shumoku02__c = false;
            tj.TJ_Shumoku03__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);
            Test.stopTest();
        }
    }

    /**
     * 口座情報を取得
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
            tj.UketoriKouzaKubun_Taishosha__c = true;
            tj.TJ_Yucho_Shumoku01__c = true;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ';
            TJ.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            // 口座情報を取得
            Test.startTest();
            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            Test.stopTest();

            Assert.areEqual(kw.KOUZAKUBUN_TAISHOSHA, kw.UketoriKouzaKubun);
            Assert.isTrue(kw.TaishoshaSelectable);
            Assert.isTrue(kw.DairininSelectable);
            Assert.areEqual(kw.kfw.GINKOKUBUN_YUCHO, kw.kfw.GinkoKubun);
            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_SOGO, kw.kfw.YuchoBunrui);
            Assert.areEqual('12345', kw.kfw.YuchoKigo);
            Assert.areEqual('12345678', kw.kfw.YuchoBango);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', kw.kfw.YuchoKouzaMeigi);
            Assert.isNull(kw.kfw.KinyuKikan);
            Assert.isNull(kw.kfw.KinyuKikanDispName);
            Assert.isNull(kw.kfw.Shiten);
            Assert.isNull(kw.kfw.ShitenDispName);
            Assert.isNull(kw.kfw.Bunrui);
            Assert.isNull(kw.kfw.KouzaBangou);
            Assert.isNull(kw.kfw.KouzaMeigi);
        }
    }

    /**
     * カバーできてないパターンを通す1
     */
    @isTest
    private static void getKozaDataDv2() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.UketoriKouzaKubun_Taishosha__c = true;
            tj.TJ_Yucho_Shumoku02__c = true;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345678';
            tj.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ';
            TJ.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            // 口座情報を取得
            Test.startTest();
            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_TSUJYO, kw.kfw.YuchoBunrui);

            tj.TJ_Yucho_Shumoku02__c = false;
            tj.TJ_Yucho_Shumoku03__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_TYOCHIKU, kw.kfw.YuchoBunrui);

            tj.TJ_Yucho_Shumoku03__c = false;
            tj.TJ_Yucho_Shumoku04__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.kfw.YUCHO_SHUMOKU_FURIKAE, kw.kfw.YuchoBunrui);
            Test.stopTest();
        }
    }

    /**
     * カバーできてないパターンを通す2
     */
    @isTest
    private static void getKozaDataSatoya3() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            tj.UketoriKouzaKubun_Seikyusha__c = true;
            tj.KinyuKikan__c = kk.Id;
            tj.Shiten__c = stn.Id;
            tj.TJ_Shumoku01__c = true;
            tj.KouzaBangou__c = '1234567';
            tj.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ';
            insert tj;

            // 口座情報を取得
            Test.startTest();
            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);

            Assert.areEqual(kw.KOUZAKUBUN_DAIRININ, kw.UketoriKouzaKubun);
            Assert.areEqual(kw.kfw.GINKOKUBUN_OTHER, kw.kfw.GinkoKubun);
            Assert.isNull(kw.kfw.YuchoBunrui);
            Assert.isNull(kw.kfw.YuchoKigo);
            Assert.isNull(kw.kfw.YuchoBango);
            Assert.areEqual(kk.Id, kw.kfw.KinyuKikan);
            Assert.areEqual('XXX：テスト金融機関', kw.kfw.KinyuKikanDispName);
            Assert.areEqual(stn.Id, kw.kfw.Shiten);
            Assert.areEqual('XYZ：テスト支店', kw.kfw.ShitenDispName);
            Assert.areEqual(kw.kfw.SHUMOKU_FUTSU, kw.kfw.Bunrui);
            Assert.areEqual('1234567', kw.kfw.KouzaBangou);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', kw.kfw.KouzaMeigi);

            tj.TJ_Shumoku01__c = false;
            tj.TJ_Shumoku02__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);

            tj.TJ_Shumoku02__c = false;
            tj.TJ_Shumoku03__c = true;
            update tj;

            kw = ExTjKozaController.getKozaData(tj.Id);
            Test.stopTest();
        }
    }

    /**
     * ゆうちょ口座名義が空白
     */
    @isTest
    private static void updateKozaDataError1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_TAISHOSHA;
            kw.kfw.GinkoKubun = kw.kfw.GINKOKUBUN_YUCHO;
            kw.kfw.YuchoBunrui = kw.kfw.YUCHO_SHUMOKU_TSUJYO;
            kw.kfw.YuchoKigo = '12345';
            kw.kfw.YuchoBango = '12345678';
            kw.kfw.YuchoKouzaMeigi = ' ';

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.areEqual(1, results.size());
            Assert.areEqual('YuchoKouzaMeigi', results[0].field);
        }
    }

    /**
     * 口座名義が空白
     */
    @isTest
    private static void updateKozaDataError2() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_TAISHOSHA;
            kw.kfw.GinkoKubun = kw.kfw.GINKOKUBUN_OTHER;
            kw.kfw.KinyuKikan = kk.Id;
            kw.kfw.Shiten = stn.Id;
            kw.kfw.Bunrui = kw.kfw.SHUMOKU_FUTSU;
            kw.kfw.KouzaBangou = '1234567';
            kw.kfw.KouzaMeigi = ' ';

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.areEqual(1, results.size());
            Assert.areEqual('KouzaMeigi', results[0].field);
        }
    }

    /**
     * 口座情報を更新 認定請求者
     */
    @isTest
    private static void updateKozaDataGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_DAIRININ;

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.isNull(results);

            TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,UketoriKouzaKubun_Seikyusha__c
                    ,UketoriKouzaKubun_Taishosha__c
                    ,TJ_Yucho_Shumoku01__c
                    ,TJ_Yucho_Shumoku02__c
                    ,TJ_Yucho_Shumoku03__c
                    ,TJ_Yucho_Shumoku04__c
                    ,YuchoKigo__c
                    ,YuchoBango__c
                    ,YuchoKouzaMeigi__c
                    ,KinyuKikan__c
                    ,KinyuKikanMei__c
                    ,KinyuKikanCode__c
                    ,Shiten__c
                    ,ShitenCode__c
                    ,ShitenMei__c
                    ,TJ_Shumoku01__c
                    ,TJ_Shumoku02__c
                    ,TJ_Shumoku03__c
                    ,KouzaBangou__c
                    ,KouzaMeigi__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isTrue(resultTj.UketoriKouzaKubun_Seikyusha__c);
            Assert.isFalse(resultTj.UketoriKouzaKubun_Taishosha__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            Assert.isNull(resultTj.YuchoKigo__c);
            Assert.isNull(resultTj.YuchoBango__c);
            Assert.isNull(resultTj.YuchoKouzaMeigi__c);
            Assert.isNull(resultTj.KinyuKikan__c);
            Assert.isNull(resultTj.KinyuKikanMei__c);
            Assert.isNull(resultTj.KinyuKikanCode__c);
            Assert.isNull(resultTj.Shiten__c);
            Assert.isNull(resultTj.ShitenCode__c);
            Assert.isNull(resultTj.ShitenMei__c);
            Assert.isFalse(resultTj.TJ_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Shumoku03__c);
            Assert.isNull(resultTj.KouzaBangou__c);
            Assert.isNull(resultTj.KouzaMeigi__c);
        }
    }

    /**
     * 口座情報を更新 対象者/ゆうちょ
     */
    @isTest
    private static void updateKozaDataGeneral2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_TAISHOSHA;
            kw.kfw.GinkoKubun = kw.kfw.GINKOKUBUN_YUCHO;
            kw.kfw.YuchoBunrui = kw.kfw.YUCHO_SHUMOKU_TSUJYO;
            kw.kfw.YuchoKigo = '12345';
            kw.kfw.YuchoBango = '12345678';
            kw.kfw.YuchoKouzaMeigi = 'ﾀｲｼﾖｳｼﾔ';

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.isNull(results);

            TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,UketoriKouzaKubun_Seikyusha__c
                    ,UketoriKouzaKubun_Taishosha__c
                    ,TJ_Yucho_Shumoku01__c
                    ,TJ_Yucho_Shumoku02__c
                    ,TJ_Yucho_Shumoku03__c
                    ,TJ_Yucho_Shumoku04__c
                    ,YuchoKigo__c
                    ,YuchoBango__c
                    ,YuchoKouzaMeigi__c
                    ,KinyuKikan__c
                    ,KinyuKikanMei__c
                    ,KinyuKikanCode__c
                    ,Shiten__c
                    ,ShitenCode__c
                    ,ShitenMei__c
                    ,TJ_Shumoku01__c
                    ,TJ_Shumoku02__c
                    ,TJ_Shumoku03__c
                    ,KouzaBangou__c
                    ,KouzaMeigi__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.UketoriKouzaKubun_Seikyusha__c);
            Assert.isTrue(resultTj.UketoriKouzaKubun_Taishosha__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            Assert.isTrue(resultTj.TJ_Yucho_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            Assert.areEqual('12345', resultTj.YuchoKigo__c);
            Assert.areEqual('12345678', resultTj.YuchoBango__c);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', resultTj.YuchoKouzaMeigi__c);
            Assert.isNull(resultTj.KinyuKikan__c);
            Assert.isNull(resultTj.KinyuKikanMei__c);
            Assert.isNull(resultTj.KinyuKikanCode__c);
            Assert.isNull(resultTj.Shiten__c);
            Assert.isNull(resultTj.ShitenCode__c);
            Assert.isNull(resultTj.ShitenMei__c);
            Assert.isFalse(resultTj.TJ_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Shumoku03__c);
            Assert.isNull(resultTj.KouzaBangou__c);
            Assert.isNull(resultTj.KouzaMeigi__c);
        }
    }

/**
     * 口座情報を更新 対象者/その他
     */
    @isTest
    private static void updateKozaDataGeneral3() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_TAISHOSHA;
            kw.kfw.GinkoKubun = kw.kfw.GINKOKUBUN_OTHER;
            kw.kfw.KinyuKikan = kk.Id;
            kw.kfw.Shiten = stn.Id;
            kw.kfw.Bunrui = kw.kfw.SHUMOKU_FUTSU;
            kw.kfw.KouzaBangou = '1234567';
            kw.kfw.KouzaMeigi = 'ﾀｲｼﾖｳｼﾔ';

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.isNull(results);

            TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,UketoriKouzaKubun_Seikyusha__c
                    ,UketoriKouzaKubun_Taishosha__c
                    ,TJ_Yucho_Shumoku01__c
                    ,TJ_Yucho_Shumoku02__c
                    ,TJ_Yucho_Shumoku03__c
                    ,TJ_Yucho_Shumoku04__c
                    ,YuchoKigo__c
                    ,YuchoBango__c
                    ,YuchoKouzaMeigi__c
                    ,KinyuKikan__c
                    ,KinyuKikanMei__c
                    ,KinyuKikanCode__c
                    ,Shiten__c
                    ,ShitenCode__c
                    ,ShitenMei__c
                    ,TJ_Shumoku01__c
                    ,TJ_Shumoku02__c
                    ,TJ_Shumoku03__c
                    ,KouzaBangou__c
                    ,KouzaMeigi__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.UketoriKouzaKubun_Seikyusha__c);
            Assert.isTrue(resultTj.UketoriKouzaKubun_Taishosha__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            Assert.isNull(resultTj.YuchoKigo__c);
            Assert.isNull(resultTj.YuchoBango__c);
            Assert.isNull(resultTj.YuchoKouzaMeigi__c);
            Assert.areEqual(kk.Id, resultTj.KinyuKikan__c);
            Assert.areEqual('テスト金融機関', resultTj.KinyuKikanMei__c);
            Assert.areEqual('XXX', resultTj.KinyuKikanCode__c);
            Assert.areEqual(stn.Id, resultTj.Shiten__c);
            Assert.areEqual('テスト支店', resultTj.ShitenMei__c);
            Assert.areEqual('XYZ', resultTj.ShitenCode__c);
            Assert.isTrue(resultTj.TJ_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Shumoku03__c);
            Assert.areEqual('1234567', resultTj.KouzaBangou__c);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', resultTj.KouzaMeigi__c);
        }
    }

    /**
     * 口座情報を更新 認定請求者
     */
    @isTest
    private static void updateKozaDataDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_DAIRININ;

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.isNull(results);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,UketoriKouzaKubun_Seikyusha__c
                    ,UketoriKouzaKubun_Taishosha__c
                    ,TJ_Yucho_Shumoku01__c
                    ,TJ_Yucho_Shumoku02__c
                    ,TJ_Yucho_Shumoku03__c
                    ,TJ_Yucho_Shumoku04__c
                    ,YuchoKigo__c
                    ,YuchoBango__c
                    ,YuchoKouzaMeigi__c
                    ,KinyuKikan__c
                    ,KinyuKikanMei__c
                    ,KinyuKikanCode__c
                    ,Shiten__c
                    ,ShitenCode__c
                    ,ShitenMei__c
                    ,TJ_Shumoku01__c
                    ,TJ_Shumoku02__c
                    ,TJ_Shumoku03__c
                    ,KouzaBangou__c
                    ,KouzaMeigi__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isTrue(resultTj.UketoriKouzaKubun_Seikyusha__c);
            Assert.isFalse(resultTj.UketoriKouzaKubun_Taishosha__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            Assert.isNull(resultTj.YuchoKigo__c);
            Assert.isNull(resultTj.YuchoBango__c);
            Assert.isNull(resultTj.YuchoKouzaMeigi__c);
            Assert.isNull(resultTj.KinyuKikan__c);
            Assert.isNull(resultTj.KinyuKikanMei__c);
            Assert.isNull(resultTj.KinyuKikanCode__c);
            Assert.isNull(resultTj.Shiten__c);
            Assert.isNull(resultTj.ShitenCode__c);
            Assert.isNull(resultTj.ShitenMei__c);
            Assert.isFalse(resultTj.TJ_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Shumoku03__c);
            Assert.isNull(resultTj.KouzaBangou__c);
            Assert.isNull(resultTj.KouzaMeigi__c);
        }
    }

    /**
     * 口座情報を更新 対象者/ゆうちょ
     */
    @isTest
    private static void updateKozaDataSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_TAISHOSHA;
            kw.kfw.GinkoKubun = kw.kfw.GINKOKUBUN_YUCHO;
            kw.kfw.YuchoBunrui = kw.kfw.YUCHO_SHUMOKU_TSUJYO;
            kw.kfw.YuchoKigo = '12345';
            kw.kfw.YuchoBango = '12345678';
            kw.kfw.YuchoKouzaMeigi = 'ﾀｲｼﾖｳｼﾔ';

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.isNull(results);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,UketoriKouzaKubun_Seikyusha__c
                    ,UketoriKouzaKubun_Taishosha__c
                    ,TJ_Yucho_Shumoku01__c
                    ,TJ_Yucho_Shumoku02__c
                    ,TJ_Yucho_Shumoku03__c
                    ,TJ_Yucho_Shumoku04__c
                    ,YuchoKigo__c
                    ,YuchoBango__c
                    ,YuchoKouzaMeigi__c
                    ,KinyuKikan__c
                    ,KinyuKikanMei__c
                    ,KinyuKikanCode__c
                    ,Shiten__c
                    ,ShitenCode__c
                    ,ShitenMei__c
                    ,TJ_Shumoku01__c
                    ,TJ_Shumoku02__c
                    ,TJ_Shumoku03__c
                    ,KouzaBangou__c
                    ,KouzaMeigi__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.UketoriKouzaKubun_Seikyusha__c);
            Assert.isTrue(resultTj.UketoriKouzaKubun_Taishosha__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            Assert.isTrue(resultTj.TJ_Yucho_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            Assert.areEqual('12345', resultTj.YuchoKigo__c);
            Assert.areEqual('12345678', resultTj.YuchoBango__c);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', resultTj.YuchoKouzaMeigi__c);
            Assert.isNull(resultTj.KinyuKikan__c);
            Assert.isNull(resultTj.KinyuKikanMei__c);
            Assert.isNull(resultTj.KinyuKikanCode__c);
            Assert.isNull(resultTj.Shiten__c);
            Assert.isNull(resultTj.ShitenCode__c);
            Assert.isNull(resultTj.ShitenMei__c);
            Assert.isFalse(resultTj.TJ_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Shumoku03__c);
            Assert.isNull(resultTj.KouzaBangou__c);
            Assert.isNull(resultTj.KouzaMeigi__c);
        }
    }

/**
     * 口座情報を更新 対象者/その他
     */
    @isTest
    private static void updateKozaDataSatoya2() {

        KinyuKikan__c kk = new KinyuKikan__c(
            Name = 'テスト金融機関'
            ,KinyuKikanCode__c = 'XXX'
        );
        insert kk;

        Shiten__c stn = new Shiten__c(
            Name = 'テスト支店'
            ,TempoCode__c = 'XYZ'
            ,KinyuKikan__c = kk.Id
        );
        insert stn;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            insert tj;

            ExTjKozaController.KozaWrapper kw = ExTjKozaController.getKozaData(tj.Id);
            kw.UketoriKouzaKubun = kw.KOUZAKUBUN_TAISHOSHA;
            kw.kfw.GinkoKubun = kw.kfw.GINKOKUBUN_OTHER;
            kw.kfw.KinyuKikan = kk.Id;
            kw.kfw.Shiten = stn.Id;
            kw.kfw.Bunrui = kw.kfw.SHUMOKU_FUTSU;
            kw.kfw.KouzaBangou = '1234567';
            kw.kfw.KouzaMeigi = 'ﾀｲｼﾖｳｼﾔ';

            // 口座名義の形式が不正
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjKozaController.updateKozaData(kw);
            Test.stopTest();

            Assert.isNull(results);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,UketoriKouzaKubun_Seikyusha__c
                    ,UketoriKouzaKubun_Taishosha__c
                    ,TJ_Yucho_Shumoku01__c
                    ,TJ_Yucho_Shumoku02__c
                    ,TJ_Yucho_Shumoku03__c
                    ,TJ_Yucho_Shumoku04__c
                    ,YuchoKigo__c
                    ,YuchoBango__c
                    ,YuchoKouzaMeigi__c
                    ,KinyuKikan__c
                    ,KinyuKikanMei__c
                    ,KinyuKikanCode__c
                    ,Shiten__c
                    ,ShitenCode__c
                    ,ShitenMei__c
                    ,TJ_Shumoku01__c
                    ,TJ_Shumoku02__c
                    ,TJ_Shumoku03__c
                    ,KouzaBangou__c
                    ,KouzaMeigi__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.UketoriKouzaKubun_Seikyusha__c);
            Assert.isTrue(resultTj.UketoriKouzaKubun_Taishosha__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            Assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            Assert.isNull(resultTj.YuchoKigo__c);
            Assert.isNull(resultTj.YuchoBango__c);
            Assert.isNull(resultTj.YuchoKouzaMeigi__c);
            Assert.areEqual(kk.Id, resultTj.KinyuKikan__c);
            Assert.areEqual('テスト金融機関', resultTj.KinyuKikanMei__c);
            Assert.areEqual('XXX', resultTj.KinyuKikanCode__c);
            Assert.areEqual(stn.Id, resultTj.Shiten__c);
            Assert.areEqual('テスト支店', resultTj.ShitenMei__c);
            Assert.areEqual('XYZ', resultTj.ShitenCode__c);
            Assert.isTrue(resultTj.TJ_Shumoku01__c);
            Assert.isFalse(resultTj.TJ_Shumoku02__c);
            Assert.isFalse(resultTj.TJ_Shumoku03__c);
            Assert.areEqual('1234567', resultTj.KouzaBangou__c);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ', resultTj.KouzaMeigi__c);
        }
    }
}