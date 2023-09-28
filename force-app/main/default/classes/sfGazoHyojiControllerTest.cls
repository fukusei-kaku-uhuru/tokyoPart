@isTest
public with sharing class sfGazoHyojiControllerTest {

    public static final String USER_PROFILE_SHINSA = '審査';
    
    public static final String USER_NAME_STR_SHINSA = 'ShinsaTest';

    public static final Date CHECK_DATA_DATE_01 = Date.newInstance(2023, 9, 1);

    private static final String CHECK_SHIMEI_STR_01            = 'テスト　氏名';
    private static final String CHECK_JUSHO_STR_01             = 'テスト県テスト市テスト町123';
    private static final String SHINSA_STATUS_STR_SHINSACHU_00 = '0次審査中';

    private static final String TAISHOSHA_NUMBER_STR = '001';

    private static final String HANTEI_KEKKA_STR_OK     = 'OK';
    private static final String HANTEI_KEKKA_STR_NOT_OK = '';

    private static final String TEIGI_LONG_NAME_STR = '長い定義名一二三四五六七八九十一二三四五六七八九十';
    
    @TestSetup
    static void makeData(){
        // 審査ユーザを準備
        User shinsaUser1 = SfTestUtil.getShinsaUser(USER_NAME_STR_SHINSA);
        insert shinsaUser1;

        // 請求者
        Seikyusha__c seikyusha = SfTestUtil.getSeikyusha();
        seikyusha.Shimei__c    = CHECK_SHIMEI_STR_01;
        seikyusha.OwnerId      = shinsaUser1.Id;
        insert seikyusha;

        // 認定請求
        NinteiSeikyu__c ninteiSeikyu = SfTestUtil.getNinteiSeikyu(seikyusha.Id);
        ninteiSeikyu.OwnerId         = shinsaUser1.Id;
        insert ninteiSeikyu;

        // 対象児童
        TaishoJido__c taishoJido = SfTestUtil.getTaishoJido(ninteiSeikyu.Id);
        insert taishoJido;

        System.runAs(shinsaUser1) {
            // 添付書類（ContentVersion）
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
            ContentVersion cv1 = SfTestUtil.getContentVersion();
            cv1.OwnerId        = shinsaUser1.Id;
            contentVersionList.add(cv1);

            ContentVersion cv2 = SfTestUtil.getContentVersion();
            cv2.OwnerId        = shinsaUser1.Id;
            contentVersionList.add(cv2);

            insert contentVersionList;

            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion];
        
            // ContentDocumentLink
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();

            ContentDocumentLink cdl1 = new ContentDocumentLink(
                ContentDocumentId = cvList.get(0).ContentDocumentId,
                LinkedEntityId    = ninteiSeikyu.Id
            );
            linkList.add(cdl1);

            ContentDocumentLink cdl2 = new ContentDocumentLink(
                ContentDocumentId = cvList.get(1).ContentDocumentId,
                LinkedEntityId    = taishoJido.Id
            );
            linkList.add(cdl2);

            insert linkList;
        }

        // 申請書類定義
        List<ShinseiShoruiTeigi__c> shoruiTeigiList = new List<ShinseiShoruiTeigi__c>();

        ShinseiShoruiTeigi__c teigi1 = SfTestUtil.getShinseiShoruiTeigi(1);
        shoruiTeigiList.add(teigi1);

        ShinseiShoruiTeigi__c teigi2 = SfTestUtil.getShinseiShoruiTeigi(2);
        shoruiTeigiList.add(teigi2);

        insert shoruiTeigiList;
    }

    // 添付書類（ContentVersion）を取得
    @isTest
    static void getContentVersion() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ShinseiShoruiTeigi__c teigi = [SELECT Id FROM ShinseiShoruiTeigi__c LIMIT 1];
        teigi.Name = TEIGI_LONG_NAME_STR;
        update teigi;

        ContentDocumentLink cdlink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ninteiSeikyu.Id];

        System.runAs(u) {
            Test.startTest();

            ContentVersion cv = [SELECT Id
                                   FROM ContentVersion
                                  WHERE ContentDocumentId = :cdlink.ContentDocumentId
                                  LIMIT 1];
            cv.ShinseiShoruiTeigiId__c   = teigi.Id;
            cv.Yoto__c                   = '本人確認';
            cv.OCR_Shimei__c             = 'テスト';
            cv.OCR_SeinenGappi__c        = '2023/01/01';
            cv.OCR_Jusho__c              = 'テスト住所';
            cv.OCR_YukoKigen__c          = '2028/01/01';
            cv.OCR_TextZembun__c         = 'テストテキスト全文';
            cv.Hantei_Shimei__c          = 'OK';
            cv.Hantei_SeinenGappi__c     = 'OK';
            cv.Hantei_Jusho__c           = 'OK';
            cv.Hantei_YukoKigen__c       = 'OK';
            update cv;

            List<ContentVersion> cvControllerList = sfGazoHyojiController.getContentVersion(ninteiSeikyu.Id);

            Test.stopTest();

            ContentVersion cvCheck = [SELECT Id,
                                             VersionDataUrl,
                                             ShinseiShoruiTeigiId__c,             // 申請書類定義ID
                                             ShinseiShoruiTeigiName__c,           // 申請書類定義名
                                             Yoto__c,                             // 用途
                                             IsDeletable__c,                      // 削除可能フラグ
                                             MaskingFubi__c,                      // マスキング不備
                                             OCR_Shimei__c,                       // 氏名（OCR結果）
                                             OCR_SeinenGappi__c,                  // 生年月日（OCR結果）
                                             OCR_Jusho__c,                        // 住所（OCR結果）
                                             OCR_YukoKigen__c,                    // 有効期限（OCR結果）
                                             OCR_TextZembun__c,                   // テキスト全文（OCR結果）
                                             ShudoCheck_Shimei__c,                // 手動チェック：氏名
                                             ShudoCheck_SeinenGappi__c,           // 手動チェック：生年月日
                                             ShudoCheck_Jusho__c,                 // 手動チェック：住所
                                             ShudoCheck_YukoKigen__c,             // 手動チェック：有効期限
                                             Hantei_Shimei__c,                    // 判定：氏名
                                             Hantei_SeinenGappi__c,               // 判定：生年月日
                                             Hantei_Jusho__c,                     // 判定：住所
                                             Hantei_YukoKigen__c,                 // 判定：有効期限
                                             CreatedDate,
                                             ContentDocumentId
                                        FROM ContentVersion
                                       WHERE Id = :cv.Id
                                       LIMIT 1];

            Assert.areEqual(cvControllerList.size(), 1);

            ContentVersion cvController = cvControllerList.get(0);
            Assert.areEqual(cvController.VersionDataUrl           , cvCheck.VersionDataUrl);
            Assert.areEqual(cvController.ShinseiShoruiTeigiId__c  , cvCheck.ShinseiShoruiTeigiId__c);
            Assert.areEqual(cvController.ShinseiShoruiTeigiName__c, cvCheck.ShinseiShoruiTeigiName__c.left(12) + '～');
            Assert.areEqual(cvController.Yoto__c                  , cvCheck.Yoto__c);
            Assert.areEqual(cvController.IsDeletable__c           , cvCheck.IsDeletable__c);
            Assert.areEqual(cvController.MaskingFubi__c           , cvCheck.MaskingFubi__c);
            Assert.areEqual(cvController.OCR_Shimei__c            , cvCheck.OCR_Shimei__c);
            Assert.areEqual(cvController.OCR_SeinenGappi__c       , cvCheck.OCR_SeinenGappi__c);
            Assert.areEqual(cvController.OCR_Jusho__c             , cvCheck.OCR_Jusho__c);
            Assert.areEqual(cvController.OCR_YukoKigen__c         , cvCheck.OCR_YukoKigen__c);
            Assert.areEqual(cvController.OCR_TextZembun__c        , cvCheck.OCR_TextZembun__c);
            Assert.areEqual(cvController.ShudoCheck_Shimei__c     , cvCheck.ShudoCheck_Shimei__c);
            Assert.areEqual(cvController.ShudoCheck_SeinenGappi__c, cvCheck.ShudoCheck_SeinenGappi__c);
            Assert.areEqual(cvController.ShudoCheck_Jusho__c      , cvCheck.ShudoCheck_Jusho__c);
            Assert.areEqual(cvController.ShudoCheck_YukoKigen__c  , cvCheck.ShudoCheck_YukoKigen__c);
            Assert.areEqual(cvController.Hantei_Shimei__c         , cvCheck.Hantei_Shimei__c);
            Assert.areEqual(cvController.Hantei_SeinenGappi__c    , cvCheck.Hantei_SeinenGappi__c);
            Assert.areEqual(cvController.Hantei_Jusho__c          , cvCheck.Hantei_Jusho__c);
            Assert.areEqual(cvController.Hantei_YukoKigen__c      , cvCheck.Hantei_YukoKigen__c);
            Assert.areEqual(cvController.CreatedDate              , cvCheck.CreatedDate);
            Assert.areEqual(cvController.ContentDocumentId        , cvCheck.ContentDocumentId);
        }
    }

    // 添付書類（ContentVersion）を取得：対象児童
    @isTest
    static void getContentVersionTaishoJido() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];

        ShinseiShoruiTeigi__c teigi = [SELECT Id FROM ShinseiShoruiTeigi__c LIMIT 1];
        teigi.Name = TEIGI_LONG_NAME_STR;
        update teigi;

        ContentDocumentLink cdlink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :taishoJido.Id];

        System.runAs(u) {
            Test.startTest();

            ContentVersion cv = [SELECT Id
                                   FROM ContentVersion
                                  WHERE ContentDocumentId = :cdlink.ContentDocumentId
                                  LIMIT 1];
            cv.ShinseiShoruiTeigiId__c   = teigi.Id;
            cv.Yoto__c                   = '本人確認';
            cv.OCR_Shimei__c             = 'テスト';
            cv.OCR_SeinenGappi__c        = '2023/01/01';
            cv.OCR_Jusho__c              = 'テスト住所';
            cv.OCR_YukoKigen__c          = '2028/01/01';
            cv.OCR_TextZembun__c         = 'テストテキスト全文';
            cv.Hantei_Shimei__c          = 'OK';
            cv.Hantei_SeinenGappi__c     = 'OK';
            cv.Hantei_Jusho__c           = 'OK';
            cv.Hantei_YukoKigen__c       = 'OK';
            update cv;

            List<ContentVersion> cvControllerList = sfGazoHyojiController.getContentVersion(taishoJido.Id);

            Test.stopTest();

            ContentVersion cvCheck = [SELECT Id,
                                             VersionDataUrl,
                                             ShinseiShoruiTeigiId__c,             // 申請書類定義ID
                                             ShinseiShoruiTeigiName__c,           // 申請書類定義名
                                             Yoto__c,                             // 用途
                                             IsDeletable__c,                      // 削除可能フラグ
                                             MaskingFubi__c,                      // マスキング不備
                                             OCR_Shimei__c,                       // 氏名（OCR結果）
                                             OCR_SeinenGappi__c,                  // 生年月日（OCR結果）
                                             OCR_Jusho__c,                        // 住所（OCR結果）
                                             OCR_YukoKigen__c,                    // 有効期限（OCR結果）
                                             OCR_TextZembun__c,                   // テキスト全文（OCR結果）
                                             ShudoCheck_Shimei__c,                // 手動チェック：氏名
                                             ShudoCheck_SeinenGappi__c,           // 手動チェック：生年月日
                                             ShudoCheck_Jusho__c,                 // 手動チェック：住所
                                             ShudoCheck_YukoKigen__c,             // 手動チェック：有効期限
                                             Hantei_Shimei__c,                    // 判定：氏名
                                             Hantei_SeinenGappi__c,               // 判定：生年月日
                                             Hantei_Jusho__c,                     // 判定：住所
                                             Hantei_YukoKigen__c,                 // 判定：有効期限
                                             CreatedDate,
                                             ContentDocumentId
                                        FROM ContentVersion
                                       WHERE Id = :cv.Id
                                       LIMIT 1];

            Assert.areEqual(cvControllerList.size(), 1);

            ContentVersion cvController = cvControllerList.get(0);
            Assert.areEqual(cvController.VersionDataUrl           , cvCheck.VersionDataUrl);
            Assert.areEqual(cvController.ShinseiShoruiTeigiId__c  , cvCheck.ShinseiShoruiTeigiId__c);
            Assert.areEqual(cvController.ShinseiShoruiTeigiName__c, cvCheck.ShinseiShoruiTeigiName__c.left(12) + '～');
            Assert.areEqual(cvController.Yoto__c                  , cvCheck.Yoto__c);
            Assert.areEqual(cvController.IsDeletable__c           , cvCheck.IsDeletable__c);
            Assert.areEqual(cvController.MaskingFubi__c           , cvCheck.MaskingFubi__c);
            Assert.areEqual(cvController.OCR_Shimei__c            , cvCheck.OCR_Shimei__c);
            Assert.areEqual(cvController.OCR_SeinenGappi__c       , cvCheck.OCR_SeinenGappi__c);
            Assert.areEqual(cvController.OCR_Jusho__c             , cvCheck.OCR_Jusho__c);
            Assert.areEqual(cvController.OCR_YukoKigen__c         , cvCheck.OCR_YukoKigen__c);
            Assert.areEqual(cvController.OCR_TextZembun__c        , cvCheck.OCR_TextZembun__c);
            Assert.areEqual(cvController.ShudoCheck_Shimei__c     , cvCheck.ShudoCheck_Shimei__c);
            Assert.areEqual(cvController.ShudoCheck_SeinenGappi__c, cvCheck.ShudoCheck_SeinenGappi__c);
            Assert.areEqual(cvController.ShudoCheck_Jusho__c      , cvCheck.ShudoCheck_Jusho__c);
            Assert.areEqual(cvController.ShudoCheck_YukoKigen__c  , cvCheck.ShudoCheck_YukoKigen__c);
            Assert.areEqual(cvController.Hantei_Shimei__c         , cvCheck.Hantei_Shimei__c);
            Assert.areEqual(cvController.Hantei_SeinenGappi__c    , cvCheck.Hantei_SeinenGappi__c);
            Assert.areEqual(cvController.Hantei_Jusho__c          , cvCheck.Hantei_Jusho__c);
            Assert.areEqual(cvController.Hantei_YukoKigen__c      , cvCheck.Hantei_YukoKigen__c);
            Assert.areEqual(cvController.CreatedDate              , cvCheck.CreatedDate);
            Assert.areEqual(cvController.ContentDocumentId        , cvCheck.ContentDocumentId);
        }
    }

    // 申請書類定義の選択リストを取得
    @isTest
    static void getShinseiShoruiTeigiPickList() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        List<ShinseiShoruiTeigi__c> teigiCheckList = [SELECT Id, Name FROM ShinseiShoruiTeigi__c];
        Map<Id, ShinseiShoruiTeigi__c> teigiCheckMap = new Map<Id, ShinseiShoruiTeigi__c>(teigiCheckList);

        System.runAs(u) {
            Test.startTest();

            String teigiSentakuListStr = sfGazoHyojiController.getShinseiShoruiTeigiPickList();

            Test.stopTest();

            List<Object> teigiSentakuList = (List<Object>)JSON.deserializeUntyped(teigiSentakuListStr);
            for(Object teigiSentaku :teigiSentakuList) {
                Map<String, Object> teigiSentakuMap = (Map<String, Object>)teigiSentaku;
                String label = (String)teigiSentakuMap.get('label');
                String value = (String)teigiSentakuMap.get('value');

                Assert.isTrue(teigiCheckMap.containsKey(value));
                Assert.areEqual(label, teigiCheckMap.get(value).Name);
            }
        }
    }

    // 添付書類の自動判定結果を取得：認定請求に紐付く場合
    @isTest
    static void setJidoHanteiKekkaNinteiSeikyu() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        Seikyusha__c seikyusha = [SELECT Id, Shimei__c FROM Seikyusha__c LIMIT 1];
        seikyusha.SeinenGappiDate__c = CHECK_DATA_DATE_01;
        seikyusha.Jusho__c           = CHECK_JUSHO_STR_01;
        update seikyusha;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.ShinseiKanryoDate__c = CHECK_DATA_DATE_01;
        ninteiSeikyu.ShinsaStatus__c      = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        String id01                    = 'test01';
        Map<String, String> hikakuNaiyo01 = new Map<String, String>();
        hikakuNaiyo01.put('id'                , id01);
        hikakuNaiyo01.put('shimeiOcr'         , 'テスト　氏名');
        hikakuNaiyo01.put('seinenGappiDateOcr', '令和5年9月1日');
        hikakuNaiyo01.put('jushoOcr'          , 'テスト県テスト市テスト町123');
        hikakuNaiyo01.put('yukoKigenDateOcr'  , '平成３５年９月１日');

        String id02                    = 'test02';
        Map<String, String> hikakuNaiyo02 = new Map<String, String>();
        hikakuNaiyo02.put('id'                , id02);
        hikakuNaiyo02.put('shimeiOcr'         , 'ﾃｽﾄ　氏名');
        hikakuNaiyo02.put('seinenGappiDateOcr', '大正112年9月1日');
        hikakuNaiyo02.put('jushoOcr'          , 'ﾃﾞｽﾞﾄﾞ県ﾃﾞｽﾞﾄﾞ市ﾃﾞｽﾞﾄﾞ町123?');
        hikakuNaiyo02.put('yukoKigenDateOcr'  , '2023年（令和５年）９月１日');

        String id03                    = 'test03';
        Map<String, String> hikakuNaiyo03 = new Map<String, String>();
        hikakuNaiyo03.put('id'                , id03);
        hikakuNaiyo03.put('shimeiOcr'         , '');
        hikakuNaiyo03.put('seinenGappiDateOcr', '');
        hikakuNaiyo03.put('jushoOcr'          , ' ');
        hikakuNaiyo03.put('yukoKigenDateOcr'  , '令和5年9月1');

        String id04                    = 'test04';
        Map<String, String> hikakuNaiyo04 = new Map<String, String>();
        hikakuNaiyo04.put('id'                , id04);
        hikakuNaiyo04.put('shimeiOcr'         , 'テスト 氏名');
        hikakuNaiyo04.put('seinenGappiDateOcr', '昭和98年9月1日');
        hikakuNaiyo04.put('jushoOcr'          , 'てすと県てすと市てすと町123');
        hikakuNaiyo04.put('yukoKigenDateOcr'  , '令和元年9月1日');

        List<Map<String, String>> hikakuNaiyoList = new List<Map<String, String>>{hikakuNaiyo01, hikakuNaiyo02, hikakuNaiyo03, hikakuNaiyo04};
        String hikakuNaiyoStr = JSON.serialize(hikakuNaiyoList);

        System.runAs(u) {
            Test.startTest();

            String jidouHanteiKekkaStr = sfGazoHyojiController.setJidoHanteiKekka(ninteiSeikyu.Id, hikakuNaiyoStr);

            Test.stopTest();

            Map<String, Map<String, Object>> hanteiKekkaCheckMap = new Map<String, Map<String, Object>>();
            List<Object> hanteiKekkaList = (List<Object>)JSON.deserializeUntyped(jidouHanteiKekkaStr);
            for(Object hanteiKekka :hanteiKekkaList) {
                Map<String, Object> hanteiKekkaMap = (Map<String, Object>)hanteiKekka;
            
                if(id01.equals((String)hanteiKekkaMap.get('id'))) {
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id02.equals((String)hanteiKekkaMap.get('id'))) {
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id03.equals((String)hanteiKekkaMap.get('id'))) {
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id04.equals((String)hanteiKekkaMap.get('id'))) {
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                }
            }
        }
        
    }

    // 添付書類の自動判定結果を取得：対象児童に紐付く場合
    @isTest
    static void setJidoHanteiKekkaTaishoJido() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        TaishoJido__c taishoJido = [SELECT Id FROM TaishoJido__c LIMIT 1];
        taishoJido.Shimei__c          = CHECK_SHIMEI_STR_01;
        taishoJido.SeinenGappiDate__c = CHECK_DATA_DATE_01;
        taishoJido.Jusho__c           = CHECK_JUSHO_STR_01;
        update taishoJido;

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];
        ninteiSeikyu.ShinseiKanryoDate__c = CHECK_DATA_DATE_01;
        ninteiSeikyu.ShinsaStatus__c      = SHINSA_STATUS_STR_SHINSACHU_00;
        update ninteiSeikyu;

        String id01                    = 'test01';
        Map<String, String> hikakuNaiyo01 = new Map<String, String>();
        hikakuNaiyo01.put('id'                , id01);
        hikakuNaiyo01.put('shimeiOcr'         , 'テスト　氏名');
        hikakuNaiyo01.put('seinenGappiDateOcr', '2023 JAN 1');
        hikakuNaiyo01.put('jushoOcr'          , 'テスト県テスト市テスト町123');
        hikakuNaiyo01.put('yukoKigenDateOcr'  , '2023 Feb 1');

        String id02                    = 'test02';
        Map<String, String> hikakuNaiyo02 = new Map<String, String>();
        hikakuNaiyo02.put('id'                , id02);
        hikakuNaiyo02.put('shimeiOcr'         , 'ﾃｽﾄ　氏名');
        hikakuNaiyo02.put('seinenGappiDateOcr', '2023 APR 1');
        hikakuNaiyo02.put('jushoOcr'          , 'ﾃﾞｽﾞﾄﾞ県ﾃﾞｽﾞﾄﾞ市ﾃﾞｽﾞﾄﾞ町123?');
        hikakuNaiyo02.put('yukoKigenDateOcr'  , '2023 May 1');

        String id03                    = 'test03';
        Map<String, String> hikakuNaiyo03 = new Map<String, String>();
        hikakuNaiyo03.put('id'                , id03);
        hikakuNaiyo03.put('shimeiOcr'         , '');
        hikakuNaiyo03.put('seinenGappiDateOcr', '2023 JULY 1');
        hikakuNaiyo03.put('jushoOcr'          , ' ');
        hikakuNaiyo03.put('yukoKigenDateOcr'  , '2023 August 1');

        String id04                    = 'test04';
        Map<String, String> hikakuNaiyo04 = new Map<String, String>();
        hikakuNaiyo04.put('id'                , id04);
        hikakuNaiyo04.put('shimeiOcr'         , 'テスト　氏名');
        hikakuNaiyo04.put('seinenGappiDateOcr', '２０２３ OCTOBER 1');
        hikakuNaiyo04.put('jushoOcr'          , 'テスト県テスト市テスト町123');
        hikakuNaiyo04.put('yukoKigenDateOcr'  , '２０２３ November 1');

        String id05                    = 'test05';
        Map<String, String> hikakuNaiyo05 = new Map<String, String>();
        hikakuNaiyo05.put('id'                , id05);
        hikakuNaiyo05.put('shimeiOcr'         , 'テスト　氏名');
        hikakuNaiyo05.put('seinenGappiDateOcr', '2023 9 1');
        hikakuNaiyo05.put('jushoOcr'          , 'テスト県テスト市テスト町123');
        hikakuNaiyo05.put('yukoKigenDateOcr'  , '令和5年9月1');

        List<Map<String, String>> hikakuNaiyoList = new List<Map<String, String>>{hikakuNaiyo01, hikakuNaiyo02, hikakuNaiyo03, hikakuNaiyo04, hikakuNaiyo05};
        String hikakuNaiyoStr = JSON.serialize(hikakuNaiyoList);

        System.runAs(u) {
            Test.startTest();

            String jidouHanteiKekkaStr = sfGazoHyojiController.setJidoHanteiKekka(taishoJido.Id, hikakuNaiyoStr);

            Test.stopTest();

            Map<String, Map<String, Object>> hanteiKekkaCheckMap = new Map<String, Map<String, Object>>();
            List<Object> hanteiKekkaList = (List<Object>)JSON.deserializeUntyped(jidouHanteiKekkaStr);
            for(Object hanteiKekka :hanteiKekkaList) {
                Map<String, Object> hanteiKekkaMap = (Map<String, Object>)hanteiKekka;
                
                if(id01.equals((String)hanteiKekkaMap.get('id'))) {
                    System.debug('確認id01：');
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id02.equals((String)hanteiKekkaMap.get('id'))) {
                    System.debug('確認id02：');
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id03.equals((String)hanteiKekkaMap.get('id'))) {
                    System.debug('確認id03：');
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id04.equals((String)hanteiKekkaMap.get('id'))) {
                    System.debug('確認id04：');
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isFalse((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                } else if(id05.equals((String)hanteiKekkaMap.get('id'))) {
                    System.debug('確認id05：');
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('shimeiKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('seinenGappiDateKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('jushoKekka'));
                    Assert.isTrue((Boolean)hanteiKekkaMap.get('yukokigenDateKekka'));
                }
            }
        }
    }

    // 添付書類の申請書類定義等を設定
    @isTest
    static void updateContentVersionTeigi() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        NinteiSeikyu__c ninteiSeikyu = [SELECT Id FROM NinteiSeikyu__c LIMIT 1];

        ShinseiShoruiTeigi__c teigi = [SELECT Id FROM ShinseiShoruiTeigi__c LIMIT 1];

        ContentDocumentLink cdlink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ninteiSeikyu.Id];

        ContentVersion cv = [SELECT Id
                               FROM ContentVersion
                              WHERE ContentDocumentId = :cdlink.ContentDocumentId
                              LIMIT 1];

        List<Map<String, Object>> setTeigiList = new List<Map<String, Object>>();

        Map<String, object> setTeigiMap = new Map<String, object>();
        setTeigiMap.put('id', cv.Id);
        setTeigiMap.put('shinseiShoruiTeigiId', teigi.Id);
        setTeigiList.add(setTeigiMap);

        String setTeigiStr = JSON.serialize(setTeigiList);

        System.runAs(u) {
            
            Test.startTest();
            
            String errorMessage = sfGazoHyojiController.updateContentVersionTeigi(setTeigiStr);
            
            Test.stopTest();

            ContentVersion checkCV = [SELECT Id,
                                             ShinseiShoruiTeigiId__c
                                        FROM ContentVersion
                                       WHERE Id = :cv.Id
                                       LIMIT 1];

            Assert.areEqual(checkCV.ShinseiShoruiTeigiId__c, teigi.Id);
        }
    }

    // 添付書類の手動チェックを更新
    @isTest
    static void updateContentVersionCheck() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        System.runAs(u) {

            List<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
            List<Map<String, Object>> checkKekkaList = new List<Map<String, Object>>();

            ContentVersion cv1 = cvList.get(0);
            Map<String, Object> checkKekkaMap1 = new Map<String, Object>();
            checkKekkaMap1.put('id'                , cv1.Id);
            checkKekkaMap1.put('shimeiCheck'       , true);
            checkKekkaMap1.put('seinenGappiCheck'  , true);
            checkKekkaMap1.put('jushoCheck'        , true);
            checkKekkaMap1.put('yukokigenDateCheck', true);
            checkKekkaMap1.put('textZembunCheck'  , true);
            checkKekkaMap1.put('maskingFubiCheck'  , true);
            checkKekkaList.add(checkKekkaMap1);

            ContentVersion cv2 = cvList.get(1);
            Map<String, Object> checkKekkaMap2 = new Map<String, Object>();
            checkKekkaMap2.put('id'                , cv2.Id);
            checkKekkaMap2.put('shimeiCheck'       , false);
            checkKekkaMap2.put('seinenGappiCheck'  , false);
            checkKekkaMap2.put('jushoCheck'        , false);
            checkKekkaMap2.put('yukokigenDateCheck', false);
            checkKekkaMap2.put('textZembunCheck'  , false);
            checkKekkaMap2.put('maskingFubiCheck'  , false);
            checkKekkaList.add(checkKekkaMap2);

            String setCheckKekkaStr = JSON.serialize(checkKekkaList);

            Test.startTest();

            String errorMessage = sfGazoHyojiController.updateContentVersionCheck(setCheckKekkaStr);

            Test.stopTest();

            List<ContentVersion> checkCVList = [SELECT Id,
                                                       ShudoCheck_Shimei__c,
                                                       ShudoCheck_SeinenGappi__c,
                                                       ShudoCheck_Jusho__c,
                                                       ShudoCheck_YukoKigen__c,
                                                       MaskingFubi__c
                                                  FROM ContentVersion];
            Map<Id, ContentVersion> checkCVMap = new Map<Id, ContentVersion>(checkCVList);

            Assert.isTrue(checkCVMap.containsKey(cv1.Id));
            Assert.isTrue(checkCVMap.get(cv1.Id).ShudoCheck_Shimei__c);
            Assert.isTrue(checkCVMap.get(cv1.Id).ShudoCheck_SeinenGappi__c);
            Assert.isTrue(checkCVMap.get(cv1.Id).ShudoCheck_Jusho__c);
            Assert.isTrue(checkCVMap.get(cv1.Id).ShudoCheck_YukoKigen__c);
            Assert.isTrue(checkCVMap.get(cv1.Id).MaskingFubi__c);

            Assert.isTrue(checkCVMap.containsKey(cv2.Id));
            Assert.isFalse(checkCVMap.get(cv2.Id).ShudoCheck_Shimei__c);
            Assert.isFalse(checkCVMap.get(cv2.Id).ShudoCheck_SeinenGappi__c);
            Assert.isFalse(checkCVMap.get(cv2.Id).ShudoCheck_Jusho__c);
            Assert.isFalse(checkCVMap.get(cv2.Id).ShudoCheck_YukoKigen__c);
            Assert.isFalse(checkCVMap.get(cv2.Id).MaskingFubi__c);
        }
    }

    // 添付書類の判定結果を更新
    @isTest
    static void updateContentVersionHantei() {
        String userName = USER_NAME_STR_SHINSA + SfTestUtil.TEST_DOMAIN;
        User u = [SELECT Id, UserName FROM User WHERE UserName = :userName LIMIT 1];

        System.runAs(u) {

            List<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
            List<Map<String, Object>> checkKekkaList = new List<Map<String, Object>>();

            ContentVersion cv1 = cvList.get(0);
            Map<String, Object> checkKekkaMap1 = new Map<String, Object>();
            checkKekkaMap1.put('id'                        , cv1.Id);
            checkKekkaMap1.put('shimeiKekkaAuto'           , true);
            checkKekkaMap1.put('seinenGappiDateKekkaAuto'  , true);
            checkKekkaMap1.put('jushoKekkaAuto'            , true);
            checkKekkaMap1.put('yukokigenDateKekkaAuto'    , false);
            checkKekkaMap1.put('shimeiKekkaManual'         , false);
            checkKekkaMap1.put('seinenGappiDateKekkaManual', false);
            checkKekkaMap1.put('jushoKekkaManual'          , false);
            checkKekkaMap1.put('yukokigenDateKekkaManual'  , true);
            checkKekkaList.add(checkKekkaMap1);

            ContentVersion cv2 = cvList.get(1);
            Map<String, Object> checkKekkaMap2 = new Map<String, Object>();
            checkKekkaMap2.put('id'                        , cv2.Id);
            checkKekkaMap2.put('shimeiKekkaAuto'           , false);
            checkKekkaMap2.put('seinenGappiDateKekkaAuto'  , false);
            checkKekkaMap2.put('jushoKekkaAuto'            , false);
            checkKekkaMap2.put('yukokigenDateKekkaAuto'    , false);
            checkKekkaMap2.put('shimeiKekkaManual'         , false);
            checkKekkaMap2.put('seinenGappiDateKekkaManual', false);
            checkKekkaMap2.put('jushoKekkaManual'          , false);
            checkKekkaMap2.put('yukokigenDateKekkaManual'  , false);
            checkKekkaList.add(checkKekkaMap2);

            String setCheckKekkaStr = JSON.serialize(checkKekkaList);

            Test.startTest();

            String kekkaListStr = sfGazoHyojiController.updateContentVersionHantei(setCheckKekkaStr);

            Test.stopTest();

            List<ContentVersion> checkCVList = [SELECT Id,
                                                       Hantei_Shimei__c,
                                                       Hantei_SeinenGappi__c,
                                                       Hantei_Jusho__c,
                                                       Hantei_YukoKigen__c
                                                  FROM ContentVersion];
            Map<Id, ContentVersion> checkCVMap = new Map<Id, ContentVersion>(checkCVList);

            Assert.isTrue(checkCVMap.containsKey(cv1.Id));
            Assert.areEqual(checkCVMap.get(cv1.Id).Hantei_Shimei__c     , HANTEI_KEKKA_STR_OK);
            Assert.areEqual(checkCVMap.get(cv1.Id).Hantei_SeinenGappi__c, HANTEI_KEKKA_STR_OK);
            Assert.areEqual(checkCVMap.get(cv1.Id).Hantei_Jusho__c      , HANTEI_KEKKA_STR_OK);
            Assert.areEqual(checkCVMap.get(cv1.Id).Hantei_YukoKigen__c  , HANTEI_KEKKA_STR_OK);

            Assert.isTrue(checkCVMap.containsKey(cv2.Id));
            Assert.isNull(checkCVMap.get(cv2.Id).Hantei_Shimei__c);
            Assert.isNull(checkCVMap.get(cv2.Id).Hantei_SeinenGappi__c);
            Assert.isNull(checkCVMap.get(cv2.Id).Hantei_Jusho__c);
            Assert.isNull(checkCVMap.get(cv2.Id).Hantei_YukoKigen__c);
        }
    }
}