public with sharing class ExTjMoushitateController {

    private static final String SITE_MODE = ExLwcUtil.getSiteMode();

    public class MoushitateWrapper {
        @AuraEnabled public final String RIYU_TANSHIN = 'tanshin';
        @AuraEnabled public final String RIYU_SHINGAKU = 'shingaku';
        @AuraEnabled public final String RIYU_SONOTA = 'sonota';

        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public String SeikyushaShimei {get;set;}
        @AuraEnabled public Boolean IsKokennin {get;set;}
        @AuraEnabled public Boolean IsBekkyo {get;set;}
        @AuraEnabled public Boolean IsRyugaku {get;set;}
        @AuraEnabled public Boolean IsRikon {get;set;}
        @AuraEnabled public Boolean IsFuboSitei {get;set;}
        @AuraEnabled public Boolean IsBetsuJusho {get;set;}
        @AuraEnabled public String BekkyoRiyu {get;set;}
        @AuraEnabled public String BekkyoRiyuSonota {get;set;}
        @AuraEnabled public Date BekkyoStart {get;set;}
        @AuraEnabled public Date BekkyoEnd {get;set;}
        @AuraEnabled public String KangoJokyo {get;set;}
        @AuraEnabled public String Ryugakusaki {get;set;}
        @AuraEnabled public Date RyugakumaeKyojuStart {get;set;}
        @AuraEnabled public Date RyugakumaeKyojuEnd {get;set;}
        @AuraEnabled public String RyugakumaeKyojuYubinBango {get;set;}
        @AuraEnabled public String RyugakumaeKyojuJusho {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}

        public MoushitateWrapper(){}

        public MoushitateWrapper(TaishoJido__c tj) {
            Id = tj.Id;
            Shimei = tj.Shimei__c;
            SeikyushaShimei = tj.NinteiSeikyu__r.Seikyusha__r.Shimei__c;

            IsKokennin = tj.Moushitate_KokenninCheck__c;
            IsBekkyo = tj.Moushitate_BekkyoKango__c;
            IsRyugaku = tj.Moushitate_KaigaiRyugakuCheck__c;
            IsRikon = tj.Moushitate_RikonKyogiCheck__c;
            IsFuboSitei = tj.Moushitate_FuboSiteishaCheck__c;
            IsBetsuJusho = false;
            if (tj.Bekkyo_Tanshifunin__c) {
                BekkyoRiyu = RIYU_TANSHIN;
            } else if (tj.Bekkyo_Shingaku__c) {
                BekkyoRiyu = RIYU_SHINGAKU;
            } else if (tj.Bekkyo_Sonota__c) {
                BekkyoRiyu = RIYU_SONOTA;
                BekkyoRiyuSonota = tj.Moushitate_BekkyoRiyuSonota__c;
            }
            BekkyoStart = tj.Moushitate_BekkyoKaishiDate__c;
            BekkyoEnd = tj.Moushitate_BekkyoShuryoDate__c;
            KangoJokyo = tj.Moushitate_KangoJokyo__c;
            Ryugakusaki = tj.Moushitate_RyugakusakiMei__c;
            RyugakumaeKyojuStart = tj.Moushitate_RyugakumaeKyojuKaishiDate__c;
            RyugakumaeKyojuEnd = tj.Moushitate_RyugakumaeKyojuShuryoDate__c;
            RyugakumaeKyojuYubinBango = tj.Moushitate_RyugakumaeKyojuYubinBango__c;
            RyugakumaeKyojuJusho = tj.Moushitate_RyugakumaeJusho__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }

        public MoushitateWrapper(DV_TaishoJido__c tj) {
            Id = tj.Id;
            Shimei = tj.Shimei__c;
            SeikyushaShimei = tj.NinteiSeikyu__r.Seikyusya__r.Shimei__c;

            IsKokennin = tj.Moushitate_KokenninCheck__c;
            IsBekkyo = tj.Moushitate_BekkyoKango__c;
            IsRyugaku = tj.Moushitate_KaigaiRyugakuCheck__c;
            IsRikon = tj.Moushitate_RikonKyogiCheck__c;
            IsFuboSitei = tj.Moushitate_FuboSiteishaCheck__c;
            IsBetsuJusho = tj.Moushitate_BetsuJushoCheck__c;
            if (tj.Bekkyo_Tanshifunin__c) {
                BekkyoRiyu = RIYU_TANSHIN;
            } else if (tj.Bekkyo_Shingaku__c) {
                BekkyoRiyu = RIYU_SHINGAKU;
            } else if (tj.Bekkyo_Sonota__c) {
                BekkyoRiyu = RIYU_SONOTA;
                BekkyoRiyuSonota = tj.Moushitate_BekkyoRiyuSonota__c;
            }
            BekkyoStart = tj.Moushitate_BekkyoKaishiDate__c;
            BekkyoEnd = tj.Moushitate_BekkyoShuryoDate__c;
            KangoJokyo = tj.Moushitate_KangoJokyo__c;
            Ryugakusaki = tj.Moushitate_RyugakusakiMei__c;
            RyugakumaeKyojuStart = tj.Moushitate_RyugakumaeKyojuKaishiDate__c;
            RyugakumaeKyojuEnd = tj.Moushitate_RyugakumaeKyojuShuryoDate__c;
            RyugakumaeKyojuYubinBango = tj.Moushitate_RyugakumaeKyojuYubinBango__c;
            RyugakumaeKyojuJusho = tj.Moushitate_RyugakumaeJusho__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }
    }

    /**
     * 申立書情報を取得
     */
    @AuraEnabled
    public static MoushitateWrapper getMoushitateData(String taishoJidoId){
        try {

            MoushitateWrapper mw;
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                mw = getMoushitateDataIppan(taishoJidoId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                mw = getMoushitateDataDv(taishoJidoId);
            }

            return mw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static MoushitateWrapper getMoushitateDataIppan(String taishoJidoId) {

        TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,Moushitate_KokenninCheck__c
                ,Moushitate_BekkyoKango__c
                ,Moushitate_KaigaiRyugakuCheck__c
                ,Moushitate_RikonKyogiCheck__c
                ,Moushitate_FuboSiteishaCheck__c
                ,Bekkyo_Tanshifunin__c
                ,Bekkyo_Shingaku__c
                ,Bekkyo_Sonota__c
                ,Moushitate_BekkyoRiyuSonota__c
                ,Moushitate_BekkyoKaishiDate__c
                ,Moushitate_BekkyoShuryoDate__c
                ,Moushitate_KangoJokyo__c
                ,Moushitate_RyugakusakiMei__c
                ,Moushitate_RyugakumaeKyojuKaishiDate__c
                ,Moushitate_RyugakumaeKyojuShuryoDate__c
                ,Moushitate_RyugakumaeKyojuYubinBango__c
                ,Moushitate_RyugakumaeJusho__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,NinteiSeikyu__r.Seikyusha__r.Shimei__c
                ,ShinsaKekkaSaishu__c
            FROM TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new MoushitateWrapper(tj);
    }

    private static MoushitateWrapper getMoushitateDataDv(String taishoJidoId) {

        DV_TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,Moushitate_KokenninCheck__c
                ,Moushitate_BekkyoKango__c
                ,Moushitate_KaigaiRyugakuCheck__c
                ,Moushitate_RikonKyogiCheck__c
                ,Moushitate_FuboSiteishaCheck__c
                ,Moushitate_BetsuJushoCheck__c
                ,Bekkyo_Tanshifunin__c
                ,Bekkyo_Shingaku__c
                ,Bekkyo_Sonota__c
                ,Moushitate_BekkyoRiyuSonota__c
                ,Moushitate_BekkyoKaishiDate__c
                ,Moushitate_BekkyoShuryoDate__c
                ,Moushitate_KangoJokyo__c
                ,Moushitate_RyugakusakiMei__c
                ,Moushitate_RyugakumaeKyojuKaishiDate__c
                ,Moushitate_RyugakumaeKyojuShuryoDate__c
                ,Moushitate_RyugakumaeKyojuYubinBango__c
                ,Moushitate_RyugakumaeJusho__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,NinteiSeikyu__r.Seikyusya__r.Shimei__c
                ,ShinsaKekkaSaishu__c
            FROM DV_TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new MoushitateWrapper(tj);
    }

    /**
     * 申立書情報を更新
     */
    @AuraEnabled
    public static List<ExValidationUtil.ErrorLog> updateTaishoJido(MoushitateWrapper mw){
        try {

            List<ExValidationUtil.ErrorLog> eLogs = validation(mw);
            if (eLogs.size() > 0) {
                return eLogs;
            }

            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                updateTaishoJidoIppan(mw);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                updateTaishoJidoDv(mw);
            }

            return null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 入力チェック
     */
    private static List<ExValidationUtil.ErrorLog> validation(MoushitateWrapper mw) {

        ExValidationUtil.ErrorLogs eLogs = new ExValidationUtil.ErrorLogs();

        // 申立の種別が選択されていない
        if (!mw.IsKokennin && !mw.IsBekkyo && !mw.IsRyugaku && !mw.IsRikon && !mw.IsFuboSitei && !mw.IsBetsuJusho) {
            eLogs.add('IsKokennin'
                ,' ' // メッセージなしの赤枠表示にする
            );
            eLogs.add('IsBekkyo'
                ,' '
            );
            eLogs.add('IsRyugaku'
                ,' '
            );
            eLogs.add('IsRikon'
                ,' '
            );

            if (SITE_MODE == ExLwcUtil.MODE_DV) {
                eLogs.add('IsFuboSitei'
                    ,' '
                );
                eLogs.add('IsBetsuJusho'
                    ,'申立の種別のいずれかを選択してください'
                );
            } else {
                eLogs.add('IsFuboSitei'
                    ,'申立の種別のいずれかを選択してください'
                );
            }
        }

        if (mw.IsBekkyo || mw.IsRyugaku) {

            // 別居の理由その他
            if (mw.BekkyoRiyu == mw.RIYU_SONOTA && String.isBlank(mw.BekkyoRiyuSonota)) {
                eLogs.add('BekkyoRiyuSonota'
                    ,'この項目を入力してください。'
                );
            }

            // 別居 開始日と終了日の前後がおかしい場合
            if (mw.BekkyoStart > mw.BekkyoEnd) {
                eLogs.add('BekkyoStart'
                    ,'開始日～終了日となるようにしてください'
                );
            }

            // 対象者の監護・生計関係の状況（面会・送金の状況）
            if (String.isBlank(mw.KangoJokyo)) {
                eLogs.add('KangoJokyo'
                    ,'この項目を入力してください。'
                );
            }
        }

        if (mw.IsRyugaku) {

            // 対象者の留学先教育機関等の名称
            if (String.isBlank(mw.Ryugakusaki)) {
                eLogs.add('Ryugakusaki'
                    ,'この項目を入力してください。'
                );
            }

            // 国内居住状況期間 開始日と終了日の前後がおかしい場合
            if (mw.RyugakumaeKyojuStart > mw.RyugakumaeKyojuEnd) {
                eLogs.add('RyugakumaeKyojuStart'
                    ,'開始日～終了日となるようにしてください'
                );
            }

            // 対象者の留学前の国内居住状況期間住所
            if (String.isBlank(mw.RyugakumaeKyojuJusho)) {
                eLogs.add('jusho'
                    ,'この項目を入力してください。'
                );
            }
        }


        return eLogs.errorLogs;
    }

    private static void updateTaishoJidoIppan(MoushitateWrapper mw) {

        TaishoJido__c tj = new TaishoJido__c();
        tj.Id = mw.Id;

        // 申立の種別
        tj.Moushitate_KokenninCheck__c = mw.IsKokennin;
        tj.Moushitate_BekkyoKango__c = mw.IsBekkyo;
        tj.Moushitate_KaigaiRyugakuCheck__c = mw.IsRyugaku;
        tj.Moushitate_RikonKyogiCheck__c = mw.IsRikon;
        tj.Moushitate_FuboSiteishaCheck__c = mw.IsFuboSitei;

        // 入力情報
        if (mw.IsBekkyo || mw.IsRyugaku) {
            tj.Bekkyo_Tanshifunin__c = mw.BekkyoRiyu == mw.RIYU_TANSHIN;
            tj.Bekkyo_Shingaku__c = mw.BekkyoRiyu == mw.RIYU_SHINGAKU;
            tj.Bekkyo_Sonota__c = mw.BekkyoRiyu == mw.RIYU_SONOTA;
            tj.Moushitate_BekkyoRiyuSonota__c = tj.Bekkyo_Sonota__c ? mw.BekkyoRiyuSonota : '';

            tj.Moushitate_BekkyoKaishiDate__c = mw.BekkyoStart;
            tj.Moushitate_BekkyoShuryoDate__c = mw.BekkyoEnd;
            tj.Moushitate_KangoJokyo__c = mw.KangoJokyo;
        } else {
            tj.Bekkyo_Tanshifunin__c = false;
            tj.Bekkyo_Shingaku__c = false;
            tj.Bekkyo_Sonota__c = false;
            tj.Moushitate_BekkyoRiyuSonota__c = null;
            tj.Moushitate_BekkyoKaishiDate__c = null;
            tj.Moushitate_BekkyoShuryoDate__c = null;
            tj.Moushitate_KangoJokyo__c = null;
        }

        if (mw.IsRyugaku) {
            tj.Moushitate_RyugakusakiMei__c = mw.Ryugakusaki;
            tj.Moushitate_RyugakumaeKyojuKaishiDate__c = mw.RyugakumaeKyojuStart;
            tj.Moushitate_RyugakumaeKyojuShuryoDate__c = mw.RyugakumaeKyojuEnd;
            tj.Moushitate_RyugakumaeKyojuYubinBango__c = mw.RyugakumaeKyojuYubinBango;
            tj.Moushitate_RyugakumaeJusho__c = mw.RyugakumaeKyojuJusho;
        } else {
            tj.Moushitate_RyugakusakiMei__c = null;
            tj.Moushitate_RyugakumaeKyojuKaishiDate__c = null;
            tj.Moushitate_RyugakumaeKyojuShuryoDate__c = null;
            tj.Moushitate_RyugakumaeKyojuYubinBango__c = null;
            tj.Moushitate_RyugakumaeJusho__c = null;
        }

        tj.MoushitateCheck__c = true;

        update tj;
    }

    private static void updateTaishoJidoDv(MoushitateWrapper mw) {

        DV_TaishoJido__c tj = new DV_TaishoJido__c();
        tj.Id = mw.Id;

        // 申立の種別
        tj.Moushitate_KokenninCheck__c = mw.IsKokennin;
        tj.Moushitate_BekkyoKango__c = mw.IsBekkyo;
        tj.Moushitate_KaigaiRyugakuCheck__c = mw.IsRyugaku;
        tj.Moushitate_RikonKyogiCheck__c = mw.IsRikon;
        tj.Moushitate_FuboSiteishaCheck__c = mw.IsFuboSitei;
        tj.Moushitate_BetsuJushoCheck__c = mw.IsBetsuJusho;

        // 入力情報
        if (mw.IsBekkyo || mw.IsRyugaku) {
            tj.Bekkyo_Tanshifunin__c = mw.BekkyoRiyu == mw.RIYU_TANSHIN;
            tj.Bekkyo_Shingaku__c = mw.BekkyoRiyu == mw.RIYU_SHINGAKU;
            tj.Bekkyo_Sonota__c = mw.BekkyoRiyu == mw.RIYU_SONOTA;
            tj.Moushitate_BekkyoRiyuSonota__c = tj.Bekkyo_Sonota__c ? mw.BekkyoRiyuSonota : '';

            tj.Bekkyo_Tanshifunin__c = mw.BekkyoRiyu == mw.RIYU_TANSHIN;
            tj.Bekkyo_Shingaku__c = mw.BekkyoRiyu == mw.RIYU_SHINGAKU;
            tj.Bekkyo_Sonota__c = mw.BekkyoRiyu == mw.RIYU_SONOTA;
            tj.Moushitate_BekkyoRiyuSonota__c = tj.Bekkyo_Sonota__c ? mw.BekkyoRiyuSonota : '';
            tj.Moushitate_BekkyoKaishiDate__c = mw.BekkyoStart;
            tj.Moushitate_BekkyoShuryoDate__c = mw.BekkyoEnd;
            tj.Moushitate_KangoJokyo__c = mw.KangoJokyo;
        } else {
            tj.Bekkyo_Tanshifunin__c = false;
            tj.Bekkyo_Shingaku__c = false;
            tj.Bekkyo_Sonota__c = false;
            tj.Moushitate_BekkyoRiyuSonota__c = null;
            tj.Moushitate_BekkyoKaishiDate__c = null;
            tj.Moushitate_BekkyoShuryoDate__c = null;
            tj.Moushitate_KangoJokyo__c = null;
        }

        if (mw.IsRyugaku) {
            tj.Moushitate_RyugakusakiMei__c = mw.Ryugakusaki;
            tj.Moushitate_RyugakumaeKyojuKaishiDate__c = mw.RyugakumaeKyojuStart;
            tj.Moushitate_RyugakumaeKyojuShuryoDate__c = mw.RyugakumaeKyojuEnd;
            tj.Moushitate_RyugakumaeKyojuYubinBango__c = mw.RyugakumaeKyojuYubinBango;
            tj.Moushitate_RyugakumaeJusho__c = mw.RyugakumaeKyojuJusho;
        } else {
            tj.Moushitate_RyugakusakiMei__c = null;
            tj.Moushitate_RyugakumaeKyojuKaishiDate__c = null;
            tj.Moushitate_RyugakumaeKyojuShuryoDate__c = null;
            tj.Moushitate_RyugakumaeKyojuYubinBango__c = null;
            tj.Moushitate_RyugakumaeJusho__c = null;
        }

        tj.MoushitateCheck__c = true;

        update tj;
    }
}