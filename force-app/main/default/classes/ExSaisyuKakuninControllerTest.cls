@isTest
private class ExSaisyuKakuninControllerTest {
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
        List<ShinseiShoruiTeigi__c> sstTaishoJidoList = ExTestUtil.getSstListTaishoJido(2);
        List<ShinseiShoruiTeigi__c> sstMoushitateList = ExTestUtil.getSstListMoushitate(6);
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

    private static Seikyusha__c getSeikyusha() {
        Seikyusha__c s = ExTestUtil.getSeikyusha();
        s.Shimei__c = '請求　太郎';
        s.ShimeiFurigana__c = 'セイキュウ　タロウ';
        s.SeinenGappiDate__c = date.newInstance(2000, 1, 15);
        s.YubinBangou__c = '000-0000';
        s.Jusho__c = 'テスト県テスト市テスト町';
        s.DenwaBangou__c = '000-0000-0000';
        s.MailAddress__c = 'test@example.com';

        return s;
    }

    private static DV_Seikyusha__c getSeikyushaDv() {
        DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
        s.Shimei__c = '請求　太郎';
        s.ShimeiFurigana__c = 'セイキュウ　タロウ';
        s.SeinenGappiDate__c = date.newInstance(2000, 1, 15);
        s.YubinBangou__c = '000-0000';
        s.Jusho__c = 'テスト県テスト市テスト町';
        s.DenwaBangou__c = '000-0000-0000';
        s.MailAddress__c = 'test@example.com';

        return s;
    }

    private static DV_Seikyusha__c getSeikyushaSatoya() {
        DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
        s.Shimei__c = '請求　太郎';
        s.ShimeiFurigana__c = 'セイキュウ　タロウ';
        s.SeinenGappiDate__c = date.newInstance(2000, 1, 15);
        s.YubinBangou__c = '000-0000';
        s.Jusho__c = 'テスト県テスト市テスト町';
        s.DenwaBangou__c = '000-0000-0000';
        s.MailAddress__c = 'test@example.com';
        s.Shisetsu_Shurui__c = '小規模住居型児童養育事業者';
        s.Shisetsu_Meisho__c = 'テスト施設';

        return s;
    }

