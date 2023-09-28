@isTest
public class ExTaishoJidoNyuryokuControllerTest {
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

        insert getTaishoshaKubuns(3);
        insert ExTestUtil.getSstKozaKakunin();
    }

    private static List<TaishoshaKubun__c> getTaishoshaKubuns(Integer count) {
        List<TaishoshaKubun__c> tkList = new List<TaishoshaKubun__c>();
        for (Integer i = 0; i < count; i++) {
            tkList.add(new TaishoshaKubun__c(
                Name = 'A' + i
                ,KyufuKahi__c = true
                ,Meigi_Taishosha__c = true
                ,Meigi_Dairinin__c = true
                ,IsMoushitate__c = true
            ));
        }
        return tkList;
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
            ,TennyuShusseiDateSonota__c = '2回目：2021/01/15'
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2020, 2, 1)
            ,TenshutsuDateSonota__c = '2回目：2021/02/01'
            ,NinteiSeikyu__c = ns.Id
            ,SeikyushaKubun_Taishosha__c = true
            ,IsKokuseki_Nihon__c = true
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
            ,TennyuShusseiDateSonota__c = '2回目：2021/01/15'
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2020, 2, 1)
            ,TenshutsuDateSonota__c = '2回目：2021/02/01'
            ,NinteiSeikyu__c = ns.Id
            ,SeikyushaKubun_Taishosha__c = true
            ,IsKokuseki_Nihon__c = true
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
            ,TennyuShusseiDateSonota__c = '2回目：2021/01/15'
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2020, 2, 1)
            ,TenshutsuDateSonota__c = '2回目：2021/02/01'
            ,NinteiSeikyu__c = ns.Id
            ,SeikyushaKubun_Taishosha__c = true
            ,IsKokuseki_Nihon__c = true
            ,TaishoShinkiSochi__c = 'はい'
            ,Shisetsu_TaishoBiko__c = '備考'
        );
    }



    /**
     * 新規登録
     */
    @isTest
    private static void getTaishoJidoData1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            // 空のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, '');
            Test.stopTest();

            // 空のデータが帰ってきている
            Assert.isNull(tjnw.taishoJidoData.Id);
            Assert.isNull(tjnw.taishoJidoData.Shimei);
        }
    }

    /**
     * 登録済
     */
    @isTest
    private static void getTaishoJidoDataGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            // 登録済のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            Test.stopTest();

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tj.Id, tjnw.taishoJidoData.Id);
            Assert.areEqual(tk.Id, tjnw.taishoJidoData.TaishoshaKubun);
            Assert.areEqual('対象者', tjnw.taishoJidoData.Shimei);
            Assert.areEqual('タイショウシャ', tjnw.taishoJidoData.ShimeiFurigana);
            Assert.areEqual(date.newInstance(2020, 1, 1), tjnw.taishoJidoData.SeinenGappiDate);
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_DOUKYO, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.isNull(tjnw.taishoJidoData.YubinBangou);
            Assert.isNull(tjnw.taishoJidoData.Jusho);
            Assert.areEqual(tjnw.taishoJidoData.KOKUSEKI_JAPAN, tjnw.taishoJidoData.Kokuseki);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_CHICHI, tjnw.taishoJidoData.SeikyushaTsudukigara);
            Assert.isNull(tjnw.taishoJidoData.SonotaShousai);
            Assert.areEqual(true, tjnw.taishoJidoData.IsTochuTennyuShussei);
            Assert.areEqual(date.newInstance(2020, 1, 15), tjnw.taishoJidoData.TennyuShusseiDate);
            Assert.areEqual('2回目：2021/01/15', tjnw.taishoJidoData.TennyuShusseiDateSonota);
            Assert.areEqual(true, tjnw.taishoJidoData.IsTochuTenshutsu);
            Assert.areEqual(date.newInstance(2020, 2, 1), tjnw.taishoJidoData.TenshutsuDate);
            Assert.areEqual('2回目：2021/02/01', tjnw.taishoJidoData.TenshutsuDateSonota);
            Assert.areEqual(false, tjnw.taishoJidoData.Fukumu18);
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_TAISHOSHA, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.isNull(tjnw.taishoJidoData.KonnendochuShinkiSochi);
            Assert.isNull(tjnw.taishoJidoData.Biko);
            Assert.areEqual(false, tjnw.taishoJidoData.isDisabled);
        }
    }

    /**
     * 登録済 カバーできていない項目取得パターンのカバー
     */
    @isTest
    private static void getTaishoJidoDataGeneral2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = true;
            tj.YubinBangou__c = '000-0000';
            tj.Jusho__c = 'テスト県テスト市テスト町0-0-0';
            tj.IsKokuseki_Nihon__c = false;
            tj.IsKokuseki_NihonIgai__c = true;
            tj.SeikyushaTsudukigara_Chichi__c = false;
            tj.SeikyushaTsudukigara_Haha__c = true;
            tj.SeikyushaKubun_Taishosha__c = false;
            tj.SeikyushaKubun_Dairinin__c = true;
            tj.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            // 登録済のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_BEKKYO, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.areEqual('000-0000', tjnw.taishoJidoData.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町0-0-0', tjnw.taishoJidoData.Jusho);
            Assert.areEqual(tjnw.taishoJidoData.KOKUSEKI_OTHER, tjnw.taishoJidoData.Kokuseki);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_HAHA, tjnw.taishoJidoData.SeikyushaTsudukigara);
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_DAIRININ, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.areEqual(true, tjnw.taishoJidoData.isDisabled);

            tj.SeikyushaKubun_Dairinin__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj.SeikyushaTsudukigara_Haha__c = false;
            tj.SeikyushaTsudukigara_Sonota__c = true;
            update tj;

            // 登録済のIdを渡す
            tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_18UNDER, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_HONNIN, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_SONOTA, tjnw.taishoJidoData.SeikyushaTsudukigara);

            Test.stopTest();
        }
    }

    /**
     * 登録済
     */
    @isTest
    private static void getTaishoJidoDataDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            // 登録済のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            Test.stopTest();

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tj.Id, tjnw.taishoJidoData.Id);
            Assert.areEqual(tk.Id, tjnw.taishoJidoData.TaishoshaKubun);
            Assert.areEqual('対象者', tjnw.taishoJidoData.Shimei);
            Assert.areEqual('タイショウシャ', tjnw.taishoJidoData.ShimeiFurigana);
            Assert.areEqual(date.newInstance(2020, 1, 1), tjnw.taishoJidoData.SeinenGappiDate);
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_DOUKYO, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.isNull(tjnw.taishoJidoData.YubinBangou);
            Assert.isNull(tjnw.taishoJidoData.Jusho);
            Assert.areEqual(tjnw.taishoJidoData.KOKUSEKI_JAPAN, tjnw.taishoJidoData.Kokuseki);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_CHICHI, tjnw.taishoJidoData.SeikyushaTsudukigara);
            Assert.isNull(tjnw.taishoJidoData.SonotaShousai);
            Assert.areEqual(true, tjnw.taishoJidoData.IsTochuTennyuShussei);
            Assert.areEqual(date.newInstance(2020, 1, 15), tjnw.taishoJidoData.TennyuShusseiDate);
            Assert.areEqual('2回目：2021/01/15', tjnw.taishoJidoData.TennyuShusseiDateSonota);
            Assert.areEqual(true, tjnw.taishoJidoData.IsTochuTenshutsu);
            Assert.areEqual(date.newInstance(2020, 2, 1), tjnw.taishoJidoData.TenshutsuDate);
            Assert.areEqual('2回目：2021/02/01', tjnw.taishoJidoData.TenshutsuDateSonota);
            Assert.areEqual(false, tjnw.taishoJidoData.Fukumu18);
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_TAISHOSHA, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.isNull(tjnw.taishoJidoData.KonnendochuShinkiSochi);
            Assert.isNull(tjnw.taishoJidoData.Biko);
            Assert.areEqual(false, tjnw.taishoJidoData.isDisabled);
        }
    }

    /**
     * 登録済 カバーできていない項目取得パターンのカバー
     */
    @isTest
    private static void getTaishoJidoDataDv2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = true;
            tj.YubinBangou__c = '000-0000';
            tj.Jusho__c = 'テスト県テスト市テスト町0-0-0';
            tj.IsKokuseki_Nihon__c = false;
            tj.IsKokuseki_NihonIgai__c = true;
            tj.SeikyushaTsudukigara_Chichi__c = false;
            tj.SeikyushaTsudukigara_Haha__c = true;
            tj.SeikyushaKubun_Taishosha__c = false;
            tj.SeikyushaKubun_Dairinin__c = true;
            tj.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            // 登録済のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_BEKKYO, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.areEqual('000-0000', tjnw.taishoJidoData.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町0-0-0', tjnw.taishoJidoData.Jusho);
            Assert.areEqual(tjnw.taishoJidoData.KOKUSEKI_OTHER, tjnw.taishoJidoData.Kokuseki);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_HAHA, tjnw.taishoJidoData.SeikyushaTsudukigara);
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_DAIRININ, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.areEqual(true, tjnw.taishoJidoData.isDisabled);

            tj.SeikyushaKubun_Dairinin__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj.SeikyushaTsudukigara_Haha__c = false;
            tj.SeikyushaTsudukigara_Sonota__c = true;
            update tj;

            // 登録済のIdを渡す
            tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_18UNDER, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_HONNIN, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_SONOTA, tjnw.taishoJidoData.SeikyushaTsudukigara);

            Test.stopTest();
        }
    }

    /**
     * 登録済 里親
     */
    @isTest
    private static void getTaishoJidoDataSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            insert tj;

            // 登録済のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            Test.stopTest();

            // 各項目に想定していた値がセットされている
            Assert.areEqual(tj.Id, tjnw.taishoJidoData.Id);
            Assert.areEqual(tk.Id, tjnw.taishoJidoData.TaishoshaKubun);
            Assert.areEqual('対象者', tjnw.taishoJidoData.Shimei);
            Assert.areEqual('タイショウシャ', tjnw.taishoJidoData.ShimeiFurigana);
            Assert.areEqual(date.newInstance(2020, 1, 1), tjnw.taishoJidoData.SeinenGappiDate);
            Assert.areEqual(tjnw.taishoJidoData.DOUKYOSHUBETSU_DOUKYO, tjnw.taishoJidoData.SeikyushaDoukyoShubetsu);
            Assert.isNull(tjnw.taishoJidoData.YubinBangou);
            Assert.isNull(tjnw.taishoJidoData.Jusho);
            Assert.areEqual(tjnw.taishoJidoData.TSUDUKIGARA_CHICHI, tjnw.taishoJidoData.SeikyushaTsudukigara);
            Assert.isNull(tjnw.taishoJidoData.SonotaShousai);
            Assert.areEqual(true, tjnw.taishoJidoData.IsTochuTennyuShussei);
            Assert.areEqual(date.newInstance(2020, 1, 15), tjnw.taishoJidoData.TennyuShusseiDate);
            Assert.areEqual(true, tjnw.taishoJidoData.IsTochuTenshutsu);
            Assert.areEqual(date.newInstance(2020, 2, 1), tjnw.taishoJidoData.TenshutsuDate);
            Assert.areEqual(false, tjnw.taishoJidoData.Fukumu18);
            Assert.areEqual(tjnw.taishoJidoData.SEIKYUSHA_TAISHOSHA, tjnw.taishoJidoData.SeikyushaKubun);
            Assert.areEqual('はい', tjnw.taishoJidoData.KonnendochuShinkiSochi);
            Assert.areEqual('備考', tjnw.taishoJidoData.Biko);
            Assert.areEqual(false, tjnw.taishoJidoData.isDisabled);
        }
    }

    /**
     * 新規 里親
     */
    @isTest
    private static void getTaishoJidoDataSatoya2() {

        TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];
        tk.Name = 'C-1';
        update tk;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            // 空のIdを渡す
            Test.startTest();
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, '');
            Test.stopTest();

            // 対象者区分のみセットされている
            Assert.isNull(tjnw.taishoJidoData.Id);
            Assert.isNull(tjnw.taishoJidoData.Shimei);
            Assert.areEqual(tjnw.taishoJidoData.TaishoshaKubun, tk.Id);
            Assert.areEqual(tjnw.taishoJidoData.TaishoshaKubunName, 'C-1');
        }
    }

    /**
     * 給付可否取得処理
     */
    @isTest
    private static void isKyufuKahi1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Test.startTest();
            Boolean isKyufuKahi = ExTaishoJidoNyuryokuController.isKyufuKahi(tk.Id);
            Test.stopTest();

            Assert.areEqual(true, isKyufuKahi);
        }
    }

    /**
     * エラー
     */
    @isTest
    private static void upsertTaishoJidoError1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Shimei = ' ';
            tjw.ShimeiFurigana = '　';
            tjw.SeinenGappiDate = Date.today().addDays(1);
            tjw.Kokuseki = tjw.KOKUSEKI_JAPAN;
            tjw.SeikyushaDoukyoShubetsu = tjw.DOUKYOSHUBETSU_BEKKYO;
            tjw.Jusho = '  ';
            tjw.SeikyushaTsudukigara = tjw.TSUDUKIGARA_SONOTA;
            tjw.SonotaShousai = '　　';

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNull(rw.taishoJidoId);
            Assert.areEqual(5, rw.errorLog.size());
            Assert.areEqual('Shimei', rw.errorLog[0].field);
            Assert.areEqual('ShimeiFurigana', rw.errorLog[1].field);
            Assert.areEqual('SeinenGappiDate', rw.errorLog[2].field);
            Assert.areEqual('jusho', rw.errorLog[3].field);
            Assert.areEqual('SonotaShousai', rw.errorLog[4].field);
        }
    }

    /**
     * 重複チェックにてエラー
     */
    @isTest
    private static void upsertTaishoJidoGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Id = null;

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNull(rw.taishoJidoId);
            Assert.areEqual(1, rw.errorLog.size());
            Assert.areEqual('Shimei', rw.errorLog[0].field);
            Assert.areEqual('名前、生年月日が一致している対象児童が既に登録されています', rw.errorLog[0].message);
        }
    }

    /**
     * 上限チェックにてエラー
     */
    @isTest
    private static void upsertTaishoJidoGeneral2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>();
            for (Integer i = 0; i < Limit__mdt.getInstance('TaishoJido').Value__c; i++) {
                tjList.add(getTaishoJido(ns, tk));
            }
            insert tjList;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tjList[0].Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Id = null;
            tjw.Shimei = 'xxxxxx';

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNull(rw.taishoJidoId);
            Assert.areEqual(1, rw.errorLog.size());
            Assert.areEqual('Shimei', rw.errorLog[0].field);
            Assert.areEqual('対象児童の数が上限に達しています', rw.errorLog[0].message);
        }
    }

    /**
     * 登録成功
     */
    @isTest
    private static void upsertTaishoJidoGeneral3() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            tj.Shimei__c = 'xxxxxx';
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Id = null;
            tjw.Shimei = '対象者';

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNotNull(rw.taishoJidoId);

            TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,NinteiSeikyu__c
                    ,TaishoshaKubun__c
                    ,Shimei__c
                    ,ShimeiFurigana__c
                    ,SeinenGappiDate__c
                    ,SeikyushaDoukyoShubetsu_Doukyo__c
                    ,SeikyushaDoukyoShubetsu_Bekkyo__c
                    ,SeikyushaDoukyoShubetsu_Honnin__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,IsKokuseki_Nihon__c
                    ,IsKokuseki_NihonIgai__c
                    ,SeikyushaTsudukigara_Chichi__c
                    ,SeikyushaTsudukigara_Haha__c
                    ,SeikyushaTsudukigara_Sonota__c
                    ,SonotaShousai__c
                    ,IsTochuTennyuShussei__c
                    ,TennyuShusseiDate__c
                    ,TennyuShusseiDateSonota__c
                    ,IsTochuTenshutsu__c
                    ,TenshutsuDate__c
                    ,TenshutsuDateSonota__c
                    ,SeikyushaKubun_Taishosha__c
                    ,SeikyushaKubun_Dairinin__c
                    ,TaishoshaJohoCheck__c
                FROM TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.areEqual(ns.Id, resultTj.NinteiSeikyu__c);
            Assert.areEqual(tk.Id, resultTj.TaishoshaKubun__c);
            Assert.areEqual('対象者', resultTj.Shimei__c);
            Assert.areEqual('タイショウシャ', resultTj.ShimeiFurigana__c);
            Assert.areEqual(date.newInstance(2020, 1, 1), resultTj.SeinenGappiDate__c);
            Assert.isTrue(resultTj.SeikyushaDoukyoShubetsu_Doukyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Bekkyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Honnin__c);
            Assert.isNull(resultTj.YubinBangou__c);
            Assert.isNull(resultTj.Jusho__c);
            Assert.isTrue(resultTj.IsKokuseki_Nihon__c);
            Assert.isFalse(resultTj.IsKokuseki_NihonIgai__c);
            Assert.isTrue(resultTj.SeikyushaTsudukigara_Chichi__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Haha__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Sonota__c);
            Assert.isNull(resultTj.SonotaShousai__c);
            Assert.isTrue(resultTj.IsTochuTennyuShussei__c);
            Assert.areEqual(date.newInstance(2020, 1, 15), resultTj.TennyuShusseiDate__c);
            Assert.areEqual('2回目：2021/01/15', resultTj.TennyuShusseiDateSonota__c);
            Assert.isTrue(resultTj.IsTochuTenshutsu__c);
            Assert.areEqual(date.newInstance(2020, 2, 1), resultTj.TenshutsuDate__c);
            Assert.areEqual('2回目：2021/02/01', resultTj.TenshutsuDateSonota__c);
            Assert.isTrue(resultTj.SeikyushaKubun_Taishosha__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Dairinin__c);
            Assert.isTrue(resultTj.TaishoshaJohoCheck__c);
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void upsertTaishoJidoGeneral4() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.SeikyushaDoukyoShubetsu = tjw.DOUKYOSHUBETSU_BEKKYO;
            tjw.IsTochuTennyuShussei = null;
            tjw.IsTochuTenshutsu = null;
            tjw.YubinBangou = '000-0000';
            tjw.Jusho = 'テスト県テスト市テスト町';
            tjw.Kokuseki = tjw.KOKUSEKI_OTHER;
            tjw.SeikyushaTsudukigara = tjw.TSUDUKIGARA_HAHA;
            tjw.SeikyushaKubun = tjw.SEIKYUSHA_DAIRININ;

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);

            TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,SeikyushaDoukyoShubetsu_Doukyo__c
                    ,SeikyushaDoukyoShubetsu_Bekkyo__c
                    ,SeikyushaDoukyoShubetsu_Honnin__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,IsKokuseki_Nihon__c
                    ,IsKokuseki_NihonIgai__c
                    ,SeikyushaTsudukigara_Chichi__c
                    ,SeikyushaTsudukigara_Haha__c
                    ,SeikyushaTsudukigara_Sonota__c
                    ,SonotaShousai__c
                    ,IsTochuTennyuShussei__c
                    ,TennyuShusseiDate__c
                    ,IsTochuTenshutsu__c
                    ,TenshutsuDate__c
                    ,SeikyushaKubun_Taishosha__c
                    ,SeikyushaKubun_Dairinin__c
                FROM TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Doukyo__c);
            Assert.isTrue(resultTj.SeikyushaDoukyoShubetsu_Bekkyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Honnin__c);
            Assert.areEqual('000-0000', resultTj.YubinBangou__c);
            Assert.areEqual('テスト県テスト市テスト町', resultTj.Jusho__c);
            Assert.isFalse(resultTj.IsKokuseki_Nihon__c);
            Assert.isTrue(resultTj.IsKokuseki_NihonIgai__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Chichi__c);
            Assert.isTrue(resultTj.SeikyushaTsudukigara_Haha__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Sonota__c);
            Assert.isNull(resultTj.SonotaShousai__c);
            Assert.isFalse(resultTj.IsTochuTennyuShussei__c);
            Assert.isNull(resultTj.TennyuShusseiDate__c);
            Assert.isFalse(resultTj.IsTochuTenshutsu__c);
            Assert.isNull(resultTj.TenshutsuDate__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Taishosha__c);
            Assert.isTrue(resultTj.SeikyushaKubun_Dairinin__c);

            tjw.SeikyushaDoukyoShubetsu = tjw.DOUKYOSHUBETSU_HONNIN;
            tjw.SeikyushaTsudukigara = tjw.TSUDUKIGARA_SONOTA;
            tjw.SonotaShousai = 'その他詳細';
            tjw.seikyushakubun = null;

            rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);

            resultTj = [
                SELECT
                    Id
                    ,SeikyushaDoukyoShubetsu_Doukyo__c
                    ,SeikyushaDoukyoShubetsu_Bekkyo__c
                    ,SeikyushaDoukyoShubetsu_Honnin__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,SeikyushaTsudukigara_Chichi__c
                    ,SeikyushaTsudukigara_Haha__c
                    ,SeikyushaTsudukigara_Sonota__c
                    ,SonotaShousai__c
                    ,SeikyushaKubun_Taishosha__c
                    ,SeikyushaKubun_Dairinin__c
                FROM TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Doukyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Bekkyo__c);
            Assert.isTrue(resultTj.SeikyushaDoukyoShubetsu_Honnin__c);
            Assert.isNull(resultTj.YubinBangou__c);
            Assert.isNull(resultTj.Jusho__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Chichi__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Haha__c);
            Assert.isTrue(resultTj.SeikyushaTsudukigara_Sonota__c);
            Assert.areEqual('その他詳細', resultTj.SonotaShousai__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Taishosha__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Dairinin__c);

            Test.stopTest();
        }
    }

    /**
     * 申立情報のクリア処理を確認
     */
    @isTest
    private static void upsertTaishoJidoGeneral5() {
        List<TaishoshaKubun__c> tkList = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 2];
        tkList[0].IsMoushitate__c = false;
        update tkList[0];

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tkList[1]);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            tj.Bekkyo_Tanshifunin__c = true;
            tj.Bekkyo_Shingaku__c = true;
            tj.Bekkyo_Sonota__c = true;
            tj.Moushitate_BekkyoRiyuSonota__c = '別居理由';
            tj.Moushitate_BekkyoKaishiDate__c = date.newInstance(2020, 7, 1);
            tj.Moushitate_BekkyoShuryoDate__c = date.newInstance(2020, 7, 15);
            tj.Moushitate_KangoJokyo__c = '監護状況';
            tj.Moushitate_RyugakusakiMei__c = '留学先名';
            tj.Moushitate_RyugakumaeKyojuKaishiDate__c = date.newInstance(2020, 8, 1);
            tj.Moushitate_RyugakumaeKyojuShuryoDate__c = date.newInstance(2020, 8, 15);
            tj.Moushitate_RyugakumaeKyojuYubinBango__c = '999-9999';
            tj.Moushitate_RyugakumaeJusho__c = 'TEST県TEST市TEST町';
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.TaishoshaKubun = tkList[0].Id;

            Test.startTest();
            ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,Moushitate_KokenninCheck__c
                    ,Moushitate_BekkyoKango__c
                    ,Moushitate_KaigaiRyugakuCheck__c
                    ,Moushitate_RikonKyogiCheck__c
                    ,Moushitate_FuboSiteishaCheck__c
                    ,Bekkyo_Tanshifunin__c
                    ,Bekkyo_Shingaku__c
                    ,Bekkyo_Sonota__c
                    ,Moushitate_BekkyoRiyuSonota__c
                    ,Moushitate_BekkyoKaishiDate__c
                    ,Moushitate_BekkyoShuryoDate__c
                    ,Moushitate_KangoJokyo__c
                    ,Moushitate_RyugakusakiMei__c
                    ,Moushitate_RyugakumaeKyojuKaishiDate__c
                    ,Moushitate_RyugakumaeKyojuShuryoDate__c
                    ,Moushitate_RyugakumaeKyojuYubinBango__c
                    ,Moushitate_RyugakumaeJusho__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.Moushitate_KokenninCheck__c);
            Assert.isFalse(resultTj.Moushitate_BekkyoKango__c);
            Assert.isFalse(resultTj.Moushitate_KaigaiRyugakuCheck__c);
            Assert.isFalse(resultTj.Moushitate_RikonKyogiCheck__c);
            Assert.isFalse(resultTj.Moushitate_FuboSiteishaCheck__c);
            Assert.isFalse(resultTj.Bekkyo_Tanshifunin__c);
            Assert.isFalse(resultTj.Bekkyo_Shingaku__c);
            Assert.isFalse(resultTj.Bekkyo_Sonota__c);
            Assert.areEqual(resultTj.Moushitate_BekkyoRiyuSonota__c, null);
            Assert.areEqual(resultTj.Moushitate_BekkyoKaishiDate__c, null);
            Assert.areEqual(resultTj.Moushitate_BekkyoShuryoDate__c, null);
            Assert.areEqual(resultTj.Moushitate_KangoJokyo__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakusakiMei__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeKyojuKaishiDate__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeKyojuShuryoDate__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeKyojuYubinBango__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeJusho__c, null);
        }
    }

    /**
     * 口座情報のクリア処理を確認
     */
    @isTest
    private static void upsertTaishoJidoGeneral6() {
        List<TaishoshaKubun__c> tkList = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 2];

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

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tkList[0]);
            tj.UketoriKouzaKubun_Seikyusha__c = true;
            tj.UketoriKouzaKubun_Taishosha__c = true;

            tj.TJ_Yucho_Shumoku01__c = true;
            tj.TJ_Yucho_Shumoku02__c = true;
            tj.TJ_Yucho_Shumoku03__c = true;
            tj.TJ_Yucho_Shumoku04__c = true;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345';
            tj.YuchoKouzaMeigi__c = '12345';

            tj.KinyuKikan__c = kk.Id;
            tj.KinyuKikanMei__c = '12345';
            tj.KinyuKikanCode__c = '1234';
            tj.Shiten__c = stn.Id;
            tj.ShitenCode__c = '123';
            tj.ShitenMei__c = '12345';

            tj.TJ_Shumoku01__c = true;
            tj.TJ_Shumoku02__c = true;
            tj.TJ_Shumoku03__c = true;
            tj.KouzaBangou__c = '12345';
            tj.KouzaMeigi__c = '12345';

            tj.KouzaJohoCheck__c = true;
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.TaishoshaKubun = tkList[1].Id;

            Test.startTest();
            ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

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
                    ,KouzaJohoCheck__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            assert.isFalse(resultTj.UketoriKouzaKubun_Seikyusha__c);
            assert.isFalse(resultTj.UketoriKouzaKubun_Taishosha__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku02__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            assert.isNull(resultTj.YuchoKigo__c);
            assert.isNull(resultTj.YuchoBango__c);
            assert.isNull(resultTj.YuchoKouzaMeigi__c);
            assert.isNull(resultTj.KinyuKikan__c);
            assert.isNull(resultTj.KinyuKikanMei__c);
            assert.isNull(resultTj.KinyuKikanCode__c);
            assert.isNull(resultTj.Shiten__c);
            assert.isNull(resultTj.ShitenCode__c);
            assert.isNull(resultTj.ShitenMei__c);
            assert.isFalse(resultTj.TJ_Shumoku01__c);
            assert.isFalse(resultTj.TJ_Shumoku02__c);
            assert.isFalse(resultTj.TJ_Shumoku03__c);
            assert.isNull(resultTj.KouzaBangou__c);
            assert.isNull(resultTj.KouzaMeigi__c);
            assert.isFalse(resultTj.KouzaJohoCheck__c);
        }
    }

    /**
     * 重複チェックにてエラー
     */
    @isTest
    private static void upsertTaishoJidoDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;
            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Id = null;

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNull(rw.taishoJidoId);
            Assert.areEqual(1, rw.errorLog.size());
            Assert.areEqual('Shimei', rw.errorLog[0].field);
            Assert.areEqual('名前、生年月日が一致している対象児童が既に登録されています', rw.errorLog[0].message);
        }
    }

    /**
     * 上限チェックにてエラー
     */
    @isTest
    private static void upsertTaishoJidoDv2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();
            for (Integer i = 0; i < Limit__mdt.getInstance('TaishoJido').Value__c; i++) {
                tjList.add(getTaishoJidoDv(ns, tk));
            }
            insert tjList;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tjList[0].Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Id = null;
            tjw.Shimei = 'xxxxxx';

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNull(rw.taishoJidoId);
            Assert.areEqual(1, rw.errorLog.size());
            Assert.areEqual('Shimei', rw.errorLog[0].field);
            Assert.areEqual('対象児童の数が上限に達しています', rw.errorLog[0].message);
        }
    }

    /**
     * 登録成功
     */
    @isTest
    private static void upsertTaishoJidoDv3() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            tj.Shimei__c = 'xxxxxx';
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.Id = null;
            tjw.Shimei = '対象者';

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNotNull(rw.taishoJidoId);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,NinteiSeikyu__c
                    ,TaishoshaKubun__c
                    ,Shimei__c
                    ,ShimeiFurigana__c
                    ,SeinenGappiDate__c
                    ,SeikyushaDoukyoShubetsu_Doukyo__c
                    ,SeikyushaDoukyoShubetsu_Bekkyo__c
                    ,SeikyushaDoukyoShubetsu_Honnin__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,IsKokuseki_Nihon__c
                    ,IsKokuseki_NihonIgai__c
                    ,SeikyushaTsudukigara_Chichi__c
                    ,SeikyushaTsudukigara_Haha__c
                    ,SeikyushaTsudukigara_Sonota__c
                    ,SonotaShousai__c
                    ,IsTochuTennyuShussei__c
                    ,TennyuShusseiDate__c
                    ,TennyuShusseiDateSonota__c
                    ,IsTochuTenshutsu__c
                    ,TenshutsuDate__c
                    ,TenshutsuDateSonota__c
                    ,SeikyushaKubun_Taishosha__c
                    ,SeikyushaKubun_Dairinin__c
                    ,TaishoshaJohoCheck__c
                FROM DV_TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.areEqual(ns.Id, resultTj.NinteiSeikyu__c);
            Assert.areEqual(tk.Id, resultTj.TaishoshaKubun__c);
            Assert.areEqual('対象者', resultTj.Shimei__c);
            Assert.areEqual('タイショウシャ', resultTj.ShimeiFurigana__c);
            Assert.areEqual(date.newInstance(2020, 1, 1), resultTj.SeinenGappiDate__c);
            Assert.isTrue(resultTj.SeikyushaDoukyoShubetsu_Doukyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Bekkyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Honnin__c);
            Assert.isNull(resultTj.YubinBangou__c);
            Assert.isNull(resultTj.Jusho__c);
            Assert.isTrue(resultTj.IsKokuseki_Nihon__c);
            Assert.isFalse(resultTj.IsKokuseki_NihonIgai__c);
            Assert.isTrue(resultTj.SeikyushaTsudukigara_Chichi__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Haha__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Sonota__c);
            Assert.isNull(resultTj.SonotaShousai__c);
            Assert.isTrue(resultTj.IsTochuTennyuShussei__c);
            Assert.areEqual(date.newInstance(2020, 1, 15), resultTj.TennyuShusseiDate__c);
            Assert.areEqual('2回目：2021/01/15', resultTj.TennyuShusseiDateSonota__c);
            Assert.isTrue(resultTj.IsTochuTenshutsu__c);
            Assert.areEqual(date.newInstance(2020, 2, 1), resultTj.TenshutsuDate__c);
            Assert.areEqual('2回目：2021/02/01', resultTj.TenshutsuDateSonota__c);
            Assert.isTrue(resultTj.SeikyushaKubun_Taishosha__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Dairinin__c);
            Assert.isTrue(resultTj.TaishoshaJohoCheck__c);
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void upsertTaishoJidoDv4() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.SeikyushaDoukyoShubetsu = tjw.DOUKYOSHUBETSU_BEKKYO;
            tjw.IsTochuTennyuShussei = null;
            tjw.IsTochuTenshutsu = null;
            tjw.YubinBangou = '000-0000';
            tjw.Jusho = 'テスト県テスト市テスト町';
            tjw.Kokuseki = tjw.KOKUSEKI_OTHER;
            tjw.SeikyushaTsudukigara = tjw.TSUDUKIGARA_HAHA;
            tjw.SeikyushaKubun = tjw.SEIKYUSHA_DAIRININ;

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,SeikyushaDoukyoShubetsu_Doukyo__c
                    ,SeikyushaDoukyoShubetsu_Bekkyo__c
                    ,SeikyushaDoukyoShubetsu_Honnin__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,IsKokuseki_Nihon__c
                    ,IsKokuseki_NihonIgai__c
                    ,SeikyushaTsudukigara_Chichi__c
                    ,SeikyushaTsudukigara_Haha__c
                    ,SeikyushaTsudukigara_Sonota__c
                    ,SonotaShousai__c
                    ,IsTochuTennyuShussei__c
                    ,TennyuShusseiDate__c
                    ,IsTochuTenshutsu__c
                    ,TenshutsuDate__c
                    ,SeikyushaKubun_Taishosha__c
                    ,SeikyushaKubun_Dairinin__c
                FROM DV_TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Doukyo__c);
            Assert.isTrue(resultTj.SeikyushaDoukyoShubetsu_Bekkyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Honnin__c);
            Assert.areEqual('000-0000', resultTj.YubinBangou__c);
            Assert.areEqual('テスト県テスト市テスト町', resultTj.Jusho__c);
            Assert.isFalse(resultTj.IsKokuseki_Nihon__c);
            Assert.isTrue(resultTj.IsKokuseki_NihonIgai__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Chichi__c);
            Assert.isTrue(resultTj.SeikyushaTsudukigara_Haha__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Sonota__c);
            Assert.isNull(resultTj.SonotaShousai__c);
            Assert.isFalse(resultTj.IsTochuTennyuShussei__c);
            Assert.isNull(resultTj.TennyuShusseiDate__c);
            Assert.isFalse(resultTj.IsTochuTenshutsu__c);
            Assert.isNull(resultTj.TenshutsuDate__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Taishosha__c);
            Assert.isTrue(resultTj.SeikyushaKubun_Dairinin__c);

            tjw.SeikyushaDoukyoShubetsu = tjw.DOUKYOSHUBETSU_HONNIN;
            tjw.SeikyushaTsudukigara = tjw.TSUDUKIGARA_SONOTA;
            tjw.SonotaShousai = 'その他詳細';
            tjw.seikyushakubun = null;

            rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);

            resultTj = [
                SELECT
                    Id
                    ,SeikyushaDoukyoShubetsu_Doukyo__c
                    ,SeikyushaDoukyoShubetsu_Bekkyo__c
                    ,SeikyushaDoukyoShubetsu_Honnin__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,SeikyushaTsudukigara_Chichi__c
                    ,SeikyushaTsudukigara_Haha__c
                    ,SeikyushaTsudukigara_Sonota__c
                    ,SonotaShousai__c
                    ,SeikyushaKubun_Taishosha__c
                    ,SeikyushaKubun_Dairinin__c
                FROM DV_TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Doukyo__c);
            Assert.isFalse(resultTj.SeikyushaDoukyoShubetsu_Bekkyo__c);
            Assert.isTrue(resultTj.SeikyushaDoukyoShubetsu_Honnin__c);
            Assert.isNull(resultTj.YubinBangou__c);
            Assert.isNull(resultTj.Jusho__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Chichi__c);
            Assert.isFalse(resultTj.SeikyushaTsudukigara_Haha__c);
            Assert.isTrue(resultTj.SeikyushaTsudukigara_Sonota__c);
            Assert.areEqual('その他詳細', resultTj.SonotaShousai__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Taishosha__c);
            Assert.isFalse(resultTj.SeikyushaKubun_Dairinin__c);

            Test.stopTest();
        }
    }

