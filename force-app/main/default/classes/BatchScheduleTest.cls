@IsTest
public class BatchScheduleTest {
    @IsTest
    static void Test(){
        // 0時30分に実行
        String schCPI = '0 30 0 * * ?';

        AWSIntegrationProcessingBatchSchedule awsSch = new AWSIntegrationProcessingBatchSchedule();
        String scheduleIdCPI = System.schedule('AWS連携用バッチスケジュール test', schCPI, awsSch);

        DV_PersonalAnnouncementCreatBatchSchedul DV_Sch = new DV_PersonalAnnouncementCreatBatchSchedul();
        String scheduleIdDV = System.schedule('個人向けお知らせ(DV)作成バッチスケジュール test', schCPI, DV_Sch);
    
        OutputDeterminationNoticeBatchSchedule OD_Sch = new OutputDeterminationNoticeBatchSchedule();
        String scheduleIdOD = System.schedule('出力	認定通知書バッチスケジュール test', schCPI, OD_Sch);
    
        OutputDisDeterminationBatchSchedule ODD_Sch = new OutputDisDeterminationBatchSchedule();
        String scheduleIdODD = System.schedule('出力 不認定通知書バッチスケジュール test', schCPI, ODD_Sch);
        
        PersonalAnnouncementCreatBatchSchedule P_Sch = new PersonalAnnouncementCreatBatchSchedule();
        String scheduleIdP = System.schedule('個人向けお知らせ作成バッチスケジュール test', schCPI, P_Sch);

        UserInfoSynchronizateBatchSchedule U_Sch = new UserInfoSynchronizateBatchSchedule();
        String scheduleIdU = System.schedule('ユーザ情報同期バッチスケジュール test', schCPI, U_Sch);


        List<oproarts1__OproartsAction__c> oproartsList = new List<oproarts1__OproartsAction__c>();
        oproarts1__OproartsAction__c oprObj = new oproarts1__OproartsAction__c();
        // 有効
        oprObj.oproarts1__IsActive__c = true;
        // サービス
        oprObj.oproarts1__Service__c = 'sf0234_tokyo';
        // 名前空間プレフィックス
        oprObj.oproarts1__NamespacePrefix__c = 'oproarts1';
        // OPROARTS キー
        oprObj.oproarts1__OproartsKey__c = 'TA';
        // ステータス
        oprObj.oproarts1__Status__c = 'Unprocessed';
        // タイプ
        oprObj.oproarts1__Type__c = '02_ninteitsuchisho_ikkatsu';
        // レコードID
        oprObj.oproarts1__RecordIds__c = 'dummy';
        oproartsList.add(oprObj);

        Datetime dtNow = Datetime.now();
        Datetime dtSchedule = dtNow.addMinutes(Integer.valueOf(System.Label.JobDelayExecTime));
        String cronString = dtSchedule.second() + ' ' +
            + dtSchedule.minute() + ' '
            + dtSchedule.hour() + ' '
            + dtSchedule.day() + ' '
            + dtSchedule.month() + ' '
            + '? '
            + dtSchedule.year();
        System.debug('cronString:' + cronString);
        String jobName = 'objdelay1exec ' + cronString + ' ' + oproartsList[0].Id;
        YusoShinseiOproartsInsertSchedule oproartsSchedule= new YusoShinseiOproartsInsertSchedule(oproartsList,jobName);
        String jobID = System.schedule(jobName, cronString, oproartsSchedule);
        
        YusoShinseiOutPutBatchSchedule yusoShinseiOutPutBatchSchedule = new YusoShinseiOutPutBatchSchedule();
        String scheduleIdYusoShinseiOutPutBatchSchedule = System.schedule('郵送申請バッチスケジュール test', schCPI, yusoShinseiOutPutBatchSchedule);
    
        OutputDeterminationNoticeDvBatchSchedule outputDeterminationNoticeDvBatchSchedule = new OutputDeterminationNoticeDvBatchSchedule();
        String scheduleIdOutputDeterminationNoticeDvBatchSchedule = System.schedule('出力 認定通知書(DV被害者)バッチスケジュール test', schCPI, outputDeterminationNoticeDvBatchSchedule);
   
        OutputDisDeterminationDvBatchSchedule outputDisDeterminationDvBatchSchedule = new OutputDisDeterminationDvBatchSchedule();
        String scheduleIdOutputDisDeterminationDvBatchSchedule = System.schedule('出力 不認定通知書(DV被害者)バッチスケジュール test', schCPI, outputDisDeterminationDvBatchSchedule);
    
        CycleJobBatchSchedule cycleJobBatchSchedule = new CycleJobBatchSchedule();
        String scheduleIdCycleJobBatchSchedule = System.schedule('サイクルジョブバッチスケジュール test', schCPI, cycleJobBatchSchedule);
    
        DV_CycleJobBatchSchedule dvCycleJobBatchSchedule = new DV_CycleJobBatchSchedule();
        String scheduleIdDvCycleJobBatchSchedule = System.schedule('DVサイクルジョブバッチスケジュール test', schCPI, dvCycleJobBatchSchedule);

        NinteiNoticeOutPutBatchSchedule  nnobSch = new NinteiNoticeOutPutBatchSchedule();
        String scheduleIdnnobSchedule = System.schedule('認定通知書出力バッチスケジュール test', schCPI, nnobSch);

        NinteiRejectedNoticeOutPutBatchSchedule  nrnobSch = new NinteiRejectedNoticeOutPutBatchSchedule();
        String scheduleIdnrnobSchedule = System.schedule('不認定通知書出力バッチスケジュール test', schCPI, nrnobSch);
    }
}