    private static TaishoJido__c getTaishoJido(NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new TaishoJido__c(
            // 対象者情報
            TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
            ,ShimeiFurigana__c = 'タイショウシャ'
            ,SeinenGappiDate__c = date.newInstance(2015, 1, 30)
            ,IsTochuTennyuShussei__c = true
            ,TennyuShusseiDate__c = date.newInstance(2023, 2, 1)
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2023, 3, 1)
            ,IsKokuseki_Nihon__c = true
            // 申立書
            ,Moushitate_KokenninCheck__c = true
            ,Moushitate_BekkyoKango__c = true
            ,Moushitate_KaigaiRyugakuCheck__c = true
            ,Moushitate_RikonKyogiCheck__c = true
            ,Moushitate_FuboSiteishaCheck__c = true
            ,Bekkyo_Tanshifunin__c = true
            ,Moushitate_BekkyoRiyuSonota__c = '別居理由その他'
            ,Moushitate_BekkyoKaishiDate__c = date.newInstance(2023, 4, 1)
            ,Moushitate_BekkyoShuryoDate__c = date.newInstance(2023, 4, 15)
            ,Moushitate_KangoJokyo__c = '監護状況'
            ,Moushitate_RyugakusakiMei__c = '留学先名'
            ,Moushitate_RyugakumaeKyojuKaishiDate__c = date.newInstance(2023, 5, 1)
            ,Moushitate_RyugakumaeKyojuShuryoDate__c = date.newInstance(2023, 5, 15)
            ,Moushitate_RyugakumaeKyojuYubinBango__c = '999-9999'
            ,Moushitate_RyugakumaeJusho__c = '留学先住所'
        );
    }

    private static DV_TaishoJido__c getTaishoJidoDv(DV_NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new DV_TaishoJido__c(
            RecordTypeId = ExTestUtil.DV_JIDO_ID
            // 対象者情報
            ,TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
            ,ShimeiFurigana__c = 'タイショウシャ'
            ,SeinenGappiDate__c = date.newInstance(2015, 1, 30)
            ,IsTochuTennyuShussei__c = true
            ,TennyuShusseiDate__c = date.newInstance(2023, 2, 1)
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2023, 3, 1)
            ,IsKokuseki_Nihon__c = true
            // 申立書
            ,Moushitate_KokenninCheck__c = true
            ,Moushitate_BekkyoKango__c = true
            ,Moushitate_KaigaiRyugakuCheck__c = true
            ,Moushitate_RikonKyogiCheck__c = true
            ,Moushitate_FuboSiteishaCheck__c = true
            ,Bekkyo_Tanshifunin__c = true
            ,Moushitate_BekkyoRiyuSonota__c = '別居理由その他'
            ,Moushitate_BekkyoKaishiDate__c = date.newInstance(2023, 4, 1)
            ,Moushitate_BekkyoShuryoDate__c = date.newInstance(2023, 4, 15)
            ,Moushitate_KangoJokyo__c = '監護状況'
            ,Moushitate_RyugakusakiMei__c = '留学先名'
            ,Moushitate_RyugakumaeKyojuKaishiDate__c = date.newInstance(2023, 5, 1)
            ,Moushitate_RyugakumaeKyojuShuryoDate__c = date.newInstance(2023, 5, 15)
            ,Moushitate_RyugakumaeKyojuYubinBango__c = '999-9999'
            ,Moushitate_RyugakumaeJusho__c = '留学先住所'
        );
    }

    private static DV_TaishoJido__c getTaishoJidoSatoya(DV_NinteiSeikyu__c ns, TaishoshaKubun__c tk) {
        return new DV_TaishoJido__c(
            RecordTypeId = ExTestUtil.SATOYA_JIDO_ID
            // 対象者情報
            ,TaishoshaKubun__c = tk.Id
            ,NinteiSeikyu__c = ns.Id
            ,Shimei__c = '対象者'
            ,ShimeiFurigana__c = 'タイショウシャ'
            ,SeinenGappiDate__c = date.newInstance(2015, 1, 30)
            ,IsTochuTennyuShussei__c = true
            ,TennyuShusseiDate__c = date.newInstance(2023, 2, 1)
            ,IsTochuTenshutsu__c = true
            ,TenshutsuDate__c = date.newInstance(2023, 3, 1)
            ,IsKokuseki_Nihon__c = true
            ,TaishoShinkiSochi__c = 'はい'
            ,Shisetsu_TaishoBiko__c = '備考'
            // 申立書
            ,Moushitate_KokenninCheck__c = true
            ,Moushitate_BekkyoKango__c = true
            ,Moushitate_KaigaiRyugakuCheck__c = true
            ,Moushitate_RikonKyogiCheck__c = true
            ,Moushitate_FuboSiteishaCheck__c = true
            ,Bekkyo_Tanshifunin__c = true
            ,Moushitate_BekkyoRiyuSonota__c = '別居理由その他'
            ,Moushitate_BekkyoKaishiDate__c = date.newInstance(2023, 4, 1)
            ,Moushitate_BekkyoShuryoDate__c = date.newInstance(2023, 4, 15)
            ,Moushitate_KangoJokyo__c = '監護状況'
            ,Moushitate_RyugakusakiMei__c = '留学先名'
            ,Moushitate_RyugakumaeKyojuKaishiDate__c = date.newInstance(2023, 5, 1)
            ,Moushitate_RyugakumaeKyojuShuryoDate__c = date.newInstance(2023, 5, 15)
            ,Moushitate_RyugakumaeKyojuYubinBango__c = '999-9999'
            ,Moushitate_RyugakumaeJusho__c = '留学先住所'
        );
    }

    /**
     * 本人確認情報を取得する
     */
    @isTest
    private static void getNinteiSeikyuDataGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            Seikyusha__c s = ExTestUtil.getSeikyusha();
            s.HonninKakuninHoho__c = '券面アップロード';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.GENERAL_NETWORK_ID);
            cv.Yoto__c = '本人確認';
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.NinteiSeikyuWrapper nsw = ExSaisyuKakuninController.getNinteiSeikyuData(ns.Id);
            Test.stopTest();

            Assert.areEqual('券面アップロード', nsw.HonninKakuninHoho);
            Assert.areEqual(1, nsw.fileList.size());
            Assert.areEqual(cv.Id, nsw.fileList[0]);
            Assert.areEqual('含まない', nsw.getFukumu18Text());
        }
    }

    /**
     * 本人確認情報を取得する
     */
    @isTest
    private static void getNinteiSeikyuDataDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            s.HonninKakuninHoho__c = '券面アップロード';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            ns.SeikyushaKubun_18saiFukumu__c = true;
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.DV_NETWORK_ID);
            cv.Yoto__c = '本人確認';
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.NinteiSeikyuWrapper nsw = ExSaisyuKakuninController.getNinteiSeikyuData(ns.Id);
            Test.stopTest();

            Assert.areEqual('券面アップロード', nsw.HonninKakuninHoho);
            Assert.areEqual(1, nsw.fileList.size());
            Assert.areEqual(cv.Id, nsw.fileList[0]);
            Assert.areEqual('含む', nsw.getFukumu18Text());
        }
    }

    /**
     * 本人確認情報を取得する
     */
    @isTest
    private static void getNinteiSeikyuDataSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            DV_Seikyusha__c s = ExTestUtil.getSeikyushaSatoya();
            s.HonninKakuninHoho__c = '公的個人認証';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, ns.Id, ExTestUtil.SATOYA_NETWORK_ID);
            cv.Yoto__c = '本人確認';
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.NinteiSeikyuWrapper nsw = ExSaisyuKakuninController.getNinteiSeikyuData(ns.Id);
            Test.stopTest();

            Assert.areEqual('公的個人認証', nsw.HonninKakuninHoho);
            Assert.isNull(nsw.fileList);
            Assert.areEqual('含まない', nsw.getFukumu18Text());
        }
    }

    /**
     * 銀行口座がゆうちょ
     */
    @isTest
    static void getSeikyushaDataGeneral1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            Seikyusha__c s = getSeikyusha();
            s.Yucho_Shumoku01__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual(s.Id, sw.Id);
            Assert.areEqual('セイキュウ　タロウ', sw.ShimeiFurigana);
            Assert.areEqual('請求　太郎', sw.Shimei);
            Assert.areEqual(date.newInstance(2000, 1, 15), sw.SeinenGappiDate);
            Assert.areEqual('000-0000', sw.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町', sw.Jusho);
            Assert.areEqual('000-0000-0000', sw.DenwaBangou);
            Assert.areEqual('test@example.com', sw.MailAddress);
            Assert.isTrue(sw.IsKozaFilled);
            Assert.isTrue(sw.IsYucho);
            Assert.areEqual('総合口座', sw.YuchoBunrui);
            Assert.areEqual('12345', sw.YuchoKigo);
            Assert.areEqual('12345678', sw.YuchoBango);
            Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', sw.YuchoKouzaMeigi);
            Assert.isNull(sw.KinyuKikan);
            Assert.isNull(sw.KinyuKikanCode);
            Assert.isNull(sw.Shiten);
            Assert.isNull(sw.ShitenCode);
            Assert.isNull(sw.Bunrui);
            Assert.isNull(sw.KouzaBangou);
            Assert.isNull(sw.KouzaMeigi);
            Assert.areEqual(1, sw.KozaShoruiList.size());
            Assert.areEqual(cv.Id, sw.KozaShoruiList[0]);

        }
    }

    /**
     * 銀行口座がゆうちょ 通せていないパターンを通す
     */
    @isTest
    static void getSeikyushaDataGeneral2(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            Seikyusha__c s = getSeikyusha();
            s.Yucho_Shumoku02__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual('通常貯金', sw.YuchoBunrui);

            s.Yucho_Shumoku02__c = false;
            s.Yucho_Shumoku03__c = true;
            update s;

            sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Assert.areEqual('通常貯蓄貯金', sw.YuchoBunrui);

            s.Yucho_Shumoku03__c = false;
            s.Yucho_Shumoku04__c = true;
            update s;

            sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Assert.areEqual('振替口座', sw.YuchoBunrui);
        }
    }

    /**
     * 銀行口座がその他
     */
    @isTest
    static void getSeikyushaDataGeneral3(){

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
            Seikyusha__c s = getSeikyusha();
            s.Shumoku01__c = true;
            s.KinyuKikan__c = kk.Id;
            s.Shiten__c = stn.Id;
            s.KouzaBango__c = '1234567';
            s.KouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual(s.Id, sw.Id);
            Assert.areEqual('セイキュウ　タロウ', sw.ShimeiFurigana);
            Assert.areEqual('請求　太郎', sw.Shimei);
            Assert.areEqual(date.newInstance(2000, 1, 15), sw.SeinenGappiDate);
            Assert.areEqual('000-0000', sw.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町', sw.Jusho);
            Assert.areEqual('000-0000-0000', sw.DenwaBangou);
            Assert.areEqual('test@example.com', sw.MailAddress);
            Assert.isTrue(sw.IsKozaFilled);
            Assert.isFalse(sw.IsYucho);
            Assert.isNull(sw.YuchoBunrui);
            Assert.isNull(sw.YuchoKigo);
            Assert.isNull(sw.YuchoBango);
            Assert.isNull(sw.YuchoKouzaMeigi);
            Assert.areEqual('テスト金融機関', sw.KinyuKikan);
            Assert.areEqual('XXX', sw.KinyuKikanCode);
            Assert.areEqual('テスト支店', sw.Shiten);
            Assert.areEqual('XYZ', sw.ShitenCode);
            Assert.areEqual('普通', sw.Bunrui);
            Assert.areEqual('1234567', sw.KouzaBangou);
            Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', sw.KouzaMeigi);
            Assert.areEqual(1, sw.KozaShoruiList.size());
            Assert.areEqual(cv.Id, sw.KozaShoruiList[0]);
        }
    }

    /**
     * 銀行口座がその他 通せていないパターンを通す
     */
    @isTest
    static void getSeikyushaDataGeneral4(){

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
            Seikyusha__c s = getSeikyusha();
            s.Shumoku02__c = true;
            s.KinyuKikan__c = kk.Id;
            s.Shiten__c = stn.Id;
            s.KouzaBango__c = '1234567';
            s.KouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual('当座', sw.Bunrui);

            s.Shumoku02__c = false;
            s.Shumoku03__c = true;
            update s;

            sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Assert.areEqual('貯蓄', sw.Bunrui);
        }
    }

    /**
     * 銀行口座が未登録
     */
    @isTest
    static void getSeikyushaDataGeneral5(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual(s.Id, sw.Id);
            Assert.areEqual('セイキュウ　タロウ', sw.ShimeiFurigana);
            Assert.areEqual('請求　太郎', sw.Shimei);
            Assert.areEqual(date.newInstance(2000, 1, 15), sw.SeinenGappiDate);
            Assert.areEqual('000-0000', sw.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町', sw.Jusho);
            Assert.areEqual('000-0000-0000', sw.DenwaBangou);
            Assert.areEqual('test@example.com', sw.MailAddress);
            Assert.isNull(sw.IsKozaFilled);
            Assert.isNull(sw.IsYucho);
            Assert.isNull(sw.YuchoBunrui);
            Assert.isNull(sw.YuchoKigo);
            Assert.isNull(sw.YuchoBango);
            Assert.isNull(sw.YuchoKouzaMeigi);
            Assert.isNull(sw.KinyuKikan);
            Assert.isNull(sw.KinyuKikanCode);
            Assert.isNull(sw.Shiten);
            Assert.isNull(sw.ShitenCode);
            Assert.isNull(sw.Bunrui);
            Assert.isNull(sw.KouzaBangou);
            Assert.isNull(sw.KouzaMeigi);
            Assert.areEqual(0, sw.KozaShoruiList.size());
        }
    }

    /**
     * 銀行口座がゆうちょ
     */
    @isTest
    static void getSeikyushaDataDv1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            DV_Seikyusha__c s = getSeikyushaDv();
            s.Yucho_Shumoku01__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual(s.Id, sw.Id);
            Assert.areEqual('セイキュウ　タロウ', sw.ShimeiFurigana);
            Assert.areEqual('請求　太郎', sw.Shimei);
            Assert.areEqual(date.newInstance(2000, 1, 15), sw.SeinenGappiDate);
            Assert.areEqual('000-0000', sw.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町', sw.Jusho);
            Assert.areEqual('000-0000-0000', sw.DenwaBangou);
            Assert.areEqual('test@example.com', sw.MailAddress);
            Assert.isTrue(sw.IsKozaFilled);
            Assert.isTrue(sw.IsYucho);
            Assert.areEqual('総合口座', sw.YuchoBunrui);
            Assert.areEqual('12345', sw.YuchoKigo);
            Assert.areEqual('12345678', sw.YuchoBango);
            Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', sw.YuchoKouzaMeigi);
            Assert.isNull(sw.KinyuKikan);
            Assert.isNull(sw.KinyuKikanCode);
            Assert.isNull(sw.Shiten);
            Assert.isNull(sw.ShitenCode);
            Assert.isNull(sw.Bunrui);
            Assert.isNull(sw.KouzaBangou);
            Assert.isNull(sw.KouzaMeigi);
            Assert.areEqual(1, sw.KozaShoruiList.size());
            Assert.areEqual(cv.Id, sw.KozaShoruiList[0]);

        }
    }

    /**
     * 銀行口座がゆうちょ 通せていないパターンを通す
     */
    @isTest
    static void getSeikyushaDataDv2(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            DV_Seikyusha__c s = getSeikyushaDv();
            s.Yucho_Shumoku02__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.DV_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual('通常貯金', sw.YuchoBunrui);

            s.Yucho_Shumoku02__c = false;
            s.Yucho_Shumoku03__c = true;
            update s;

            sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Assert.areEqual('通常貯蓄貯金', sw.YuchoBunrui);

            s.Yucho_Shumoku03__c = false;
            s.Yucho_Shumoku04__c = true;
            update s;

            sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Assert.areEqual('振替口座', sw.YuchoBunrui);
        }
    }

    /**
     * 銀行口座がその他
     */
    @isTest
    static void getSeikyushaDataSatoya1(){

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
            DV_Seikyusha__c s = getSeikyushaSatoya();
            s.Shumoku01__c = true;
            s.KinyuKikan__c = kk.Id;
            s.Shiten__c = stn.Id;
            s.KouzaBango__c = '1234567';
            s.KouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual(s.Id, sw.Id);
            Assert.areEqual('セイキュウ　タロウ', sw.ShimeiFurigana);
            Assert.areEqual('請求　太郎', sw.Shimei);
            Assert.areEqual(date.newInstance(2000, 1, 15), sw.SeinenGappiDate);
            Assert.areEqual('000-0000', sw.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町', sw.Jusho);
            Assert.areEqual('000-0000-0000', sw.DenwaBangou);
            Assert.areEqual('test@example.com', sw.MailAddress);
            Assert.isTrue(sw.IsKozaFilled);
            Assert.isFalse(sw.IsYucho);
            Assert.isNull(sw.YuchoBunrui);
            Assert.isNull(sw.YuchoKigo);
            Assert.isNull(sw.YuchoBango);
            Assert.isNull(sw.YuchoKouzaMeigi);
            Assert.areEqual('テスト金融機関', sw.KinyuKikan);
            Assert.areEqual('XXX', sw.KinyuKikanCode);
            Assert.areEqual('テスト支店', sw.Shiten);
            Assert.areEqual('XYZ', sw.ShitenCode);
            Assert.areEqual('普通', sw.Bunrui);
            Assert.areEqual('1234567', sw.KouzaBangou);
            Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', sw.KouzaMeigi);
            Assert.areEqual(1, sw.KozaShoruiList.size());
            Assert.areEqual(cv.Id, sw.KozaShoruiList[0]);
        }
    }

    /**
     * 銀行口座がその他 通せていないパターンを通す
     */
    @isTest
    static void getSeikyushaDataSatoya2(){

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
            DV_Seikyusha__c s = getSeikyushaSatoya();
            s.Shumoku02__c = true;
            s.KinyuKikan__c = kk.Id;
            s.Shiten__c = stn.Id;
            s.KouzaBango__c = '1234567';
            s.KouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.SATOYA_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual('当座', sw.Bunrui);

            s.Shumoku02__c = false;
            s.Shumoku03__c = true;
            update s;

            sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Assert.areEqual('貯蓄', sw.Bunrui);
        }
    }

    /**
     * 銀行口座が未登録
     */
    @isTest
    static void getSeikyushaDataSatoya3(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            DV_Seikyusha__c s = getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.SeikyushaWrapper sw = ExSaisyuKakuninController.getSeikyushaData(ns.Id);
            Test.stopTest();

            Assert.areEqual(s.Id, sw.Id);
            Assert.areEqual('セイキュウ　タロウ', sw.ShimeiFurigana);
            Assert.areEqual('請求　太郎', sw.Shimei);
            Assert.areEqual(date.newInstance(2000, 1, 15), sw.SeinenGappiDate);
            Assert.areEqual('000-0000', sw.YubinBangou);
            Assert.areEqual('テスト県テスト市テスト町', sw.Jusho);
            Assert.areEqual('000-0000-0000', sw.DenwaBangou);
            Assert.areEqual('test@example.com', sw.MailAddress);
            Assert.areEqual('小規模住居型児童養育事業者', sw.ShisetsuShurui);
            Assert.areEqual('テスト施設', sw.ShisetsuMeisho);
            Assert.isNull(sw.IsKozaFilled);
            Assert.isNull(sw.IsYucho);
            Assert.isNull(sw.YuchoBunrui);
            Assert.isNull(sw.YuchoKigo);
            Assert.isNull(sw.YuchoBango);
            Assert.isNull(sw.YuchoKouzaMeigi);
            Assert.isNull(sw.KinyuKikan);
            Assert.isNull(sw.KinyuKikanCode);
            Assert.isNull(sw.Shiten);
            Assert.isNull(sw.ShitenCode);
            Assert.isNull(sw.Bunrui);
            Assert.isNull(sw.KouzaBangou);
            Assert.isNull(sw.KouzaMeigi);
            Assert.areEqual(0, sw.KozaShoruiList.size());
        }
    }

    /**
     * 対象児童が登録されていない
     */
    @isTest
    static void getTaishoJidoData1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            ContentVersion cv = ExTestUtil.getContentVersion(sst, s.Id, ExTestUtil.GENERAL_NETWORK_ID);
            insert cv;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(0, tjwList.size());
        }
    }

    /**
     * 対象児童のデータを取得 口座情報以外の部分
     */
    @isTest
    static void getTaishoJidoDataGeneral1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.SeikyushaKubun_Taishosha__c = true;
            tj1.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj1.SeikyushaTsudukigara_Chichi__c = true;
            tj1.UketoriKouzaKubun_Seikyusha__c = true;

            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.SeikyushaKubun_Dairinin__c = true;
            tj2.SeikyushaDoukyoShubetsu_Bekkyo__c = true;
            tj2.YubinBangou__c = '000-2222';
            tj2.Jusho__c = 'テスト県テスト市テスト村';
            tj2.SeikyushaTsudukigara_Haha__c = true;
            tj2.IsKokuseki_Nihon__c = false;
            tj2.IsKokuseki_NihonIgai__c = true;
            tj2.UketoriKouzaKubun_Seikyusha__c = true;
            tj2.Bekkyo_Tanshifunin__c = false;
            tj2.Bekkyo_Shingaku__c = true;

            TaishoJido__c tj3 = getTaishoJido(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj3.SeikyushaTsudukigara_Sonota__c = true;
            tj3.SonotaShousai__c = 'その他続柄';
            tj3.UketoriKouzaKubun_Seikyusha__c = true;
            tj3.Bekkyo_Tanshifunin__c = false;
            tj3.Bekkyo_Sonota__c = true;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>{tj1, tj2, tj3};
            insert tjList;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (TaishoJido__c tj : tjList) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                for (TaishoJido__c tj : tjList) {
                    cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
                }
            }
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(3, tjwList.size());

            { // 対象者1
                ExSaisyuKakuninController.TaishoJidoWrapper tjw = tjwList[0];
                Assert.areEqual('A0', tjw.TaishoshaKubun);
                Assert.areEqual('対象者1', tjw.Shimei);
                Assert.areEqual('タイショウシャ', tjw.ShimeiFurigana);
                Assert.areEqual(date.newInstance(2015, 1, 30), tjw.SeinenGappiDate);
                Assert.isFalse(tjw.Fukumu18);
                Assert.areEqual('対象者自身が認定請求を行う', tjw.SeikyushaKubun);
                Assert.areEqual(System.label.EX_TJD_DoukyoShubetsu_Doukyo, tjw.SeikyushaDoukyoShubetsu);
                Assert.isTrue(tjw.getIsNotSeikyushaDoukyoShubetsuHonnin());
                Assert.isFalse(tjw.IsBekkyo);
                Assert.isNull(tjw.YubinBangou);
                Assert.isNull(tjw.Jusho);
                Assert.areEqual(System.label.EX_TJD_Tsudukigara_Chichi, tjw.SeikyushaTsudukigara);
                Assert.isNull(tjw.SonotaShousai);
                Assert.isTrue(tjw.IsTochuTennyuShussei);
                Assert.areEqual(date.newInstance(2023, 2, 1), tjw.TennyuShusseiDate);
                Assert.isTrue(tjw.IsTochuTenshutsu);
                Assert.areEqual(date.newInstance(2023, 3, 1), tjw.TenshutsuDate);
                Assert.areEqual(System.label.EX_TJD_Kokuseki_Nihon, tjw.Kokuseki);
                Assert.isFalse(tjw.getIsTsudukigaraSonota());

                Assert.isTrue(tjw.IsMoushitate);
                Assert.isTrue(tjw.IsKokennin);
                Assert.isTrue(tjw.IsBekkyoKango);
                Assert.isTrue(tjw.IsRyugaku);
                Assert.isTrue(tjw.IsRikon);
                Assert.isTrue(tjw.getIsBekkyoOrRyugaku());
                Assert.isTrue(tjw.IsFuboSitei);
                Assert.areEqual(System.label.EX_TJD_Bekkyo_Tanshinfunin, tjw.BekkyoRiyu);
                Assert.isNull(tjw.BekkyoRiyuSonota);
                Assert.isFalse(tjw.getIsBekkyoRiyuSonota());
                Assert.areEqual(date.newInstance(2023, 4, 1), tjw.BekkyoStart);
                Assert.areEqual(date.newInstance(2023, 4, 15), tjw.BekkyoEnd);
                Assert.areEqual('監護状況', tjw.KangoJokyo);
                Assert.areEqual('留学先名', tjw.Ryugakusaki);
                Assert.areEqual(date.newInstance(2023, 5, 1), tjw.RyugakumaeKyojuStart);
                Assert.areEqual(date.newInstance(2023, 5, 15), tjw.RyugakumaeKyojuEnd);
                Assert.areEqual('999-9999', tjw.RyugakumaeKyojuYubinBango);
                Assert.areEqual('留学先住所', tjw.RyugakumaeKyojuJusho);

                Assert.areEqual(7, tjw.TaishoJidoFileList.size());
            }

            { // 対象者2
                ExSaisyuKakuninController.TaishoJidoWrapper tjw = tjwList[1];
                Assert.areEqual('対象者2', tjw.Shimei);
                Assert.areEqual('対象者の代理人が認定請求を行う', tjw.SeikyushaKubun);
                Assert.areEqual(System.label.EX_TJD_DoukyoShubetsu_Bekkyo, tjw.SeikyushaDoukyoShubetsu);
                Assert.isTrue(tjw.IsBekkyo);
                Assert.areEqual('000-2222', tjw.YubinBangou);
                Assert.areEqual('テスト県テスト市テスト村', tjw.Jusho);
                Assert.areEqual(System.label.EX_TJD_Tsudukigara_Haha, tjw.SeikyushaTsudukigara);
                Assert.isNull(tjw.SonotaShousai);
                Assert.areEqual(System.label.EX_TJD_Kokuseki_NihonIgai, tjw.Kokuseki);
                Assert.areEqual(System.label.EX_TJD_Bekkyo_Shingaku, tjw.BekkyoRiyu);
                Assert.isNull(tjw.BekkyoRiyuSonota);
            }

            { // 対象者3
                ExSaisyuKakuninController.TaishoJidoWrapper tjw = tjwList[2];
                Assert.areEqual('対象者3', tjw.Shimei);
                Assert.areEqual(System.label.EX_TJD_DoukyoShubetsu_Honnin, tjw.SeikyushaDoukyoShubetsu);
                Assert.isFalse(tjw.getIsNotSeikyushaDoukyoShubetsuHonnin());
                Assert.isFalse(tjw.IsBekkyo);
                Assert.isNull(tjw.YubinBangou);
                Assert.isNull(tjw.Jusho);
                Assert.areEqual(System.label.EX_TJD_Tsudukigara_Sonota, tjw.SeikyushaTsudukigara);
                Assert.areEqual('その他続柄', tjw.SonotaShousai);
                Assert.areEqual(System.label.EX_TJD_Bekkyo_Sonota, tjw.BekkyoRiyu);
                Assert.areEqual('別居理由その他', tjw.BekkyoRiyuSonota);
                Assert.isTrue(tjw.getIsBekkyoRiyuSonota());
            }
        }
    }

    /**
     * 対象児童のデータを取得 ゆうちょ
     */
    @isTest
    static void getTaishoJidoDataGeneral2(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.TJ_Yucho_Shumoku01__c = true;
            tj1.YuchoKigo__c = '12345';
            tj1.YuchoBango__c = '12345678';
            tj1.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ1';

            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.TJ_Yucho_Shumoku02__c = true;
            tj2.YuchoKigo__c = '12345';
            tj2.YuchoBango__c = '12345678';
            tj2.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ2';

            TaishoJido__c tj3 = getTaishoJido(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.UketoriKouzaKubun_Taishosha__c = true;
            tj3.TJ_Yucho_Shumoku03__c = true;
            tj3.YuchoKigo__c = '12345';
            tj3.YuchoBango__c = '12345678';
            tj3.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ3';

            TaishoJido__c tj4 = getTaishoJido(ns, tk);
            tj4.Shimei__c = '対象者4';
            tj4.UketoriKouzaKubun_Taishosha__c = true;
            tj4.TJ_Yucho_Shumoku04__c = true;
            tj4.YuchoKigo__c = '12345';
            tj4.YuchoBango__c = '12345678';
            tj4.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ4';

            List<TaishoJido__c> tjList = new List<TaishoJido__c>{tj1, tj2, tj3, tj4};
            insert tjList;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID);

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(4, tjwList.size());

            Assert.isTrue(tjwList[0].IsYucho);
            Assert.areEqual('12345', tjwList[0].YuchoKigo);
            Assert.areEqual('12345678', tjwList[0].YuchoBango);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ1', tjwList[0].YuchoKouzaMeigi);

            Assert.areEqual('総合口座', tjwList[0].YuchoBunrui);
            Assert.areEqual('通常貯金', tjwList[1].YuchoBunrui);
            Assert.areEqual('通常貯蓄貯金', tjwList[2].YuchoBunrui);
            Assert.areEqual('振替口座', tjwList[3].YuchoBunrui);

            Assert.areEqual(1, tjwList[0].TaishoJidoFileList.size());
        }
    }

