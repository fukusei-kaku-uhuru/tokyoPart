@IsTest
public without sharing class NinteiNoticeOutPutBatchTest {
    @isTest
    public static void testNo01(){
        JobSettei__c setting = new JobSettei__c();
        setting.Name = 'jobsetteiTEST';
        setting.JobShubetsu__c = 'APEX';
        setting.ApexJobMei__c = '認定通知書出力';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = Datetime.now().addSeconds(1);
        jk.JobSettei__c = setting.Id;
        insert jk;

        Seikyusha__c sks = new Seikyusha__c();
        sks.HonninKakuninHoho__c = '券面アップロード';
        sks.Shimei__c = '請求者す';
        insert sks;

        YusoShinsei__c ys = new YusoShinsei__c();
        ys.Status__c = '受付';
        insert ys;

        NinteiSeikyu__c ns = new NinteiSeikyu__c();
        ns.ShinsaStatus__c = '承認完了';
        ns.Seikyusha__c = sks.Id;
        ns.YusoShinsei__c = ys.Id;
        ns.SequenceBango__c = '00000167';
        insert ns;

        List<TaishoJido__c> tjList = new List<TaishoJido__c>();
        TaishoJido__c tj = new TaishoJido__c();
        tj.NinteiSeikyu__c = ns.Id;
        tj.BunsyoKanriBangou__c = 'bkNo1234';
        // tj.NinteiTsuchishoHakkoDate__c = Date.today();
        tj.Shimei__c = '対象　児童１';
        tj.Nintei_KetteiNengappiDate__c = Date.today();
        tj.ShikyuNinteiKaishiTsukiTochoDate__c = Date.valueOf('2023-04-01');
        tj.Nintei_Goukeigaku__c = 60000;
        // tj.SeikyuBangou__c = 'W00000167-00000067';
        tj.ShoninKekka__c = '認定';
        tjList.add(tj);

        TaishoJido__c tj2 = new TaishoJido__c();
        tj2.NinteiSeikyu__c = ns.Id;
        tj2.BunsyoKanriBangou__c = 'bkNo1235';
        // tj.NinteiTsuchishoHakkoDate__c = Date.today();
        tj2.Shimei__c = '対象　児童2';
        tj2.Nintei_KetteiNengappiDate__c = Date.today();
        tj2.ShikyuNinteiKaishiTsukiTochoDate__c = Date.valueOf('2019-04-30');
        tj2.Nintei_Goukeigaku__c = 10000;
        // tj.SeikyuBangou__c = 'W00000167-00000067';
        tj2.ShoninKekka__c = '認定';
        tjList.add(tj2);

        TaishoJido__c tj3 = new TaishoJido__c();
        tj3.NinteiSeikyu__c = ns.Id;
        tj3.BunsyoKanriBangou__c = 'bkNo1236';
        // tj.NinteiTsuchishoHakkoDate__c = Date.today();
        tj3.Shimei__c = '対象　児童3';
        tj3.Nintei_KetteiNengappiDate__c = Date.today();
        tj3.ShikyuNinteiKaishiTsukiTochoDate__c = Date.valueOf('2019-04-30');
        tj3.Nintei_Goukeigaku__c = 10000;
        // tj.SeikyuBangou__c = 'W00000167-00000067';
        tj3.ShoninKekka__c = '不認定';
        tjList.add(tj3);

        insert tjList;

        NinteiNoticeOutPutBatch batch = new NinteiNoticeOutPutBatch();
        Test.startTest();
        Database.executeBatch(batch, 2000);
        Test.stopTest();

        tj = [Select Id, NinteiTsuchiStatus__c from TaishoJido__c where id = :tj.Id];
        System.assertEquals('通知手配中（郵送）', tj.NinteiTsuchiStatus__c, '');

        tj2 = [Select Id, NinteiTsuchiStatus__c from TaishoJido__c where id = :tj2.Id];
        System.assertEquals('通知手配中（郵送）', tj2.NinteiTsuchiStatus__c, '');

        tj3 = [Select Id, NinteiTsuchiStatus__c from TaishoJido__c where id = :tj3.Id];
        System.assertEquals(null, tj3.NinteiTsuchiStatus__c, '');
    }

    @isTest
    public static void testNo02(){
        JobSettei__c setting = new JobSettei__c();
        setting.Name = 'jobsetteiTEST';
        setting.JobShubetsu__c = 'APEX';
        setting.ApexJobMei__c = '認定通知書出力';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = Datetime.now();
        jk.JobSettei__c = setting.Id;
        insert jk;

        NinteiNoticeOutPutBatch batch = new NinteiNoticeOutPutBatch();
        Test.startTest();
        Database.executeBatch(batch, 2000);
        Test.stopTest();

        jk = [Select Id, ShoriKekka__c from JobKanri__c where id = :jk.Id];
        System.assertEquals('成功（対象データなし）', jk.ShoriKekka__c, '');
    }

    @isTest
    public static void testNo03(){

        NinteiNoticeOutPutBatch batch = new NinteiNoticeOutPutBatch();
        Test.startTest();
        Database.executeBatch(batch, 2000);
        Test.stopTest();
    }

}