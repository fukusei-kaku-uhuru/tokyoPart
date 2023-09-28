@isTest
private class ExKozaFormControllerTest {

    /**
     * ゆうちょ
     */
    @isTest
    private static void isInputYucho1() {

        Test.startTest();

        // 値が入力されていなければ、false
        ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
        kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;

        Assert.isFalse(kfw.isInputYucho());

        // 値が入っていれば、trueになる
        kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_FURIKAE;
        Assert.isTrue(kfw.isInputYucho());

        kfw.YuchoBunrui = null;
        kfw.YuchoKigo = '12345';
        Assert.isTrue(kfw.isInputYucho());

        kfw.YuchoKigo = null;
        kfw.YuchoBango = '12345678';
        Assert.isTrue(kfw.isInputYucho());

        kfw.YuchoBango = null;
        kfw.YuchoKouzaMeigi = 'ﾃｽﾄ';
        Assert.isTrue(kfw.isInputYucho());

        Test.stopTest();
    }

    /**
     * ゆうちょ
     */
    @isTest
    private static void isInputYucho2() {

        Test.startTest();

        // ゆうちょが選択されていなければ、false
        ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
        kfw.GinkoKubun = kfw.GINKOKUBUN_OTHER;
        kfw.YuchoKouzaMeigi = 'ﾃｽﾄ';

        Assert.isFalse(kfw.isInputYucho());

        // 他は入力されていない & 口座名義が空白ならば、false
        kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;
        kfw.YuchoKouzaMeigi = ' ';
        Assert.isFalse(kfw.isInputYucho());

        Test.stopTest();
    }

    /**
     * その他
     */
    @isTest
    private static void isInputOther1() {

        // テスト用データ投入
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

        Test.startTest();

        // 値が入力されていなければ、false
        ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
        kfw.GinkoKubun = kfw.GINKOKUBUN_OTHER;

        Assert.isFalse(kfw.isInputOther());

        // 値が入っていれば、trueになる
        kfw.KinyuKikan = kk.Id;
        Assert.isTrue(kfw.isInputOther());

        kfw.KinyuKikan = null;
        kfw.Shiten = stn.Id;
        Assert.isTrue(kfw.isInputOther());

        kfw.Shiten = null;
        kfw.Bunrui = kfw.SHUMOKU_FUTSU;
        Assert.isTrue(kfw.isInputOther());

        kfw.Bunrui = null;
        kfw.KouzaBangou = '1234567';
        Assert.isTrue(kfw.isInputOther());

        kfw.KouzaBangou = null;
        kfw.KouzaMeigi = 'ﾃｽﾄ';
        Assert.isTrue(kfw.isInputOther());

        Test.stopTest();
    }

    /**
     * その他
     */
    @isTest
    private static void isInputOther2() {

        Test.startTest();

        // その他が選択されていなければ、false
        ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
        kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;

        Assert.isFalse(kfw.isInputOther());

        // 他は入力されていない & 口座名義が空白ならば、false
        kfw.KouzaMeigi = ' ';
        Assert.isFalse(kfw.isInputOther());

        Test.stopTest();
    }
}