/**
     * 対象児童のデータを取得 その他口座
     */
    @isTest
    static void getTaishoJidoDataGeneral3(){

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

            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.KinyuKikan__c = kk.Id;
            tj1.Shiten__c = stn.Id;
            tj1.TJ_Shumoku01__c = true;
            tj1.KouzaBangou__c = '1234567';
            tj1.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ1';

            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.KinyuKikan__c = kk.Id;
            tj2.Shiten__c = stn.Id;
            tj2.TJ_Shumoku02__c = true;
            tj2.KouzaBangou__c = '1234567';
            tj2.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ2';

            TaishoJido__c tj3 = getTaishoJido(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.UketoriKouzaKubun_Taishosha__c = true;
            tj3.KinyuKikan__c = kk.Id;
            tj3.Shiten__c = stn.Id;
            tj3.TJ_Shumoku03__c = true;
            tj3.KouzaBangou__c = '1234567';
            tj3.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ3';

            List<TaishoJido__c> tjList = new List<TaishoJido__c>{tj1, tj2, tj3};
            insert tjList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(3, tjwList.size());

            Assert.isFalse(tjwList[0].IsYucho);
            Assert.areEqual('テスト金融機関', tjwList[0].KinyuKikan);
            Assert.areEqual('XXX', tjwList[0].KinyuKikanCode);
            Assert.areEqual('テスト支店', tjwList[0].Shiten);
            Assert.areEqual('XYZ', tjwList[0].ShitenCode);
            Assert.areEqual('1234567', tjwList[0].KouzaBangou);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ1', tjwList[0].KouzaMeigi);

            Assert.areEqual('普通', tjwList[0].Bunrui);
            Assert.areEqual('当座', tjwList[1].Bunrui);
            Assert.areEqual('貯蓄', tjwList[2].Bunrui);
        }
    }

