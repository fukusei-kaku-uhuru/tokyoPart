@IsTest public with sharing class JobKanriControlTest {
    @testSetup
    static void setup() {
        // 各テストメソッドで使用できるテストデータを作成する
    }

    @isTest
    static void Test01() {
        JobSettei__c js = new JobSettei__c();
        js.Name = 'jobsetteiTEST';
        js.JobShubetsu__c = 'APEX';
        js.ApexJobMei__c = '郵送申請情報出力';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        insert jk;

        // JobKanriControl jkc = new JobKanriControl();
        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(true, jk.RequestZumi__c);

    }

    @isTest
    static void Test02_01() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'OPROARTSアクション';
        js.OproartsActionMei__c = '出力_認定通知書(通常)';
        js.OproartsActionParamater__c = 'params';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        insert jk;

        Test.startTest();
        // JobKanriControl jkc = new JobKanriControl();
        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(true, jk.RequestZumi__c);
        Test.stopTest();

    }

    @isTest
    static void Test02_02() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'OPROARTSアクション';
        js.OproartsActionMei__c = '出力_不認定通知書(通常)';
        js.OproartsActionParamater__c = 'params';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        insert jk;

        Test.startTest();
        // JobKanriControl jkc = new JobKanriControl();
        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(true, jk.RequestZumi__c);
        Test.stopTest();

    }

    @isTest
    static void Test02_03() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'OPROARTSアクション';
        js.OproartsActionMei__c = '出力_認定通知書(DV被害者)';
        js.OproartsActionParamater__c = 'params';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        insert jk;

        Test.startTest();
        // JobKanriControl jkc = new JobKanriControl();
        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(true, jk.RequestZumi__c);
        Test.stopTest();

    }

    @isTest
    static void Test02_04() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'OPROARTSアクション';
        js.OproartsActionMei__c = '出力_不認定通知書(DV被害者)';
        js.OproartsActionParamater__c = 'params';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        insert jk;

        Test.startTest();
        // JobKanriControl jkc = new JobKanriControl();
        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(true, jk.RequestZumi__c);
        Test.stopTest();

    }

    // @isTest
    // static void Test02_03() {
    //     JobSettei__c js = new JobSettei__c();
    //     js.JobShubetsu__c = 'OPROARTSアクション';
    //     js.OproartsActionMei__c = '出力_不備通知書';
    //     js.OproartsActionParamater__c = 'params';

    //     insert js;

    //     JobKanri__c jk = new JobKanri__c();
    //     jk.JobSettei__c = js.Id;
    //     jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
    //     insert jk;

    //     Test.startTest();
    //     // JobKanriControl jkc = new JobKanriControl();
    //     JobKanriControl.registJob(String.valueOf(jk.Id));

    //     jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
    //     system.assertEquals(true, jk.RequestZumi__c);
    //     Test.stopTest();

    // }

    // @isTest
    // static void Test02_04() {
    //     JobSettei__c js = new JobSettei__c();
    //     js.JobShubetsu__c = 'OPROARTSアクション';
    //     js.OproartsActionMei__c = '出力_受給資格取消通知書';
    //     js.OproartsActionParamater__c = 'params';

    //     insert js;

    //     JobKanri__c jk = new JobKanri__c();
    //     jk.JobSettei__c = js.Id;
    //     jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
    //     insert jk;

    //     Test.startTest();
    //     // JobKanriControl jkc = new JobKanriControl();
    //     JobKanriControl.registJob(String.valueOf(jk.Id));

    //     jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
    //     system.assertEquals(true, jk.RequestZumi__c);
    //     Test.stopTest();

    // }

    @isTest
    static void Test03() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'AWS';
        js.LambdaURL__c = 'url';
        js.LambdaSecret__c = 'secret__c';
        js.LambdaParamater__c = 'paramater__c';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        insert jk;

        Test.startTest();
        // JobKanriControl jkc = new JobKanriControl();
        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(true, jk.RequestZumi__c);
        Test.stopTest();

    }

    @isTest
    static void Test04_01() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'APEX';
        js.ApexJobMei__c = '郵送申請情報出力';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        jk.RequestZumi__c = true;
        insert jk;

        JobKanriControl.registJob(String.valueOf(jk.Id));

        JobKanriControl.cancleJob(String.valueOf(jk.Id));

        jk = [select id, ShoriKekka__c from JobKanri__c where id = :jk.Id];
        system.assertEquals('取り消し', jk.ShoriKekka__c);

    }

    @isTest
    static void Test04_02() {
        JobSettei__c js = new JobSettei__c();
        js.JobShubetsu__c = 'OPROARTSアクション';
        js.OproartsActionMei__c = '出力_認定通知書(通常)';
        js.OproartsActionParamater__c = 'params';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        jk.RequestZumi__c = true;
        insert jk;

        JobKanriControl.registJob(String.valueOf(jk.Id));

        JobKanriControl.cancleJob(String.valueOf(jk.Id));

        jk = [select id, ShoriKekka__c from JobKanri__c where id = :jk.Id];
        system.assertEquals('取り消し', jk.ShoriKekka__c);

    }

    @isTest
    static void Test04_03() {
        JobSettei__c js = new JobSettei__c();
        js.Name = 'Lambda Test';
        js.JobShubetsu__c = 'AWS';
        js.LambdaURL__c = 'htpps://url';
        js.LambdaSecret__c = 'secret';
        js.LambdaParamater__c = 'paras';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(10);
        jk.RequestZumi__c = true;
        insert jk;

        JobKanriControl.registJob(String.valueOf(jk.Id));

        JobKanriControl.cancleJob(String.valueOf(jk.Id));

        jk = [select id, ShoriKekka__c from JobKanri__c where id = :jk.Id];
        system.assertEquals('取り消し', jk.ShoriKekka__c);

    }

    @isTest
    /**
     * 異常系(registJob)
     */
    static void Test05() {
        JobSettei__c js = new JobSettei__c();
        js.Name = 'jobsetteiTEST';
        js.JobShubetsu__c = 'APEX';
        js.ApexJobMei__c = '郵送申請情報出力';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(-10);
        insert jk;

        JobKanriControl.registJob(String.valueOf(jk.Id));

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(false, jk.RequestZumi__c);

        List<BatchErrorInfo__c> beiList = [Select BatchName__c, BatchClassName__c, OccurTime__c, ExceptionInfo__c, ExceptionStacktrace__c  from BatchErrorInfo__c];
        system.assertEquals(1, beiList.size());

    }

    @isTest
    /**
     * 異常系(cancleJob)
     */
    static void Test06() {
        JobSettei__c js = new JobSettei__c();
        js.Name = 'jobsetteiTEST';
        js.JobShubetsu__c = 'APEX';
        js.ApexJobMei__c = '郵送申請情報出力';

        insert js;

        JobKanri__c jk = new JobKanri__c();
        jk.JobSettei__c = js.Id;
        jk.JikkoNichiji__c = Datetime.now().addSeconds(-10);
        insert jk;

        JobKanriControl.cancleJob('01p1y000006Pxqp');

        jk = [select id, RequestZumi__c from JobKanri__c where id = :jk.Id];
        system.assertEquals(false, jk.RequestZumi__c);

        List<BatchErrorInfo__c> beiList = [Select BatchName__c, BatchClassName__c, OccurTime__c, ExceptionInfo__c, ExceptionStacktrace__c  from BatchErrorInfo__c];
        system.assertEquals(1, beiList.size());

    }

}