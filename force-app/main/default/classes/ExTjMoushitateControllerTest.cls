@isTest
private class ExTjMoushitateControllerTest {

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
     * 申立書情報を取得
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

            // 申立書情報を取得
            Test.startTest();
            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.areEqual(tj.Id, mw.Id);
            Assert.areEqual('対象者', mw.Shimei);
            Assert.isTrue(mw.IsKokennin);
            Assert.isTrue(mw.IsBekkyo);
            Assert.isTrue(mw.IsRyugaku);
            Assert.isTrue(mw.IsRikon);
            Assert.isTrue(mw.IsFuboSitei);
            Assert.areEqual(mw.RIYU_SONOTA, mw.BekkyoRiyu);
            Assert.areEqual('別居理由', mw.BekkyoRiyuSonota);
            Assert.areEqual(date.newInstance(2020, 7, 1), mw.BekkyoStart);
            Assert.areEqual(date.newInstance(2020, 7, 15), mw.BekkyoEnd);
            Assert.areEqual('監護状況', mw.KangoJokyo);
            Assert.areEqual('留学先名', mw.Ryugakusaki);
            Assert.areEqual(date.newInstance(2020, 8, 1), mw.RyugakumaeKyojuStart);
            Assert.areEqual(date.newInstance(2020, 8, 15), mw.RyugakumaeKyojuEnd);
            Assert.areEqual('999-9999', mw.RyugakumaeKyojuYubinBango);
            Assert.areEqual('TEST県TEST市TEST町', mw.RyugakumaeKyojuJusho);
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
            tj.Bekkyo_Tanshifunin__c = true;
            insert tj;

            // 申立書情報を取得
            Test.startTest();
            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.areEqual(mw.RIYU_TANSHIN, mw.BekkyoRiyu);
            Assert.isNull(mw.BekkyoRiyuSonota);
            Assert.isTrue(mw.isDisabled);

            tj.Bekkyo_Tanshifunin__c = false;
            tj.Bekkyo_Shingaku__c = true;
            update tj;

            mw = ExTjMoushitateController.getMoushitateData(tj.Id);