/**
     * 申立情報のクリア処理を確認
     */
    @isTest
    private static void upsertTaishoJidoDv5() {
        List<TaishoshaKubun__c> tkList = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 2];
        tkList[0].IsMoushitate__c = false;
        update tkList[0];

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tkList[1]);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
            tj.Bekkyo_Tanshifunin__c = true;
            tj.Bekkyo_Shingaku__c = true;
            tj.Bekkyo_Sonota__c = true;
            tj.Moushitate_BekkyoRiyuSonota__c = '別居理由';
            tj.Moushitate_BekkyoKaishiDate__c = date.newInstance(2020, 7, 1);
            tj.Moushitate_BekkyoShuryoDate__c = date.newInstance(2020, 7, 15);
            tj.Moushitate_KangoJokyo__c = '監護状況';
            tj.Moushitate_RyugakusakiMei__c = '留学先名';
            tj.Moushitate_RyugakumaeKyojuKaishiDate__c = date.newInstance(2020, 8, 1);
            tj.Moushitate_RyugakumaeKyojuShuryoDate__c = date.newInstance(2020, 8, 15);
            tj.Moushitate_RyugakumaeKyojuYubinBango__c = '999-9999';
            tj.Moushitate_RyugakumaeJusho__c = 'TEST県TEST市TEST町';
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.TaishoshaKubun = tkList[0].Id;

            Test.startTest();
            ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,Moushitate_KokenninCheck__c
                    ,Moushitate_BekkyoKango__c
                    ,Moushitate_KaigaiRyugakuCheck__c
                    ,Moushitate_RikonKyogiCheck__c
                    ,Moushitate_FuboSiteishaCheck__c
                    ,Bekkyo_Tanshifunin__c
                    ,Bekkyo_Shingaku__c
                    ,Bekkyo_Sonota__c
                    ,Moushitate_BekkyoRiyuSonota__c
                    ,Moushitate_BekkyoKaishiDate__c
                    ,Moushitate_BekkyoShuryoDate__c
                    ,Moushitate_KangoJokyo__c
                    ,Moushitate_RyugakusakiMei__c
                    ,Moushitate_RyugakumaeKyojuKaishiDate__c
                    ,Moushitate_RyugakumaeKyojuShuryoDate__c
                    ,Moushitate_RyugakumaeKyojuYubinBango__c
                    ,Moushitate_RyugakumaeJusho__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.Moushitate_KokenninCheck__c);
            Assert.isFalse(resultTj.Moushitate_BekkyoKango__c);
            Assert.isFalse(resultTj.Moushitate_KaigaiRyugakuCheck__c);
            Assert.isFalse(resultTj.Moushitate_RikonKyogiCheck__c);
            Assert.isFalse(resultTj.Moushitate_FuboSiteishaCheck__c);
            Assert.isFalse(resultTj.Bekkyo_Tanshifunin__c);
            Assert.isFalse(resultTj.Bekkyo_Shingaku__c);
            Assert.isFalse(resultTj.Bekkyo_Sonota__c);
            Assert.areEqual(resultTj.Moushitate_BekkyoRiyuSonota__c, null);
            Assert.areEqual(resultTj.Moushitate_BekkyoKaishiDate__c, null);
            Assert.areEqual(resultTj.Moushitate_BekkyoShuryoDate__c, null);
            Assert.areEqual(resultTj.Moushitate_KangoJokyo__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakusakiMei__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeKyojuKaishiDate__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeKyojuShuryoDate__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeKyojuYubinBango__c, null);
            Assert.areEqual(resultTj.Moushitate_RyugakumaeJusho__c, null);
        }
    }

    /**
     * 口座情報のクリア処理を確認
     */
    @isTest
    private static void upsertTaishoJidoDv6() {
        List<TaishoshaKubun__c> tkList = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 2];

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

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tkList[0]);
            tj.UketoriKouzaKubun_Seikyusha__c = true;
            tj.UketoriKouzaKubun_Taishosha__c = true;

            tj.TJ_Yucho_Shumoku01__c = true;
            tj.TJ_Yucho_Shumoku02__c = true;
            tj.TJ_Yucho_Shumoku03__c = true;
            tj.TJ_Yucho_Shumoku04__c = true;
            tj.YuchoKigo__c = '12345';
            tj.YuchoBango__c = '12345';
            tj.YuchoKouzaMeigi__c = '12345';

            tj.KinyuKikan__c = kk.Id;
            tj.KinyuKikanMei__c = '12345';
            tj.KinyuKikanCode__c = '1234';
            tj.Shiten__c = stn.Id;
            tj.ShitenCode__c = '123';
            tj.ShitenMei__c = '12345';

            tj.TJ_Shumoku01__c = true;
            tj.TJ_Shumoku02__c = true;
            tj.TJ_Shumoku03__c = true;
            tj.KouzaBangou__c = '12345';
            tj.KouzaMeigi__c = '12345';

            tj.KouzaJohoCheck__c = true;
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;
            tjw.TaishoshaKubun = tkList[1].Id;

            Test.startTest();
            ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

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
                    ,KouzaJohoCheck__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            assert.isFalse(resultTj.UketoriKouzaKubun_Seikyusha__c);
            assert.isFalse(resultTj.UketoriKouzaKubun_Taishosha__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku01__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku02__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku03__c);
            assert.isFalse(resultTj.TJ_Yucho_Shumoku04__c);
            assert.isNull(resultTj.YuchoKigo__c);
            assert.isNull(resultTj.YuchoBango__c);
            assert.isNull(resultTj.YuchoKouzaMeigi__c);
            assert.isNull(resultTj.KinyuKikan__c);
            assert.isNull(resultTj.KinyuKikanMei__c);
            assert.isNull(resultTj.KinyuKikanCode__c);
            assert.isNull(resultTj.Shiten__c);
            assert.isNull(resultTj.ShitenCode__c);
            assert.isNull(resultTj.ShitenMei__c);
            assert.isFalse(resultTj.TJ_Shumoku01__c);
            assert.isFalse(resultTj.TJ_Shumoku02__c);
            assert.isFalse(resultTj.TJ_Shumoku03__c);
            assert.isNull(resultTj.KouzaBangou__c);
            assert.isNull(resultTj.KouzaMeigi__c);
            assert.isFalse(resultTj.KouzaJohoCheck__c);
        }
    }

    /**
     * 登録成功
     */
    @isTest
    private static void upsertTaishoJidoSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            insert tj;

            ExTaishoJidoNyuryokuController.TaishoJidoNyuryokuWrapper tjnw = ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData(ns.Id, tj.Id);
            ExTaishoJidoNyuryokuController.TaishoJidoWrapper tjw = tjnw.taishoJidoData;

            Test.startTest();
            ExTaishoJidoNyuryokuController.ResultWrapper rw = ExTaishoJidoNyuryokuController.upsertTaishoJido(ns.Id, tjw);
            Test.stopTest();

            Assert.isNotNull(rw.taishoJidoId);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,TaishoShinkiSochi__c
                    ,Shisetsu_TaishoBiko__c
                FROM DV_TaishoJido__c
                WHERE Id = :rw.taishoJidoId
            ];

            Assert.areEqual('はい', resultTj.TaishoShinkiSochi__c);
            Assert.areEqual('備考', resultTj.Shisetsu_TaishoBiko__c);
        }
    }
}