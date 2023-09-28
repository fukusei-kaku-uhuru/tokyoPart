public with sharing class ExTjKozaController {

    private static final String SITE_MODE = ExLwcUtil.getSiteMode();

    public class KozaWrapper {
        @AuraEnabled public final String KOUZAKUBUN_TAISHOSHA = 'taishosha';
        @AuraEnabled public final String KOUZAKUBUN_DAIRININ = 'dairinin';

        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public String UketoriKouzaKubun {get;set;}
        @AuraEnabled public Boolean TaishoshaSelectable {get;set;}
        @AuraEnabled public Boolean DairininSelectable {get;set;}
        @AuraEnabled public ExKozaFormController.KozaFormWrapper kfw {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}

        public KozaWrapper(){}

        public KozaWrapper(TaishoJido__c tj){
            Id = tj.Id;
            Shimei = tj.Shimei__c;

            if (tj.UketoriKouzaKubun_Taishosha__c) {
                UketoriKouzaKubun = KOUZAKUBUN_TAISHOSHA;
            } else if (tj.UketoriKouzaKubun_Seikyusha__c) {
                UketoriKouzaKubun = KOUZAKUBUN_DAIRININ;
            }

            TaishoshaSelectable = tj.TaishoshaKubun__r.Meigi_Taishosha__c;
            DairininSelectable = tj.TaishoshaKubun__r.Meigi_Dairinin__c;

            ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
            // 口座情報（ゆうちょ）
            if (String.isNotEmpty(tj.YuchoBango__c)) {
                kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;
                if (tj.TJ_Yucho_Shumoku01__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_SOGO;
                } else if (tj.TJ_Yucho_Shumoku02__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TSUJYO;
                } else if (tj.TJ_Yucho_Shumoku03__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TYOCHIKU;
                } else if (tj.TJ_Yucho_Shumoku04__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_FURIKAE;
                }
                kfw.YuchoKigo = tj.YuchoKigo__c;
                kfw.YuchoBango = tj.YuchoBango__c;
                kfw.YuchoKouzaMeigi = tj.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else {
                kfw.GinkoKubun = kfw.GINKOKUBUN_OTHER;
                kfw.KinyuKikan = tj.KinyuKikan__c;
                if (String.isNotBlank(tj.KinyuKikan__c)) {
                    kfw.KinyuKikanDispName = tj.KinyuKikan__r.KinyuKikanCode__c + '：' + tj.KinyuKikan__r.Name;
                }
                kfw.Shiten = tj.Shiten__c;
                if (String.isNotBlank(tj.Shiten__c)) {
                    kfw.ShitenDispName = tj.Shiten__r.TempoCode__c + '：' + tj.Shiten__r.Name;
                }
                if (tj.TJ_Shumoku01__c) {
                    kfw.Bunrui = kfw.SHUMOKU_FUTSU;
                } else if (tj.TJ_Shumoku02__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TOZA;
                } else if (tj.TJ_Shumoku03__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TYOCHIKU;
                }
                kfw.KouzaBangou = tj.KouzaBangou__c;
                kfw.KouzaMeigi = tj.KouzaMeigi__c;
            }
            this.kfw = kfw;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }

        public KozaWrapper(DV_TaishoJido__c tj){
            Id = tj.Id;
            Shimei = tj.Shimei__c;

            if (tj.UketoriKouzaKubun_Taishosha__c) {
                UketoriKouzaKubun = KOUZAKUBUN_TAISHOSHA;
            } else if (tj.UketoriKouzaKubun_Seikyusha__c) {
                UketoriKouzaKubun = KOUZAKUBUN_DAIRININ;
            }

            TaishoshaSelectable = tj.TaishoshaKubun__r.Meigi_Taishosha__c;
            DairininSelectable = tj.TaishoshaKubun__r.Meigi_Dairinin__c;

            ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
            // 口座情報（ゆうちょ）
            if (String.isNotEmpty(tj.YuchoBango__c)) {
                kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;
                if (tj.TJ_Yucho_Shumoku01__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_SOGO;
                } else if (tj.TJ_Yucho_Shumoku02__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TSUJYO;
                } else if (tj.TJ_Yucho_Shumoku03__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TYOCHIKU;
                } else if (tj.TJ_Yucho_Shumoku04__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_FURIKAE;
                }
                kfw.YuchoKigo = tj.YuchoKigo__c;
                kfw.YuchoBango = tj.YuchoBango__c;
                kfw.YuchoKouzaMeigi = tj.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else {
                kfw.GinkoKubun = kfw.GINKOKUBUN_OTHER;
                kfw.KinyuKikan = tj.KinyuKikan__c;
                if (String.isNotBlank(tj.KinyuKikan__c)) {
                    kfw.KinyuKikanDispName = tj.KinyuKikan__r.KinyuKikanCode__c + '：' + tj.KinyuKikan__r.Name;
                }
                kfw.Shiten = tj.Shiten__c;
                if (String.isNotBlank(tj.Shiten__c)) {
                    kfw.ShitenDispName = tj.Shiten__r.TempoCode__c + '：' + tj.Shiten__r.Name;
                }
                if (tj.TJ_Shumoku01__c) {
                    kfw.Bunrui = kfw.SHUMOKU_FUTSU;
                } else if (tj.TJ_Shumoku02__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TOZA;
                } else if (tj.TJ_Shumoku03__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TYOCHIKU;
                }
                kfw.KouzaBangou = tj.KouzaBangou__c;
                kfw.KouzaMeigi = tj.KouzaMeigi__c;
            }
            this.kfw = kfw;

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
     * 対象児童の口座情報を取得
     */
    @AuraEnabled
    public static KozaWrapper getKozaData(String taishoJidoId) {
        try {
            KozaWrapper kw;
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                kw = getKozaDataIppan(taishoJidoId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                kw = getKozaDataDv(taishoJidoId);
            }

            return kw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static KozaWrapper getKozaDataIppan(String taishoJidoId) {
        TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,UketoriKouzaKubun_Seikyusha__c
                ,UketoriKouzaKubun_Taishosha__c
                ,TaishoshaKubun__r.Meigi_Taishosha__c
                ,TaishoshaKubun__r.Meigi_Dairinin__c
                ,TJ_Yucho_Shumoku01__c
                ,TJ_Yucho_Shumoku02__c
                ,TJ_Yucho_Shumoku03__c
                ,TJ_Yucho_Shumoku04__c
                ,YuchoBango__c
                ,YuchoKigo__c
                ,YuchoKouzaMeigi__c
                ,KinyuKikan__c
                ,KinyuKikan__r.Name
                ,KinyuKikan__r.KinyuKikanCode__c
                ,Shiten__c
                ,Shiten__r.Name
                ,Shiten__r.TempoCode__c
                ,TJ_Shumoku01__c
                ,TJ_Shumoku02__c
                ,TJ_Shumoku03__c
                ,KouzaBangou__c
                ,KouzaMeigi__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,ShinsaKekkaSaishu__c
            FROM TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new KozaWrapper(tj);
    }

    private static KozaWrapper getKozaDataDv(String taishoJidoId) {
        DV_TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,UketoriKouzaKubun_Seikyusha__c
                ,UketoriKouzaKubun_Taishosha__c
                ,TaishoshaKubun__r.Meigi_Taishosha__c
                ,TaishoshaKubun__r.Meigi_Dairinin__c
                ,TJ_Yucho_Shumoku01__c
                ,TJ_Yucho_Shumoku02__c
                ,TJ_Yucho_Shumoku03__c
                ,TJ_Yucho_Shumoku04__c
                ,YuchoBango__c
                ,YuchoKigo__c
                ,YuchoKouzaMeigi__c
                ,KinyuKikan__c
                ,KinyuKikan__r.Name
                ,KinyuKikan__r.KinyuKikanCode__c
                ,Shiten__c
                ,Shiten__r.Name
                ,Shiten__r.TempoCode__c
                ,TJ_Shumoku01__c
                ,TJ_Shumoku02__c
                ,TJ_Shumoku03__c
                ,KouzaBangou__c
                ,KouzaMeigi__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,ShinsaKekkaSaishu__c
            FROM DV_TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new KozaWrapper(tj);
    }

    /**
     * 口座情報を更新
     */
    @AuraEnabled
    public static List<ExValidationUtil.ErrorLog> updateKozaData(KozaWrapper kw){
        try {
            List<ExValidationUtil.ErrorLog> eLogs = validation(kw);
            if (eLogs.size() > 0) {
                return eLogs;
            }

            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                updateTaishoJidoIppan(kw);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                updateTaishoJidoDv(kw);
            }

            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 入力チェック
     */
    private static List<ExValidationUtil.ErrorLog> validation(KozaWrapper kw) {
        ExValidationUtil.ErrorLogs eLogs = new ExValidationUtil.ErrorLogs();

        // 口座情報（ゆうちょ）
        if (kw.kfw.isInputYucho()) {
            if (String.isBlank(kw.kfw.YuchoKouzaMeigi)) {
                eLogs.add('YuchoKouzaMeigi'
                    ,'この項目を入力してください。'
                );
            }
        }

        // 口座情報
        if (kw.kfw.isInputOther()) {
            if (String.isBlank(kw.kfw.KouzaMeigi)) {
                eLogs.add('KouzaMeigi'
                    ,'この項目を入力してください。'
                );
            }
        }
        return eLogs.errorLogs;
    }

    /**
     * 対象児童更新
     */
    private static void updateTaishoJidoIppan(KozaWrapper kw) {

        TaishoJido__c tj = new TaishoJido__c();
        tj.Id = kw.Id;

        // 認定請求者の口座
        if (kw.UketoriKouzaKubun == kw.KOUZAKUBUN_DAIRININ) {
            tj.UketoriKouzaKubun_Seikyusha__c = true;
            tj.UketoriKouzaKubun_Taishosha__c = false;

            // 認定請求者の口座を利用する場合、口座情報を初期化する
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

        // 対象者の口座
        } else if (kw.UketoriKouzaKubun == kw.KOUZAKUBUN_TAISHOSHA) {
            tj.UketoriKouzaKubun_Seikyusha__c = false;
            tj.UketoriKouzaKubun_Taishosha__c = true;

            // 口座情報（ゆうちょ）
            if (kw.kfw.GinkoKubun == kw.kfw.GINKOKUBUN_YUCHO) {
                tj.TJ_Yucho_Shumoku01__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_SOGO;
                tj.TJ_Yucho_Shumoku02__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_TSUJYO;
                tj.TJ_Yucho_Shumoku03__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_TYOCHIKU;
                tj.TJ_Yucho_Shumoku04__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_FURIKAE;
                tj.YuchoKigo__c = kw.kfw.YuchoKigo;
                tj.YuchoBango__c = kw.kfw.YuchoBango;
                tj.YuchoKouzaMeigi__c = kw.kfw.YuchoKouzaMeigi;

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

            // 口座情報（ゆうちょ以外）
            } else if (kw.kfw.GinkoKubun == kw.kfw.GINKOKUBUN_OTHER) {
                tj.TJ_Yucho_Shumoku01__c = false;
                tj.TJ_Yucho_Shumoku02__c = false;
                tj.TJ_Yucho_Shumoku03__c = false;
                tj.TJ_Yucho_Shumoku04__c = false;
                tj.YuchoKigo__c = null;
                tj.YuchoBango__c = null;
                tj.YuchoKouzaMeigi__c = null;

                tj.KinyuKikan__c = kw.kfw.KinyuKikan;
                KinyuKikan__c kinyuKikanInfo = getKinyuKikanInfo(tj.KinyuKikan__c);
                tj.KinyuKikanCode__c = kinyuKikanInfo.KinyuKikanCode__c;
                tj.KinyuKikanMei__c = kinyuKikanInfo.Name;

                tj.Shiten__c = kw.kfw.Shiten;
                Shiten__c shitenInfo = getShitenInfo(tj.Shiten__c);
                tj.ShitenCode__c = shitenInfo.TempoCode__c;
                tj.ShitenMei__c = shitenInfo.Name;

                tj.TJ_Shumoku01__c = kw.kfw.Bunrui == kw.kfw.SHUMOKU_FUTSU;
                tj.TJ_Shumoku02__c = kw.kfw.Bunrui == kw.kfw.SHUMOKU_TOZA;
                tj.TJ_Shumoku03__c = kw.kfw.Bunrui == kw.kfw.SHUMOKU_TYOCHIKU;
                tj.KouzaBangou__c = kw.kfw.KouzaBangou;
                tj.KouzaMeigi__c = kw.kfw.KouzaMeigi;
            }
        }

        tj.KouzaJohoCheck__c = true;

        update tj;
    }

    private static void updateTaishoJidoDv(KozaWrapper kw) {

        DV_TaishoJido__c tj = new DV_TaishoJido__c();
        tj.Id = kw.Id;

        // 認定請求者の口座
        if (kw.UketoriKouzaKubun == kw.KOUZAKUBUN_DAIRININ) {
            tj.UketoriKouzaKubun_Seikyusha__c = true;
            tj.UketoriKouzaKubun_Taishosha__c = false;

            // 認定請求者の口座を利用する場合、口座情報を初期化する
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

        // 対象者の口座
        } else if (kw.UketoriKouzaKubun == kw.KOUZAKUBUN_TAISHOSHA) {
            tj.UketoriKouzaKubun_Seikyusha__c = false;
            tj.UketoriKouzaKubun_Taishosha__c = true;

            // 口座情報（ゆうちょ）
            if (kw.kfw.GinkoKubun == kw.kfw.GINKOKUBUN_YUCHO) {
                tj.TJ_Yucho_Shumoku01__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_SOGO;
                tj.TJ_Yucho_Shumoku02__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_TSUJYO;
                tj.TJ_Yucho_Shumoku03__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_TYOCHIKU;
                tj.TJ_Yucho_Shumoku04__c = kw.kfw.YuchoBunrui == kw.kfw.YUCHO_SHUMOKU_FURIKAE;
                tj.YuchoKigo__c = kw.kfw.YuchoKigo;
                tj.YuchoBango__c = kw.kfw.YuchoBango;
                tj.YuchoKouzaMeigi__c = kw.kfw.YuchoKouzaMeigi;

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

            // 口座情報（ゆうちょ以外）
            } else if (kw.kfw.GinkoKubun == kw.kfw.GINKOKUBUN_OTHER) {
                tj.TJ_Yucho_Shumoku01__c = false;
                tj.TJ_Yucho_Shumoku02__c = false;
                tj.TJ_Yucho_Shumoku03__c = false;
                tj.TJ_Yucho_Shumoku04__c = false;
                tj.YuchoKigo__c = null;
                tj.YuchoBango__c = null;
                tj.YuchoKouzaMeigi__c = null;

                tj.KinyuKikan__c = kw.kfw.KinyuKikan;
                KinyuKikan__c kinyuKikanInfo = getKinyuKikanInfo(tj.KinyuKikan__c);
                tj.KinyuKikanCode__c = kinyuKikanInfo.KinyuKikanCode__c;
                tj.KinyuKikanMei__c = kinyuKikanInfo.Name;

                tj.Shiten__c = kw.kfw.Shiten;
                Shiten__c shitenInfo = getShitenInfo(tj.Shiten__c);
                tj.ShitenCode__c = shitenInfo.TempoCode__c;
                tj.ShitenMei__c = shitenInfo.Name;

                tj.TJ_Shumoku01__c = kw.kfw.Bunrui == kw.kfw.SHUMOKU_FUTSU;
                tj.TJ_Shumoku02__c = kw.kfw.Bunrui == kw.kfw.SHUMOKU_TOZA;
                tj.TJ_Shumoku03__c = kw.kfw.Bunrui == kw.kfw.SHUMOKU_TYOCHIKU;
                tj.KouzaBangou__c = kw.kfw.KouzaBangou;
                tj.KouzaMeigi__c = kw.kfw.KouzaMeigi;
            }
        }

        tj.KouzaJohoCheck__c = true;

        update tj;
    }

    /**
     * 選択された金融機関の情報を取得する
     */
    private static KinyuKikan__c getKinyuKikanInfo(String recordId){
        return [
            SELECT
                Id
                ,Name
                ,KinyuKikanCode__c
            FROM KinyuKikan__c
            WHERE Id = :recordId
        ];
    }

    /**
     * 選択された支店の情報を取得する
     */
    private static Shiten__c getShitenInfo(String recordId){
        return [
            SELECT
                Id
                ,Name
                ,TempoCode__c
            FROM Shiten__c
            WHERE Id = :recordId
        ];
    }
}