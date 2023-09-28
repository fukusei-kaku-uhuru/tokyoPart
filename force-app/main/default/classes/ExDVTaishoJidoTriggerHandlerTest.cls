@isTest
private class ExDVTaishoJidoTriggerHandlerTest {

    /**
     * before insert
     */
    @isTest
    private static void convertWebValueToOcrValue_BeforeInsert(){

        // データの準備
        // 請求者(DV)を作成
        DV_Seikyusha__c webS = ExTestUtil.getSeikyushaDv();
        DV_Seikyusha__c yusoS = ExTestUtil.getSeikyushaDv();
        insert new List<DV_Seikyusha__c>{webS, yusoS};

        // Webの認定請求(DV)を作る
        DV_NinteiSeikyu__c webNs = ExTestUtil.getNinteiSeikyuDv(webS);

        // 郵送申請を作る
        YusoShinsei__c yuso = new YusoShinsei__c();
        insert yuso;

        // 郵送の認定請求(DV)を作る
        DV_NinteiSeikyu__c yusoNs = ExTestUtil.getNinteiSeikyuDv(yusoS);
        yusoNs.YusoShinsei__c = yuso.Id;
        insert new List<DV_NinteiSeikyu__c>{webNs, yusoNs};

        // insert用のデータの作成
        List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();

        // Webの対象児童（途中転入あり）を作る
        DV_TaishoJido__c webTjTennyu = new DV_TaishoJido__c();
        webTjTennyu.NinteiSeikyu__c = webNs.Id;
        webTjTennyu.IsTochuTennyuShussei__c = true;
        webTjTennyu.IsTochuTenshutsu__c = false;
        webTjTennyu.Shimei__c = 'tj1';
        tjList.add(webTjTennyu);

        // Webの対象児童（途中転出あり）を作る
        DV_TaishoJido__c webTjTenshutsu = new DV_TaishoJido__c();
        webTjTenshutsu.NinteiSeikyu__c = webNs.Id;
        webTjTenshutsu.IsTochuTennyuShussei__c = false;
        webTjTenshutsu.IsTochuTenshutsu__c = true;
        webTjTenshutsu.Shimei__c = 'tj2';
        tjList.add(webTjTenshutsu);

        // 郵送の対象児童（途中転入あり）を作る
        DV_TaishoJido__c yusoTjTennyu = new DV_TaishoJido__c();
        yusoTjTennyu.NinteiSeikyu__c = yusoNs.Id;
        yusoTjTennyu.IsTochuTennyuShussei__c = true;
        yusoTjTennyu.IsTochuTenshutsu__c = false;
        yusoTjTennyu.Shimei__c = 'tj3';
        tjList.add(yusoTjTennyu);

        // 郵送の対象児童（途中転出あり）を作る
        DV_TaishoJido__c yusoTjTenshutsu = new DV_TaishoJido__c();
        yusoTjTenshutsu.NinteiSeikyu__c = yusoNs.Id;
        yusoTjTenshutsu.IsTochuTennyuShussei__c = false;
        yusoTjTenshutsu.IsTochuTenshutsu__c = true;
        yusoTjTenshutsu.Shimei__c = 'tj4';
        tjList.add(yusoTjTenshutsu);

        // テストの実行
        Test.startTest();
        insert tjList;
        Test.stopTest();

        // 結果の確認
        List<DV_TaishoJido__c> result = [
                                    SELECT
                                        Tennyu_Ari__c,
                                        Tennyu_Nashi__c,
                                        Tenshutu_Ari__c,
                                        Tenshutu_Nashi__c
                                    FROM
                                        DV_TaishoJido__c
                                    ORDER BY
                                        Shimei__c];

        // 途中転入ありのWebの対象児童：転入ありの項目が更新されていること
        Assert.isTrue(result.get(0).Tennyu_Ari__c);
        Assert.isFalse(result.get(0).Tennyu_Nashi__c);
        Assert.isFalse(result.get(0).Tenshutu_Ari__c);
        Assert.isTrue(result.get(0).Tenshutu_Nashi__c);

        // 途中転出ありのWebの対象児童：転出ありの項目が更新されていること
        Assert.isFalse(result.get(1).Tennyu_Ari__c);
        Assert.isTrue(result.get(1).Tennyu_Nashi__c);
        Assert.isTrue(result.get(1).Tenshutu_Ari__c);
        Assert.isFalse(result.get(1).Tenshutu_Nashi__c);

        // 途中転入ありの郵送の対象児童：転入ありの項目が更新されていないこと
        Assert.isFalse(result.get(2).Tennyu_Ari__c);
        Assert.isFalse(result.get(2).Tennyu_Nashi__c);
        Assert.isFalse(result.get(2).Tenshutu_Ari__c);
        Assert.isFalse(result.get(2).Tenshutu_Nashi__c);

        // 途中転出ありの郵送の対象児童：転出ありの項目が更新されていないこと
        Assert.isFalse(result.get(3).Tennyu_Ari__c);
        Assert.isFalse(result.get(3).Tennyu_Nashi__c);
        Assert.isFalse(result.get(3).Tenshutu_Ari__c);
        Assert.isFalse(result.get(3).Tenshutu_Nashi__c);
    }

