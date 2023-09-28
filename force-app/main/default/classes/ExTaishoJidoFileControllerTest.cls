@isTest
private class ExTaishoJidoFileControllerTest {

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
        List<ShinseiShoruiTeigi__c> sstList = ExTestUtil.getSstListTaishoJido(3);
        sstList[2].IsNiniTeisyutsu__c = true;
        insert sstList;
        List<KubunBetsuShinseiShorui__c> kbssList = ExTestUtil.getKbssList(tk, sstList);
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
     * 家族関係確認書類用データを取得
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

            Test.startTest();
            ExTaishoJidoFileController.TaishoJidoWrapper tjw = ExTaishoJidoFileController.getTaishoJidoData(tj.Id);
            Test.stopTest();

            Assert.areEqual('対象者', tjw.Shimei);
            Assert.isTrue(tjw.IsMoushitate);
            Assert.isFalse(tjw.isDisabled);
            Assert.isTrue(tjw.NeedFileUpload);

            Assert.areEqual(3, tjw.kazokuKakuninOptions.size());
            Assert.areEqual('* 書類定義1', tjw.kazokuKakuninOptions[0].get('label'));
            Assert.areEqual('* 書類定義2', tjw.kazokuKakuninOptions[1].get('label'));
            Assert.areEqual('書類定義3', tjw.kazokuKakuninOptions[2].get('label'));
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void getTaishoJidoDataGeneral2() {

        List<ShinseiShoruiTeigi__c> sstList = [SELECT Id FROM ShinseiShoruiTeigi__c];
        for (ShinseiShoruiTeigi__c sst : sstList) {
            sst.IsNiniTeisyutsu__c = true;
        }
        update sstList;

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

            Test.startTest();
            ExTaishoJidoFileController.TaishoJidoWrapper tjw = ExTaishoJidoFileController.getTaishoJidoData(tj.Id);
            Test.stopTest();

            Assert.isTrue(tjw.isDisabled);
            Assert.isTrue(tjw.NeedFileUpload); // 複数件なので、true
        }
    }

    /**
     * カバーできてないパターンを通す
     */
    @isTest
    private static void getTaishoJidoDataGeneral3() {

        ShinseiShoruiTeigi__c sst = [SELECT Id FROM ShinseiShoruiTeigi__c limit 1];
        sst.IsNiniTeisyutsu__c = true;
        update sst;

        List<KubunBetsuShinseiShorui__c> kbssList = [SELECT Id FROM KubunBetsuShinseiShorui__c WHERE ShinseiShoruiTeigi__c != :sst.Id];
        delete kbssList;

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

            Test.startTest();
            ExTaishoJidoFileController.TaishoJidoWrapper tjw = ExTaishoJidoFileController.getTaishoJidoData(tj.Id);
            Test.stopTest();

            Assert.isFalse(tjw.NeedFileUpload); // 1件のみなので、false
        }
    }

    /**
     * 家族関係確認書類用データを取得
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

            Test.startTest();
            ExTaishoJidoFileController.TaishoJidoWrapper tjw = ExTaishoJidoFileController.getTaishoJidoData(tj.Id);
            Test.stopTest();

            Assert.areEqual('対象者', tjw.Shimei);
            Assert.isTrue(tjw.IsMoushitate);
            Assert.isFalse(tjw.isDisabled);

            Assert.areEqual(3, tjw.kazokuKakuninOptions.size());
            Assert.areEqual('* 書類定義1', tjw.kazokuKakuninOptions[0].get('label'));
            Assert.areEqual('* 書類定義2', tjw.kazokuKakuninOptions[1].get('label'));
            Assert.areEqual('書類定義3', tjw.kazokuKakuninOptions[2].get('label'));
        }
    }

    /**
     * 家族関係確認書類用データを取得
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
            tj.ShinsaKekkaSaishu__c = 'OK';
            insert tj;

            Test.startTest();
            ExTaishoJidoFileController.TaishoJidoWrapper tjw = ExTaishoJidoFileController.getTaishoJidoData(tj.Id);
            Test.stopTest();

            Assert.areEqual('対象者', tjw.Shimei);
            Assert.isTrue(tjw.IsMoushitate);
            Assert.isTrue(tjw.isDisabled);

            Assert.areEqual(3, tjw.kazokuKakuninOptions.size());
            Assert.areEqual('* 書類定義1', tjw.kazokuKakuninOptions[0].get('label'));
            Assert.areEqual('* 書類定義2', tjw.kazokuKakuninOptions[1].get('label'));
            Assert.areEqual('書類定義3', tjw.kazokuKakuninOptions[2].get('label'));
        }
    }

    /**
     * 保険証マスキングフラグを更新
     */
    @isTest
    private static void updateMaskingKenkoHokenGeneral1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];
        User admin = new User(Id = UserInfo.getUserId());
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
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.GENERAL_NETWORK_ID));
            }
            cvList[1].HoninKakuninShoruiMaskKenkoHoken__c = true;
            insert cvList;

            // 保険証マスキングフラグを更新
            Test.startTest();
            ExTaishoJidoFileController.updateMaskingKenkoHoken(tj.Id);

            TaishoJido__c resultTj = [SELECT Id, HokenshoMaskingZumi__c FROM TaishoJido__c WHERE Id = :tj.Id];
            Assert.isTrue(resultTj.HokenshoMaskingZumi__c);

            cvList[1].HoninKakuninShoruiMaskKenkoHoken__c = false;
            update cvList[1];
            ExTaishoJidoFileController.updateMaskingKenkoHoken(tj.Id);

            resultTj = [SELECT Id, HokenshoMaskingZumi__c FROM TaishoJido__c WHERE Id = :tj.Id];
            Assert.isFalse(resultTj.HokenshoMaskingZumi__c);

            Test.stopTest();
        }
    }

    /**
     * 保険証マスキングフラグを更新
     */
    @isTest
    private static void updateMaskingKenkoHokenDv1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];
        User admin = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            // ファイル追加
            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (Integer i = 0; i < 2; i++) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.DV_NETWORK_ID));
            }
            cvList[1].HoninKakuninShoruiMaskKenkoHoken__c = true;
            insert cvList;

            // 保険証マスキングフラグを更新
            Test.startTest();
            ExTaishoJidoFileController.updateMaskingKenkoHoken(tj.Id);

            DV_TaishoJido__c resultTj = [SELECT Id, HokenshoMaskingZumi__c FROM DV_TaishoJido__c WHERE Id = :tj.Id];
            Assert.isTrue(resultTj.HokenshoMaskingZumi__c);

            cvList[1].HoninKakuninShoruiMaskKenkoHoken__c = false;
            update cvList[1];
            ExTaishoJidoFileController.updateMaskingKenkoHoken(tj.Id);

            resultTj = [SELECT Id, HokenshoMaskingZumi__c FROM DV_TaishoJido__c WHERE Id = :tj.Id];
            Assert.isFalse(resultTj.HokenshoMaskingZumi__c);

            Test.stopTest();
        }
    }

    /**
     * 保険証マスキングフラグを更新
     */
    @isTest
    private static void updateMaskingKenkoHokenSatoya1() {

        User u = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];
        User admin = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            TaishoshaKubun__c tk = [SELECT Id FROM TaishoshaKubun__c ORDER BY Name asc LIMIT 1];

            DV_Seikyusha__c s = ExTestUtil.getSeikyushaDv();
            insert s;
            DV_NinteiSeikyu__c ns = ExTestUtil.getNinteiSeikyuDv(s);
            insert ns;

            DV_TaishoJido__c tj = getTaishoJidoDv(ns, tk);
            insert tj;

            // ファイル追加
            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getListByTaishoJido()[0];
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (Integer i = 0; i < 2; i++) {
                cvList.add(ExTestUtil.getContentVersion(sst, tj.Id, ExTestUtil.SATOYA_NETWORK_ID));
            }
            cvList[1].HoninKakuninShoruiMaskKenkoHoken__c = true;
            insert cvList;

            // 保険証マスキングフラグを更新
            Test.startTest();
            ExTaishoJidoFileController.updateMaskingKenkoHoken(tj.Id);

            DV_TaishoJido__c resultTj = [SELECT Id, HokenshoMaskingZumi__c FROM DV_TaishoJido__c WHERE Id = :tj.Id];
            Assert.isTrue(resultTj.HokenshoMaskingZumi__c);

            cvList[1].HoninKakuninShoruiMaskKenkoHoken__c = false;
            update cvList[1];
            ExTaishoJidoFileController.updateMaskingKenkoHoken(tj.Id);

            resultTj = [SELECT Id, HokenshoMaskingZumi__c FROM DV_TaishoJido__c WHERE Id = :tj.Id];
            Assert.isFalse(resultTj.HokenshoMaskingZumi__c);

            Test.stopTest();
        }
    }

    /**
     * 必要書類が全て登録されているかチェック
     * 不足している書類名の一覧を返す
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

            Test.startTest();
            List<String> resultList = ExTaishoJidoFileController.needUploadShinseiShorui(tj.Id);
            Test.stopTest();

            Assert.areEqual(2, resultList.size());
            Assert.areEqual('書類定義1', resultList[0]);
            Assert.areEqual('書類定義2', resultList[1]);
        }
    }

    /**
     * 必要書類が全て登録されているかチェック
     * 不足している書類名の一覧を返す
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
            insert tj;

            Test.startTest();
            List<String> resultList = ExTaishoJidoFileController.needUploadShinseiShorui(tj.Id);
            Test.stopTest();

            Assert.areEqual(2, resultList.size());
            Assert.areEqual('書類定義1', resultList[0]);
            Assert.areEqual('書類定義2', resultList[1]);
        }
    }

    /**
     * 必要書類が全て登録されているかチェック
     * 不足している書類名の一覧を返す
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
            insert tj;

            Test.startTest();
            List<String> resultList = ExTaishoJidoFileController.needUploadShinseiShorui(tj.Id);
            Test.stopTest();

            Assert.areEqual(2, resultList.size());
            Assert.areEqual('書類定義1', resultList[0]);
            Assert.areEqual('書類定義2', resultList[1]);
        }
    }
}