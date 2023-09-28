@IsTest public without sharing class CycleJobBatchTest {

    static List<String> sstList = new List<String>();
    static List<Seikyusha__c> sksList = new List<Seikyusha__c>();
    static List<Seikyusha__c> mynumsksList = new List<Seikyusha__c>();
    static List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
    static List<NinteiSeikyu__c> nsList = new List<NinteiSeikyu__c>();
    static List<NinteiSeikyu__c> mynumnsList = new List<NinteiSeikyu__c>();
    static List<TaishoJido__c> tjList = new List<TaishoJido__c>();

    @testSetup
    static void setup() {
        System.debug('start setup...');
        // 各テストメソッドで使用できるテストデータを作成する
        // List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        ShinseiShoruiTeigi__c ssta = new ShinseiShoruiTeigi__c();
        ssta.Name = '認定請求書1枚目の表';
        ssta.ShoruiSetsumei__c = 'A';
        insert ssta;
        // SRSM_A = ssta.Id;
        sstList.add(String.valueOf(ssta.Id));

        ShinseiShoruiTeigi__c sstb = new ShinseiShoruiTeigi__c();
        sstb.Name = '認定請求書1枚目の裏';
        sstb.ShoruiSetsumei__c = 'B';
        insert sstb;
        sstList.add(String.valueOf(sstb.Id));

        System.debug(sstList);

        // 郵送申請レコードを作成
        // createYusoShinseiList();

        System.debug(ysList);

        System.debug('finish setup...');
    }

    @isTest
    static void Test01() {

        System.debug('Test01...');

        createSeikyushaList();

        createYusoShinseiList();

        System.debug(sksList);

        createNinteiSeikyu();

        insert nsList;
        System.debug('NinteiSeikyu__c List:');
        System.debug(nsList);

        createTaishoJido();

        List<ContentVersion> cvList = new List<ContentVersion>();

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';
        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-1-A';

        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        insert cvList;

        documentName = String.valueOf(tjList.get(0).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(0).Id);

        documentName = String.valueOf(tjList.get(1).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(1).Id);

        documentName = String.valueOf(tjList.get(2).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(2).Id);

        documentName = String.valueOf(tjList.get(3).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(3).Id);

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        Set<Id> idset = new Set<Id>();
        idset.add(nsList.get(0).Id);
        idset.add(nsList.get(1).Id);
        idset.add(nsList.get(2).Id);
        idset.add(nsList.get(3).Id);

        nsList = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];

        for (NinteiSeikyu__c nsItem : nsList){
            system.assertEquals('OCR処理中', nsItem.ShinsaStatus__c, '');
        }

        idset.clear();
        // 公的個人認証
        idset.add(mynumnsList.get(0).Id);
        nsList = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];
        for (NinteiSeikyu__c nsItem : nsList){
            system.assertEquals('0次審査待ち', nsItem.ShinsaStatus__c, '');
        }

    }

    @isTest
    static void Test02() {

        createSeikyushaList();

        createYusoShinseiList();

        System.debug(sksList);

        createNinteiSeikyu();
        insert nsList;

        createTaishoJido();
        
        System.debug('NinteiSeikyu__c List:');
        System.debug(nsList);

        List<ContentVersion> cvList = new List<ContentVersion>();

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';

        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-3-C';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-41-D';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-5-B';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-6-1';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        insert cvList;

        documentName = String.valueOf(tjList.get(0).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(0).Id);

        documentName = String.valueOf(tjList.get(1).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(1).Id);

        documentName = String.valueOf(tjList.get(2).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(2).Id);

        documentName = String.valueOf(tjList.get(3).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(3).Id);

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        Set<Id> idset = new Set<Id>();
        idset.add(nsList.get(0).Id);
        idset.add(nsList.get(1).Id);
        idset.add(nsList.get(2).Id);
        idset.add(nsList.get(3).Id);

        nsList = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];

        for (NinteiSeikyu__c nsItem : nsList){
            System.debug('審査ステータス: ' + nsItem.ShinsaStatus__c);
            system.assertEquals('0次審査待ち', nsItem.ShinsaStatus__c, '');
        }

    }

    @isTest
    static void Test03() {

        createSeikyushaList();

        createYusoShinseiList();

        System.debug(sksList);

        createNinteiSeikyu();

        insert nsList;
        System.debug('NinteiSeikyu__c List:');
        System.debug(nsList);

        createTaishoJido();

        List<ContentVersion> cvList = new List<ContentVersion>();

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';
        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        insert cvList;

        documentName = String.valueOf(tjList.get(0).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(0).Id);

        documentName = String.valueOf(tjList.get(1).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(1).Id);

        documentName = String.valueOf(tjList.get(2).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(2).Id);

        documentName = String.valueOf(tjList.get(3).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, true, tjList.get(3).Id);

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        Set<Id> idset = new Set<Id>();
        idset.add(nsList.get(0).Id);
        idset.add(nsList.get(1).Id);
        idset.add(nsList.get(2).Id);
        idset.add(nsList.get(3).Id);
        idset.add(mynumnsList.get(0).Id);
        System.debug(mynumnsList.get(0).Id);
        System.debug(idset);
       
        List<NinteiSeikyu__c> nsList2 = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];
        Map<Id, String> statusMap = new Map<Id, String>();
        for (NinteiSeikyu__c nsItem : nsList2){
            statusMap.put(nsItem.Id, nsItem.ShinsaStatus__c);
        }

        System.debug(nsList2);

        System.debug('id(0): ' + nsList.get(0).Id);
        System.debug('id(1): ' + nsList.get(1).Id);
        System.debug('id(2): ' + nsList.get(2).Id);
        System.debug('id(3): ' + nsList.get(3).Id);
        system.assertEquals('OCR処理中', statusMap.get(nsList.get(0).Id), '');
        system.assertEquals('0次審査待ち', statusMap.get(nsList.get(1).Id), '');
        system.assertEquals('OCR処理中', statusMap.get(nsList.get(2).Id), '');
        system.assertEquals('0次審査待ち', statusMap.get(nsList.get(3).Id), '');
        system.assertEquals('0次審査待ち', statusMap.get(mynumnsList.get(0).Id), '');

    }

    @isTest
    static void Test04() {

        createSeikyushaList();

        createYusoShinseiList();

        System.debug(sksList);

        createNinteiSeikyu();

        insert nsList;
        System.debug('NinteiSeikyu__c List:');
        System.debug(nsList);

        createTaishoJido();

        List<ContentVersion> cvList = new List<ContentVersion>();

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';
        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(2).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-2-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-3-A';
        cv = createContentVersion(documentName, bodyBlob, false);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(3).Id) + '-4-A';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        insert cvList;

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        Set<Id> idset = new Set<Id>();
        idset.add(nsList.get(0).Id);
        idset.add(nsList.get(1).Id);
        idset.add(nsList.get(2).Id);
        idset.add(nsList.get(3).Id);

        nsList = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];
        Map<Id, String> statusMap = new Map<Id, String>();
        for (NinteiSeikyu__c nsItem : nsList){
            statusMap.put(nsItem.Id, nsItem.ShinsaStatus__c);
        }

        system.assertEquals('0次審査待ち', statusMap.get(nsList.get(0).Id), '');
        system.assertEquals('OCR処理中', statusMap.get(nsList.get(1).Id), '');
        system.assertEquals('0次審査待ち', statusMap.get(nsList.get(2).Id), '');
        system.assertEquals('OCR処理中', statusMap.get(nsList.get(3).Id), '');

    }

    @isTest
    static void Test05() {

        createSeikyushaList();

        createYusoShinseiList();

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(0).Id;
        ns.YusoShinsei__c = ysList.get(0).Id;

        insert ns;
        System.debug('NinteiSeikyu__c:');
        System.debug(ns);

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';
        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, true);

        insert cv;

        // TaishoshaKubun__c tkA = new TaishoshaKubun__c();
        // tka.Name = 'A-1';
        // insert tka;

        // TaishoshaKubun__c tkB = new TaishoshaKubun__c();
        // tkb.Name = 'B-1';
        // insert tkb;

        List<TaishoJido__c> tjList = new List<TaishoJido__c>();

        // 転入転出なし     12ヶ月
        TaishoJido__c tj = new TaishoJido__c();
        // tj.TaishoshaKubun__c = tka.Id;
        tj.NinteiSeikyu__c = ns.Id;
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間内都内転入あり(月初) 2023/6/1~2024/3/31  10ヶ月
        tj = new TaishoJido__c();
        // tj.TaishoshaKubun__c = tkb.Id;
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2023-06-01');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間内都内転入あり(月初以外) 2023/8/1~2024/3/31  8ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2023-07-02');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間外都内転出あり   2023/4/1~2023/12/31     9ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-12-02');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間内都内転出あり   2023/5/2 < 申請日/システム日付 転出済　返下
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-05-02');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 都内転出 次に 都内転入   2023/4/1~2023/5/31 + 2023/8/1~2024/3/31     10ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-06-01');
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2023-07-12');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 都内転入 次に 都内転出   2023/5/1~2023/12/31     7ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2023-05-31');
        tj.IsTochuTennyuShussei__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-12-12');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間内都内転入あり システム日付以降~2024/3/31  0ヶ月 
        tj = new TaishoJido__c();
        // tj.TaishoshaKubun__c = tkb.Id;
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.today().addMonths(1);
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 都内転出 次に 都内転入   2023/4/1~2023/5/31 + システム日付以降~2024/3/31     0ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-05-31');
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.today().addMonths(1);
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 都内転入 次に 都内転出   2023/5/1~2023/12/31     0ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TennyuShusseiDate__c = Date.today().addMonths(1);
        tj.IsTochuTennyuShussei__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-12-12');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 都内転出 次に 都内転入   2023/4/1~2023/6/30 + 2023/8/1~2024/3/31     11ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2023-06-02');
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2023-07-12');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間外都内転入 転出   2018/7/2 ~ 2018/10/2     0ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTenshutsu__c = true;
        tj.TenshutsuDate__c = Date.valueOf('2012-08-15');
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2018-08-15');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        // 期間内都内転入あり(月初) 2013/6/1~2024/3/31  0ヶ月
        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.IsTochuTennyuShussei__c = true;
        tj.TennyuShusseiDate__c = Date.valueOf('2013-06-01');
        tj.KyojuKikan__c = 0;
        tjList.add(tj);

        insert tjList;

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        NinteiSeikyu__c newNS = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id = :ns.Id];
        system.assertEquals('0次審査待ち', newNS.ShinsaStatus__c, '');

        Set<Id> keySet = new Set<Id>();
        for(TaishoJido__c t : tjList) {
            keySet.add(t.Id);
        }

        List<TaishoJido__c> updedList = [SELECT id, KyojuKikan__c from TaishoJido__c WHERE id in :keySet];
        Map<Id, TaishoJido__c> taishoJidoMap = new Map<Id, TaishoJido__c>();
        for(TaishoJido__c t : updedList) {
            taishoJidoMap.put(t.Id, t);
        }

        System.assertEquals(12, taishoJidoMap.get(tjList.get(0).Id).KyojuKikan__c, '' );
        System.assertEquals(10, taishoJidoMap.get(tjList.get(1).Id).KyojuKikan__c, '' );
        System.assertEquals(8, taishoJidoMap.get(tjList.get(2).Id).KyojuKikan__c, '');
        System.assertEquals(9, taishoJidoMap.get(tjList.get(3).Id).KyojuKikan__c, '');
        System.assertEquals(0, taishoJidoMap.get(tjList.get(4).Id).KyojuKikan__c, '');
        System.assertEquals(10, taishoJidoMap.get(tjList.get(5).Id).KyojuKikan__c, '');
        System.assertEquals(7, taishoJidoMap.get(tjList.get(6).Id).KyojuKikan__c, '');
        System.assertEquals(0, taishoJidoMap.get(tjList.get(7).Id).KyojuKikan__c, '');
        System.assertEquals(0, taishoJidoMap.get(tjList.get(8).Id).KyojuKikan__c, '');
        System.assertEquals(0, taishoJidoMap.get(tjList.get(9).Id).KyojuKikan__c, '');
        System.assertEquals(11, taishoJidoMap.get(tjList.get(10).Id).KyojuKikan__c, '');
        System.assertEquals(0, taishoJidoMap.get(tjList.get(11).Id).KyojuKikan__c, '');
        System.assertEquals(0, taishoJidoMap.get(tjList.get(12).Id).KyojuKikan__c, '');

    }

    // @isTest
    // /**
    //  * 異常系確認
    //  */
    // static void Test06(){

    //     createSeikyushaList();

    //     createYusoShinseiList();

    //     List<NinteiSeikyu__c> nsList = new List<NinteiSeikyu__c>();
    //     NinteiSeikyu__c ns = new NinteiSeikyu__c();
    //     ns.ShinsaStatus__c = 'OCR処理中';
    //     ns.Seikyusha__c = sksList.get(0).Id;
    //     ns.YusoShinsei__c = ysList.get(0).Id;
    //     nsList.add(ns);

    //     insert nsList;
    //     System.debug('NinteiSeikyu__c List:');
    //     System.debug(nsList);

    //     // List<ContentVersion> cvList = new List<ContentVersion>();

    //     // //本体
    //     // String documentBody = 'test,csv';
    //     // Blob bodyBlob = Blob.valueOf(documentBody);

    //     // //タイトル
    //     // String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';
    //     // //ファイルの生成
    //     // ContentVersion cv = createContentVersion(documentName, bodyBlob, true);
    //     // cvList.add(cv);

    //     // insert cvList;

    //     Profile padmin = [SELECT Id FROM Profile WHERE Name='システム管理者_カスタム'];
    //     User uadmin = [Select id, name, userroleid from user where ProfileId = :padmin.Id and isactive = true limit 1 ];

    //     userrole us =  [Select id, name from userrole where name = '事務局'];

    //     if (uadmin.userroleid == null) {
    //         uadmin.userroleid = us.Id;
    //         update uadmin;
    //     }
        
    //     User u;
    //     System.runAs(uadmin) {
    //         Profile p = [SELECT Id FROM Profile WHERE Name='認定請求者'];
    //         u = new User(Alias = 'testuser', Email='standarduser@testorg.com', 
    //             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    //             LocaleSidKey='en_US', ProfileId = p.Id,
    //             TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
            
    //         insert u;
    //     }

    //     System.runAs(u) {
    //         System.debug('Current User: ' + UserInfo.getUserName());
    //         System.debug('Current Profile: ' + UserInfo.getProfileId());

    //         Test.StartTest();
    //         CycleJobBatch cjb = new CycleJobBatch();
    //         Database.executebatch(cjb);
    //         Test.stopTest();
    //     }
    //     List<BatchErrorInfo__c> beiList = [Select BatchName__c, BatchClassName__c, OccurTime__c, ExceptionInfo__c, ExceptionStacktrace__c  from BatchErrorInfo__c];
    //     system.debug(beiList);
    //     system.assertEquals(1, beiList.size());
        
    // }

    @isTest
    /**
     * 特別ケース：添付ファイルある、チェック対象0件
     */
    static void Test07() {

        createSeikyushaList();

        createYusoShinseiList();

        List<NinteiSeikyu__c> nsList = new List<NinteiSeikyu__c>();
        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(0).Id;
        ns.YusoShinsei__c = ysList.get(0).Id;
        nsList.add(ns);
        ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(1).Id;
        ns.YusoShinsei__c = ysList.get(1).Id;
        nsList.add(ns);

        insert nsList;
        System.debug('NinteiSeikyu__c List:');
        System.debug(nsList);

        List<ContentVersion> cvList = new List<ContentVersion>();

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-11-';

        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(0).Id) + '-12-';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-21-';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-22-';
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        insert cvList;

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        Set<Id> idset = new Set<Id>();
        idset.add(nsList.get(0).Id);
        idset.add(nsList.get(1).Id);

        nsList = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];

        for (NinteiSeikyu__c nsItem : nsList){
            System.debug('審査ステータス: ' + nsItem.ShinsaStatus__c);
            system.assertEquals('0次審査待ち', nsItem.ShinsaStatus__c, '');
        }

    }

    @isTest
    static void Test08() {

        createSeikyushaList();

        createYusoShinseiList();

        System.debug(sksList);

        createNinteiSeikyu();
        insert nsList;

        createTaishoJido();
        
        System.debug('NinteiSeikyu__c List:');
        System.debug(nsList);

        List<ContentVersion> cvList = new List<ContentVersion>();

        //本体
        String documentBody = 'test,csv';
        Blob bodyBlob = Blob.valueOf(documentBody);

        //タイトル
        String documentName = String.valueOf(ysList.get(0).Id) + '-1-A';

        //ファイルの生成
        ContentVersion cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        documentName = String.valueOf(ysList.get(1).Id) + '-1-A';
        //ファイルの生成
        cv = createContentVersion(documentName, bodyBlob, true);
        cvList.add(cv);

        insert cvList;

        documentName = String.valueOf(tjList.get(0).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, false, tjList.get(0).Id);

        documentName = String.valueOf(tjList.get(1).Id) + '-4-B';
        createWebContentVersion(documentName, bodyBlob, false, tjList.get(1).Id);

        Test.StartTest();
        CycleJobBatch cjb = new CycleJobBatch();
        Database.executebatch(cjb);
        Test.stopTest();

        Set<Id> idset = new Set<Id>();
        idset.add(nsList.get(0).Id);
        idset.add(nsList.get(1).Id);

        nsList = [select id, name, ShinsaStatus__c from NinteiSeikyu__c where id in :idset];

        for (NinteiSeikyu__c nsItem : nsList){
            System.debug('審査ステータス: ' + nsItem.ShinsaStatus__c);
            system.assertEquals('OCR処理中', nsItem.ShinsaStatus__c, '');
        }

    }

    private static ContentVersion createContentVersion(String title, Blob body, Boolean kanryoFlg) {
        ContentVersion cv = new ContentVersion(
            Title=title
            , PathOnClient = title + '.csv'
            , VersionData = body
            , OwnerId = UserInfo.getUserId()
            , OCR_Kanryo__c = kanryoFlg
            , Shubetsu__c = '郵送'
        );
        return cv;
    }

    private static List<Seikyusha__c> createSeikyushaList() {
        Seikyusha__c sks = new Seikyusha__c();
        sks.HonninKakuninHoho__c = '券面アップロード';
        sksList.add(sks);

        sks = new Seikyusha__c();
        sks.HonninKakuninHoho__c = '券面アップロード';
        sksList.add(sks);

        sks = new Seikyusha__c();
        sks.HonninKakuninHoho__c = '券面アップロード';
        sksList.add(sks);

        sks = new Seikyusha__c();
        sks.HonninKakuninHoho__c = '券面アップロード';
        sksList.add(sks);
        
        insert sksList;

        sks = new Seikyusha__c();
        sks.HonninKakuninHoho__c = '公的個人認証';
        mynumsksList.add(sks);
        insert mynumsksList;

        return sksList;
    }

    private static List<YusoShinsei__c> createYusoShinseiList() {
        // List<YusoShinsei__c> ysList = new List<YusoShinsei__c>();
        YusoShinsei__c ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        ysList.add(ys);

        ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        ysList.add(ys);

        ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        ysList.add(ys);

        ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        ysList.add(ys);

        insert ysList;

        return ysList;
    }

    private static List<NinteiSeikyu__c> createNinteiSeikyu() {
        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(0).Id;
        ns.YusoShinsei__c = ysList.get(0).Id;
        nsList.add(ns);
        ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(1).Id;
        ns.YusoShinsei__c =  ysList.get(1).Id;
        nsList.add(ns);
        ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(2).Id;
        ns.YusoShinsei__c =  ysList.get(2).Id;
        nsList.add(ns);
        ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sksList.get(3).Id;
        ns.YusoShinsei__c =  ysList.get(3).Id;
        nsList.add(ns);

        // 公的個人認証
        ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = mynumsksList.get(0).Id;
        // ns.YusoShinsei__c =  ysList.get(3).Id;
        mynumnsList.add(ns);

        insert mynumnsList;
        System.debug('認定請求ID(公的個人認証) : ' + mynumnsList.get(0).Id);
        return nsList;
    }

    private static List<TaishoJido__c> createTaishoJido(){
        TaishoJido__c tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = nsList.get(0).Id;
        tjList.add(tj);

        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = nsList.get(1).Id;
        tjList.add(tj);

        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = nsList.get(2).Id;
        tjList.add(tj);

        tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = nsList.get(3).Id;
        tjList.add(tj);

        insert tjList;
        return tjList;
    }

    private static ContentVersion createWebContentVersion(String title, Blob body, Boolean kanryoFlg, Id targetId) {

        List<ShinseiShoruiTeigi__c> sstList2 = [select id, Name from ShinseiShoruiTeigi__c limit 10];

        ContentVersion cv = new ContentVersion(
            Title=title
            , PathOnClient = title + '.csv'
            , VersionData = body
            , OwnerId = UserInfo.getUserId()
            , OCR_Kanryo__c = kanryoFlg
            , Shubetsu__c = 'Web'
            , ShinseiShoruiTeigiId__c = sstList2.get(0).Id
        );

        insert cv;

        Contentversion cvId = [select id, ContentDocumentId, OCR_Kanryo__c, Shubetsu__c, ShinseiShoruiTeigiId__c from Contentversion where id =: cv.id];
        System.debug(cvId);
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = targetId;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId= cvId.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        List<ContentDocumentLink> cdlList = [select id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :targetId];
        System.debug(cdlList);

        return cv;
    }

}