/**
     * 対象児童のデータを取得 口座情報以外の部分
     */
    @isTest
    static void getTaishoJidoDataDv1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj1 = getTaishoJidoDv(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.SeikyushaKubun_Taishosha__c = true;
            tj1.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj1.SeikyushaTsudukigara_Chichi__c = true;
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.Moushitate_BetsuJushoCheck__c = true;

            DV_TaishoJido__c tj2 = getTaishoJidoDv(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.SeikyushaKubun_Dairinin__c = true;
            tj2.SeikyushaDoukyoShubetsu_Bekkyo__c = true;
            tj2.YubinBangou__c = '000-2222';
            tj2.Jusho__c = 'テスト県テスト市テスト村';
            tj2.SeikyushaTsudukigara_Haha__c = true;
            tj2.IsKokuseki_Nihon__c = false;
            tj2.IsKokuseki_NihonIgai__c = true;
            tj2.UketoriKouzaKubun_Seikyusha__c = true;
            tj2.Bekkyo_Tanshifunin__c = false;
            tj2.Bekkyo_Shingaku__c = true;

            DV_TaishoJido__c tj3 = getTaishoJidoDv(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj3.SeikyushaTsudukigara_Sonota__c = true;
            tj3.SonotaShousai__c = 'その他続柄';
            tj3.UketoriKouzaKubun_Seikyusha__c = true;
            tj3.Bekkyo_Tanshifunin__c = false;
            tj3.Bekkyo_Sonota__c = true;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2, tj3};
            insert tjList;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (DV_TaishoJido__c tj : tjList) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.DV_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                for (DV_TaishoJido__c tj : tjList) {
                    cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj.Id, ExTestUtil.DV_NETWORK_ID));
                }
            }
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(3, tjwList.size());

            { // 対象者1
                ExSaisyuKakuninController.TaishoJidoWrapper tjw = tjwList[0];
                Assert.areEqual('A0', tjw.TaishoshaKubun);
                Assert.areEqual('対象者1', tjw.Shimei);
                Assert.areEqual('タイショウシャ', tjw.ShimeiFurigana);
                Assert.areEqual(date.newInstance(2015, 1, 30), tjw.SeinenGappiDate);
                Assert.isFalse(tjw.Fukumu18);
                Assert.areEqual('対象者自身が認定請求を行う', tjw.SeikyushaKubun);
                Assert.areEqual(System.label.EX_TJD_DoukyoShubetsu_Doukyo, tjw.SeikyushaDoukyoShubetsu);
                Assert.isFalse(tjw.IsBekkyo);
                Assert.isNull(tjw.YubinBangou);
                Assert.isNull(tjw.Jusho);
                Assert.areEqual(System.label.EX_TJD_Tsudukigara_Chichi, tjw.SeikyushaTsudukigara);
                Assert.isNull(tjw.SonotaShousai);
                Assert.isTrue(tjw.IsTochuTennyuShussei);
                Assert.areEqual(date.newInstance(2023, 2, 1), tjw.TennyuShusseiDate);
                Assert.isTrue(tjw.IsTochuTenshutsu);
                Assert.areEqual(date.newInstance(2023, 3, 1), tjw.TenshutsuDate);
                Assert.areEqual(System.label.EX_TJD_Kokuseki_Nihon, tjw.Kokuseki);
                Assert.isFalse(tjw.getIsTsudukigaraSonota());

                Assert.isTrue(tjw.IsMoushitate);
                Assert.isTrue(tjw.IsKokennin);
                Assert.isTrue(tjw.IsBekkyoKango);
                Assert.isTrue(tjw.IsRyugaku);
                Assert.isTrue(tjw.IsRikon);
                Assert.isTrue(tjw.IsFuboSitei);
                Assert.isTrue(tjw.IsBetsuJusho);
                Assert.areEqual(System.label.EX_TJD_Bekkyo_Tanshinfunin, tjw.BekkyoRiyu);
                Assert.isNull(tjw.BekkyoRiyuSonota);
                Assert.areEqual(date.newInstance(2023, 4, 1), tjw.BekkyoStart);
                Assert.areEqual(date.newInstance(2023, 4, 15), tjw.BekkyoEnd);
                Assert.areEqual('監護状況', tjw.KangoJokyo);
                Assert.areEqual('留学先名', tjw.Ryugakusaki);
                Assert.areEqual(date.newInstance(2023, 5, 1), tjw.RyugakumaeKyojuStart);
                Assert.areEqual(date.newInstance(2023, 5, 15), tjw.RyugakumaeKyojuEnd);
                Assert.areEqual('999-9999', tjw.RyugakumaeKyojuYubinBango);
                Assert.areEqual('留学先住所', tjw.RyugakumaeKyojuJusho);

                Assert.areEqual(7, tjw.TaishoJidoFileList.size());
            }

            { // 対象者2
                ExSaisyuKakuninController.TaishoJidoWrapper tjw = tjwList[1];
                Assert.areEqual('対象者2', tjw.Shimei);
                Assert.areEqual('対象者の代理人が認定請求を行う', tjw.SeikyushaKubun);
                Assert.areEqual(System.label.EX_TJD_DoukyoShubetsu_Bekkyo, tjw.SeikyushaDoukyoShubetsu);
                Assert.isTrue(tjw.IsBekkyo);
                Assert.areEqual('000-2222', tjw.YubinBangou);
                Assert.areEqual('テスト県テスト市テスト村', tjw.Jusho);
                Assert.areEqual(System.label.EX_TJD_Tsudukigara_Haha, tjw.SeikyushaTsudukigara);
                Assert.isNull(tjw.SonotaShousai);
                Assert.areEqual(System.label.EX_TJD_Kokuseki_NihonIgai, tjw.Kokuseki);
                Assert.areEqual(System.label.EX_TJD_Bekkyo_Shingaku, tjw.BekkyoRiyu);
                Assert.isNull(tjw.BekkyoRiyuSonota);
            }

            { // 対象者3
                ExSaisyuKakuninController.TaishoJidoWrapper tjw = tjwList[2];
                Assert.areEqual('対象者3', tjw.Shimei);
                Assert.areEqual(System.label.EX_TJD_DoukyoShubetsu_Honnin, tjw.SeikyushaDoukyoShubetsu);
                Assert.isFalse(tjw.IsBekkyo);
                Assert.isNull(tjw.YubinBangou);
                Assert.isNull(tjw.Jusho);
                Assert.areEqual(System.label.EX_TJD_Tsudukigara_Sonota, tjw.SeikyushaTsudukigara);
                Assert.areEqual('その他続柄', tjw.SonotaShousai);
                Assert.areEqual(System.label.EX_TJD_Bekkyo_Sonota, tjw.BekkyoRiyu);
                Assert.areEqual('別居理由その他', tjw.BekkyoRiyuSonota);
            }
        }
    }

    /**
     * 対象児童のデータを取得 ゆうちょ
     */
    @isTest
    static void getTaishoJidoDataSatoya1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj1 = getTaishoJidoSatoya(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.TJ_Yucho_Shumoku01__c = true;
            tj1.YuchoKigo__c = '12345';
            tj1.YuchoBango__c = '12345678';
            tj1.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ1';

            DV_TaishoJido__c tj2 = getTaishoJidoSatoya(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.TJ_Yucho_Shumoku02__c = true;
            tj2.YuchoKigo__c = '12345';
            tj2.YuchoBango__c = '12345678';
            tj2.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ2';

            DV_TaishoJido__c tj3 = getTaishoJidoSatoya(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.UketoriKouzaKubun_Taishosha__c = true;
            tj3.TJ_Yucho_Shumoku03__c = true;
            tj3.YuchoKigo__c = '12345';
            tj3.YuchoBango__c = '12345678';
            tj3.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ3';

            DV_TaishoJido__c tj4 = getTaishoJidoSatoya(ns, tk);
            tj4.Shimei__c = '対象者4';
            tj4.UketoriKouzaKubun_Taishosha__c = true;
            tj4.TJ_Yucho_Shumoku04__c = true;
            tj4.YuchoKigo__c = '12345';
            tj4.YuchoBango__c = '12345678';
            tj4.YuchoKouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ4';

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2, tj3, tj4};
            insert tjList;

            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID);

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(4, tjwList.size());

            Assert.areEqual('はい', tjwList[0].KonnendochuShinkiSochi);
            Assert.areEqual('備考', tjwList[0].Biko);

            Assert.isTrue(tjwList[0].IsYucho);
            Assert.areEqual('12345', tjwList[0].YuchoKigo);
            Assert.areEqual('12345678', tjwList[0].YuchoBango);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ1', tjwList[0].YuchoKouzaMeigi);

            Assert.areEqual('総合口座', tjwList[0].YuchoBunrui);
            Assert.areEqual('通常貯金', tjwList[1].YuchoBunrui);
            Assert.areEqual('通常貯蓄貯金', tjwList[2].YuchoBunrui);
            Assert.areEqual('振替口座', tjwList[3].YuchoBunrui);

            Assert.areEqual(1, tjwList[0].TaishoJidoFileList.size());
        }
    }

