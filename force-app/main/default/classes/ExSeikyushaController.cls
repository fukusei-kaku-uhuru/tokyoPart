public with sharing class ExSeikyushaController {

    private static String siteMode = ExLwcUtil.getSiteMode();

    private static final ShinseiShoruiTeigi__c KOZA_KAKUNIN = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];

    /**
     * データやりとり用クラス
     */
    public class SeikyushaWrapper {
        @AuraEnabled public final String MODE_IPPAN = ExLwcUtil.MODE_IPPAN;
        @AuraEnabled public final String MODE_DV = ExLwcUtil.MODE_DV;
        @AuraEnabled public final String MODE_SATOYA = ExLwcUtil.MODE_SATOYA;

        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String ShimeiFurigana {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public Date SeinenGappiDate {get;set;}
        @AuraEnabled public String YubinBangou {get;set;}
        @AuraEnabled public String Jusho {get;set;}
        @AuraEnabled public String DenwaBangou {get;set;}
        @AuraEnabled public String MailAddress {get;set;}
        @AuraEnabled public Boolean isTrustdocApproved {get;set;}
        @AuraEnabled public ExKozaFormController.KozaFormWrapper kfw {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}
        @AuraEnabled public String SiteMode {get;set;}
        @AuraEnabled public List<Map<String, String>> KozaOption {get;set;}
        @AuraEnabled public List<String> KozaShoruiList {get;set;}

        // 里親のときだけ利用
        @AuraEnabled public String ShisetsuShurui {get;set;}
        @AuraEnabled public String ShisetsuMeisho {get;set;}

        public void set(Seikyusha__c s, NinteiSeikyu__c ns) {
            Id = s.Id;
            ShimeiFurigana = s.ShimeiFurigana__c;
            Shimei = s.Shimei__c;
            SeinenGappiDate = s.SeinenGappiDate__c;
            YubinBangou = s.YubinBangou__c;
            Jusho = s.Jusho__c;
            DenwaBangou = s.DenwaBangou__c;
            MailAddress = UserInfo.getUserEmail();

            isTrustdocApproved = s.TrustdocKekka__c == 'approved';

            ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
            // 口座情報（ゆうちょ）
            if (String.isNotEmpty(s.YuchoBango__c)) {
                kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;
                if (s.Yucho_Shumoku01__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_SOGO;
                } else if (s.Yucho_Shumoku02__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TSUJYO;
                } else if (s.Yucho_Shumoku03__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TYOCHIKU;
                } else if (s.Yucho_Shumoku04__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_FURIKAE;
                }
                kfw.YuchoKigo = s.YuchoKigo__c;
                kfw.YuchoBango = s.YuchoBango__c;
                kfw.YuchoKouzaMeigi = s.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else {
                kfw.GinkoKubun = kfw.GINKOKUBUN_OTHER;
                kfw.KinyuKikan = s.KinyuKikan__c;
                if (String.isNotBlank(s.KinyuKikan__c)) {
                    kfw.KinyuKikanDispName = s.KinyuKikan__r.KinyuKikanCode__c + '：' + s.KinyuKikan__r.Name;
                }
                kfw.Shiten = s.Shiten__c;
                if (String.isNotBlank(s.Shiten__c)) {
                    kfw.ShitenDispName = s.Shiten__r.TempoCode__c + '：' + s.Shiten__r.Name;
                }
                if (s.Shumoku01__c) {
                    kfw.Bunrui = kfw.SHUMOKU_FUTSU;
                } else if (s.Shumoku02__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TOZA;
                } else if (s.Shumoku03__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TYOCHIKU;
                }
                kfw.KouzaBangou = s.KouzaBango__c;
                kfw.KouzaMeigi = s.KouzaMeigi__c;
            }
            this.kfw = kfw;

            // 審査ステータスに応じて値を変動
            if (ns.ShinsaStatus__c == '未申請'
                && s.ShinsaKekkaSaishu__c != 'OK'
                && s.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }
        }

        public void set(DV_Seikyusha__c s, DV_NinteiSeikyu__c ns) {
            Id = s.Id;
            ShimeiFurigana = s.ShimeiFurigana__c;
            Shimei = s.Shimei__c;
            SeinenGappiDate = s.SeinenGappiDate__c;
            YubinBangou = s.YubinBangou__c;
            Jusho = s.Jusho__c;
            DenwaBangou = s.DenwaBangou__c;
            MailAddress = UserInfo.getUserEmail();

            isTrustdocApproved = s.TrustdocKekka__c == 'approved';

            ExKozaFormController.KozaFormWrapper kfw = new ExKozaFormController.KozaFormWrapper();
            // 口座情報（ゆうちょ）
            if (String.isNotEmpty(s.YuchoBango__c)) {
                kfw.GinkoKubun = kfw.GINKOKUBUN_YUCHO;
                if (s.Yucho_Shumoku01__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_SOGO;
                } else if (s.Yucho_Shumoku02__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TSUJYO;
                } else if (s.Yucho_Shumoku03__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_TYOCHIKU;
                } else if (s.Yucho_Shumoku04__c) {
                    kfw.YuchoBunrui = kfw.YUCHO_SHUMOKU_FURIKAE;
                }
                kfw.YuchoKigo = s.YuchoKigo__c;
                kfw.YuchoBango = s.YuchoBango__c;
                kfw.YuchoKouzaMeigi = s.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else {
                kfw.GinkoKubun = kfw.GINKOKUBUN_OTHER;
                kfw.KinyuKikan = s.KinyuKikan__c;
                if (String.isNotBlank(s.KinyuKikan__c)) {
                    kfw.KinyuKikanDispName = s.KinyuKikan__r.KinyuKikanCode__c + '：' + s.KinyuKikan__r.Name;
                }
                kfw.Shiten = s.Shiten__c;
                if (String.isNotBlank(s.Shiten__c)) {
                    kfw.ShitenDispName = s.Shiten__r.TempoCode__c + '：' + s.Shiten__r.Name;
                }
                if (s.Shumoku01__c) {
                    kfw.Bunrui = kfw.SHUMOKU_FUTSU;
                } else if (s.Shumoku02__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TOZA;
                } else if (s.Shumoku03__c) {
                    kfw.Bunrui = kfw.SHUMOKU_TYOCHIKU;
                }
                kfw.KouzaBangou = s.KouzaBango__c;
                kfw.KouzaMeigi = s.KouzaMeigi__c;
            }
            this.kfw = kfw;

            // 審査ステータスに応じて値を変動
            if (ns.ShinsaStatus__c == '未申請'
                && s.ShinsaKekkaSaishu__c != 'OK'
                && s.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }

            // 里親のときだけ利用
            ShisetsuShurui = s.Shisetsu_Shurui__c;
            ShisetsuMeisho = s.Shisetsu_Meisho__c;
        }
    }

    /**
     * 請求者情報を取得する
     */
    @AuraEnabled
    public static SeikyushaWrapper getSeikyushaData(String id){
        try {

            SeikyushaWrapper sw = new SeikyushaWrapper();

            if (siteMode == ExLwcUtil.MODE_IPPAN) {
                sw = getSeikyushaDataIppan(id);
            } else if (siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA) {
                sw = getSeikyushaDataDv(id);
            }
            sw.SiteMode = siteMode;
            sw.KozaOption = getKozaOption();
            sw.KozaShoruiList = getKozaShoruiList(sw.Id);

            return sw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 請求者情報を取得する（一般）
     */
    private static SeikyushaWrapper getSeikyushaDataIppan(String id) {

        SeikyushaWrapper sw = new SeikyushaWrapper();

        NinteiSeikyu__c ns = getNinteiSeikyuIppan(id);

        // 請求者のデータを取得して詰め替える
        Seikyusha__c s = [
            SELECT
                Id
                ,ShimeiFurigana__c
                ,Shimei__c
                ,SeinenGappiDate__c
                ,YubinBangou__c
                ,Jusho__c
                ,DenwaBangou__c
                ,TrustdocKekka__c
                ,Yucho_Shumoku01__c
                ,Yucho_Shumoku02__c
                ,Yucho_Shumoku03__c
                ,Yucho_Shumoku04__c
                ,YuchoBango__c
                ,YuchoKigo__c
                ,YuchoKouzaMeigi__c
                ,KinyuKikan__c
                ,KinyuKikan__r.Name
                ,KinyuKikan__r.KinyuKikanCode__c
                ,Shiten__c
                ,Shiten__r.Name
                ,Shiten__r.TempoCode__c
                ,Shumoku01__c
                ,Shumoku02__c
                ,Shumoku03__c
                ,KouzaBango__c
                ,KouzaMeigi__c
                ,ShinsaKekkaSaishu__c
            FROM Seikyusha__c
            WHERE Id = :ns.Seikyusha__c
        ];

        sw.set(s, ns);

        return sw;
    }

    /**
     * 請求者情報を取得する（DV / 里親・ファミリーホーム）
     */
    private static SeikyushaWrapper getSeikyushaDataDv(String id) {

        SeikyushaWrapper sw = new SeikyushaWrapper();

        DV_NinteiSeikyu__c ns = getNinteiSeikyuDv(id);

        // 請求者のデータを取得して詰め替える
        DV_Seikyusha__c s = [
            SELECT
                Id
                ,ShimeiFurigana__c
                ,Shimei__c
                ,SeinenGappiDate__c
                ,YubinBangou__c
                ,Jusho__c
                ,DenwaBangou__c
                ,TrustdocKekka__c
                ,Yucho_Shumoku01__c
                ,Yucho_Shumoku02__c
                ,Yucho_Shumoku03__c
                ,Yucho_Shumoku04__c
                ,YuchoBango__c
                ,YuchoKigo__c
                ,YuchoKouzaMeigi__c
                ,KinyuKikan__c
                ,KinyuKikan__r.Name
                ,KinyuKikan__r.KinyuKikanCode__c
                ,Shiten__c
                ,Shiten__r.Name
                ,Shiten__r.TempoCode__c
                ,Shumoku01__c
                ,Shumoku02__c
                ,Shumoku03__c
                ,KouzaBango__c
                ,KouzaMeigi__c
                ,ShinsaKekkaSaishu__c
                // 里親のときだけ利用
                ,Shisetsu_Shurui__c
                ,Shisetsu_Meisho__c
            FROM DV_Seikyusha__c
            WHERE Id = :ns.Seikyusya__c
        ];

        sw.set(s, ns);

        return sw;
    }

    /**
     * 認定請求を取得する
     */
    private static NinteiSeikyu__c getNinteiSeikyuIppan(String ninteiSeikyuId) {
        return [select Id, Seikyusha__c, ShinsaStatus__c from NinteiSeikyu__c where Id = :ninteiSeikyuId];
    }

    /**
     * 認定請求（DV）を取得する
     */
    private static DV_NinteiSeikyu__c getNinteiSeikyuDv(String ninteiSeikyuId) {
        return [select Id, Seikyusya__c, ShinsaStatus__c from DV_NinteiSeikyu__c where Id = :ninteiSeikyuId];
    }

    private static List<Map<String, String>> getKozaOption() {
        return new List<Map<String, String>>{
            new Map<String, String>{
                    'label' => KOZA_KAKUNIN.Name
                    ,'value' => KOZA_KAKUNIN.Id
                }
            };
    }

    /**
     * 口座確認書類一覧を取得
     */
    @AuraEnabled
    public static List<String> getKozaShoruiList(String seikyushaId){
        try {

            // 請求者に紐づく口座確認書類一覧を取得
            List<ContentDocumentLink> cdlList = [
                SELECT
                    Id
                    ,ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :seikyushaId
                AND ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c = :KOZA_KAKUNIN.Id
                ORDER BY ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiName__c
            ];

            List<String> cvIdList = new List<String>();
            for (ContentDocumentLink cdl : cdlList) {
                cvIdList.add(cdl.ContentDocument.LatestPublishedVersionId);
            }

            return cvIdList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 請求者情報を更新する
     */
    @AuraEnabled
    public static List<ExValidationUtil.ErrorLog> updateSeikyusha(SeikyushaWrapper param){
        try {

            // 入力チェックを行う
            List<ExValidationUtil.ErrorLog> eLogList = validation(param);
            if (eLogList.size() != 0) {
                return eLogList;
            }

            if (siteMode == ExLwcUtil.MODE_IPPAN) {
                updateSeikyushaIppan(param);
            } else if (siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA) {
                updateSeikyushaDv(param);
            }

            // エラーがなければnullを返す
            return null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<ExValidationUtil.ErrorLog> validation(SeikyushaWrapper sw) {
        ExValidationUtil.ErrorLogs eLogs = new ExValidationUtil.ErrorLogs();

        // 氏名
        if (String.isBlank(sw.Shimei.trim())) {
            eLogs.add('Shimei'
                ,'この項目を入力してください。'
            );
        }

        // 生年月日
        if (sw.SeinenGappiDate > Date.today()) {
            eLogs.add('SeinenGappiDate'
                ,'生年月日は過去日を入力してください。'
            );
        }

        // 住所
        if (String.isBlank(sw.Jusho.trim())) {
            eLogs.add('jusho'
                ,'この項目を入力してください。'
            );
        }

        // 電話番号
        if (!Pattern.matches('^[-0-9]+$', sw.DenwaBangou.toUpperCase())) {
            eLogs.add('DenwaBangou'
                ,'電話番号の形式が不正です'
            );
        }

        final String KOZA_INPUT_ERROR = '口座情報はすべて入力してください';
        // 口座情報（ゆうちょ）
        if (sw.kfw.isInputYucho()) {
            if (String.isEmpty(sw.kfw.YuchoBunrui)) {
                eLogs.add('YuchoBunrui'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isEmpty(sw.kfw.YuchoKigo)) {
                eLogs.add('YuchoKigo'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isEmpty(sw.kfw.YuchoBango)) {
                eLogs.add('YuchoBango'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isBlank(sw.kfw.YuchoKouzaMeigi)) {
                eLogs.add('YuchoKouzaMeigi'
                    ,KOZA_INPUT_ERROR
                );
            }
        }

        // 口座情報
        if (sw.kfw.isInputOther()) {
            if (String.isEmpty(sw.kfw.KinyuKikan)) {
                eLogs.add('KinyuKikan'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isEmpty(sw.kfw.Shiten)) {
                eLogs.add('Shiten'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isEmpty(sw.kfw.Bunrui)) {
                eLogs.add('Bunrui'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isEmpty(sw.kfw.KouzaBangou)) {
                eLogs.add('KouzaBangou'
                    ,KOZA_INPUT_ERROR
                );
            }

            if (String.isBlank(sw.kfw.KouzaMeigi)) {
                eLogs.add('KouzaMeigi'
                    ,KOZA_INPUT_ERROR
                );
            }
        }


        return eLogs.errorLogs;
    }

    private static void updateSeikyushaIppan(SeikyushaWrapper param) {
        Seikyusha__c s = new Seikyusha__c(
            Id = param.Id
            ,ShimeiFurigana__c = param.ShimeiFurigana
            ,Shimei__c = param.Shimei
            ,SeinenGappiDate__c = param.SeinenGappiDate
            ,YubinBangou__c = param.YubinBangou
            ,Jusho__c = param.Jusho
            ,DenwaBangou__c = param.DenwaBangou
            ,MailAddress__c = param.MailAddress
        );

        // 口座情報（ゆうちょ）
        if (param.kfw.GinkoKubun == param.kfw.GINKOKUBUN_YUCHO) {
            s.Yucho_Shumoku01__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_SOGO;
            s.Yucho_Shumoku02__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_TSUJYO;
            s.Yucho_Shumoku03__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_TYOCHIKU;
            s.Yucho_Shumoku04__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_FURIKAE;
            s.YuchoKigo__c = param.kfw.YuchoKigo;
            s.YuchoBango__c = param.kfw.YuchoBango;
            s.YuchoKouzaMeigi__c = param.kfw.YuchoKouzaMeigi;

            s.KinyuKikan__c = null;
            s.KinyuKikanCode__c = null;
            s.Shiten__c = null;
            s.ShitenCode__c = null;

            s.Shumoku01__c = false;
            s.Shumoku02__c = false;
            s.Shumoku03__c = false;
            s.KouzaBango__c = null;
            s.KouzaMeigi__c = null;

        // 口座情報（ゆうちょ以外）
        } else if (param.kfw.GinkoKubun == param.kfw.GINKOKUBUN_OTHER) {
            s.Yucho_Shumoku01__c = false;
            s.Yucho_Shumoku02__c = false;
            s.Yucho_Shumoku03__c = false;
            s.Yucho_Shumoku04__c = false;
            s.YuchoKigo__c = null;
            s.YuchoBango__c = null;
            s.YuchoKouzaMeigi__c = null;

            KinyuKikan__c kinyuKikanInfo = getKinyuKikanInfo(param.kfw.KinyuKikan);
            s.KinyuKikan__c = kinyuKikanInfo?.Id;
            s.KinyuKikanCode__c = kinyuKikanInfo?.KinyuKikanCode__c;

            Shiten__c shitenInfo = getShitenInfo(param.kfw.Shiten);
            s.Shiten__c = shitenInfo?.Id;
            s.ShitenCode__c = shitenInfo?.TempoCode__c;

            s.Shumoku01__c = param.kfw.Bunrui == param.kfw.SHUMOKU_FUTSU;
            s.Shumoku02__c = param.kfw.Bunrui == param.kfw.SHUMOKU_TOZA;
            s.Shumoku03__c = param.kfw.Bunrui == param.kfw.SHUMOKU_TYOCHIKU;
            s.KouzaBango__c = param.kfw.KouzaBangou;
            s.KouzaMeigi__c = param.kfw.KouzaMeigi;
        }

        update s;
    }

    private static void updateSeikyushaDv(SeikyushaWrapper param) {
        DV_Seikyusha__c s = new DV_Seikyusha__c(
            Id = param.Id
            ,ShimeiFurigana__c = param.ShimeiFurigana
            ,Shimei__c = param.Shimei
            ,SeinenGappiDate__c = param.SeinenGappiDate
            ,YubinBangou__c = param.YubinBangou
            ,Jusho__c = param.Jusho
            ,DenwaBangou__c = param.DenwaBangou
            ,MailAddress__c = param.MailAddress
        );

        // 口座情報（ゆうちょ）
        if (param.kfw.GinkoKubun == param.kfw.GINKOKUBUN_YUCHO) {
            s.Yucho_Shumoku01__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_SOGO;
            s.Yucho_Shumoku02__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_TSUJYO;
            s.Yucho_Shumoku03__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_TYOCHIKU;
            s.Yucho_Shumoku04__c = param.kfw.YuchoBunrui == param.kfw.YUCHO_SHUMOKU_FURIKAE;
            s.YuchoKigo__c = param.kfw.YuchoKigo;
            s.YuchoBango__c = param.kfw.YuchoBango;
            s.YuchoKouzaMeigi__c = param.kfw.YuchoKouzaMeigi;

            s.KinyuKikan__c = null;
            s.KinyuKikanCode__c = null;
            s.Shiten__c = null;
            s.ShitenCode__c = null;

            s.Shumoku01__c = false;
            s.Shumoku02__c = false;
            s.Shumoku03__c = false;
            s.KouzaBango__c = null;
            s.KouzaMeigi__c = null;

        // 口座情報（ゆうちょ以外）
        } else if (param.kfw.GinkoKubun == param.kfw.GINKOKUBUN_OTHER) {
            s.Yucho_Shumoku01__c = false;
            s.Yucho_Shumoku02__c = false;
            s.Yucho_Shumoku03__c = false;
            s.Yucho_Shumoku04__c = false;
            s.YuchoKigo__c = null;
            s.YuchoBango__c = null;
            s.YuchoKouzaMeigi__c = null;

            KinyuKikan__c kinyuKikanInfo = getKinyuKikanInfo(param.kfw.KinyuKikan);
            s.KinyuKikan__c = kinyuKikanInfo?.Id;
            s.KinyuKikanCode__c = kinyuKikanInfo?.KinyuKikanCode__c;
            s.Kinyukikanmei__c = kinyuKikanInfo?.Name;

            Shiten__c shitenInfo = getShitenInfo(param.kfw.Shiten);
            s.Shiten__c = shitenInfo?.Id;
            s.ShitenCode__c = shitenInfo?.TempoCode__c;
            s.Shitenmei__c = shitenInfo?.Name;

            s.Shumoku01__c = param.kfw.Bunrui == param.kfw.SHUMOKU_FUTSU;
            s.Shumoku02__c = param.kfw.Bunrui == param.kfw.SHUMOKU_TOZA;
            s.Shumoku03__c = param.kfw.Bunrui == param.kfw.SHUMOKU_TYOCHIKU;
            s.KouzaBango__c = param.kfw.KouzaBangou;
            s.KouzaMeigi__c = param.kfw.KouzaMeigi;
        }

        // 里親のときだけ利用
        if (siteMode == ExLwcUtil.MODE_SATOYA) {
            s.Shisetsu_Shurui__c = param.ShisetsuShurui;
            if (s.Shisetsu_Shurui__c != '里親') {
                s.Shisetsu_Meisho__c = param.ShisetsuMeisho;
            } else {
                s.Shisetsu_Meisho__c = null;
            }
        }

        update s;
    }

    /**
     * 選択された金融機関の情報を取得する
     */
    private static KinyuKikan__c getKinyuKikanInfo(String recordId){
        List<KinyuKikan__c> kkList = [
            SELECT
                Id
                ,Name
                ,KinyuKikanCode__c
            FROM KinyuKikan__c
            WHERE Id = :recordId
        ];
        return kkList.size() > 0 ? kkList[0] : new KinyuKikan__c();
    }

    /**
     * 選択された支店の情報を取得する
     */
    private static Shiten__c getShitenInfo(String recordId){
        List<Shiten__c> stnList = [
            SELECT
                Id
                ,Name
                ,TempoCode__c
            FROM Shiten__c
            WHERE Id = :recordId
        ];
        return stnList.size() > 0 ? stnList[0] : new Shiten__c();
    }

    /**
     * 口座確認書類が提出されているかをチェックする
     */
    @AuraEnabled
    public static List<String> needUploadShinseiShorui(SeikyushaWrapper sw){
        try {
            // 口座情報を入力していない場合、エラーなしで返す
            if (!sw.kfw.isInputYucho() && !sw.kfw.isInputOther()) {
                return new List<String>();
            }

            // 対象児童に紐づく書類一覧を取得
            List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(sw.Id);

            return ExValidationUtil.needUploadShinseiShorui(cdlList, new List<ShinseiShoruiTeigi__c>{KOZA_KAKUNIN});

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}