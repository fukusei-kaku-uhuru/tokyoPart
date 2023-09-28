/**
 * 出力	受給資格取消通知書バッチ処理（OPROARTSアクション用）
 */
public class RecipientQualificationCancelNoticeBatch implements Database.Batchable<sObject>, Database.Stateful{
    // エラーメッセージ
    private String msgErr = ''; 
    private Boolean isErr = false;
    private JobKanri__c jyobKanri = new JobKanri__c();
    // 仕様名
    private static final String ACTIONNAME = '出力	受給資格取消通知書';
    // クラス名
    private static final String CLASSNAME = 'RecipientQualificationCancelNoticeBatch';
    // SPACE
    private static final String CONST_SPACE = ' ';

    public RecipientQualificationCancelNoticeBatch() {
    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query;
        System.debug('system time'+ System.now());
        System.debug('system time'+ DateTime.now());

        // ジョブ管理とジョブ設定からパラメータを取得する
        // TODO パラメータ未定
        List<JobKanri__c> jobList = [SELECT Id,JikkoNichiji__c, JobSettei__r.OproartsActionParamater__c 
                                        FROM JobKanri__c 
                                        WHERE JobSettei__r.JobShubetsu__c = 'OPROARTSアクション' 
                                        AND JobSettei__r.OproartsActionMei__c = '受給資格取消通知書'];

        // 現在時刻と上記JobListのJikkoNichiji__cの年月日時分を比較し、一致する場合バッチ処理を実行する
        Boolean isJob = false;

        for(JobKanri__c job : jobList){
            System.debug('JikkoNichiji__c'+ job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm'));
            System.debug('now'+ DateTime.now().format('yyyy/MM/dd HH:mm'));
            if(job.JikkoNichiji__c != null && job.JikkoNichiji__c.format('yyyy/MM/dd HH:mm') == DateTime.now().format('yyyy/MM/dd HH:mm')){
                isJob = true;
                jyobKanri = job;
                break;
            }
        }

        if(!isJob){
            query = 'SELECT Id FROM TaishoJido__c Limit 0 ';
        } else {
            // ジョブ管理からパラメータを取得する
            // TOD 条件未定　　jyobKanriから条件項目を取得する            

            query = 'SELECT Id ' +
                        // ',ShinsaKekkaSaiCheck__c ,' +
                        // 'Kouken_Haha_Shimei__c ,' +
                        // 'Kouken_Haha_YubinBangou__c ,' +
                        // 'Kouken_Chichi_Jusho__c ,' +
                        // 'Kouken_Chichi_Shimei__c ,' +
                        // 'Kouken_Chichi_YubinBangou__c ,' +
                        // 'Hunintei_KyakkaRiyu_Sonota__c ,' +
                        // 'BekkyoKango_SonotaRiyu__c ,' +
                        // 'SonotaShousai__c ,' +
                        // 'RikonKyougi_Jido_ShimeiFurigana__c ,' +
                        // 'YuchoBunrui__c ,' +
                        // 'YuchoBunruiOCR__c ,' +
                        // 'YuchoBango__c ,' +
                        // 'YuchoKigo__c ,' +
                        // 'HeyaBangou__c ,' +
                        // 'EscalationStatus__c ,' +
                        // 'HubiStatus__c ,' +
                        // 'BekkyoKango_SetaiNushi_ShimeiFurigana__c ,' +
                        // 'BekkyoKango_SetaiNushi_Shimei__c ,' +
                        // 'KonnendochuShinkiSochi__c ,' +
                        // 'DairininShimei__c ,' +
                        // 'IsTochuTennyuShussei__c ,' +
                        // 'IsTochuTenshutsu__c ,' +
                        // 'Jusho__c ,' +
                        // 'HuboShitei_Jusho__c ,' +
                        // 'RikonKyougi_JyuminHyo_Jusho__c ,' +
                        // 'RikonKyougi_JyuminHyo_YubinBangou__c ,' +
                        // 'CreatedById ,' +
                        // 'HokenshoMaskingZumi__c ,' +
                        // 'Biko__c ,' +
                        // 'BekkyoKango_Tsudukigara__c ,' +
                        // 'HuboShitei_Hubo_ShimeiFurigana__c ,' +
                        // 'HuboShitei_Hubo_Jusho__c ,' +
                        // 'HuboShitei_Hubo_Kankei__c ,' +
                        // 'HuboShitei_Hubo_Shimei__c ,' +
                        // 'HuboShitei_Hubo_SeinenGappiDate__c ,' +
                        // 'HuboShitei_Hubo_Shomei__c ,' +
                        // 'HuboShitei_Hubo_YubinBangou__c ,' +
                        // 'Bunrui__c ,' +
                        // 'BunruiOCR__c ,' +
                        // 'BekkyoKango_Jido_ShimeiFurigana__c ,' +
                        // 'BekkyoKango_Jido_Jusho__c ,' +
                        // 'BekkyoKango_Jido_Shimei__c ,' +
                        // 'BekkyoKango_Jido_SeinenGappiDate__c ,' +
                        // 'BekkyoKango_Jido_Tsudukigara__c ,' +
                        // 'BekkyoKango_Jido_YubinBangou__c ,' +
                        // 'BekkyoKango_BekkyoShuryoDate__c ,' +
                        // 'BekkyoKango_BekkyoKaishiDate__c ,' +
                        // 'Hunintei_KyakkaRiyu_SonotaText__c ,' +
                        // 'TorikeshiShometsu__c ,' +
                        // 'KouzaMeigi__c ,' +
                        // 'KouzaBangou__c ,' +
                        // 'ChihouKoukyouDantaiCode__c ,' +
                        // 'GaibuKey__c ,' +
                        // 'RikonKyougi_Jido_Seibetsu_Onna__c ,' +
                        // 'RikonKyougi_Kyojyu_Jusho__c ,' +
                        // 'RikonKyougi_Kyojyu_YubinBangou__c ,' +
                        // 'ShinsaKekka_00__c ,' +
                        // 'ShinsaKekkaImage_00__c ,' +
                        // 'ShinsaKekka_01__c ,' +
                        // 'ShinsaKekkaImage_01__c ,' +
                        // 'ShinsaKekka_02__c ,' +
                        // 'ShinsaKekkaImage_02__c ,' +
                        // 'ShinsaKekkaSaishu__c ,' +
                        // 'ShinsaKekkaComment_00__c ,' +
                        // 'ShinsaKekkaComment_01__c ,' +
                        // 'ShinsaKekkaComment_02__c ,' +
                        // 'Name ,' +
                        // 'TaishoshaNumber__c ,' +
                        // 'SeikyushaTsudukigara_Sonota__c ,' +
                        // 'SeikyushaTsudukigara_Haha__c ,' +
                        // 'SeikyushaTsudukigara_Chichi__c ,' +
                        // 'Hunintei_KyakkaRiyu_Nenrei__c ,' +
                        // 'Hunintei_KyakkaRiyu_Togai__c ,' +
                        // 'Ryugaku_Doukyo_Shimei_01__c ,' +
                        // 'Ryugaku_Doukyo_Shimei_02__c ,' +
                        // 'SeikyushaKubun_Dairinin__c ,' +
                        // 'UketoriKouzaKubun_Taishosha__c ,' +
                        // 'TaishoshaKubun__c ,' +
                        // 'Nintei_Shimei__c ,' +
                        // 'Hunintei_Shimei__c ,' +
                        // 'SeikyushaKubun_Taishosha__c ,' +
                        // 'Ryugaku_Kyojyuchi__c ,' +
                        // 'ShikuChoson__c ,' +
                        // 'RikonKyougi_Seibetsu__c ,' +
                        // 'ShoninKekka__c ,' +
                        // 'FurikomiId__c ,' +
                        // 'FurikomiStatus__c ,' +
                        // 'Nintei_HurikomiNengappiDate__c ,' +
                        // 'Shiten__c ,' +
                        // 'ShitenCode__c ,' +
                        // 'ShitenMei__c ,' +
                        // 'Nintei_Goukeigaku__c ,' +
                        // 'BunsyoKanriBangou__c ,' +
                        // 'LastModifiedById ,' +
                        // 'Shimei__c ,' +
                        // 'Kouken_Jido_Shimei__c ,' +
                        // 'HuboShitei_Shimei__c ,' +
                        // 'RikonKyougi_Jido_Shimei__c ,' +
                        // 'Ryugaku_Jido_Shimei__c ,' +
                        // 'ShimeiFurigana__c ,' +
                        // 'Nintei_KetteiNengappiDate__c ,' +
                        // 'Hunintei_KetteiNengappiDate__c ,' +
                        // 'Shometsu_Jiyu__c ,' +
                        // 'Shometsu_Jiyu_Sonota__c ,' +
                        // 'Shometsu_Jiyu_Detail_Sonota__c ,' +
                        // 'Shometsu_Jiyu_Detail__c ,' +
                        // 'Shometsu_Date__c ,' +
                        // 'HuboShitei_Shiteisha_ShimeiFurigana__c ,' +
                        // 'HuboShitei_Shiteisha_Jusho__c ,' +
                        // 'HuboShitei_Shiteisha_Shimei__c ,' +
                        // 'HuboShitei_Shiteisha_SeinenGappiDate__c ,' +
                        // 'HuboShitei_Shiteisha_YubinBangou__c ,' +
                        // 'HuboShitei_Shiteisha_DenwaBangou__c ,' +
                        // 'HuboShitei_DoukyoShubetsu__c ,' +
                        // 'HuboShitei_Kankei__c ,' +
                        // 'HuboShitei_BekkyoRiyu__c ,' +
                        // 'MeigiShiteiRiyu__c ,' +
                        // 'SeinenGappiDate__c ,' +
                        // 'Kouken_Jido_SeinenGappiDate__c ,' +
                        // 'HuboShitei_SeinenGappiDate__c ,' +
                        // 'RikonKyougi_Jido_SeinenGappiDate__c ,' +
                        // 'Ryugaku_Jido_SeinenGappiDate__c ,' +
                        // 'Ryugaku_SeikeiJyokyo__c ,' +
                        // 'Kouken_Jusho__c ,' +
                        // 'Ryugaku_Jusho__c ,' +
                        // 'BekkyoKango_Jusho__c ,' +
                        // 'RikonKyougi_Jusho__c ,' +
                        // 'BekkyoKango_Shimei__c ,' +
                        // 'Ryugaku_Shimei__c ,' +
                        // 'Kouken_Shimei__c ,' +
                        // 'RikonKyougi_Shimei__c ,' +
                        // 'BekkyoKango_YubinBangou__c ,' +
                        // 'Ryugaku_YubinBangou__c ,' +
                        // 'Kouken_YubinBangou__c ,' +
                        // 'RikonKyougi_YubinBangou__c ,' +
                        // 'RikonKyougi_Jido_Seibetsu_Otoko__c ,' +
                        // 'Ryugaku_GakkouMei__c ,' +
                        // 'Ryugaku_TempuShoruiCheck_01__c ,' +
                        // 'Ryugaku_Mokuteki__c ,' +
                        // 'Ryugaku_Mae_Jusho_01__c ,' +
                        // 'Ryugaku_Mae_ShuryoDate_01__c ,' +
                        // 'Ryugaku_Mae_YubinBangou_01__c ,' +
                        // 'Ryugaku_Mae_KaishiDate_01__c ,' +
                        // 'Ryugaku_Mae_Jusho_02__c ,' +
                        // 'Ryugaku_Mae_ShuryoDate_02__c ,' +
                        // 'Ryugaku_Mae_YubinBangou_02__c ,' +
                        // 'Ryugaku_Mae_KaishiDate_02__c ,' +
                        // 'Ryugaku_Mae_Jusho_03__c ,' +
                        // 'Ryugaku_Mae_ShuryoDate_03__c ,' +
                        // 'Ryugaku_Mae_YubinBangou_03__c ,' +
                        // 'Ryugaku_Mae_KaishiDate_03__c ,' +
                        // 'Ryugaku_TempuShoruiCheck_02__c ,' +
                        // 'Ryugaku_ShuryoDate__c ,' +
                        // 'Ryugaku_KaishiDate__c ,' +
                        // 'Chiban__c ,' +
                        // 'Ryugaku_KangoJyokyo__c ,' +
                        // 'BekkyoKango_SeikeiJyokyo__c ,' +
                        // 'Ryugaku_Doukyo_Tsudukigara_01__c ,' +
                        // 'Ryugaku_Doukyo_Tsudukigara_02__c ,' +
                        // 'Ryugaku_TempuShoruiCheck_03__c ,' +
                        // 'NinteiSeikyu__c ,' +
                        // 'Hunintei_KyakkaRiyu_Seikyusha__c ,' +
                        // 'SeikyushaDoukyoShubetsu_Bekkyo__c ,' +
                        // 'SeikyushaDoukyoShubetsu_Doukyo__c ,' +
                        // 'SeikyushaDoukyoShubetsu_Honnin__c ,' +
                        // 'Ryugaku_Seikyusha_Jusho__c ,' +
                        // 'UketoriKouzaKubun_Seikyusha__c ,' +
                        // 'Ryugaku_Seikyusha_Shimei__c ,' +
                        // 'Ryugaku_Seikyusha_Tsudukigara__c ,' +
                        // 'Ryugaku_Seikyusha_YubinBangou__c ,' +
                        // 'Hunintei_SeikyushaShimei__c ,' +
                        // 'NinteiTsuchiStatus__c ,' +
                        // 'ChosaStatus__c ,' +
                        // 'SeikyuBangou__c ,' +
                        // 'TennyuShusseiDate__c ,' +
                        // 'TenshutsuDate__c ,' +
                        // 'HuboShitei_YubinBangou__c ,' +
                        // 'YubinBangou__c ,' +
                        // 'KinyuKikan__c ,' +
                        // 'KinyuKikanCode__c ,' +
                        // 'KinyuKikanMei__c ,' +
                        // 'BekkyoKango_BekkyoRiyu_Shigoto__c ,' +
                        // 'BekkyoKango_BekkyoRiyu_Tsugaku__c ,' +
                        // 'BekkyoKango_BekkyoRiyu_Sonota__c ' +
                        ' FROM TaishoJido__c Limit 0';
        }
        return Database.getQueryLocator(query);
    }

    /**
     * バッチ実行
     */
    public void execute(Database.BatchableContext bc, List<SObject> scopes) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('execute RecipientQualificationCancelNoticeBatch ');
            
            for (SObject obj : scopes) {
                // 処理を実行する
            }
        } catch (Exception e) {
            Database.rollback(sp);
            isErr = true;
            msgErr += '\n' + e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
            // システム時間
            Datetime finishDate = DateTime.now();

            // 共通処理
            // バッチエラー情報
            BatchErrorInfo__c info = new BatchErrorInfo__c();
            // バッチ名
            info.BatchName__c = ACTIONNAME;
            // バッチクラス名
            info.BatchClassName__c = CLASSNAME;
            // 発生日時
            info.OccurTime__c = finishDate;
            // 例外情報
            info.ExceptionInfo__c = 'ERROR' + CONST_SPACE + ':' + CONST_SPACE + e.getMessage();
            // 例外発生箇所
            info.ExceptionStacktrace__c = e.getStackTraceString();
            insert info;
        }
    }

    /**
     * バッチ終了
     */
    public void finish(Database.BatchableContext bc) {
        if(String.isNotBlank(jyobKanri.Id)) {
            if (isErr) {
                // エラー処理、ジョブ管理を更新する
                jyobKanri.ShoriKekka__c = 'エラー';
                // エラーメッセージ
                jyobKanri.ErrorMessage__c = msgErr;
                // 処理日時
                jyobKanri.ShoriNichiji__c = DateTime.now();
                update jyobKanri;
            } else {
                // 正常終了処理、ジョブ管理を更新する
                // 処理結果
                jyobKanri.ShoriKekka__c = '成功';
                // 処理日時
                jyobKanri.ShoriNichiji__c = DateTime.now();
                update jyobKanri;
            }
        }
    }
}