/**
     * 対象児童のデータを取得 その他口座
     */
    @isTest
    static void getTaishoJidoDataSatoya2(){

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

            DV_Seikyusha__c s = getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj1 = getTaishoJidoSatoya(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.KinyuKikan__c = kk.Id;
            tj1.Shiten__c = stn.Id;
            tj1.TJ_Shumoku01__c = true;
            tj1.KouzaBangou__c = '1234567';
            tj1.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ1';

            DV_TaishoJido__c tj2 = getTaishoJidoSatoya(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;
            tj2.KinyuKikan__c = kk.Id;
            tj2.Shiten__c = stn.Id;
            tj2.TJ_Shumoku02__c = true;
            tj2.KouzaBangou__c = '1234567';
            tj2.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ2';

            DV_TaishoJido__c tj3 = getTaishoJidoSatoya(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.UketoriKouzaKubun_Taishosha__c = true;
            tj3.KinyuKikan__c = kk.Id;
            tj3.Shiten__c = stn.Id;
            tj3.TJ_Shumoku03__c = true;
            tj3.KouzaBangou__c = '1234567';
            tj3.KouzaMeigi__c = 'ﾀｲｼﾖｳｼﾔ3';

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2, tj3};
            insert tjList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExSaisyuKakuninController.TaishoJidoWrapper> tjwList = ExSaisyuKakuninController.getTaishoJidoData(ns.Id);
            Test.stopTest();

            Assert.areEqual(3, tjwList.size());

            Assert.isFalse(tjwList[0].IsYucho);
            Assert.areEqual('テスト金融機関', tjwList[0].KinyuKikan);
            Assert.areEqual('XXX', tjwList[0].KinyuKikanCode);
            Assert.areEqual('テスト支店', tjwList[0].Shiten);
            Assert.areEqual('XYZ', tjwList[0].ShitenCode);
            Assert.areEqual('1234567', tjwList[0].KouzaBangou);
            Assert.areEqual('ﾀｲｼﾖｳｼﾔ1', tjwList[0].KouzaMeigi);

            Assert.areEqual('普通', tjwList[0].Bunrui);
            Assert.areEqual('当座', tjwList[1].Bunrui);
            Assert.areEqual('貯蓄', tjwList[2].Bunrui);
        }
    }

    /**
     * 必要情報のチェックを行う
     */
    @isTest
    static void validationTaishoJidoGeneral1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            // 書類等すべて提出済
            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.MoushitateCheck__c = true;
            tj1.KouzaJohoCheck__c = true;

            // 全情報未提出
            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>{tj1, tj2};
            insert tjList;

            // 1の分だけ書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExValidationUtil.ErrorLog> result = ExSaisyuKakuninController.validationTaishoJido(ns.Id);
            Test.stopTest();

            Assert.areEqual(1, result.size());

            Assert.areEqual('【対象者2】', result[0].field);
            Assert.areEqual(System.label.EX_TJD_NeedKazokuKakuninFile
                + '\n' + System.label.EX_TJD_IsNotMoushitateFinished
                + '\n' + System.label.EX_TJD_NeedMoushitateFile
                + '\n' + System.label.EX_TJD_IsNotKozaJohoFinished
                + '\n' + System.label.EX_TJD_NeedKozaKakuninFile
                , result[0].message);
        }
    }

    /**
     * 必要情報のチェックを行う 通せていないパターンを通す
     */
    @isTest
    static void validationTaishoJidoGeneral2(){

        List<ShinseiShoruiTeigi__c> sstMoushitateList = ExShinseiShoruiTeigiUtil.getListByMoushitatesho();
        List<ShinseiShoruiTeigi__c> deleteSstMoushitateList = new List<ShinseiShoruiTeigi__c>();
        deleteSstMoushitateList.add(sstMoushitateList[0]);
        deleteSstMoushitateList.add(sstMoushitateList[1]);
        deleteSstMoushitateList.add(sstMoushitateList[2]);
        delete deleteSstMoushitateList;

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = getSeikyusha();
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            // 申立書入力
            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.KouzaJohoCheck__c = true;

            // 申立書 ファイルアップロード ( + 請求者の口座情報 入力)
            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Seikyusha__c = true;
            tj2.MoushitateCheck__c = true;
            tj2.KouzaJohoCheck__c = true;

            // 請求者の口座情報 入力
            TaishoJido__c tj3 = getTaishoJido(ns, tk);
            tj3.Shimei__c = '対象者3';
            tj3.UketoriKouzaKubun_Seikyusha__c = true;
            tj3.MoushitateCheck__c = true;
            tj3.KouzaJohoCheck__c = true;

            // 口座情報 入力
            TaishoJido__c tj4 = getTaishoJido(ns, tk);
            tj4.Shimei__c = '対象者4';
            tj4.UketoriKouzaKubun_Taishosha__c = true;
            tj4.MoushitateCheck__c = true;

            // 口座情報 ファイルアップロード
            TaishoJido__c tj5 = getTaishoJido(ns, tk);
            tj5.Shimei__c = '対象者5';
            tj5.UketoriKouzaKubun_Taishosha__c = true;
            tj5.MoushitateCheck__c = true;
            tj5.KouzaJohoCheck__c = true;

            List<TaishoJido__c> tjList = new List<TaishoJido__c>{tj1, tj2, tj3, tj4, tj5};
            insert tjList;

            // 書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();

            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                for (TaishoJido__c tj : tjList) {
                    cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
                }
            }
            List<TaishoJido__c> moushitateTjList = new List<TaishoJido__c>{tj1, tj3, tj4, tj5};
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                for (TaishoJido__c tj : moushitateTjList) {
                    cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
                }
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            List<TaishoJido__c> kozaTjList = new List<TaishoJido__c>{tj1, tj2, tj3, tj4};
            for (TaishoJido__c tj : kozaTjList) {
                cvList.add(ExTestUtil.getContentVersion(sstKoza, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExValidationUtil.ErrorLog> result = ExSaisyuKakuninController.validationTaishoJido(ns.Id);
            Test.stopTest();

            Assert.areEqual(5, result.size());

            Assert.areEqual(System.label.EX_TJD_IsNotMoushitateFinished, result[0].message);
            Assert.areEqual(System.label.EX_TJD_NeedMoushitateFile + '\n' + System.label.EX_TJD_IsNotSeikyushaKozaJohoFinished, result[1].message);
            Assert.areEqual(System.label.EX_TJD_IsNotSeikyushaKozaJohoFinished, result[2].message);
            Assert.areEqual(System.label.EX_TJD_IsNotKozaJohoFinished, result[3].message);
            Assert.areEqual(System.label.EX_TJD_NeedKozaKakuninFile, result[4].message);
        }
    }

    /**
     * 必要情報のチェックを行う
     */
    @isTest
    static void validationTaishoJidoDv1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            // 書類等すべて提出済
            DV_TaishoJido__c tj1 = getTaishoJidoDv(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.MoushitateCheck__c = true;
            tj1.KouzaJohoCheck__c = true;

            // 全情報未提出
            DV_TaishoJido__c tj2 = getTaishoJidoDv(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2};
            insert tjList;

            // 1の分だけ書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.DV_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.DV_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.DV_NETWORK_ID));
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExValidationUtil.ErrorLog> result = ExSaisyuKakuninController.validationTaishoJido(ns.Id);
            Test.stopTest();

            Assert.areEqual(1, result.size());

            Assert.areEqual('【対象者2】', result[0].field);
            Assert.areEqual(System.label.EX_TJD_NeedKazokuKakuninFile
                + '\n' + System.label.EX_TJD_IsNotMoushitateFinished
                + '\n' + System.label.EX_TJD_NeedMoushitateFile
                + '\n' + System.label.EX_TJD_IsNotKozaJohoFinished
                + '\n' + System.label.EX_TJD_NeedKozaKakuninFile
                , result[0].message);
        }
    }

    /**
     * 必要情報のチェックを行う
     */
    @isTest
    static void validationTaishoJidoSatoya1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = getSeikyushaSatoya();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            // 書類等すべて提出済
            DV_TaishoJido__c tj1 = getTaishoJidoSatoya(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.UketoriKouzaKubun_Taishosha__c = true;
            tj1.MoushitateCheck__c = true;
            tj1.KouzaJohoCheck__c = true;

            // 全情報未提出
            DV_TaishoJido__c tj2 = getTaishoJidoSatoya(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.UketoriKouzaKubun_Taishosha__c = true;

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2};
            insert tjList;

            // 1の分だけ書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID));
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            List<ExValidationUtil.ErrorLog> result = ExSaisyuKakuninController.validationTaishoJido(ns.Id);
            Test.stopTest();

            Assert.areEqual(1, result.size());

            Assert.areEqual('【対象者2】', result[0].field);
            Assert.areEqual(System.label.EX_TJD_NeedKazokuKakuninFile
                + '\n' + System.label.EX_TJD_IsNotMoushitateFinished
                + '\n' + System.label.EX_TJD_NeedMoushitateFile
                + '\n' + System.label.EX_TJD_IsNotKozaJohoFinished
                + '\n' + System.label.EX_TJD_NeedKozaKakuninFile
                , result[0].message);
        }
    }

    /**
     * 認定請求を申請する
     */
    @isTest
    static void submitRequestGeneral1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            Seikyusha__c s = getSeikyusha();
            s.Yucho_Shumoku01__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyu(s);
            insert ns;

            TaishoJido__c tj1 = getTaishoJido(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.Moushitate_KokenninCheck__c = false;
            tj1.Moushitate_BekkyoKango__c = false;
            tj1.Moushitate_KaigaiRyugakuCheck__c = false;
            tj1.Moushitate_RikonKyogiCheck__c = false;
            tj1.Moushitate_FuboSiteishaCheck__c = true;

            TaishoJido__c tj2 = getTaishoJido(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj2.Moushitate_FuboSiteishaCheck__c = true;
            tj2.ShinsaKekkaSaishu__c = 'NG';

            List<TaishoJido__c> tjList = new List<TaishoJido__c>{tj1, tj2};
            insert tjList;

            // 書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            ShinseiShoruiTeigi__c sstKojin = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKojin, ns.Id, ExTestUtil.GENERAL_NETWORK_ID));
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.GENERAL_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.GENERAL_NETWORK_ID));
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.submitRequest(ns.Id);
            Test.stopTest();

            tjList = [
                SELECT
                    Id
                    ,Shimei__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,SK_Yucho_Shumoku01__c
                    ,SK_Yucho_Shumoku02__c
                    ,SK_Yucho_Shumoku03__c
                    ,SK_Yucho_Shumoku04__c
                    ,SK_YuchoBango__c
                    ,SK_YuchoKigo__c
                    ,SK_YuuchoKouzaMeigi__c
                    ,SK_KinyuKikan__c
                    ,SK_KinyuKikanCode__c
                    ,SK_Shiten__c
                    ,SK_ShitenCode__c
                    ,SK_Shumoku01__c
                    ,SK_Shumoku02__c
                    ,SK_Shumoku03__c
                    ,SK_KouzaBango__c
                    ,SK_KouzaMeigi__c
                    ,MoushideDate__c
                FROM TaishoJido__c
                WHERE Id in :tjList
            ];

            { // 対象者1
                TaishoJido__c tj = tjList[0];
                Assert.areEqual('対象者1', tj.Shimei__c);
                Assert.areEqual('000-0000', tj.YubinBangou__c);
                Assert.areEqual('テスト県テスト市テスト町', tj.Jusho__c);
                Assert.isTrue(tj.SK_Yucho_Shumoku01__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku02__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku03__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku04__c);
                Assert.areEqual('12345678', tj.SK_YuchoBango__c);
                Assert.areEqual('12345', tj.SK_YuchoKigo__c);
                Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', tj.SK_YuuchoKouzaMeigi__c);
                Assert.isNull(tj.SK_KinyuKikan__c);
                Assert.isNull(tj.SK_KinyuKikanCode__c);
                Assert.isNull(tj.SK_Shiten__c);
                Assert.isNull(tj.SK_ShitenCode__c);
                Assert.isFalse(tj.SK_Shumoku01__c);
                Assert.isFalse(tj.SK_Shumoku02__c);
                Assert.isFalse(tj.SK_Shumoku03__c);
                Assert.isNull(tj.SK_KouzaBango__c);
                Assert.isNull(tj.SK_KouzaMeigi__c);
                Assert.areEqual(Date.today(), tj.MoushideDate__c);
            }

            { // 対象者2
                TaishoJido__c tj = tjList[1];
                Assert.areEqual('対象者2', tj.Shimei__c);
                Assert.areEqual('000-0000', tj.YubinBangou__c);
                Assert.areEqual('テスト県テスト市テスト町', tj.Jusho__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku01__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku02__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku03__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku04__c);
                Assert.isNull(tj.SK_YuchoBango__c);
                Assert.isNull(tj.SK_YuchoKigo__c);
                Assert.isNull(tj.SK_YuuchoKouzaMeigi__c);
                Assert.isNull(tj.SK_KinyuKikan__c);
                Assert.isNull(tj.SK_KinyuKikanCode__c);
                Assert.isNull(tj.SK_Shiten__c);
                Assert.isNull(tj.SK_ShitenCode__c);
                Assert.isFalse(tj.SK_Shumoku01__c);
                Assert.isFalse(tj.SK_Shumoku02__c);
                Assert.isFalse(tj.SK_Shumoku03__c);
                Assert.isNull(tj.SK_KouzaBango__c);
                Assert.isNull(tj.SK_KouzaMeigi__c);
                Assert.isNull(tj.MoushideDate__c);
            }

            cvList = [SELECT Id, IsDeletable__c FROM ContentVersion WHERE Id in :cvList];
            for (ContentVersion cv : cvList) {
                Assert.isFalse(cv.IsDeletable__c);
            }

            ns = [SELECT Id, ShinsaStatus__c, ShinseiKanryoDateTime__c FROM NinteiSeikyu__c WHERE Id = :ns.Id];
            Assert.areEqual('OCR処理中', ns.ShinsaStatus__c);
            Assert.areEqual(Date.today(), ns.ShinseiKanryoDateTime__c.date());
        }
    }

    /**
     * 認定請求を申請する
     */
    @isTest
    static void submitRequestDv1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = getSeikyushaDv();
            s.Yucho_Shumoku01__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj1 = getTaishoJidoDv(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.Moushitate_KokenninCheck__c = false;
            tj1.Moushitate_BekkyoKango__c = false;
            tj1.Moushitate_KaigaiRyugakuCheck__c = false;
            tj1.Moushitate_RikonKyogiCheck__c = false;
            tj1.Moushitate_FuboSiteishaCheck__c = true;

            DV_TaishoJido__c tj2 = getTaishoJidoDv(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj2.Moushitate_FuboSiteishaCheck__c = true;
            tj2.ShinsaKekkaSaishu__c = 'NG';

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2};
            insert tjList;

            // 書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            ShinseiShoruiTeigi__c sstKojin = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKojin, ns.Id, ExTestUtil.DV_NETWORK_ID));
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.DV_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.DV_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.DV_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.DV_NETWORK_ID));
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.submitRequest(ns.Id);
            Test.stopTest();

            tjList = [
                SELECT
                    Id
                    ,Shimei__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,SK_Yucho_Shumoku01__c
                    ,SK_Yucho_Shumoku02__c
                    ,SK_Yucho_Shumoku03__c
                    ,SK_Yucho_Shumoku04__c
                    ,SK_YuchoBango__c
                    ,SK_YuchoKigo__c
                    ,SK_YuuchoKouzaMeigi__c
                    ,SK_KinyuKikan__c
                    ,SK_KinyuKikanCode__c
                    ,SK_Shiten__c
                    ,SK_ShitenCode__c
                    ,SK_Shumoku01__c
                    ,SK_Shumoku02__c
                    ,SK_Shumoku03__c
                    ,SK_KouzaBango__c
                    ,SK_KouzaMeigi__c
                    ,MoushideDate__c
                FROM DV_TaishoJido__c
                WHERE Id in :tjList
            ];

            { // 対象者1
                DV_TaishoJido__c tj = tjList[0];
                Assert.areEqual('対象者1', tj.Shimei__c);
                Assert.areEqual('000-0000', tj.YubinBangou__c);
                Assert.areEqual('テスト県テスト市テスト町', tj.Jusho__c);
                Assert.isTrue(tj.SK_Yucho_Shumoku01__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku02__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku03__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku04__c);
                Assert.areEqual('12345678', tj.SK_YuchoBango__c);
                Assert.areEqual('12345', tj.SK_YuchoKigo__c);
                Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', tj.SK_YuuchoKouzaMeigi__c);
                Assert.isNull(tj.SK_KinyuKikan__c);
                Assert.isNull(tj.SK_KinyuKikanCode__c);
                Assert.isNull(tj.SK_Shiten__c);
                Assert.isNull(tj.SK_ShitenCode__c);
                Assert.isFalse(tj.SK_Shumoku01__c);
                Assert.isFalse(tj.SK_Shumoku02__c);
                Assert.isFalse(tj.SK_Shumoku03__c);
                Assert.isNull(tj.SK_KouzaBango__c);
                Assert.isNull(tj.SK_KouzaMeigi__c);
                Assert.areEqual(Date.today(), tj.MoushideDate__c);
            }

            { // 対象者2
                DV_TaishoJido__c tj = tjList[1];
                Assert.areEqual('対象者2', tj.Shimei__c);
                Assert.areEqual('000-0000', tj.YubinBangou__c);
                Assert.areEqual('テスト県テスト市テスト町', tj.Jusho__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku01__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku02__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku03__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku04__c);
                Assert.isNull(tj.SK_YuchoBango__c);
                Assert.isNull(tj.SK_YuchoKigo__c);
                Assert.isNull(tj.SK_YuuchoKouzaMeigi__c);
                Assert.isNull(tj.SK_KinyuKikan__c);
                Assert.isNull(tj.SK_KinyuKikanCode__c);
                Assert.isNull(tj.SK_Shiten__c);
                Assert.isNull(tj.SK_ShitenCode__c);
                Assert.isFalse(tj.SK_Shumoku01__c);
                Assert.isFalse(tj.SK_Shumoku02__c);
                Assert.isFalse(tj.SK_Shumoku03__c);
                Assert.isNull(tj.SK_KouzaBango__c);
                Assert.isNull(tj.SK_KouzaMeigi__c);
                Assert.isNull(tj.MoushideDate__c);
            }

            cvList = [SELECT Id, IsDeletable__c FROM ContentVersion WHERE Id in :cvList];
            for (ContentVersion cv : cvList) {
                Assert.isFalse(cv.IsDeletable__c);
            }

            ns = [SELECT Id, ShinsaStatus__c, ShinseiKanryoDateTime__c FROM DV_NinteiSeikyu__c WHERE Id = :ns.Id];
            Assert.areEqual('OCR処理中', ns.ShinsaStatus__c);
            Assert.areEqual(Date.today(), ns.ShinseiKanryoDateTime__c.date());
        }
    }

    /**
     * 認定請求を申請する
     */
    @isTest
    static void submitRequestSatoya1(){

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = getSeikyushaSatoya();
            s.Yucho_Shumoku01__c = true;
            s.YuchoBango__c = '12345678';
            s.YuchoKigo__c = '12345';
            s.YuchoKouzaMeigi__c = 'ｾｲｷﾕｳ ﾀﾛｳ';
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuSatoya(s);
            insert ns;

            DV_TaishoJido__c tj1 = getTaishoJidoSatoya(ns, tk);
            tj1.Shimei__c = '対象者1';
            tj1.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj1.UketoriKouzaKubun_Seikyusha__c = true;
            tj1.Moushitate_KokenninCheck__c = false;
            tj1.Moushitate_BekkyoKango__c = false;
            tj1.Moushitate_KaigaiRyugakuCheck__c = false;
            tj1.Moushitate_RikonKyogiCheck__c = false;
            tj1.Moushitate_FuboSiteishaCheck__c = true;

            DV_TaishoJido__c tj2 = getTaishoJidoSatoya(ns, tk);
            tj2.Shimei__c = '対象者2';
            tj2.SeikyushaDoukyoShubetsu_Honnin__c = true;
            tj2.Moushitate_FuboSiteishaCheck__c = true;
            tj2.ShinsaKekkaSaishu__c = 'NG';

            List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>{tj1, tj2};
            insert tjList;

            // 書類登録
            List<ContentVersion> cvList = new List<ContentVersion>();
            ShinseiShoruiTeigi__c sstKojin = ExShinseiShoruiTeigiUtil.getListByKojinNinsho()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKojin, ns.Id, ExTestUtil.SATOYA_NETWORK_ID));
            for (ShinseiShoruiTeigi__c sstKazoku : ExShinseiShoruiTeigiUtil.getListByTaishoJido()) {
                cvList.add(ExTestUtil.getContentVersion(sstKazoku, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID));
            }
            for (ShinseiShoruiTeigi__c sstMoushitate : ExShinseiShoruiTeigiUtil.getListByMoushitatesho()) {
                cvList.add(ExTestUtil.getContentVersion(sstMoushitate, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID));
            }
            ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            cvList.add(ExTestUtil.getContentVersion(sstKoza, s.Id, ExTestUtil.SATOYA_NETWORK_ID));
            cvList.add(ExTestUtil.getContentVersion(sstKoza, tj1.Id, ExTestUtil.SATOYA_NETWORK_ID));
            insert cvList;

            // 本人確認情報を取得する
            Test.startTest();
            ExSaisyuKakuninController.submitRequest(ns.Id);
            Test.stopTest();

            tjList = [
                SELECT
                    Id
                    ,Shimei__c
                    ,YubinBangou__c
                    ,Jusho__c
                    ,SK_Yucho_Shumoku01__c
                    ,SK_Yucho_Shumoku02__c
                    ,SK_Yucho_Shumoku03__c
                    ,SK_Yucho_Shumoku04__c
                    ,SK_YuchoBango__c
                    ,SK_YuchoKigo__c
                    ,SK_YuuchoKouzaMeigi__c
                    ,SK_KinyuKikan__c
                    ,SK_KinyuKikanCode__c
                    ,SK_Shiten__c
                    ,SK_ShitenCode__c
                    ,SK_Shumoku01__c
                    ,SK_Shumoku02__c
                    ,SK_Shumoku03__c
                    ,SK_KouzaBango__c
                    ,SK_KouzaMeigi__c
                    ,MoushideDate__c
                FROM DV_TaishoJido__c
                WHERE Id in :tjList
            ];

            { // 対象者1
                DV_TaishoJido__c tj = tjList[0];
                Assert.areEqual('対象者1', tj.Shimei__c);
                Assert.areEqual('000-0000', tj.YubinBangou__c);
                Assert.areEqual('テスト県テスト市テスト町', tj.Jusho__c);
                Assert.isTrue(tj.SK_Yucho_Shumoku01__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku02__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku03__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku04__c);
                Assert.areEqual('12345678', tj.SK_YuchoBango__c);
                Assert.areEqual('12345', tj.SK_YuchoKigo__c);
                Assert.areEqual('ｾｲｷﾕｳ ﾀﾛｳ', tj.SK_YuuchoKouzaMeigi__c);
                Assert.isNull(tj.SK_KinyuKikan__c);
                Assert.isNull(tj.SK_KinyuKikanCode__c);
                Assert.isNull(tj.SK_Shiten__c);
                Assert.isNull(tj.SK_ShitenCode__c);
                Assert.isFalse(tj.SK_Shumoku01__c);
                Assert.isFalse(tj.SK_Shumoku02__c);
                Assert.isFalse(tj.SK_Shumoku03__c);
                Assert.isNull(tj.SK_KouzaBango__c);
                Assert.isNull(tj.SK_KouzaMeigi__c);
                Assert.areEqual(Date.today(), tj.MoushideDate__c);
            }

            { // 対象者2
                DV_TaishoJido__c tj = tjList[1];
                Assert.areEqual('対象者2', tj.Shimei__c);
                Assert.areEqual('000-0000', tj.YubinBangou__c);
                Assert.areEqual('テスト県テスト市テスト町', tj.Jusho__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku01__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku02__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku03__c);
                Assert.isFalse(tj.SK_Yucho_Shumoku04__c);
                Assert.isNull(tj.SK_YuchoBango__c);
                Assert.isNull(tj.SK_YuchoKigo__c);
                Assert.isNull(tj.SK_YuuchoKouzaMeigi__c);
                Assert.isNull(tj.SK_KinyuKikan__c);
                Assert.isNull(tj.SK_KinyuKikanCode__c);
                Assert.isNull(tj.SK_Shiten__c);
                Assert.isNull(tj.SK_ShitenCode__c);
                Assert.isFalse(tj.SK_Shumoku01__c);
                Assert.isFalse(tj.SK_Shumoku02__c);
                Assert.isFalse(tj.SK_Shumoku03__c);
                Assert.isNull(tj.SK_KouzaBango__c);
                Assert.isNull(tj.SK_KouzaMeigi__c);
                Assert.isNull(tj.MoushideDate__c);
            }

            cvList = [SELECT Id, IsDeletable__c FROM ContentVersion WHERE Id in :cvList];
            for (ContentVersion cv : cvList) {
                Assert.isFalse(cv.IsDeletable__c);
            }

            ns = [SELECT Id, ShinsaStatus__c, ShinseiKanryoDateTime__c FROM DV_NinteiSeikyu__c WHERE Id = :ns.Id];
            Assert.areEqual('OCR処理中', ns.ShinsaStatus__c);
            Assert.areEqual(Date.today(), ns.ShinseiKanryoDateTime__c.date());
        }
    }
}