            Assert.areEqual(mw.RIYU_SHINGAKU, mw.BekkyoRiyu);
            Assert.isNull(mw.BekkyoRiyuSonota);
        }
    }

    /**
     * 申立書情報を取得
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
            tj.Moushitate_BetsuJushoCheck__c = true;
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

            // 申立書情報を取得
            Test.startTest();
            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.areEqual(tj.Id, mw.Id);
            Assert.areEqual('対象者', mw.Shimei);
            Assert.isTrue(mw.IsKokennin);
            Assert.isTrue(mw.IsBekkyo);
            Assert.isTrue(mw.IsRyugaku);
            Assert.isTrue(mw.IsRikon);
            Assert.isTrue(mw.IsFuboSitei);
            Assert.isTrue(mw.IsBetsuJusho);
            Assert.areEqual(mw.RIYU_SONOTA, mw.BekkyoRiyu);
            Assert.areEqual('別居理由', mw.BekkyoRiyuSonota);
            Assert.areEqual(date.newInstance(2020, 7, 1), mw.BekkyoStart);
            Assert.areEqual(date.newInstance(2020, 7, 15), mw.BekkyoEnd);
            Assert.areEqual('監護状況', mw.KangoJokyo);
            Assert.areEqual('留学先名', mw.Ryugakusaki);
            Assert.areEqual(date.newInstance(2020, 8, 1), mw.RyugakumaeKyojuStart);
            Assert.areEqual(date.newInstance(2020, 8, 15), mw.RyugakumaeKyojuEnd);
            Assert.areEqual('999-9999', mw.RyugakumaeKyojuYubinBango);
            Assert.areEqual('TEST県TEST市TEST町', mw.RyugakumaeKyojuJusho);
            Assert.isFalse(mw.isDisabled);
        }
    }

    /**
     * 申立書情報を取得
     */
    @isTest
    private static void getMoushitateDataSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            tj.ShinsaKekkaSaishu__c = 'OK';
            tj.Bekkyo_Tanshifunin__c = true;
            insert tj;

            // 申立書情報を取得
            Test.startTest();
            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            Test.stopTest();

            Assert.areEqual(mw.RIYU_TANSHIN, mw.BekkyoRiyu);
            Assert.isNull(mw.BekkyoRiyuSonota);
            Assert.isTrue(mw.isDisabled);

            tj.Bekkyo_Tanshifunin__c = false;
            tj.Bekkyo_Shingaku__c = true;
            update tj;

            mw = ExTjMoushitateController.getMoushitateData(tj.Id);

            Assert.areEqual(mw.RIYU_SHINGAKU, mw.BekkyoRiyu);
            Assert.isNull(mw.BekkyoRiyuSonota);
        }
    }

    /**
     * バリデーションエラー
     */
    @isTest
    private static void updateTaishoJidoError1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            mw.BekkyoStart = date.newInstance(2022, 9, 15);
            mw.BekkyoEnd = date.newInstance(2022, 9, 1);
            mw.RyugakumaeKyojuStart = date.newInstance(2022, 10, 15);
            mw.RyugakumaeKyojuEnd = date.newInstance(2022, 10, 1);

            // バリデーションエラー
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.areEqual(5, results.size());
            // 申立の種別が選択されていない
            Assert.areEqual('IsKokennin', results[0].field);
            Assert.areEqual(' ', results[0].message);
            Assert.areEqual('IsBekkyo', results[1].field);
            Assert.areEqual(' ', results[1].message);
            Assert.areEqual('IsRyugaku', results[2].field);
            Assert.areEqual(' ', results[2].message);
            Assert.areEqual('IsRikon', results[3].field);
            Assert.areEqual(' ', results[3].message);
            Assert.areEqual('IsFuboSitei', results[4].field);
            Assert.areEqual('申立の種別のいずれかを選択してください', results[4].message);
        }
    }

    /**
     * バリデーションエラー
     */
    @isTest
    private static void updateTaishoJidoError2() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            mw.IsRyugaku = true;
            mw.BekkyoRiyu = mw.RIYU_SONOTA;
            mw.BekkyoStart = date.newInstance(2022, 9, 15);
            mw.BekkyoEnd = date.newInstance(2022, 9, 1);
            mw.RyugakumaeKyojuStart = date.newInstance(2022, 10, 15);
            mw.RyugakumaeKyojuEnd = date.newInstance(2022, 10, 1);

            // バリデーションエラー
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.areEqual(6, results.size());
            // 申立の種別が選択されていない
            Assert.areEqual('BekkyoRiyuSonota', results[0].field);
            Assert.areEqual('BekkyoStart', results[1].field);
            Assert.areEqual('KangoJokyo', results[2].field);
            Assert.areEqual('Ryugakusaki', results[3].field);
            Assert.areEqual('RyugakumaeKyojuStart', results[4].field);
            Assert.areEqual('jusho', results[5].field);
        }
    }

    /**
     * バリデーションエラー
     */
    @isTest
    private static void updateTaishoJidoError3() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);

            // バリデーションエラー
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.areEqual(6, results.size());
            // 申立の種別が選択されていない
            Assert.areEqual('IsKokennin', results[0].field);
            Assert.areEqual(' ', results[0].message);
            Assert.areEqual('IsBekkyo', results[1].field);
            Assert.areEqual(' ', results[1].message);
            Assert.areEqual('IsRyugaku', results[2].field);
            Assert.areEqual(' ', results[2].message);
            Assert.areEqual('IsRikon', results[3].field);
            Assert.areEqual(' ', results[3].message);
            Assert.areEqual('IsFuboSitei', results[4].field);
            Assert.areEqual(' ', results[4].message);
            Assert.areEqual('IsBetsuJusho', results[5].field);
            Assert.areEqual('申立の種別のいずれかを選択してください', results[5].message);
        }
    }

    /**
     * 申立書情報を更新
     */
    @isTest
    private static void updateTaishoJidoGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = ExTestUtil.getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj = getTaishoJido(ns, tk);
            insert tj;

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            mw.IsKokennin = true;
            mw.IsBekkyo = true;
            mw.IsRyugaku = true;
            mw.IsRikon = true;
            mw.IsFuboSitei = true;
            mw.BekkyoRiyu = mw.RIYU_SONOTA;
            mw.BekkyoRiyuSonota = '別居理由';
            mw.BekkyoStart = date.newInstance(2022, 9, 1);
            mw.BekkyoEnd = date.newInstance(2022, 9, 15);
            mw.KangoJokyo = '監護状況';
            mw.Ryugakusaki = '留学先';
            mw.RyugakumaeKyojuStart = date.newInstance(2022, 10, 1);
            mw.RyugakumaeKyojuEnd = date.newInstance(2022, 10, 15);
            mw.RyugakumaeKyojuYubinBango = '999-9999';
            mw.RyugakumaeKyojuJusho = 'TEST県TEST市TEST町';

            // 申立書情報を更新
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.isNull(results);

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
                    ,MoushitateCheck__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isTrue(resultTj.Moushitate_KokenninCheck__c);
            Assert.isTrue(resultTj.Moushitate_BekkyoKango__c);
            Assert.isTrue(resultTj.Moushitate_KaigaiRyugakuCheck__c);
            Assert.isTrue(resultTj.Moushitate_RikonKyogiCheck__c);
            Assert.isTrue(resultTj.Moushitate_FuboSiteishaCheck__c);
            Assert.isFalse(resultTj.Bekkyo_Tanshifunin__c);
            Assert.isFalse(resultTj.Bekkyo_Shingaku__c);
            Assert.isTrue(resultTj.Bekkyo_Sonota__c);
            Assert.areEqual('別居理由', resultTj.Moushitate_BekkyoRiyuSonota__c);
            Assert.areEqual(date.newInstance(2022, 9, 1), resultTj.Moushitate_BekkyoKaishiDate__c);
            Assert.areEqual(date.newInstance(2022, 9, 15), resultTj.Moushitate_BekkyoShuryoDate__c);
            Assert.areEqual('監護状況', resultTj.Moushitate_KangoJokyo__c);
            Assert.areEqual('留学先', resultTj.Moushitate_RyugakusakiMei__c);
            Assert.areEqual(date.newInstance(2022, 10, 1), resultTj.Moushitate_RyugakumaeKyojuKaishiDate__c);
            Assert.areEqual(date.newInstance(2022, 10, 15), resultTj.Moushitate_RyugakumaeKyojuShuryoDate__c);
            Assert.areEqual('999-9999', resultTj.Moushitate_RyugakumaeKyojuYubinBango__c);
            Assert.areEqual('TEST県TEST市TEST町', resultTj.Moushitate_RyugakumaeJusho__c);
            Assert.isTrue(resultTj.MoushitateCheck__c);
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void updateTaishoJidoGeneral2() {

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

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            mw.IsKokennin = false;
            mw.IsBekkyo = false;
            mw.IsRyugaku = false;
            mw.IsRikon = false;
            mw.IsFuboSitei = true;

            // 申立書情報を更新
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.isNull(results);

            TaishoJido__c resultTj = [
                SELECT
                    Id
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
                    ,MoushitateCheck__c
                FROM TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.Bekkyo_Tanshifunin__c);
            Assert.isFalse(resultTj.Bekkyo_Shingaku__c);
            Assert.isFalse(resultTj.Bekkyo_Sonota__c);
            Assert.isNull(resultTj.Moushitate_BekkyoRiyuSonota__c);
            Assert.isNull(resultTj.Moushitate_BekkyoKaishiDate__c);
            Assert.isNull(resultTj.Moushitate_BekkyoShuryoDate__c);
            Assert.isNull(resultTj.Moushitate_KangoJokyo__c);
            Assert.isNull(resultTj.Moushitate_RyugakusakiMei__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeKyojuKaishiDate__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeKyojuShuryoDate__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeKyojuYubinBango__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeJusho__c);
        }
    }

    /**
     * 申立書情報を更新
     */
    @isTest
    private static void updateTaishoJidoDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            mw.IsKokennin = true;
            mw.IsBekkyo = true;
            mw.IsRyugaku = true;
            mw.IsRikon = true;
            mw.IsFuboSitei = true;
            mw.IsBetsuJusho = true;
            mw.BekkyoRiyu = mw.RIYU_SONOTA;
            mw.BekkyoRiyuSonota = '別居理由';
            mw.BekkyoStart = date.newInstance(2022, 9, 1);
            mw.BekkyoEnd = date.newInstance(2022, 9, 15);
            mw.KangoJokyo = '監護状況';
            mw.Ryugakusaki = '留学先';
            mw.RyugakumaeKyojuStart = date.newInstance(2022, 10, 1);
            mw.RyugakumaeKyojuEnd = date.newInstance(2022, 10, 15);
            mw.RyugakumaeKyojuYubinBango = '999-9999';
            mw.RyugakumaeKyojuJusho = 'TEST県TEST市TEST町';

            // 申立書情報を更新
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.isNull(results);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
                    ,Moushitate_KokenninCheck__c
                    ,Moushitate_BekkyoKango__c
                    ,Moushitate_KaigaiRyugakuCheck__c
                    ,Moushitate_RikonKyogiCheck__c
                    ,Moushitate_FuboSiteishaCheck__c
                    ,Moushitate_BetsuJushoCheck__c
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
                    ,MoushitateCheck__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isTrue(resultTj.Moushitate_KokenninCheck__c);
            Assert.isTrue(resultTj.Moushitate_BekkyoKango__c);
            Assert.isTrue(resultTj.Moushitate_KaigaiRyugakuCheck__c);
            Assert.isTrue(resultTj.Moushitate_RikonKyogiCheck__c);
            Assert.isTrue(resultTj.Moushitate_FuboSiteishaCheck__c);
            Assert.isTrue(resultTj.Moushitate_BetsuJushoCheck__c);
            Assert.isFalse(resultTj.Bekkyo_Tanshifunin__c);
            Assert.isFalse(resultTj.Bekkyo_Shingaku__c);
            Assert.isTrue(resultTj.Bekkyo_Sonota__c);
            Assert.areEqual('別居理由', resultTj.Moushitate_BekkyoRiyuSonota__c);
            Assert.areEqual(date.newInstance(2022, 9, 1), resultTj.Moushitate_BekkyoKaishiDate__c);
            Assert.areEqual(date.newInstance(2022, 9, 15), resultTj.Moushitate_BekkyoShuryoDate__c);
            Assert.areEqual('監護状況', resultTj.Moushitate_KangoJokyo__c);
            Assert.areEqual('留学先', resultTj.Moushitate_RyugakusakiMei__c);
            Assert.areEqual(date.newInstance(2022, 10, 1), resultTj.Moushitate_RyugakumaeKyojuKaishiDate__c);
            Assert.areEqual(date.newInstance(2022, 10, 15), resultTj.Moushitate_RyugakumaeKyojuShuryoDate__c);
            Assert.areEqual('999-9999', resultTj.Moushitate_RyugakumaeKyojuYubinBango__c);
            Assert.areEqual('TEST県TEST市TEST町', resultTj.Moushitate_RyugakumaeJusho__c);
            Assert.isTrue(resultTj.MoushitateCheck__c);
        }
    }

    /**
     * 申立書情報を更新
     */
    @isTest
    private static void updateTaishoJidoSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoSatoya(ns, tk);
            tj.Moushitate_KokenninCheck__c = true;
            tj.Moushitate_BekkyoKango__c = true;
            tj.Moushitate_KaigaiRyugakuCheck__c = true;
            tj.Moushitate_RikonKyogiCheck__c = true;
            tj.Moushitate_FuboSiteishaCheck__c = true;
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

            ExTjMoushitateController.MoushitateWrapper mw = ExTjMoushitateController.getMoushitateData(tj.Id);
            mw.IsKokennin = false;
            mw.IsBekkyo = false;
            mw.IsRyugaku = false;
            mw.IsRikon = false;
            mw.IsFuboSitei = true;

            // 申立書情報を更新
            Test.startTest();
            List<ExValidationUtil.ErrorLog> results = ExTjMoushitateController.updateTaishoJido(mw);
            Test.stopTest();

            Assert.isNull(results);

            DV_TaishoJido__c resultTj = [
                SELECT
                    Id
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
                    ,MoushitateCheck__c
                FROM DV_TaishoJido__c
                WHERE Id = :tj.Id
            ];

            Assert.isFalse(resultTj.Bekkyo_Tanshifunin__c);
            Assert.isFalse(resultTj.Bekkyo_Shingaku__c);
            Assert.isFalse(resultTj.Bekkyo_Sonota__c);
            Assert.isNull(resultTj.Moushitate_BekkyoRiyuSonota__c);
            Assert.isNull(resultTj.Moushitate_BekkyoKaishiDate__c);
            Assert.isNull(resultTj.Moushitate_BekkyoShuryoDate__c);
            Assert.isNull(resultTj.Moushitate_KangoJokyo__c);
            Assert.isNull(resultTj.Moushitate_RyugakusakiMei__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeKyojuKaishiDate__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeKyojuShuryoDate__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeKyojuYubinBango__c);
            Assert.isNull(resultTj.Moushitate_RyugakumaeJusho__c);
        }
    }
}