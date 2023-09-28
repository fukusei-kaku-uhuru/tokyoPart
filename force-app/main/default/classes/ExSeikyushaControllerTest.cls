@isTest
public with sharing class ExSeikyushaControllerTest {

    @TestSetup
    static void makeData(){
        Account acc1 = new Account(
            LastName = 'TestAccount_generalUser'
        );
        Account acc2 = new Account(
            LastName = 'TestAccount_dvUser'
        );
        Account acc3 = new Account(
            LastName = 'TestAccount_satoyaUser'
        );
        insert new List<Account>{acc1, acc2, acc3};

        User generalUser = ExTestUtil.getGeneralUser('TestAccount_generalUser', acc1.Id);
        User dvUser = ExTestUtil.getDvUser('TestAccount_dvUser', acc2.Id);
        User satoyaUser = ExTestUtil.getSatoyaUser('TestAccount_satoyaUser', acc3.Id);
        insert new List<User>{generalUser, dvUser, satoyaUser};

        System.runAs(generalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                ShimeiFurigana__c = 'テストタロウ',
                Shimei__c = 'テスト太郎',
                SeinenGappiDate__c = Date.newInstance(2000, 1, 1),
                YubinBangou__c = '000-0000',
                Jusho__c = '住所サンプル',
                DenwaBangou__c = '000-0000-0000',
                MailAddress__c = 'sample@example.com',
                TrustdocKekka__c = 'approved'
            );
            insert seikyusha;

            NinteiSeikyu__c nintei = new NinteiSeikyu__c(
                Seikyusha__c = seikyusha.Id,
                ShinsaStatus__c = '未申請'
            );
            insert nintei;
        }

        System.runAs(dvUser){
            DV_Seikyusha__c dv_seikyusha = new DV_Seikyusha__c(
                RecordTypeId = ExTestUtil.DV_SEIKYUSHA_ID,
                ShimeiFurigana__c = 'テストタロウ',
                Shimei__c = 'テスト太郎',
                SeinenGappiDate__c = Date.newInstance(2000, 1, 1),
                YubinBangou__c = '000-0000',
                Jusho__c = '住所サンプル',
                DenwaBangou__c = '000-0000-0000',
                MailAddress__c = 'sample@example.com',
                TrustdocKekka__c = 'approved'
            );
            insert dv_seikyusha;

            DV_NinteiSeikyu__c dv_nintei = new DV_NinteiSeikyu__c(
                RecordTypeId = ExTestUtil.DV_SEIKYU_ID,
                Seikyusya__c = dv_seikyusha.Id,
                ShinsaStatus__c = '未申請'
            );
            insert dv_nintei;
        }

        System.runAs(satoyaUser){
            DV_Seikyusha__c dv_seikyusha = new DV_Seikyusha__c(
                RecordTypeId = ExTestUtil.SATOYA_SEIKYUSHA_ID,
                ShimeiFurigana__c = 'テストタロウ',
                Shimei__c = 'テスト太郎',
                SeinenGappiDate__c = Date.newInstance(2000, 1, 1),
                YubinBangou__c = '000-0000',
                Jusho__c = '住所サンプル',
                DenwaBangou__c = '000-0000-0000',
                MailAddress__c = 'sample@example.com',
                TrustdocKekka__c = 'approved'
            );
            insert dv_seikyusha;

            DV_NinteiSeikyu__c dv_nintei = new DV_NinteiSeikyu__c(
                RecordTypeId = ExTestUtil.SATOYA_SEIKYU_ID,
                Seikyusya__c = dv_seikyusha.Id,
                ShinsaStatus__c = '未申請'
            );
            insert dv_nintei;
        }

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

        insert ExTestUtil.getSstKozaKakunin();
    }

    /**
     * 銀行口座がゆうちょ
     */
    @isTest
    static void getSeikyushaData_general_1(){
        User generalUser = [SELECT Id, Email FROM User WHERE Name = 'TestAccount_generalUser'];

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        seikyusha.Yucho_Shumoku01__c = true;
        seikyusha.YuchoKigo__c = '12345';
        seikyusha.YuchoBango__c = '12345678';
        seikyusha.YuchoKouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();
        
        System.runAs(generalUser){
            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, seikyusha.Id, ExTestUtil.GENERAL_NETWORK_ID);
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(seikyusha.Id, wrapper.Id);
        Assert.areEqual(seikyusha.ShimeiFurigana__c, wrapper.ShimeiFurigana);
        Assert.areEqual(seikyusha.Shimei__c, wrapper.Shimei);
        Assert.areEqual(seikyusha.SeinenGappiDate__c, wrapper.SeinenGappiDate);
        Assert.areEqual(seikyusha.YubinBangou__c, wrapper.YubinBangou);
        Assert.areEqual(seikyusha.Jusho__c, wrapper.Jusho);
        Assert.areEqual(seikyusha.DenwaBangou__c, wrapper.DenwaBangou);
        Assert.areEqual(generalUser.Email, wrapper.MailAddress);
        Assert.areEqual(wrapper.kfw.GINKOKUBUN_YUCHO, wrapper.kfw.GinkoKubun);
        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_SOGO, wrapper.kfw.YuchoBunrui);
        Assert.areEqual('12345', wrapper.kfw.YuchoKigo);
        Assert.areEqual('12345678', wrapper.kfw.YuchoBango);
        Assert.areEqual('ﾃｽﾄﾀﾛｳ', wrapper.kfw.YuchoKouzaMeigi);
        Assert.isFalse(wrapper.isDisabled);
        Assert.isTrue(wrapper.isTrustdocApproved);
    }

    /**
     * 銀行口座がゆうちょ カバーできてないパターンを通す
     */
    @isTest
    static void getSeikyushaData_general_2(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Seikyusha__c seikyusha = [
            SELECT Id
            FROM Seikyusha__c
            LIMIT 1
        ];
        seikyusha.Yucho_Shumoku02__c = true;
        seikyusha.YuchoKigo__c = '12345';
        seikyusha.YuchoBango__c = '12345678';
        seikyusha.YuchoKouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;
        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();

        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_TSUJYO, wrapper.kfw.YuchoBunrui);

        seikyusha.Yucho_Shumoku02__c = false;
        seikyusha.Yucho_Shumoku03__c = true;
        update seikyusha;

        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_TYOCHIKU, wrapper.kfw.YuchoBunrui);

        seikyusha.Yucho_Shumoku03__c = false;
        seikyusha.Yucho_Shumoku04__c = true;
        update seikyusha;

        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_FURIKAE, wrapper.kfw.YuchoBunrui);
    }

    /**
     * 銀行口座がその他
     */
    @isTest
    static void getSeikyushaData_general_3(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        KinyuKikan__c kk = [SELECT Id FROM KinyuKikan__c LIMIT 1];
        Shiten__c stn = [SELECT Id FROM Shiten__c LIMIT 1];

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        seikyusha.KinyuKikan__c = kk.Id;
        seikyusha.Shiten__c = stn.Id;
        seikyusha.Shumoku01__c = true;
        seikyusha.KouzaBango__c = '1234567';
        seikyusha.KouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
        nintei.ShinsaStatus__c = '0次審査待ち';
        update nintei;

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();
        
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.isTrue(wrapper.isDisabled);
        Assert.areEqual(wrapper.kfw.GINKOKUBUN_OTHER, wrapper.kfw.GinkoKubun);
        Assert.areEqual(kk.Id, wrapper.kfw.KinyuKikan);
        Assert.areEqual('XXX：テスト金融機関', wrapper.kfw.KinyuKikanDispName);
        Assert.areEqual(stn.Id, wrapper.kfw.Shiten);
        Assert.areEqual('XYZ：テスト支店', wrapper.kfw.ShitenDispName);
        Assert.areEqual(wrapper.kfw.SHUMOKU_FUTSU, wrapper.kfw.Bunrui);
        Assert.areEqual('1234567', wrapper.kfw.KouzaBangou);
        Assert.areEqual('ﾃｽﾄﾀﾛｳ', wrapper.kfw.KouzaMeigi);
    }

    /**
     * 銀行口座がその他 カバーできてないパターンを通す
     */
    @isTest
    static void getSeikyushaData_general_4(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        KinyuKikan__c kk = [SELECT Id FROM KinyuKikan__c LIMIT 1];
        Shiten__c stn = [SELECT Id FROM Shiten__c LIMIT 1];

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        seikyusha.KinyuKikan__c = kk.Id;
        seikyusha.Shiten__c = stn.Id;
        seikyusha.Shumoku02__c = true;
        seikyusha.KouzaBango__c = '1234567';
        seikyusha.KouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
        nintei.ShinsaStatus__c = '0次審査待ち';
        update nintei;

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();

        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(wrapper.kfw.SHUMOKU_TOZA, wrapper.kfw.Bunrui);

        seikyusha.Shumoku02__c = false;
        seikyusha.Shumoku03__c = true;
        update seikyusha;

        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Assert.areEqual(wrapper.kfw.SHUMOKU_TYOCHIKU, wrapper.kfw.Bunrui);
    }

    /**
     * 銀行口座を未登録
     */
    @isTest
    static void getSeikyushaData_general_5(){
        User generalUser = [SELECT Id, Email FROM User WHERE Name = 'TestAccount_generalUser'];

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        update seikyusha;
        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();

        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(seikyusha.Id, wrapper.Id);
        Assert.areEqual(seikyusha.ShimeiFurigana__c, wrapper.ShimeiFurigana);
        Assert.areEqual(seikyusha.Shimei__c, wrapper.Shimei);
        Assert.areEqual(seikyusha.SeinenGappiDate__c, wrapper.SeinenGappiDate);
        Assert.areEqual(seikyusha.YubinBangou__c, wrapper.YubinBangou);
        Assert.areEqual(seikyusha.Jusho__c, wrapper.Jusho);
        Assert.areEqual(seikyusha.DenwaBangou__c, wrapper.DenwaBangou);
        Assert.areEqual(generalUser.Email, wrapper.MailAddress);
    }

    /**
     * 銀行口座がゆうちょ
     */
    @isTest
    static void getSeikyushaData_dv_1(){
        User dvUser = [SELECT Id, Email FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        seikyusha.Yucho_Shumoku01__c = true;
        seikyusha.YuchoKigo__c = '12345';
        seikyusha.YuchoBango__c = '12345678';
        seikyusha.YuchoKouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;
        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();
        
        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(seikyusha.Id, wrapper.Id);
        Assert.areEqual(seikyusha.ShimeiFurigana__c, wrapper.ShimeiFurigana);
        Assert.areEqual(seikyusha.Shimei__c, wrapper.Shimei);
        Assert.areEqual(seikyusha.SeinenGappiDate__c, wrapper.SeinenGappiDate);
        Assert.areEqual(seikyusha.YubinBangou__c, wrapper.YubinBangou);
        Assert.areEqual(seikyusha.Jusho__c, wrapper.Jusho);
        Assert.areEqual(seikyusha.DenwaBangou__c, wrapper.DenwaBangou);
        Assert.areEqual(dvUser.Email, wrapper.MailAddress);
        Assert.areEqual(wrapper.kfw.GINKOKUBUN_YUCHO, wrapper.kfw.GinkoKubun);
        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_SOGO, wrapper.kfw.YuchoBunrui);
        Assert.areEqual('12345', wrapper.kfw.YuchoKigo);
        Assert.areEqual('12345678', wrapper.kfw.YuchoBango);
        Assert.areEqual('ﾃｽﾄﾀﾛｳ', wrapper.kfw.YuchoKouzaMeigi);
        Assert.isFalse(wrapper.isDisabled);
        Assert.isTrue(wrapper.isTrustdocApproved);
    }

    /**
     * 銀行口座がゆうちょ カバーできてないパターンを通す
     */
    @isTest
    static void getSeikyushaData_dv_2(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Seikyusha__c seikyusha = [
            SELECT Id
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        seikyusha.Yucho_Shumoku02__c = true;
        seikyusha.YuchoKigo__c = '12345';
        seikyusha.YuchoBango__c = '12345678';
        seikyusha.YuchoKouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;
        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();

        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_TSUJYO, wrapper.kfw.YuchoBunrui);

        seikyusha.Yucho_Shumoku02__c = false;
        seikyusha.Yucho_Shumoku03__c = true;
        update seikyusha;

        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_TYOCHIKU, wrapper.kfw.YuchoBunrui);

        seikyusha.Yucho_Shumoku03__c = false;
        seikyusha.Yucho_Shumoku04__c = true;
        update seikyusha;

        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Assert.areEqual(wrapper.kfw.YUCHO_SHUMOKU_FURIKAE, wrapper.kfw.YuchoBunrui);
    }

    /**
     * 銀行口座がその他
     */
    @isTest
    static void getSeikyushaData_dv_3(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        KinyuKikan__c kk = [SELECT Id FROM KinyuKikan__c LIMIT 1];
        Shiten__c stn = [SELECT Id FROM Shiten__c LIMIT 1];

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        seikyusha.KinyuKikan__c = kk.Id;
        seikyusha.Shiten__c = stn.Id;
        seikyusha.Shumoku01__c = true;
        seikyusha.KouzaBango__c = '1234567';
        seikyusha.KouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        nintei.ShinsaStatus__c = '0次審査待ち';
        update nintei;

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();
        
        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.isTrue(wrapper.isDisabled);
        Assert.areEqual(wrapper.kfw.GINKOKUBUN_OTHER, wrapper.kfw.GinkoKubun);
        Assert.areEqual(kk.Id, wrapper.kfw.KinyuKikan);
        Assert.areEqual('XXX：テスト金融機関', wrapper.kfw.KinyuKikanDispName);
        Assert.areEqual(stn.Id, wrapper.kfw.Shiten);
        Assert.areEqual('XYZ：テスト支店', wrapper.kfw.ShitenDispName);
        Assert.areEqual(wrapper.kfw.SHUMOKU_FUTSU, wrapper.kfw.Bunrui);
        Assert.areEqual('1234567', wrapper.kfw.KouzaBangou);
        Assert.areEqual('ﾃｽﾄﾀﾛｳ', wrapper.kfw.KouzaMeigi);
    }

    /**
     * 銀行口座がその他 カバーできてないパターンを通す
     */
    @isTest
    static void getSeikyushaData_dv_4(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        KinyuKikan__c kk = [SELECT Id FROM KinyuKikan__c LIMIT 1];
        Shiten__c stn = [SELECT Id FROM Shiten__c LIMIT 1];

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        seikyusha.KinyuKikan__c = kk.Id;
        seikyusha.Shiten__c = stn.Id;
        seikyusha.Shumoku02__c = true;
        seikyusha.KouzaBango__c = '1234567';
        seikyusha.KouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];
        nintei.ShinsaStatus__c = '0次審査待ち';
        update nintei;

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();

        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(wrapper.kfw.SHUMOKU_TOZA, wrapper.kfw.Bunrui);

        seikyusha.Shumoku02__c = false;
        seikyusha.Shumoku03__c = true;
        update seikyusha;

        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Assert.areEqual(wrapper.kfw.SHUMOKU_TYOCHIKU, wrapper.kfw.Bunrui);
    }

    /**
     * 銀行口座を未登録
     */
    @isTest
    static void getSeikyushaData_dv_5(){
        User dvUser = [SELECT Id, Email FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        update seikyusha;
        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        Test.startTest();

        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(seikyusha.Id, wrapper.Id);
        Assert.areEqual(seikyusha.ShimeiFurigana__c, wrapper.ShimeiFurigana);
        Assert.areEqual(seikyusha.Shimei__c, wrapper.Shimei);
        Assert.areEqual(seikyusha.SeinenGappiDate__c, wrapper.SeinenGappiDate);
        Assert.areEqual(seikyusha.YubinBangou__c, wrapper.YubinBangou);
        Assert.areEqual(seikyusha.Jusho__c, wrapper.Jusho);
        Assert.areEqual(seikyusha.DenwaBangou__c, wrapper.DenwaBangou);
        Assert.areEqual(dvUser.Email, wrapper.MailAddress);
    }

    /**
     * 里親項目
     */
    @isTest
    static void getSeikyushaData_satoya_1(){
        User satoyaUser = [SELECT Id, Email FROM User WHERE Name = 'TestAccount_satoyaUser'];

        System.runAs(satoyaUser){

            DV_Seikyusha__c seikyusha = [
                SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                    Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c
                FROM DV_Seikyusha__c
                LIMIT 1
            ];
            seikyusha.Shisetsu_Shurui__c = '小規模住居型児童養育事業者';
            seikyusha.Shisetsu_Meisho__c = 'テスト施設';
            update seikyusha;
            DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            ExSeikyushaController.SeikyushaWrapper wrapper;
            Test.startTest();

            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);

            Test.stopTest();

            Assert.areEqual('小規模住居型児童養育事業者', wrapper.ShisetsuShurui);
            Assert.areEqual('テスト施設', wrapper.ShisetsuMeisho);
        }
    }

    /**
     * エラーパターン
     */
    @isTest
    static void updateSeikyusha_error_1(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

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

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-9999-1111';
        wrapper.MailAddress = 'a@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_YUCHO;
        wrapper.kfw.YuchoKouzaMeigi = 'ｺｳｼﾝ ﾀﾛｳ';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Assert.areEqual(3, errorList.size());
        Assert.areEqual('YuchoBunrui', errorList[0].field);
        Assert.areEqual('YuchoKigo', errorList[1].field);
        Assert.areEqual('YuchoBango', errorList[2].field);

        wrapper.kfw.YuchoBunrui = wrapper.kfw.YUCHO_SHUMOKU_FURIKAE;
        wrapper.kfw.YuchoKigo = '12345';
        wrapper.kfw.YuchoBango = '12345678';
        wrapper.kfw.YuchoKouzaMeigi = '';

        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Assert.areEqual(1, errorList.size());
        Assert.areEqual('YuchoKouzaMeigi', errorList[0].field);

        Test.stopTest();
    }

    /**
     * エラーパターン
     */
    @isTest
    static void updateSeikyusha_error_2(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

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

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = 'a';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_OTHER;
        wrapper.kfw.KouzaMeigi = 'ｺｳｼﾝ ﾀﾛｳ';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Assert.areEqual(5, errorList.size());
        Assert.areEqual('DenwaBangou', errorList[0].field);
        Assert.areEqual('KinyuKikan', errorList[1].field);
        Assert.areEqual('Shiten', errorList[2].field);
        Assert.areEqual('Bunrui', errorList[3].field);
        Assert.areEqual('KouzaBangou', errorList[4].field);

        wrapper.DenwaBangou = '000-9999-1111';
        wrapper.kfw.KinyuKikan = kk.Id;
        wrapper.kfw.Shiten = stn.Id;
        wrapper.kfw.Bunrui = wrapper.kfw.SHUMOKU_FUTSU;
        wrapper.kfw.KouzaBangou = '1234567';
        wrapper.kfw.KouzaMeigi = '';

        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Assert.areEqual(1, errorList.size());
        Assert.areEqual('KouzaMeigi', errorList[0].field);

        Test.stopTest();
    }

    /**
     * エラーパターン
     */
    @isTest
    static void updateSeikyusha_error_3(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = ' ';
        wrapper.SeinenGappiDate = Date.today().addDays(1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = '  ';
        wrapper.DenwaBangou = '000-9999-1111';
        wrapper.MailAddress = 'a@example.com';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        Assert.areEqual(3, errorList.size());
        Assert.areEqual('Shimei', errorList[0].field);
        Assert.areEqual('SeinenGappiDate', errorList[1].field);
        Assert.areEqual('jusho', errorList[2].field);
    }

    /**
     * 銀行口座がその他
     */
    @isTest
    static void updateSeikyusha_general_1(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

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

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-1111-1111';
        wrapper.MailAddress = 'sample.update@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_OTHER;
        wrapper.kfw.KinyuKikan = kk.Id;
        wrapper.kfw.Shiten = stn.Id;
        wrapper.kfw.Bunrui = wrapper.kfw.SHUMOKU_FUTSU;
        wrapper.kfw.KouzaBangou = '1234567';
        wrapper.kfw.KouzaMeigi = 'ｺｳｼﾝ ﾀﾛｳ';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('更新太郎', seikyusha.Shimei__c);
        Assert.areEqual('コウシンタロウ', seikyusha.ShimeiFurigana__c);
        Assert.areEqual(Date.newInstance(2023, 1, 1), seikyusha.SeinenGappiDate__c);
        Assert.areEqual('111-1111', seikyusha.YubinBangou__c);
        Assert.areEqual('サンプル更新住所', seikyusha.Jusho__c);
        Assert.areEqual('000-1111-1111', seikyusha.DenwaBangou__c);
        Assert.areEqual('sample.update@example.com', seikyusha.MailAddress__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku01__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku02__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku03__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku04__c);
        Assert.isNull(seikyusha.YuchoKigo__c);
        Assert.isNull(seikyusha.YuchoBango__c);
        Assert.isNull(seikyusha.YuchoKouzaMeigi__c);
        Assert.areEqual(kk.Id, seikyusha.KinyuKikan__c);
        Assert.areEqual('XXX', seikyusha.KinyuKikanCode__c);
        Assert.areEqual(stn.Id, seikyusha.Shiten__c);
        Assert.areEqual('XYZ', seikyusha.ShitenCode__c);
        Assert.isTrue(seikyusha.Shumoku01__c);
        Assert.isFalse(seikyusha.Shumoku02__c);
        Assert.isFalse(seikyusha.Shumoku03__c);
        Assert.areEqual('1234567', seikyusha.KouzaBango__c);
        Assert.areEqual('ｺｳｼﾝ ﾀﾛｳ', seikyusha.KouzaMeigi__c);
    }

    /**
     * 銀行口座がゆうちょ
     */
    @isTest
    static void updateSeikyusha_general_2(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-1111-1111';
        wrapper.MailAddress = 'sample.update@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_YUCHO;
        wrapper.kfw.YuchoBunrui = wrapper.kfw.YUCHO_SHUMOKU_FURIKAE;
        wrapper.kfw.YuchoKigo = '12345';
        wrapper.kfw.YuchoBango = '12345678';
        wrapper.kfw.YuchoKouzaMeigi = 'ｺｳｼﾝ ﾀﾛｳ';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('更新太郎', seikyusha.Shimei__c);
        Assert.areEqual('コウシンタロウ', seikyusha.ShimeiFurigana__c);
        Assert.areEqual(Date.newInstance(2023, 1, 1), seikyusha.SeinenGappiDate__c);
        Assert.areEqual('111-1111', seikyusha.YubinBangou__c);
        Assert.areEqual('サンプル更新住所', seikyusha.Jusho__c);
        Assert.areEqual('000-1111-1111', seikyusha.DenwaBangou__c);
        Assert.areEqual('sample.update@example.com', seikyusha.MailAddress__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku01__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku02__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku03__c);
        Assert.isTrue(seikyusha.Yucho_Shumoku04__c);
        Assert.areEqual('12345', seikyusha.YuchoKigo__c);
        Assert.areEqual('12345678', seikyusha.YuchoBango__c);
        Assert.areEqual('ｺｳｼﾝ ﾀﾛｳ', seikyusha.YuchoKouzaMeigi__c);
        Assert.isNull(seikyusha.KinyuKikan__c);
        Assert.isNull(seikyusha.KinyuKikanCode__c);
        Assert.isNull(seikyusha.Shiten__c);
        Assert.isNull(seikyusha.ShitenCode__c);
        Assert.isFalse(seikyusha.Shumoku01__c);
        Assert.isFalse(seikyusha.Shumoku02__c);
        Assert.isFalse(seikyusha.Shumoku03__c);
        Assert.isNull(seikyusha.KouzaBango__c);
        Assert.isNull(seikyusha.KouzaMeigi__c);
    }

    /**
     * 銀行口座が設定なし
     */
    @isTest
    static void updateSeikyusha_general_3(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(generalUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-1111-1111';
        wrapper.MailAddress = 'sample.update@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_OTHER;

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(generalUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c, KouzaBango__c, KouzaMeigi__c
            FROM Seikyusha__c
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('更新太郎', seikyusha.Shimei__c);
        Assert.areEqual('コウシンタロウ', seikyusha.ShimeiFurigana__c);
        Assert.areEqual(Date.newInstance(2023, 1, 1), seikyusha.SeinenGappiDate__c);
        Assert.areEqual('111-1111', seikyusha.YubinBangou__c);
        Assert.areEqual('サンプル更新住所', seikyusha.Jusho__c);
        Assert.areEqual('000-1111-1111', seikyusha.DenwaBangou__c);
        Assert.areEqual('sample.update@example.com', seikyusha.MailAddress__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku01__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku02__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku03__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku04__c);
        Assert.isNull(seikyusha.YuchoKigo__c);
        Assert.isNull(seikyusha.YuchoBango__c);
        Assert.isNull(seikyusha.YuchoKouzaMeigi__c);
        Assert.isNull(seikyusha.KinyuKikan__c);
        Assert.isNull(seikyusha.KinyuKikanCode__c);
        Assert.isNull(seikyusha.Shiten__c);
        Assert.isNull(seikyusha.ShitenCode__c);
        Assert.isFalse(seikyusha.Shumoku01__c);
        Assert.isFalse(seikyusha.Shumoku02__c);
        Assert.isFalse(seikyusha.Shumoku03__c);
        Assert.isNull(seikyusha.KouzaBango__c);
        Assert.isNull(seikyusha.KouzaMeigi__c);
    }

    /**
     * 銀行口座がその他
     */
    @isTest
    static void updateSeikyusha_dv_1(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

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

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-1111-1111';
        wrapper.MailAddress = 'sample.update@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_OTHER;
        wrapper.kfw.KinyuKikan = kk.Id;
        wrapper.kfw.Shiten = stn.Id;
        wrapper.kfw.Bunrui = wrapper.kfw.SHUMOKU_FUTSU;
        wrapper.kfw.KouzaBangou = '1234567';
        wrapper.kfw.KouzaMeigi = 'ｺｳｼﾝ ﾀﾛｳ';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(dvUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('更新太郎', seikyusha.Shimei__c);
        Assert.areEqual('コウシンタロウ', seikyusha.ShimeiFurigana__c);
        Assert.areEqual(Date.newInstance(2023, 1, 1), seikyusha.SeinenGappiDate__c);
        Assert.areEqual('111-1111', seikyusha.YubinBangou__c);
        Assert.areEqual('サンプル更新住所', seikyusha.Jusho__c);
        Assert.areEqual('000-1111-1111', seikyusha.DenwaBangou__c);
        Assert.areEqual('sample.update@example.com', seikyusha.MailAddress__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku01__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku02__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku03__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku04__c);
        Assert.isNull(seikyusha.YuchoKigo__c);
        Assert.isNull(seikyusha.YuchoBango__c);
        Assert.isNull(seikyusha.YuchoKouzaMeigi__c);
        Assert.areEqual(kk.Id, seikyusha.KinyuKikan__c);
        Assert.areEqual('XXX', seikyusha.KinyuKikanCode__c);
        Assert.areEqual(stn.Id, seikyusha.Shiten__c);
        Assert.areEqual('XYZ', seikyusha.ShitenCode__c);
        Assert.isTrue(seikyusha.Shumoku01__c);
        Assert.isFalse(seikyusha.Shumoku02__c);
        Assert.isFalse(seikyusha.Shumoku03__c);
        Assert.areEqual('1234567', seikyusha.KouzaBango__c);
        Assert.areEqual('ｺｳｼﾝ ﾀﾛｳ', seikyusha.KouzaMeigi__c);
    }

    /**
     * 銀行口座がゆうちょ
     */
    @isTest
    static void updateSeikyusha_dv_2(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-1111-1111';
        wrapper.MailAddress = 'sample.update@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_YUCHO;
        wrapper.kfw.YuchoBunrui = wrapper.kfw.YUCHO_SHUMOKU_FURIKAE;
        wrapper.kfw.YuchoKigo = '12345';
        wrapper.kfw.YuchoBango = '12345678';
        wrapper.kfw.YuchoKouzaMeigi = 'ｺｳｼﾝ ﾀﾛｳ';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(dvUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('更新太郎', seikyusha.Shimei__c);
        Assert.areEqual('コウシンタロウ', seikyusha.ShimeiFurigana__c);
        Assert.areEqual(Date.newInstance(2023, 1, 1), seikyusha.SeinenGappiDate__c);
        Assert.areEqual('111-1111', seikyusha.YubinBangou__c);
        Assert.areEqual('サンプル更新住所', seikyusha.Jusho__c);
        Assert.areEqual('000-1111-1111', seikyusha.DenwaBangou__c);
        Assert.areEqual('sample.update@example.com', seikyusha.MailAddress__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku01__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku02__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku03__c);
        Assert.isTrue(seikyusha.Yucho_Shumoku04__c);
        Assert.areEqual('12345', seikyusha.YuchoKigo__c);
        Assert.areEqual('12345678', seikyusha.YuchoBango__c);
        Assert.areEqual('ｺｳｼﾝ ﾀﾛｳ', seikyusha.YuchoKouzaMeigi__c);
        Assert.isNull(seikyusha.KinyuKikan__c);
        Assert.isNull(seikyusha.KinyuKikanCode__c);
        Assert.isNull(seikyusha.Shiten__c);
        Assert.isNull(seikyusha.ShitenCode__c);
        Assert.isFalse(seikyusha.Shumoku01__c);
        Assert.isFalse(seikyusha.Shumoku02__c);
        Assert.isFalse(seikyusha.Shumoku03__c);
        Assert.isNull(seikyusha.KouzaBango__c);
        Assert.isNull(seikyusha.KouzaMeigi__c);
    }

    /**
     * 銀行口座が設定なし
     */
    @isTest
    static void updateSeikyusha_dv_3(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(dvUser){
            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.Shimei = '更新太郎';
        wrapper.ShimeiFurigana = 'コウシンタロウ';
        wrapper.SeinenGappiDate = Date.newInstance(2023, 1, 1);
        wrapper.YubinBangou = '111-1111';
        wrapper.Jusho = 'サンプル更新住所';
        wrapper.DenwaBangou = '000-1111-1111';
        wrapper.MailAddress = 'sample.update@example.com';
        wrapper.kfw.GinkoKubun = wrapper.kfw.GINKOKUBUN_OTHER;

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(dvUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c
            FROM DV_Seikyusha__c
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('更新太郎', seikyusha.Shimei__c);
        Assert.areEqual('コウシンタロウ', seikyusha.ShimeiFurigana__c);
        Assert.areEqual(Date.newInstance(2023, 1, 1), seikyusha.SeinenGappiDate__c);
        Assert.areEqual('111-1111', seikyusha.YubinBangou__c);
        Assert.areEqual('サンプル更新住所', seikyusha.Jusho__c);
        Assert.areEqual('000-1111-1111', seikyusha.DenwaBangou__c);
        Assert.areEqual('sample.update@example.com', seikyusha.MailAddress__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku01__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku02__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku03__c);
        Assert.isFalse(seikyusha.Yucho_Shumoku04__c);
        Assert.isNull(seikyusha.YuchoKigo__c);
        Assert.isNull(seikyusha.YuchoBango__c);
        Assert.isNull(seikyusha.YuchoKouzaMeigi__c);
        Assert.isNull(seikyusha.KinyuKikan__c);
        Assert.isNull(seikyusha.KinyuKikanCode__c);
        Assert.isNull(seikyusha.Shiten__c);
        Assert.isNull(seikyusha.ShitenCode__c);
        Assert.isFalse(seikyusha.Shumoku01__c);
        Assert.isFalse(seikyusha.Shumoku02__c);
        Assert.isFalse(seikyusha.Shumoku03__c);
        Assert.isNull(seikyusha.KouzaBango__c);
        Assert.isNull(seikyusha.KouzaMeigi__c);
    }

    /**
     * 里親項目
     */
    @isTest
    static void updateSeikyusha_satoya_1(){
        User satoyaUser = [SELECT Id FROM User WHERE Name = 'TestAccount_satoyaUser'];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(satoyaUser){
            DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.ShisetsuShurui = '小規模住居型児童養育事業者';
        wrapper.ShisetsuMeisho = 'テスト施設';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(satoyaUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c,
                   Shisetsu_Shurui__c, Shisetsu_Meisho__c
            FROM DV_Seikyusha__c
            WHERE RecordTypeId = :ExTestUtil.SATOYA_SEIKYUSHA_ID
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('小規模住居型児童養育事業者', seikyusha.Shisetsu_Shurui__c);
        Assert.areEqual('テスト施設', seikyusha.Shisetsu_Meisho__c);
    }

    /**
     * 里親項目
     */
    @isTest
    static void updateSeikyusha_satoya_2(){
        User satoyaUser = [SELECT Id FROM User WHERE Name = 'TestAccount_satoyaUser'];

        ExSeikyushaController.SeikyushaWrapper wrapper;
        System.runAs(satoyaUser){
            DV_NinteiSeikyu__c nintei = [SELECT Id FROM DV_NinteiSeikyu__c LIMIT 1];

            wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
        }
        wrapper.ShisetsuShurui = '里親';
        wrapper.ShisetsuMeisho = 'テスト施設';

        Test.startTest();

        List<ExValidationUtil.ErrorLog> errorList;
        System.runAs(satoyaUser){
            errorList = ExSeikyushaController.updateSeikyusha(wrapper);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyusha = [
            SELECT Id, ShimeiFurigana__c, Shimei__c, SeinenGappiDate__c, YubinBangou__c,
                   Jusho__c, DenwaBangou__c, MailAddress__c, TrustdocKekka__c, ShinsaKekkaSaishu__c,
                   Yucho_Shumoku01__c, Yucho_Shumoku02__c, Yucho_Shumoku03__c, Yucho_Shumoku04__c,
                   YuchoKigo__c, YuchoBango__c, YuchoKouzaMeigi__c,
                   KinyuKikan__c, KinyuKikanCode__c, Shiten__c, ShitenCode__c,
                   Shumoku01__c, Shumoku02__c, Shumoku03__c,
                   KouzaBango__c, KouzaMeigi__c,
                   Shisetsu_Shurui__c, Shisetsu_Meisho__c
            FROM DV_Seikyusha__c
            WHERE RecordTypeId = :ExTestUtil.SATOYA_SEIKYUSHA_ID
            LIMIT 1
        ];
        Assert.isNull(errorList);
        Assert.areEqual('里親', seikyusha.Shisetsu_Shurui__c);
        Assert.isNull(seikyusha.Shisetsu_Meisho__c);
    }

    /**
     * 提出済
     */
    @isTest
    static void needUploadShinseiShorui_1() {
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Seikyusha__c seikyusha = [
            SELECT Id
            FROM Seikyusha__c
            LIMIT 1
        ];
        seikyusha.Yucho_Shumoku01__c = true;
        seikyusha.YuchoKigo__c = '12345';
        seikyusha.YuchoBango__c = '12345678';
        seikyusha.YuchoKouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        List<String> results = new List<String>();
        Test.startTest();
        
        System.runAs(generalUser){
            ShinseiShoruiTeigi__c sst = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];
            insert ExTestUtil.getContentVersion(sst, seikyusha.Id, ExTestUtil.GENERAL_NETWORK_ID);
            ExSeikyushaController.SeikyushaWrapper wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
            results = ExSeikyushaController.needUploadShinseiShorui(wrapper);
        }

        Assert.areEqual(0, results.size());

        Test.stopTest();
    }

    /**
     * 未提出
     */
    @isTest
    static void needUploadShinseiShorui_2() {
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        KinyuKikan__c kk = [SELECT Id FROM KinyuKikan__c LIMIT 1];
        Shiten__c stn = [SELECT Id FROM Shiten__c LIMIT 1];

        Seikyusha__c seikyusha = [
            SELECT Id
            FROM Seikyusha__c
            LIMIT 1
        ];
        seikyusha.KinyuKikan__c = kk.Id;
        seikyusha.Shiten__c = stn.Id;
        seikyusha.Shumoku02__c = true;
        seikyusha.KouzaBango__c = '1234567';
        seikyusha.KouzaMeigi__c = 'ﾃｽﾄﾀﾛｳ';
        update seikyusha;

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        List<String> results = new List<String>();
        Test.startTest();
        
        System.runAs(generalUser){
            ExSeikyushaController.SeikyushaWrapper wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
            results = ExSeikyushaController.needUploadShinseiShorui(wrapper);
        }

        Assert.areEqual(1, results.size());
        Assert.areEqual('書類定義', results[0]);

        Test.stopTest();
    }

    /**
     * 口座情報未登録
     */
    @isTest
    static void needUploadShinseiShorui_3() {
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Seikyusha__c seikyusha = [
            SELECT Id
            FROM Seikyusha__c
            LIMIT 1
        ];

        NinteiSeikyu__c nintei = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        List<String> results = new List<String>();
        Test.startTest();
        
        System.runAs(generalUser){
            ExSeikyushaController.SeikyushaWrapper wrapper = ExSeikyushaController.getSeikyushaData(nintei.Id);
            results = ExSeikyushaController.needUploadShinseiShorui(wrapper);
        }

        Assert.areEqual(0, results.size());

        Test.stopTest();
    }
}