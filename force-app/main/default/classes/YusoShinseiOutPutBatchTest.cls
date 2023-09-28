@isTest
public class YusoShinseiOutPutBatchTest {
    @IsTest
    static void runBatchWithData01() {
        
        JobSettei__c setting = new JobSettei__c();
        setting.JobShubetsu__c = 'APEX';
        setting.ApexJobMei__c = '郵送申請情報出力';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = System.now();
        jk.JobSettei__c = setting.Id;
        insert jk;

        YusoShinseiOutPutBatch batch = new YusoShinseiOutPutBatch();

        YusoShinsei__c yuso = new YusoShinsei__c();
        yuso.YusoAtena__c = 'テスト';
        yuso.YusoYubinBangou__c = '1234567';
        yuso.YusoTodouFuken__c = '東京都';
        yuso.YusoShikuChoson__c = '千代田区';
        yuso.YusoChiban__c = '1-1';
        yuso.YusoHeyaBangou__c = '101';
        yuso.Status__c = '受付';
        insert yuso;

        Test.startTest();

        Database.executeBatch(batch);
        Test.stopTest();
    }

    
    @IsTest
    static void runBatchWithData02() {
        
        JobSettei__c setting = new JobSettei__c();
        setting.JobShubetsu__c = 'APEX';
        setting.ApexJobMei__c = '郵送申請情報出力';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = System.now() + 1;
        jk.JobSettei__c = setting.Id;
        insert jk;

        YusoShinseiOutPutBatch batch = new YusoShinseiOutPutBatch();

        YusoShinsei__c yuso = new YusoShinsei__c();
        yuso.YusoAtena__c = 'テスト';
        yuso.YusoYubinBangou__c = '1234567';
        yuso.YusoTodouFuken__c = '東京都';
        yuso.YusoShikuChoson__c = '千代田区';
        yuso.YusoChiban__c = '1-1';
        yuso.YusoHeyaBangou__c = '101';
        yuso.Status__c = '受付';
        insert yuso;

        Test.startTest();

        Database.executeBatch(batch);
        Test.stopTest();
    }

    
    @IsTest
    static void runBatchWithData03() {
        Test.startTest();
        
        JobSettei__c setting = new JobSettei__c();
        setting.JobShubetsu__c = 'APEX';
        setting.ApexJobMei__c = '郵送申請情報出力';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = System.now();
        jk.JobSettei__c = setting.Id;
        insert jk;

        YusoShinseiOutPutBatch batch = new YusoShinseiOutPutBatch();

        List<YusoShinsei__c> yusoList = new List<YusoShinsei__c>();
        for (Integer i = 0; i < 10; i++) {
            YusoShinsei__c yoso = new YusoShinsei__c();
            yoso.YusoAtena__c = 'テスト' + i;
            yoso.YusoYubinBangou__c = '1234567';
            yoso.YusoTodouFuken__c = '東京都';
            yoso.YusoShikuChoson__c = '千代田区';
            yoso.YusoChiban__c = '1-1';
            yoso.YusoHeyaBangou__c = '101';
            yoso.Status__c = '受付';
            yusoList.add(yoso);
        }
        insert yusoList;

        try {
            Database.executeBatch(batch);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    
    @IsTest
    static void runBatchWithData04() {
        
        JobSettei__c setting = new JobSettei__c();
        setting.JobShubetsu__c = 'APEX';
        setting.ApexJobMei__c = '郵送申請情報出力';
        insert setting;

        JobKanri__c jk = new JobKanri__c();
        jk.JikkoNichiji__c = System.now();
        jk.JobSettei__c = setting.Id;
        insert jk;

        YusoShinseiOutPutBatch batch = new YusoShinseiOutPutBatch();

        Test.startTest();

        Database.executeBatch(batch);
        Test.stopTest();
    }
}