    /**
     * before update
     */
    @isTest
    private static void convertWebValueToOcrValue_BeforeUpdate(){

        // データの準備
        // 請求者(DV)を作成
        DV_Seikyusha__c webS = ExTestUtil.getSeikyushaDv();
        DV_Seikyusha__c yusoS = ExTestUtil.getSeikyushaDv();
        insert new List<DV_Seikyusha__c>{webS, yusoS};

        // Webの認定請求(DV)を作る
        DV_NinteiSeikyu__c webNs = ExTestUtil.getNinteiSeikyuDv(webS);

        // 郵送申請を作る
        YusoShinsei__c yuso = new YusoShinsei__c();
        insert yuso;

        // 郵送の認定請求(DV)を作る
        DV_NinteiSeikyu__c yusoNs = ExTestUtil.getNinteiSeikyuDv(yusoS);
        yusoNs.YusoShinsei__c = yuso.Id;
        insert new List<DV_NinteiSeikyu__c>{webNs, yusoNs};

        // update用のデータの作成
        List<DV_TaishoJido__c> tjList = new List<DV_TaishoJido__c>();

        // Webの対象児童（途中転入あり用）を作る
        DV_TaishoJido__c webTjTennyu = new DV_TaishoJido__c();
        webTjTennyu.NinteiSeikyu__c = webNs.Id;
        webTjTennyu.Shimei__c = 'tj1';
        tjList.add(webTjTennyu);

        // Webの対象児童（途中転出あり用）を作る
        DV_TaishoJido__c webTjTenshutsu = new DV_TaishoJido__c();
        webTjTenshutsu.NinteiSeikyu__c = webNs.Id;
        webTjTenshutsu.Shimei__c = 'tj2';
        tjList.add(webTjTenshutsu);

        // 郵送の対象児童（途中転入あり用）を作る
        DV_TaishoJido__c yusoTjTennyu = new DV_TaishoJido__c();
        yusoTjTennyu.NinteiSeikyu__c = yusoNs.Id;
        yusoTjTennyu.Shimei__c = 'tj3';
        tjList.add(yusoTjTennyu);

        // 郵送の対象児童（途中転出あり用）を作る
        DV_TaishoJido__c yusoTjTenshutsu = new DV_TaishoJido__c();
        yusoTjTenshutsu.NinteiSeikyu__c = yusoNs.Id;
        yusoTjTenshutsu.Shimei__c = 'tj4';
        tjList.add(yusoTjTenshutsu);

        // テストデータの登録
        insert tjList;

        // Webの対象児童テストデータに項目(途中転入あり)を追加する
        tjList.get(0).IsTochuTennyuShussei__c = true;
        tjList.get(0).IsTochuTenshutsu__c = false;

        // Webの対象児童テストデータに項目(途中転出あり)を追加する
        tjList.get(1).IsTochuTennyuShussei__c = false;
        tjList.get(1).IsTochuTenshutsu__c = true;

        // 郵送の対象児童テストデータに項目(途中転入あり)を追加する
        tjList.get(2).IsTochuTennyuShussei__c = true;
        tjList.get(2).IsTochuTenshutsu__c = false;

        // 郵送の対象児童テストデータに項目(途中転出あり)を追加する
        tjList.get(3).IsTochuTennyuShussei__c = false;
        tjList.get(3).IsTochuTenshutsu__c = true;

        // テストの実行
        Test.startTest();
        update tjList;
        Test.stopTest();

        // 結果の確認
        List<DV_TaishoJido__c> result = [
                                    SELECT
                                        Tennyu_Ari__c,
                                        Tennyu_Nashi__c,
                                        Tenshutu_Ari__c,
                                        Tenshutu_Nashi__c
                                    FROM
                                        DV_TaishoJido__c
                                    ORDER BY
                                        Shimei__c];

        // 途中転入ありのWebの対象児童：転入ありの項目が更新されていること
        Assert.isTrue(result.get(0).Tennyu_Ari__c);
        Assert.isFalse(result.get(0).Tennyu_Nashi__c);
        Assert.isFalse(result.get(0).Tenshutu_Ari__c);
        Assert.isTrue(result.get(0).Tenshutu_Nashi__c);

        // 途中転出ありのWebの対象児童：転出ありの項目が更新されていること
        Assert.isFalse(result.get(1).Tennyu_Ari__c);
        Assert.isTrue(result.get(1).Tennyu_Nashi__c);
        Assert.isTrue(result.get(1).Tenshutu_Ari__c);
        Assert.isFalse(result.get(1).Tenshutu_Nashi__c);

        // 途中転入ありの郵送の対象児童：転入ありの項目が更新されていないこと
        Assert.isFalse(result.get(2).Tennyu_Ari__c);
        Assert.isFalse(result.get(2).Tennyu_Nashi__c);
        Assert.isFalse(result.get(2).Tenshutu_Ari__c);
        Assert.isFalse(result.get(2).Tenshutu_Nashi__c);

        // 途中転出ありの郵送の対象児童：転出ありの項目が更新されていないこと
        Assert.isFalse(result.get(3).Tennyu_Ari__c);
        Assert.isFalse(result.get(3).Tennyu_Nashi__c);
        Assert.isFalse(result.get(3).Tenshutu_Ari__c);
        Assert.isFalse(result.get(3).Tenshutu_Nashi__c);
    }
}