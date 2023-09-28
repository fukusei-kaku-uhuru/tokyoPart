public with sharing class ExTaishoJidoNyuryokuController {
    private static final String SITE_MODE = ExLwcUtil.getSiteMode();

    public class TaishoJidoNyuryokuWrapper {
        @AuraEnabled public TaishoJidoWrapper taishoJidoData {get;set;}
        @AuraEnabled public Boolean isFukumu18 {get;set;}
    }
    @AuraEnabled
    public static TaishoJidoNyuryokuWrapper getTaishoJidoNyuryokuData(String ninteiSeikyuId, String taishoJidoId){
        try {
            TaishoJidoNyuryokuWrapper tjnw = new TaishoJidoNyuryokuWrapper();
            tjnw.taishoJidoData = getTaishoJidoData(taishoJidoId);
            tjnw.isFukumu18 = isFukumu18(ninteiSeikyuId);

            return tjnw;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * データやり取り用クラス
     */
    public class TaishoJidoWrapper {
        @AuraEnabled public final String DOUKYOSHUBETSU_DOUKYO = 'doukyo';
        @AuraEnabled public final String DOUKYOSHUBETSU_BEKKYO = 'bekkyo';
        @AuraEnabled public final String DOUKYOSHUBETSU_HONNIN = 'honnin';
        @AuraEnabled public final String TSUDUKIGARA_CHICHI = 'chichi';
        @AuraEnabled public final String TSUDUKIGARA_HAHA = 'haha';
        @AuraEnabled public final String TSUDUKIGARA_SONOTA = 'tsudukigara_sonota';
        @AuraEnabled public final String SEIKYUSHA_18UNDER = '18under';
        @AuraEnabled public final String SEIKYUSHA_TAISHOSHA = 'taishosha';
        @AuraEnabled public final String SEIKYUSHA_DAIRININ = 'dairinin';
        @AuraEnabled public final String KOKUSEKI_JAPAN = 'japan';
        @AuraEnabled public final String KOKUSEKI_OTHER = 'kokuseki_other';

        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String TaishoshaKubun {get;set;}
        @AuraEnabled public String TaishoshaKubunName {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public String ShimeiFurigana {get;set;}
        @AuraEnabled public Date SeinenGappiDate {get;set;}
        @AuraEnabled public Boolean Fukumu18 {get;set;}
        @AuraEnabled public String SeikyushaKubun {get;set;}
        @AuraEnabled public String SeikyushaDoukyoShubetsu {get;set;}
        @AuraEnabled public String YubinBangou {get;set;}
        @AuraEnabled public String Jusho {get;set;}
        @AuraEnabled public String SeikyushaTsudukigara {get;set;}
        @AuraEnabled public String SonotaShousai {get;set;}
        @AuraEnabled public Boolean IsTochuTennyuShussei {get;set;}
        @AuraEnabled public Date TennyuShusseiDate {get;set;}
        @AuraEnabled public String TennyuShusseiDateSonota {get;set;}
        @AuraEnabled public Boolean IsTochuTenshutsu {get;set;}
        @AuraEnabled public Date TenshutsuDate {get;set;}
        @AuraEnabled public String TenshutsuDateSonota {get;set;}
        @AuraEnabled public String Kokuseki {get;set;}
        @AuraEnabled public String KonnendochuShinkiSochi {get;set;}
        @AuraEnabled public String Biko {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}

        public TaishoJidoWrapper(){}

        public TaishoJidoWrapper(TaishoJido__c tj) {
            // 対象児童情報
            Id = tj.Id;
            TaishoshaKubun = tj.TaishoshaKubun__c;
            TaishoshaKubunName = tj.TaishoshaKubun__r.Name;
            Shimei = tj.Shimei__c;
            ShimeiFurigana = tj.ShimeiFurigana__c;
            SeinenGappiDate = tj.SeinenGappiDate__c;
            Fukumu18 = tj.NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c;

            // 請求者区分
            if (tj.SeikyushaKubun_Taishosha__c) {
                SeikyushaKubun = SEIKYUSHA_TAISHOSHA;
            } else if (tj.SeikyushaKubun_Dairinin__c) {
                SeikyushaKubun = SEIKYUSHA_DAIRININ;
            } else {
                SeikyushaKubun = SEIKYUSHA_18UNDER;
            }

            // 同居種別
            if (tj.SeikyushaDoukyoShubetsu_Doukyo__c) {
                SeikyushaDoukyoShubetsu = DOUKYOSHUBETSU_DOUKYO;
            } else if (tj.SeikyushaDoukyoShubetsu_Bekkyo__c) {
                SeikyushaDoukyoShubetsu = DOUKYOSHUBETSU_BEKKYO;
            } else if (tj.SeikyushaDoukyoShubetsu_Honnin__c) {
                SeikyushaDoukyoShubetsu = DOUKYOSHUBETSU_HONNIN;
            }

            // 住所
            YubinBangou = tj.YubinBangou__c;
            Jusho = tj.Jusho__c;

            // 続柄
            if (tj.SeikyushaTsudukigara_Chichi__c) {
                SeikyushaTsudukigara = TSUDUKIGARA_CHICHI;
            } else if (tj.SeikyushaTsudukigara_Haha__c) {
                SeikyushaTsudukigara = TSUDUKIGARA_HAHA;
            } else if (tj.SeikyushaTsudukigara_Sonota__c) {
                SeikyushaTsudukigara = TSUDUKIGARA_SONOTA;
            }

            // その他
            SonotaShousai = tj.SonotaShousai__c;
            IsTochuTennyuShussei = tj.IsTochuTennyuShussei__c;
            TennyuShusseiDate = tj.TennyuShusseiDate__c;
            TennyuShusseiDateSonota = tj.TennyuShusseiDateSonota__c;
            IsTochuTenshutsu = tj.IsTochuTenshutsu__c;
            TenshutsuDate = tj.TenshutsuDate__c;
            TenshutsuDateSonota = tj.TenshutsuDateSonota__c;

            if (tj.IsKokuseki_Nihon__c) {
                Kokuseki = KOKUSEKI_JAPAN;
            } else if (tj.IsKokuseki_NihonIgai__c) {
                Kokuseki = KOKUSEKI_OTHER;
            }

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }

        public TaishoJidoWrapper(DV_TaishoJido__c tj) {
            // 対象児童情報
            Id = tj.Id;
            TaishoshaKubun = tj.TaishoshaKubun__c;
            TaishoshaKubunName = tj.TaishoshaKubun__r.Name;
            Shimei = tj.Shimei__c;
            ShimeiFurigana = tj.ShimeiFurigana__c;
            SeinenGappiDate = tj.SeinenGappiDate__c;
            Fukumu18 = tj.NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c;

            // 請求者区分
            if (tj.SeikyushaKubun_Taishosha__c) {
                SeikyushaKubun = SEIKYUSHA_TAISHOSHA;
            } else if (tj.SeikyushaKubun_Dairinin__c) {
                SeikyushaKubun = SEIKYUSHA_DAIRININ;
            } else {
                SeikyushaKubun = SEIKYUSHA_18UNDER;
            }

            // 同居種別
            if (tj.SeikyushaDoukyoShubetsu_Doukyo__c) {
                SeikyushaDoukyoShubetsu = DOUKYOSHUBETSU_DOUKYO;
            } else if (tj.SeikyushaDoukyoShubetsu_Bekkyo__c) {
                SeikyushaDoukyoShubetsu = DOUKYOSHUBETSU_BEKKYO;
            } else if (tj.SeikyushaDoukyoShubetsu_Honnin__c) {
                SeikyushaDoukyoShubetsu = DOUKYOSHUBETSU_HONNIN;
            }

            // 住所
            YubinBangou = tj.YubinBangou__c;
            Jusho = tj.Jusho__c;

            // 続柄
            if (tj.SeikyushaTsudukigara_Chichi__c) {
                SeikyushaTsudukigara = TSUDUKIGARA_CHICHI;
            } else if (tj.SeikyushaTsudukigara_Haha__c) {
                SeikyushaTsudukigara = TSUDUKIGARA_HAHA;
            } else if (tj.SeikyushaTsudukigara_Sonota__c) {
                SeikyushaTsudukigara = TSUDUKIGARA_SONOTA;
            }

            // その他
            SonotaShousai = tj.SonotaShousai__c;
            IsTochuTennyuShussei = tj.IsTochuTennyuShussei__c;
            TennyuShusseiDate = tj.TennyuShusseiDate__c;
            TennyuShusseiDateSonota = tj.TennyuShusseiDateSonota__c;
            IsTochuTenshutsu = tj.IsTochuTenshutsu__c;
            TenshutsuDate = tj.TenshutsuDate__c;
            TenshutsuDateSonota = tj.TenshutsuDateSonota__c;

            if (tj.IsKokuseki_Nihon__c) {
                Kokuseki = KOKUSEKI_JAPAN;
            } else if (tj.IsKokuseki_NihonIgai__c) {
                Kokuseki = KOKUSEKI_OTHER;
            }

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }

            // DVオブジェクトにのみ存在する項目
            KonnendochuShinkiSochi = tj.TaishoShinkiSochi__c;
            Biko = tj.Shisetsu_TaishoBiko__c;
        }
    }

    /**
     * 対象児童のデータを取得
     */
    private static TaishoJidoWrapper getTaishoJidoData(String taishoJidoId){
        TaishoJidoWrapper tjw = new TaishoJidoWrapper();

        // 新規登録の場合、空で返す
        if (String.isBlank(taishoJidoId)) {
            tjw.SeikyushaKubun = tjw.SEIKYUSHA_18UNDER;

            // 里親の場合、専用の対象者区分をセット
            if (SITE_MODE == ExLWcUtil.MODE_SATOYA) {
                TaishoshaKubun__c tk = getSatoyaTaishoshaKubun();
                tjw.TaishoshaKubun = tk.Id;
                tjw.TaishoshaKubunName = tk.Name;
            }

            return tjw;
        }

        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            tjw = getTaishoJidoIppan(taishoJidoId);
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            tjw = getTaishoJidoDv(taishoJidoId);
        }

        return tjw;
    }

    private static TaishoJidoWrapper getTaishoJidoIppan(String taishoJidoId) {

        TaishoJido__c tj = [
            SELECT
                Id
                ,TaishoshaKubun__c
                ,TaishoshaKubun__r.Name
                ,Shimei__c
                ,ShimeiFurigana__c
                ,SeinenGappiDate__c
                ,NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c
                ,SeikyushaKubun_Taishosha__c
                ,SeikyushaKubun_Dairinin__c
                ,SeikyushaDoukyoShubetsu_Doukyo__c
                ,SeikyushaDoukyoShubetsu_Bekkyo__c
                ,SeikyushaDoukyoShubetsu_Honnin__c
                ,YubinBangou__c
                ,Jusho__c
                ,SeikyushaTsudukigara_Chichi__c
                ,SeikyushaTsudukigara_Haha__c
                ,SeikyushaTsudukigara_Sonota__c
                ,SonotaShousai__c
                ,IsTochuTennyuShussei__c
                ,TennyuShusseiDate__c
                ,TennyuShusseiDateSonota__c
                ,IsTochuTenshutsu__c
                ,TenshutsuDate__c
                ,TenshutsuDateSonota__c
                ,IsKokuseki_Nihon__c
                ,IsKokuseki_NihonIgai__c
                ,NinteiSeikyu__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,ShinsaKekkaSaishu__c
            FROM TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new TaishoJidoWrapper(tj);
    }

    private static TaishoJidoWrapper getTaishoJidoDv(String taishoJidoId) {

        DV_TaishoJido__c tj = [
            SELECT
                Id
                ,TaishoshaKubun__c
                ,TaishoshaKubun__r.Name
                ,Shimei__c
                ,ShimeiFurigana__c
                ,SeinenGappiDate__c
                ,NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c
                ,SeikyushaKubun_Taishosha__c
                ,SeikyushaKubun_Dairinin__c
                ,SeikyushaDoukyoShubetsu_Doukyo__c
                ,SeikyushaDoukyoShubetsu_Bekkyo__c
                ,SeikyushaDoukyoShubetsu_Honnin__c
                ,YubinBangou__c
                ,Jusho__c
                ,SeikyushaTsudukigara_Chichi__c
                ,SeikyushaTsudukigara_Haha__c
                ,SeikyushaTsudukigara_Sonota__c
                ,SonotaShousai__c
                ,IsTochuTennyuShussei__c
                ,TennyuShusseiDate__c
                ,TennyuShusseiDateSonota__c
                ,IsTochuTenshutsu__c
                ,TenshutsuDate__c
                ,TenshutsuDateSonota__c
                ,IsKokuseki_Nihon__c
                ,IsKokuseki_NihonIgai__c
                ,NinteiSeikyu__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,ShinsaKekkaSaishu__c
                ,TaishoShinkiSochi__c
                ,Shisetsu_TaishoBiko__c
            FROM DV_TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new TaishoJidoWrapper(tj);
    }

    private static Boolean isFukumu18(String ninteiSeikyuId) {

        Boolean isFukumu18 = false;
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            isFukumu18 = [SELECT SeikyushaKubun_18saiFukumu__c FROM NinteiSeikyu__c WHERE Id = :ninteiSeikyuId].SeikyushaKubun_18saiFukumu__c;
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            isFukumu18 = [SELECT SeikyushaKubun_18saiFukumu__c FROM DV_NinteiSeikyu__c WHERE Id = :ninteiSeikyuId].SeikyushaKubun_18saiFukumu__c;
        }

        return isFukumu18;
    }

    /**
     * 里親用の対象者区分を取得
     */
    private static TaishoshaKubun__c getSatoyaTaishoshaKubun() {
        return [SELECT Id, Name FROM TaishoshaKubun__c WHERE Name = 'C-1'];
    }

    /**
     * 対象者区分の給付可否を取得
     */
    @AuraEnabled
    public static Boolean isKyufuKahi(String recordId){
        try {
            if (String.isEmpty(recordId)) {
                return true;
            }
            TaishoshaKubun__c tk = [  select
                                                    Id
                                                    ,KyufuKahi__c
                                                from TaishoshaKubun__c
                                                where Id = :recordId
            ];

            return tk.KyufuKahi__c;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ResultWrapper {
        @AuraEnabled public List<ExValidationUtil.ErrorLog> errorLog {get;set;}
        @AuraEnabled public String taishoJidoId {get;set;}
    }

    /**
     * 対象児童データを登録/更新する
     */
    @AuraEnabled
    public static ResultWrapper upsertTaishoJido(String recordId, TaishoJidoWrapper tjw){

        ResultWrapper result = new ResultWrapper();

        // 各種値をチェックする
        List<ExValidationUtil.ErrorLog> errorLog = validation(recordId, tjw);
        if (errorLog.size() > 0) {
            result.errorLog = errorLog;
            return result;
        }

        // 対象児童データを登録/更新する
        String taishoJidoId = '';
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            taishoJidoId = upsertTaishoJidoIppan(recordId, tjw);
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            taishoJidoId = upsertTaishoJidoDv(recordId, tjw);
        }

        // エラーがなければ対象児童IDを返す
        result.taishoJidoId = taishoJidoId;
        return result;
    }

    private static List<ExValidationUtil.ErrorLog> validation(String recordId, TaishoJidoWrapper tjw) {

        ExValidationUtil.ErrorLogs eLogs = new ExValidationUtil.ErrorLogs();

        // 同じ認定請求に、氏名と生年月日が同一のデータがある場合エラー
        if (!duplicationCheck(recordId, tjw)) {
            eLogs.add('Shimei', '名前、生年月日が一致している対象児童が既に登録されています');
            return eLogs.errorLogs;
        }

        // 対象児童の総数が上限に達していないかチェック
        if (String.isEmpty(tjw.Id) && !ExTaishoJidoUtil.canAddTaishoJido(recordId, SITE_MODE)) {
            eLogs.add('Shimei', '対象児童の数が上限に達しています');
            return eLogs.errorLogs;
        }

        // 氏名
        if (String.isBlank(tjw.Shimei)) {
            eLogs.add('Shimei', 'この項目を入力してください。');
        }

        // 氏名(フリガナ)
        if (tjw.Kokuseki == tjw.KOKUSEKI_JAPAN && String.isBlank(tjw.ShimeiFurigana)) {
            eLogs.add('ShimeiFurigana', 'この項目を入力してください。');
        }

        // 生年月日
        if (tjw.SeinenGappiDate > Date.today()) {
            eLogs.add('SeinenGappiDate', '生年月日は過去日を入力してください。');
        }

        // 住所
        if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_BEKKYO && String.isBlank(tjw.Jusho)) {
            eLogs.add('jusho', 'この項目を入力してください。');
        }

        // その他の詳細
        if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_SONOTA && String.isBlank(tjw.SonotaShousai)) {
            eLogs.add('SonotaShousai', 'この項目を入力してください。');
        }

        return eLogs.errorLogs;
    }

    private static Boolean duplicationCheck(String recordId, TaishoJidoWrapper tjw) {

        Integer count = 0;
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            count = [
                SELECT Id
                FROM TaishoJido__c
                WHERE Shimei__c = :tjw.Shimei
                AND SeinenGappiDate__c = :tjw.SeinenGappiDate
                AND NinteiSeikyu__c = :recordId
                AND Id != :tjw.Id
            ].size();
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            count = [
                SELECT Id
                FROM DV_TaishoJido__c
                WHERE Shimei__c = :tjw.Shimei
                AND SeinenGappiDate__c = :tjw.SeinenGappiDate
                AND NinteiSeikyu__c = :recordId
                AND Id != :tjw.Id
            ].size();
        }

        return count == 0;
    }

    private static String upsertTaishoJidoIppan(String ninteiSeikyuId, TaishoJidoWrapper tjw) {
        TaishoJido__c tj = new TaishoJido__c();
        // 対象児童情報
        tj.Id = tjw.Id;
        tj.TaishoshaKubun__c = tjw.TaishoshaKubun;
        tj.Shimei__c = tjw.Shimei;
        tj.ShimeiFurigana__c = tjw.ShimeiFurigana;
        tj.SeinenGappiDate__c = tjw.SeinenGappiDate;

        // 請求者区分
        if (tjw.SeikyushaKubun == tjw.SEIKYUSHA_TAISHOSHA) {
            tj.SeikyushaKubun_Taishosha__c = true;
            tj.SeikyushaKubun_Dairinin__c = false;
        } else if (tjw.SeikyushaKubun == tjw.SEIKYUSHA_DAIRININ) {
            tj.SeikyushaKubun_Taishosha__c = false;
            tj.SeikyushaKubun_Dairinin__c = true;
        } else {
            tj.SeikyushaKubun_Taishosha__c = false;
            tj.SeikyushaKubun_Dairinin__c = false;
        }

        // 同居種別
        if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_DOUKYO) {
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = false;
            // 住所
            tj.YubinBangou__c = null;
            tj.Jusho__c = null;
        } else if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_BEKKYO) {
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = true;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = false;
            // 住所
            tj.YubinBangou__c = tjw.YubinBangou;
            tj.Jusho__c = tjw.Jusho;
        } else if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_HONNIN) {
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = true;
            // 住所
            tj.YubinBangou__c = null;
            tj.Jusho__c = null;
        }

        // 続柄
        if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_CHICHI) {
            tj.SeikyushaTsudukigara_Chichi__c = true;
            tj.SeikyushaTsudukigara_Haha__c = false;
            tj.SeikyushaTsudukigara_Sonota__c = false;
            tj.SonotaShousai__c = null;
        } else if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_HAHA) {
            tj.SeikyushaTsudukigara_Chichi__c = false;
            tj.SeikyushaTsudukigara_Haha__c = true;
            tj.SeikyushaTsudukigara_Sonota__c = false;
            tj.SonotaShousai__c = null;
        } else if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_SONOTA) {
            tj.SeikyushaTsudukigara_Chichi__c = false;
            tj.SeikyushaTsudukigara_Haha__c = false;
            tj.SeikyushaTsudukigara_Sonota__c = true;
            tj.SonotaShousai__c = tjw.SonotaShousai;
        }

        // その他
        tj.IsTochuTennyuShussei__c = (Boolean)ObjectUtil.nvl(tjw.IsTochuTennyuShussei, false);
        tj.TennyuShusseiDate__c = tj.IsTochuTennyuShussei__c ? tjw.TennyuShusseiDate : null;
        tj.TennyuShusseiDateSonota__c = tj.IsTochuTennyuShussei__c ? tjw.TennyuShusseiDateSonota : null;
        tj.IsTochuTenshutsu__c = (Boolean)ObjectUtil.nvl(tjw.IsTochuTenshutsu, false);
        tj.TenshutsuDate__c = tj.IsTochuTenshutsu__c ? tjw.TenshutsuDate : null;
        tj.TenshutsuDateSonota__c = tj.IsTochuTenshutsu__c ? tjw.TenshutsuDateSonota : null;
        if (tjw.Kokuseki == tjw.KOKUSEKI_JAPAN) {
            tj.IsKokuseki_Nihon__c = true;
            tj.IsKokuseki_NihonIgai__c = false;
        } else if (tjw.Kokuseki == tjw.KOKUSEKI_OTHER) {
            tj.IsKokuseki_Nihon__c = false;
            tj.IsKokuseki_NihonIgai__c = true;
        }

        tj.TaishoshaJohoCheck__c = true;

        if (String.isEmpty(tj.Id)) {
            tj.NinteiSeikyu__c = ninteiSeikyuId;
            insert tj;
        } else {
            tj = clearMoushitateIppan(tj);
            tj = clearKozaDataIppan(tj);
            update tj;
        }

        return tj.Id;
    }

    private static String upsertTaishoJidoDv(String ninteiSeikyuId, TaishoJidoWrapper tjw) {
        DV_TaishoJido__c tj = new DV_TaishoJido__c();
        // 対象児童情報
        tj.Id = tjw.Id;
        tj.TaishoshaKubun__c = tjw.TaishoshaKubun;
        tj.Shimei__c = tjw.Shimei;
        tj.ShimeiFurigana__c = tjw.ShimeiFurigana;
        tj.SeinenGappiDate__c = tjw.SeinenGappiDate;

        // 請求者区分
        if (tjw.SeikyushaKubun == tjw.SEIKYUSHA_TAISHOSHA) {
            tj.SeikyushaKubun_Taishosha__c = true;
            tj.SeikyushaKubun_Dairinin__c = false;
        } else if (tjw.SeikyushaKubun == tjw.SEIKYUSHA_DAIRININ) {
            tj.SeikyushaKubun_Taishosha__c = false;
            tj.SeikyushaKubun_Dairinin__c = true;
        } else {
            tj.SeikyushaKubun_Taishosha__c = false;
            tj.SeikyushaKubun_Dairinin__c = false;
        }

        // 同居種別
        if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_DOUKYO) {
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = true;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = false;
            // 住所
            tj.YubinBangou__c = null;
            tj.Jusho__c = null;
        } else if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_BEKKYO) {
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = true;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = false;
            // 住所
            tj.YubinBangou__c = tjw.YubinBangou;
            tj.Jusho__c = tjw.Jusho;
        } else if (tjw.SeikyushaDoukyoShubetsu == tjw.DOUKYOSHUBETSU_HONNIN) {
            tj.SeikyushaDoukyoShubetsu_Doukyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Bekkyo__c = false;
            tj.SeikyushaDoukyoShubetsu_Honnin__c = true;
            // 住所
            tj.YubinBangou__c = null;
            tj.Jusho__c = null;
        }

        // 続柄
        if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_CHICHI) {
            tj.SeikyushaTsudukigara_Chichi__c = true;
            tj.SeikyushaTsudukigara_Haha__c = false;
            tj.SeikyushaTsudukigara_Sonota__c = false;
            tj.SonotaShousai__c = null;
        } else if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_HAHA) {
            tj.SeikyushaTsudukigara_Chichi__c = false;
            tj.SeikyushaTsudukigara_Haha__c = true;
            tj.SeikyushaTsudukigara_Sonota__c = false;
            tj.SonotaShousai__c = null;
        } else if (tjw.SeikyushaTsudukigara == tjw.TSUDUKIGARA_SONOTA) {
            tj.SeikyushaTsudukigara_Chichi__c = false;
            tj.SeikyushaTsudukigara_Haha__c = false;
            tj.SeikyushaTsudukigara_Sonota__c = true;
            tj.SonotaShousai__c = tjw.SonotaShousai;
        }

        // その他
        tj.IsTochuTennyuShussei__c = (Boolean)ObjectUtil.nvl(tjw.IsTochuTennyuShussei, false);
        tj.TennyuShusseiDate__c = tj.IsTochuTennyuShussei__c ? tjw.TennyuShusseiDate : null;
        tj.TennyuShusseiDateSonota__c = tj.IsTochuTennyuShussei__c ? tjw.TennyuShusseiDateSonota : null;
        tj.IsTochuTenshutsu__c = (Boolean)ObjectUtil.nvl(tjw.IsTochuTenshutsu, false);
        tj.TenshutsuDate__c = tj.IsTochuTenshutsu__c ? tjw.TenshutsuDate : null;
        tj.TenshutsuDateSonota__c = tj.IsTochuTenshutsu__c ? tjw.TenshutsuDateSonota : null;
        if (tjw.Kokuseki == tjw.KOKUSEKI_JAPAN) {
            tj.IsKokuseki_Nihon__c = true;
            tj.IsKokuseki_NihonIgai__c = false;
        } else if (tjw.Kokuseki == tjw.KOKUSEKI_OTHER) {
            tj.IsKokuseki_Nihon__c = false;
            tj.IsKokuseki_NihonIgai__c = true;
        }

        // 里親のときだけ登録する項目
        if (SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            tj.TaishoShinkiSochi__c = tjw.KonnendochuShinkiSochi;
            tj.Shisetsu_TaishoBiko__c = tjw.Biko;
        }
        tj.TaishoshaJohoCheck__c = true;

        if (String.isEmpty(tj.Id)) {
            tj.NinteiSeikyu__c = ninteiSeikyuId;
            tj.RecordTypeId = ExLwcUtil.getTaishoJidoRecordTypeId();
            insert tj;
        } else {
            tj = clearMoushitateDv(tj);
            tj = clearKozaDataDv(tj);
            update tj;
        }

        return tj.Id;
    }

    /**
     * 申立不要の対象者区分であれば、クリアする
     * 紐づくファイルの削除も行う
     */
    private static TaishoJido__c clearMoushitateIppan(TaishoJido__c tj) {

        // 要申立の対象者区分が設定されていれば、クリアせず処理終了
        TaishoshaKubun__c tk = [SELECT IsMoushitate__c FROM TaishoshaKubun__c WHERE Id = :tj.TaishoshaKubun__c];
        if (tk.IsMoushitate__c) {
            return tj;
        }

        // 申立の種別
        tj.Moushitate_KokenninCheck__c = false;
        tj.Moushitate_BekkyoKango__c = false;
        tj.Moushitate_KaigaiRyugakuCheck__c = false;
        tj.Moushitate_RikonKyogiCheck__c = false;
        tj.Moushitate_FuboSiteishaCheck__c = false;

        // 入力情報
        tj.Bekkyo_Tanshifunin__c = false;
        tj.Bekkyo_Shingaku__c = false;
        tj.Bekkyo_Sonota__c = false;
        tj.Moushitate_BekkyoRiyuSonota__c = null;
        tj.Moushitate_BekkyoKaishiDate__c = null;
        tj.Moushitate_BekkyoShuryoDate__c = null;
        tj.Moushitate_KangoJokyo__c = null;
        tj.Moushitate_RyugakusakiMei__c = null;
        tj.Moushitate_RyugakumaeKyojuKaishiDate__c = null;
        tj.Moushitate_RyugakumaeKyojuShuryoDate__c = null;
        tj.Moushitate_RyugakumaeKyojuYubinBango__c = null;
        tj.Moushitate_RyugakumaeJusho__c = null;

        tj.MoushitateCheck__c = false;

        // 申立書類の削除
        clearMoushiteFile(tj.Id);

        return tj;
    }

    /**
     * 申立不要の対象者区分であれば、クリアする
     * 紐づくファイルの削除も行う
     */
    private static DV_TaishoJido__c clearMoushitateDv(DV_TaishoJido__c tj) {

        // 要申立の対象者区分が設定されていれば、クリアせず処理終了
        TaishoshaKubun__c tk = [SELECT IsMoushitate__c FROM TaishoshaKubun__c WHERE Id = :tj.TaishoshaKubun__c];
        if (tk.IsMoushitate__c) {
            return tj;
        }

        // 申立の種別
        tj.Moushitate_KokenninCheck__c = false;
        tj.Moushitate_BekkyoKango__c = false;
        tj.Moushitate_KaigaiRyugakuCheck__c = false;
        tj.Moushitate_RikonKyogiCheck__c = false;
        tj.Moushitate_FuboSiteishaCheck__c = false;

        // 入力情報
        tj.Bekkyo_Tanshifunin__c = false;
        tj.Bekkyo_Shingaku__c = false;
        tj.Bekkyo_Sonota__c = false;
        tj.Moushitate_BekkyoRiyuSonota__c = null;
        tj.Moushitate_BekkyoKaishiDate__c = null;
        tj.Moushitate_BekkyoShuryoDate__c = null;
        tj.Moushitate_KangoJokyo__c = null;
        tj.Moushitate_RyugakusakiMei__c = null;
        tj.Moushitate_RyugakumaeKyojuKaishiDate__c = null;
        tj.Moushitate_RyugakumaeKyojuShuryoDate__c = null;
        tj.Moushitate_RyugakumaeKyojuYubinBango__c = null;
        tj.Moushitate_RyugakumaeJusho__c = null;

        tj.MoushitateCheck__c = false;

        // 申立書類の削除
        clearMoushiteFile(tj.Id);

        return tj;
    }

    /**
     * 紐づく申立用の書類を削除する
     */
    private static void clearMoushiteFile(Id taishoJidoId) {

        // 申立書用書類の一覧を取得
        List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getListByMoushitatesho();
        // Idを、String型のSetで抽出
        Set<String> sstIdSet = new Set<String>();
        for (ShinseiShoruiTeigi__c sst : sstList) {
            sstIdSet.add(sst.Id);
        }

        // 紐づくファイルを取得
        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :taishoJidoId
            AND ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c in :sstIdSet
        ];

        List<ContentDocument> cdList = new List<ContentDocument>();
        for (ContentDocumentLink cdl : cdlList) {
            cdList.add(new ContentDocument(Id = cdl.ContentDocumentId));
        }

        delete cdList;
    }

    /**
     * 対象者区分が変更されている場合、口座関連の情報を全てクリアする
     * 添付ファイルも削除する
     */
    private static TaishoJido__c clearKozaDataIppan(TaishoJido__c tj) {

        // 対象者区分が変更されていなければ、処理を終了する
        TaishoJido__c oldTj = [SELECT Id, TaishoshaKubun__c FROM TaishoJido__c WHERE Id = :tj.Id];
        if (tj.TaishoshaKubun__c == oldTj.TaishoshaKubun__c) {
            return tj;
        }

        tj.UketoriKouzaKubun_Seikyusha__c = false;
        tj.UketoriKouzaKubun_Taishosha__c = false;

        tj.TJ_Yucho_Shumoku01__c = false;
        tj.TJ_Yucho_Shumoku02__c = false;
        tj.TJ_Yucho_Shumoku03__c = false;
        tj.TJ_Yucho_Shumoku04__c = false;
        tj.YuchoKigo__c = null;
        tj.YuchoBango__c = null;
        tj.YuchoKouzaMeigi__c = null;

        tj.KinyuKikan__c = null;
        tj.KinyuKikanMei__c = null;
        tj.KinyuKikanCode__c = null;
        tj.Shiten__c = null;
        tj.ShitenCode__c = null;
        tj.ShitenMei__c = null;

        tj.TJ_Shumoku01__c = false;
        tj.TJ_Shumoku02__c = false;
        tj.TJ_Shumoku03__c = false;
        tj.KouzaBangou__c = null;
        tj.KouzaMeigi__c = null;

        tj.KouzaJohoCheck__c = false;

        // 口座確認書類の削除
        clearKozaFile(tj.Id);

        return tj;
    }

    /**
     * 対象者区分が変更されている場合、口座関連の情報を全てクリアする
     * 添付ファイルも削除する
     */
    private static DV_TaishoJido__c clearKozaDataDv(DV_TaishoJido__c tj) {

        // 対象者区分が変更されていなければ、処理を終了する
        DV_TaishoJido__c oldTj = [SELECT Id, TaishoshaKubun__c FROM DV_TaishoJido__c WHERE Id = :tj.Id];
        if (tj.TaishoshaKubun__c == oldTj.TaishoshaKubun__c) {
            return tj;
        }

        tj.UketoriKouzaKubun_Seikyusha__c = false;
        tj.UketoriKouzaKubun_Taishosha__c = false;

        tj.TJ_Yucho_Shumoku01__c = false;
        tj.TJ_Yucho_Shumoku02__c = false;
        tj.TJ_Yucho_Shumoku03__c = false;
        tj.TJ_Yucho_Shumoku04__c = false;
        tj.YuchoKigo__c = null;
        tj.YuchoBango__c = null;
        tj.YuchoKouzaMeigi__c = null;

        tj.KinyuKikan__c = null;
        tj.KinyuKikanMei__c = null;
        tj.KinyuKikanCode__c = null;
        tj.Shiten__c = null;
        tj.ShitenCode__c = null;
        tj.ShitenMei__c = null;

        tj.TJ_Shumoku01__c = false;
        tj.TJ_Shumoku02__c = false;
        tj.TJ_Shumoku03__c = false;
        tj.KouzaBangou__c = null;
        tj.KouzaMeigi__c = null;

        tj.KouzaJohoCheck__c = false;

        // 口座確認書類の削除
        clearKozaFile(tj.Id);

        return tj;
    }

    /**
     * 紐づく口座確認用書類を削除する
     */
    private static void clearKozaFile(Id taishoJidoId) {

        ShinseiShoruiTeigi__c sstKoza = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];

        // 紐づくファイルを取得
        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :taishoJidoId
            AND ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c = :sstKoza.Id
        ];

        List<ContentDocument> cdList = new List<ContentDocument>();
        for (ContentDocumentLink cdl : cdlList) {
            cdList.add(new ContentDocument(Id = cdl.ContentDocumentId));
        }

        delete cdList;
    }
}