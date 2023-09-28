@IsTest
public without sharing class SfTaishoJidoTriggerHandlerTest {
    @IsTest
    static void yusoShinseiScanDataUpdateTest001(){

        Seikyusha__c sks = new Seikyusha__c();
        insert sks;

        YusoShinsei__c ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        insert ys;

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sks.Id;
        ns.YusoShinsei__c = ys.Id;
        insert ns;

        TaishoJido__c tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.KyojuKikan__c = 0;
        insert tj;

        KinyuKikan__c kk = new KinyuKikan__c();
        kk.KinyuKikanCode__c = '0001';
        kk.Name = 'テスト銀行１';
        insert kk;
        Shiten__c st = new Shiten__c();
        st.KinyuKikan__c = kk.id;
        st.Name = '支店1';
        st.TempoCode__c = '001';
        st.NarabiCode__c = '1';
        st.ExternalId__c = '0001-001-1';
        insert st;
        Test.StartTest();
        TaishoJido__c tjUpdate = [select id,KinyuKikanCode__c,ShitenCode__c from TaishoJido__c where id =: tj.id];
        tjUpdate.KinyuKikanCode__c = '0001';
        tjUpdate.ShitenCode__c = '001';
        update tjUpdate;
        Test.stopTest();
    }

    @IsTest
    static void yusoShinseiScanDataUpdateTest002(){

        Seikyusha__c sks = new Seikyusha__c();
        insert sks;

        YusoShinsei__c ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        insert ys;

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sks.Id;
        ns.YusoShinsei__c = ys.Id;
        insert ns;

        TaishoJido__c tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.KyojuKikan__c = 0;
        insert tj;

        KinyuKikan__c kk = new KinyuKikan__c();
        kk.KinyuKikanCode__c = '0001';
        kk.Name = 'テスト銀行１';
        insert kk;
        Shiten__c st = new Shiten__c();
        st.KinyuKikan__c = kk.id;
        st.Name = '支店1';
        st.TempoCode__c = '001';
        st.NarabiCode__c = '1';
        st.ExternalId__c = '0001-001-1';
        insert st;
        Test.StartTest();
        TaishoJido__c tjUpdate = [select id,SK_KinyuKikanCode__c,SK_ShitenCode__c from TaishoJido__c where id =: tj.id];
        tjUpdate.SK_KinyuKikanCode__c = '0001';
        tjUpdate.SK_ShitenCode__c = '001';
        update tjUpdate;
        Test.stopTest();
    }
    @IsTest
    static void yusoShinseiScanDataUpdateTest003(){

        Seikyusha__c sks = new Seikyusha__c();
        insert sks;

        YusoShinsei__c ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        insert ys;

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sks.Id;
        ns.YusoShinsei__c = ys.Id;
        insert ns;

        TaishoJido__c tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.KyojuKikan__c = 0;
        insert tj;

        KinyuKikan__c kk = new KinyuKikan__c();
        kk.KinyuKikanCode__c = '0001';
        kk.Name = 'テスト銀行１';
        insert kk;
        Shiten__c st = new Shiten__c();
        st.KinyuKikan__c = kk.id;
        st.Name = '支店1';
        st.TempoCode__c = '001';
        st.NarabiCode__c = '1';
        st.ExternalId__c = '0001-001-1';
        insert st;
        Test.StartTest();
        TaishoJido__c tjUpdate = [select id,KinyuKikanCode__c,ShitenCode__c from TaishoJido__c where id =: tj.id];
        tjUpdate.KinyuKikanCode__c = '0002';
        tjUpdate.ShitenCode__c = '002';
        update tjUpdate;
        Test.stopTest();
    }

    @IsTest
    static void yusoShinseiScanDataUpdateTest004(){

        Seikyusha__c sks = new Seikyusha__c();
        insert sks;

        YusoShinsei__c ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        insert ys;

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.Seikyusha__c = sks.Id;
        ns.YusoShinsei__c = ys.Id;
        insert ns;

        TaishoJido__c tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.KyojuKikan__c = 0;
        insert tj;

        KinyuKikan__c kk = new KinyuKikan__c();
        kk.KinyuKikanCode__c = '0001';
        kk.Name = 'テスト銀行１';
        insert kk;
        Shiten__c st = new Shiten__c();
        st.KinyuKikan__c = kk.id;
        st.Name = '支店1';
        st.TempoCode__c = '001';
        st.NarabiCode__c = '1';
        st.ExternalId__c = '0001-001-1';
        insert st;
        Test.StartTest();
        TaishoJido__c tjUpdate = [select id,SK_KinyuKikanCode__c,SK_ShitenCode__c from TaishoJido__c where id =: tj.id];
        tjUpdate.SK_KinyuKikanCode__c = '0002';
        tjUpdate.SK_ShitenCode__c = '002';
        update tjUpdate;
        Test.stopTest();
    }
}