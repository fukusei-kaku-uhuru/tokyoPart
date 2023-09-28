public with sharing class ExSaisyuKakuninController {
    private static final String SITE_MODE = ExLwcUtil.getSiteMode();

    public class NinteiSeikyuWrapper {
        @AuraEnabled public Boolean fukumu18 {get;set;}
        @AuraEnabled public String HonninKakuninHoho {get;set;}
        @AuraEnabled public List<String> fileList {get;set;}
        @AuraEnabled public String getFukumu18Text() {
            return fukumu18 ? '含む' : '含まない';
        }
    }
    /**
     * 本人確認情報を取得する
     */
    @AuraEnabled
    public static NinteiSeikyuWrapper getNinteiSeikyuData(String recordId) {
        NinteiSeikyuWrapper nsw = new NinteiSeikyuWrapper();

        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            NinteiSeikyu__c ns = [
                SELECT
                    Id
                    ,SeikyushaKubun_18saiFukumu__c
                    ,Seikyusha__r.HonninKakuninHoho__c
                FROM NinteiSeikyu__c
                WHERE Id = :recordId
            ];
            nsw.fukumu18 = ns.SeikyushaKubun_18saiFukumu__c;
            nsw.HonninKakuninHoho = ns.Seikyusha__r.HonninKakuninHoho__c;
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            DV_NinteiSeikyu__c ns = [
                SELECT
                    Id
                    ,SeikyushaKubun_18saiFukumu__c
                    ,Seikyusya__r.HonninKakuninHoho__c
                FROM DV_NinteiSeikyu__c
                WHERE Id = :recordId
            ];
            nsw.fukumu18 = ns.SeikyushaKubun_18saiFukumu__c;
            nsw.HonninKakuninHoho = ns.Seikyusya__r.HonninKakuninHoho__c;
        }

        // 公的個人認証だった場合は、ここで返す
        if (nsw.HonninKakuninHoho == '公的個人認証') {
            return nsw;
        }

        // 提出された本人確認書類を取得
        List<ContentDocumentLink> cdlList = [
            SELECT
                Id
                ,ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            AND ContentDocument.LatestPublishedVersion.Yoto__c = '本人確認'
        ];
        List<String> cvList = new List<String>();
        for (ContentDocumentLink cdl : cdlList) {
            cvList.add(cdl.ContentDocument.LatestPublishedVersionId);
        }
        nsw.fileList = cvList;

        return nsw;
    }

    public class SeikyushaWrapper {
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String ShimeiFurigana {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public Date SeinenGappiDate {get;set;}
        @AuraEnabled public String YubinBangou {get;set;}
        @AuraEnabled public String Jusho {get;set;}
        @AuraEnabled public String DenwaBangou {get;set;}
        @AuraEnabled public String MailAddress {get;set;}
        @AuraEnabled public Boolean IsKozaFilled {get;set;}
        @AuraEnabled public Boolean IsYucho {get;set;}
        @AuraEnabled public String YuchoBunrui {get;set;}
        @AuraEnabled public String YuchoKigo {get;set;}
        @AuraEnabled public String YuchoBango {get;set;}
        @AuraEnabled public String YuchoKouzaMeigi {get;set;}
        @AuraEnabled public String KinyuKikan {get;set;}
        @AuraEnabled public String KinyuKikanCode {get;set;}
        @AuraEnabled public String Shiten {get;set;}
        @AuraEnabled public String ShitenCode {get;set;}
        @AuraEnabled public String Bunrui {get;set;}
        @AuraEnabled public String KouzaBangou {get;set;}
        @AuraEnabled public String KouzaMeigi {get;set;}
        @AuraEnabled public List<String> KozaShoruiList {get;set;}
        
        // 里親のときだけ利用
        @AuraEnabled public String ShisetsuShurui {get;set;}
        @AuraEnabled public String ShisetsuMeisho {get;set;}

        public void set(Seikyusha__c s) {
            Id = s.Id;
            ShimeiFurigana = s.ShimeiFurigana__c;
            Shimei = s.Shimei__c;
            SeinenGappiDate = s.SeinenGappiDate__c;
            YubinBangou = s.YubinBangou__c;
            Jusho = s.Jusho__c;
            DenwaBangou = s.DenwaBangou__c;
            MailAddress = s.MailAddress__c;

            if (String.isNotEmpty(s.YuchoBango__c)) {
                IsKozaFilled = true;
                IsYucho = true;
                if (s.Yucho_Shumoku01__c) {
                    YuchoBunrui = '総合口座';
                } else if (s.Yucho_Shumoku02__c) {
                    YuchoBunrui = '通常貯金';
                } else if (s.Yucho_Shumoku03__c) {
                    YuchoBunrui = '通常貯蓄貯金';
                } else if (s.Yucho_Shumoku04__c) {
                    YuchoBunrui = '振替口座';
                }
                YuchoKigo = s.YuchoKigo__c;
                YuchoBango = s.YuchoBango__c;
                YuchoKouzaMeigi = s.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else if (String.isNotEmpty(s.KouzaBango__c)) {
                IsKozaFilled = true;
                IsYucho = false;
                if (String.isNotBlank(s.KinyuKikan__c)) {
                    KinyuKikan = s.KinyuKikan__r.Name;
                    KinyuKikanCode = s.KinyuKikan__r.KinyuKikanCode__c;
                }
                if (String.isNotBlank(s.Shiten__c)) {
                    Shiten = s.Shiten__r.Name;
                    ShitenCode = s.Shiten__r.TempoCode__c;
                }
                if (s.Shumoku01__c) {
                    Bunrui = '普通';
                } else if (s.Shumoku02__c) {
                    Bunrui = '当座';
                } else if (s.Shumoku03__c) {
                    Bunrui = '貯蓄';
                }
                KouzaBangou = s.KouzaBango__c;
                KouzaMeigi = s.KouzaMeigi__c;
            }
        }

        public void set(DV_Seikyusha__c s) {
            Id = s.Id;
            ShimeiFurigana = s.ShimeiFurigana__c;
            Shimei = s.Shimei__c;
            SeinenGappiDate = s.SeinenGappiDate__c;
            YubinBangou = s.YubinBangou__c;
            Jusho = s.Jusho__c;
            DenwaBangou = s.DenwaBangou__c;
            MailAddress = s.MailAddress__c;

            if (String.isNotEmpty(s.YuchoBango__c)) {
                IsKozaFilled = true;
                IsYucho = true;
                if (s.Yucho_Shumoku01__c) {
                    YuchoBunrui = '総合口座';
                } else if (s.Yucho_Shumoku02__c) {
                    YuchoBunrui = '通常貯金';
                } else if (s.Yucho_Shumoku03__c) {
                    YuchoBunrui = '通常貯蓄貯金';
                } else if (s.Yucho_Shumoku04__c) {
                    YuchoBunrui = '振替口座';
                }
                YuchoKigo = s.YuchoKigo__c;
                YuchoBango = s.YuchoBango__c;
                YuchoKouzaMeigi = s.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else if (String.isNotEmpty(s.KouzaBango__c)) {
                IsKozaFilled = true;
                IsYucho = false;
                if (String.isNotBlank(s.KinyuKikan__c)) {
                    KinyuKikan = s.KinyuKikan__r.Name;
                    KinyuKikanCode = s.KinyuKikan__r.KinyuKikanCode__c;
                }
                if (String.isNotBlank(s.Shiten__c)) {
                    Shiten = s.Shiten__r.Name;
                    ShitenCode = s.Shiten__r.TempoCode__c;
                }
                if (s.Shumoku01__c) {
                    Bunrui = '普通';
                } else if (s.Shumoku02__c) {
                    Bunrui = '当座';
                } else if (s.Shumoku03__c) {
                    Bunrui = '貯蓄';
                }
                KouzaBangou = s.KouzaBango__c;
                KouzaMeigi = s.KouzaMeigi__c;
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
    public static SeikyushaWrapper getSeikyushaData(String recordId){
        try {
            SeikyushaWrapper sw = new SeikyushaWrapper();

            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                sw = getSeikyushaDataIppan(recordId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                sw = getSeikyushaDataDv(recordId);
            }
            sw.KozaShoruiList = getKozaShoruiList(sw.Id);

            return sw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static SeikyushaWrapper getSeikyushaDataIppan(String recordId) {
        SeikyushaWrapper sw = new SeikyushaWrapper();

        NinteiSeikyu__c ns = [select Id, Seikyusha__c from NinteiSeikyu__c where Id = :recordId];

        // 請求者のデータを取得して詰め替える
        Seikyusha__c s = [select
                            Id
                            ,ShimeiFurigana__c
                            ,Shimei__c
                            ,SeinenGappiDate__c
                            ,YubinBangou__c
                            ,Jusho__c
                            ,DenwaBangou__c
                            ,MailAddress__c
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
                        from Seikyusha__c
                        where Id = :ns.Seikyusha__c
        ];

        sw.set(s);
        return sw;
    }

    private static SeikyushaWrapper getSeikyushaDataDv(String recordId) {
        SeikyushaWrapper sw = new SeikyushaWrapper();

        DV_NinteiSeikyu__c ns = [select Id, Seikyusya__c from DV_NinteiSeikyu__c where Id = :recordId];

        // 請求者のデータを取得して詰め替える
        DV_Seikyusha__c s = [select
                            Id
                            ,ShimeiFurigana__c
                            ,Shimei__c
                            ,SeinenGappiDate__c
                            ,YubinBangou__c
                            ,Jusho__c
                            ,DenwaBangou__c
                            ,MailAddress__c
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
                            // 里親のときだけ利用
                            ,Shisetsu_Shurui__c
                            ,Shisetsu_Meisho__c
                        from DV_Seikyusha__c
                        where Id = :ns.Seikyusya__c
        ];

        sw.set(s);
        return sw;
    }

    /**
     * 口座確認書類一覧を取得
     */
    private static List<String> getKozaShoruiList(String seikyushaId){
        try {

            ShinseiShoruiTeigi__c kozaKakunin = ExShinseiShoruiTeigiUtil.getKozaKakunin()[0];

            // 請求者に紐づく口座確認書類一覧を取得
            List<ContentDocumentLink> cdlList = [
                SELECT
                    Id
                    ,ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :seikyushaId
                AND ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c = :kozaKakunin.Id
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

    public class TaishoJidoWrapper {
        @AuraEnabled public String Id {get;set;}
        // 対象者入力
        @AuraEnabled public String TaishoshaKubun {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public String ShimeiFurigana {get;set;}
        @AuraEnabled public Date SeinenGappiDate {get;set;}
        @AuraEnabled public Boolean Fukumu18 {get;set;}
        @AuraEnabled public String SeikyushaKubun {get;set;}
        @AuraEnabled public String SeikyushaDoukyoShubetsu {get;set;}
        @AuraEnabled public Boolean IsBekkyo {get;set;}
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
        @AuraEnabled public Boolean getIsNotSeikyushaDoukyoShubetsuHonnin() {
            return SeikyushaDoukyoShubetsu != System.label.EX_TJD_DoukyoShubetsu_Honnin;
        }
        @AuraEnabled public Boolean getIsTsudukigaraSonota() {
            return SeikyushaTsudukigara == System.label.EX_TJD_Tsudukigara_Sonota;
        }

        // 申立書
        @AuraEnabled public Boolean IsMoushitate {get;set;}
        @AuraEnabled public Boolean IsKokennin {get;set;}
        @AuraEnabled public Boolean IsBekkyoKango {get;set;}
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
        @AuraEnabled public Boolean getIsBekkyoOrRyugaku() {
            return IsBekkyoKango || IsRyugaku;
        }
        @AuraEnabled public Boolean getIsBekkyoRiyuSonota() {
            return BekkyoRiyu == 'その他';
        }

        // 口座情報
        @AuraEnabled public String UketoriKouzaKubun {get;set;}
        @AuraEnabled public Boolean IsSelectedTaishosha {get;set;}
        @AuraEnabled public Boolean IsYucho {get;set;}
        @AuraEnabled public String YuchoBunrui {get;set;}
        @AuraEnabled public String YuchoKigo {get;set;}
        @AuraEnabled public String YuchoBango {get;set;}
        @AuraEnabled public String YuchoKouzaMeigi {get;set;}
        @AuraEnabled public String KinyuKikan {get;set;}
        @AuraEnabled public String KinyuKikanCode {get;set;}
        @AuraEnabled public String Shiten {get;set;}
        @AuraEnabled public String ShitenCode {get;set;}
        @AuraEnabled public String Bunrui {get;set;}
        @AuraEnabled public String KouzaBangou {get;set;}
        @AuraEnabled public String KouzaMeigi {get;set;}

        // ファイル一覧
        @AuraEnabled public List<String> TaishoJidoFileList {get;set;}

        public void set(TaishoJido__c tj) {

            // 対象児童情報
            Id = tj.Id;
            TaishoshaKubun = tj.TaishoshaKubun__r.Name;
            Shimei = tj.Shimei__c;
            ShimeiFurigana = tj.ShimeiFurigana__c;
            SeinenGappiDate = tj.SeinenGappiDate__c;
            Fukumu18 = tj.NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c;

            // 請求者区分
            if (tj.SeikyushaKubun_Taishosha__c) {
                SeikyushaKubun = '対象者自身が認定請求を行う';
            } else if (tj.SeikyushaKubun_Dairinin__c) {
                SeikyushaKubun = '対象者の代理人が認定請求を行う';
            } else {
                SeikyushaKubun = '対象者が18歳未満';
            }

            // 同居種別
            if (tj.SeikyushaDoukyoShubetsu_Doukyo__c) {
                SeikyushaDoukyoShubetsu = System.label.EX_TJD_DoukyoShubetsu_Doukyo;
                IsBekkyo = false;
            } else if (tj.SeikyushaDoukyoShubetsu_Bekkyo__c) {
                SeikyushaDoukyoShubetsu = System.label.EX_TJD_DoukyoShubetsu_Bekkyo;
                IsBekkyo = true;
                YubinBangou = tj.YubinBangou__c;
                Jusho = tj.Jusho__c;
            } else if (tj.SeikyushaDoukyoShubetsu_Honnin__c) {
                SeikyushaDoukyoShubetsu = System.label.EX_TJD_DoukyoShubetsu_Honnin;
                IsBekkyo = false;
            }

            // 続柄
            if (tj.SeikyushaTsudukigara_Chichi__c) {
                SeikyushaTsudukigara = System.label.EX_TJD_Tsudukigara_Chichi;
            } else if (tj.SeikyushaTsudukigara_Haha__c) {
                SeikyushaTsudukigara = System.label.EX_TJD_Tsudukigara_Haha;
            } else if (tj.SeikyushaTsudukigara_Sonota__c) {
                SeikyushaTsudukigara = System.label.EX_TJD_Tsudukigara_Sonota;
                SonotaShousai = tj.SonotaShousai__c;
            }

            // その他
            IsTochuTennyuShussei = tj.IsTochuTennyuShussei__c;
            TennyuShusseiDate = tj.TennyuShusseiDate__c;
            TennyuShusseiDateSonota = tj.TennyuShusseiDateSonota__c;
            IsTochuTenshutsu = tj.IsTochuTenshutsu__c;
            TenshutsuDate = tj.TenshutsuDate__c;
            TenshutsuDateSonota = tj.TenshutsuDateSonota__c;
            if (tj.IsKokuseki_Nihon__c) {
                Kokuseki = System.label.EX_TJD_Kokuseki_Nihon;
            } else if (tj.IsKokuseki_NihonIgai__c) {
                Kokuseki = System.label.EX_TJD_Kokuseki_NihonIgai;
            }

            // 申立書
            IsMoushitate = tj.TaishoshaKubun__r.IsMoushitate__c;
            IsKokennin = tj.Moushitate_KokenninCheck__c;
            IsBekkyoKango = tj.Moushitate_BekkyoKango__c;
            IsRyugaku = tj.Moushitate_KaigaiRyugakuCheck__c;
            IsRikon = tj.Moushitate_RikonKyogiCheck__c;
            IsFuboSitei = tj.Moushitate_FuboSiteishaCheck__c;

            if (tj.Bekkyo_Tanshifunin__c) {
                BekkyoRiyu = System.label.EX_TJD_Bekkyo_Tanshinfunin;
            } else if (tj.Bekkyo_Shingaku__c) {
                BekkyoRiyu = System.label.EX_TJD_Bekkyo_Shingaku;
            } else if (tj.Bekkyo_Sonota__c) {
                BekkyoRiyu = System.label.EX_TJD_Bekkyo_Sonota;
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

            // 受取口座区分
            if (tj.UketoriKouzaKubun_Seikyusha__c) {
                UketoriKouzaKubun = '認定請求者の名義';
                IsSelectedTaishosha = false;
            } else if (tj.UketoriKouzaKubun_Taishosha__c) {
                UketoriKouzaKubun = '対象者(子供)の名義';
                IsSelectedTaishosha = true;
            }

            // 口座情報（ゆうちょ）
            if (String.isNotEmpty(tj.YuchoBango__c)) {
                IsYucho = true;
                if (tj.TJ_Yucho_Shumoku01__c) {
                    YuchoBunrui = '総合口座';
                } else if (tj.TJ_Yucho_Shumoku02__c) {
                    YuchoBunrui = '通常貯金';
                } else if (tj.TJ_Yucho_Shumoku03__c) {
                    YuchoBunrui = '通常貯蓄貯金';
                } else if (tj.TJ_Yucho_Shumoku04__c) {
                    YuchoBunrui = '振替口座';
                }
                YuchoKigo = tj.YuchoKigo__c;
                YuchoBango = tj.YuchoBango__c;
                YuchoKouzaMeigi = tj.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else {
                IsYucho = false;
                KinyuKikan = tj.KinyuKikan__r.Name;
                KinyuKikanCode = tj.KinyuKikan__r.KinyuKikanCode__c;
                Shiten = tj.Shiten__r.Name;
                ShitenCode = tj.Shiten__r.TempoCode__c;
                if (tj.TJ_Shumoku01__c) {
                    Bunrui = '普通';
                } else if (tj.TJ_Shumoku02__c) {
                    Bunrui = '当座';
                } else if (tj.TJ_Shumoku03__c) {
                    Bunrui = '貯蓄';
                }
                KouzaBangou = tj.KouzaBangou__c;
                KouzaMeigi = tj.KouzaMeigi__c;
            }

            TaishoJidoFileList = new List<String>();
        }

        public void set(DV_TaishoJido__c tj) {

            // 対象児童情報
            Id = tj.Id;
            TaishoshaKubun = tj.TaishoshaKubun__r.Name;
            Shimei = tj.Shimei__c;
            ShimeiFurigana = tj.ShimeiFurigana__c;
            SeinenGappiDate = tj.SeinenGappiDate__c;
            Fukumu18 = tj.NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c;

            // 請求者区分
            if (tj.SeikyushaKubun_Taishosha__c) {
                SeikyushaKubun = '対象者自身が認定請求を行う';
            } else if (tj.SeikyushaKubun_Dairinin__c) {
                SeikyushaKubun = '対象者の代理人が認定請求を行う';
            } else {
                SeikyushaKubun = '対象者が18歳未満';
            }

            // 同居種別
            if (tj.SeikyushaDoukyoShubetsu_Doukyo__c) {
                SeikyushaDoukyoShubetsu = System.label.EX_TJD_DoukyoShubetsu_Doukyo;
                IsBekkyo = false;
            } else if (tj.SeikyushaDoukyoShubetsu_Bekkyo__c) {
                SeikyushaDoukyoShubetsu = System.label.EX_TJD_DoukyoShubetsu_Bekkyo;
                IsBekkyo = true;
                YubinBangou = tj.YubinBangou__c;
                Jusho = tj.Jusho__c;
            } else if (tj.SeikyushaDoukyoShubetsu_Honnin__c) {
                SeikyushaDoukyoShubetsu = System.label.EX_TJD_DoukyoShubetsu_Honnin;
                IsBekkyo = false;
            }

            // 続柄
            if (tj.SeikyushaTsudukigara_Chichi__c) {
                SeikyushaTsudukigara = System.label.EX_TJD_Tsudukigara_Chichi;
            } else if (tj.SeikyushaTsudukigara_Haha__c) {
                SeikyushaTsudukigara = System.label.EX_TJD_Tsudukigara_Haha;
            } else if (tj.SeikyushaTsudukigara_Sonota__c) {
                SeikyushaTsudukigara = System.label.EX_TJD_Tsudukigara_Sonota;
                SonotaShousai = tj.SonotaShousai__c;
            }

            // その他
            IsTochuTennyuShussei = tj.IsTochuTennyuShussei__c;
            TennyuShusseiDate = tj.TennyuShusseiDate__c;
            TennyuShusseiDateSonota = tj.TennyuShusseiDateSonota__c;
            IsTochuTenshutsu = tj.IsTochuTenshutsu__c;
            TenshutsuDate = tj.TenshutsuDate__c;
            TenshutsuDateSonota = tj.TenshutsuDateSonota__c;
            if (tj.IsKokuseki_Nihon__c) {
                Kokuseki = System.label.EX_TJD_Kokuseki_Nihon;
            } else if (tj.IsKokuseki_NihonIgai__c) {
                Kokuseki = System.label.EX_TJD_Kokuseki_NihonIgai;
            }

            // 申立書
            IsMoushitate = tj.TaishoshaKubun__r.IsMoushitate__c;
            IsKokennin = tj.Moushitate_KokenninCheck__c;
            IsBekkyoKango = tj.Moushitate_BekkyoKango__c;
            IsRyugaku = tj.Moushitate_KaigaiRyugakuCheck__c;
            IsRikon = tj.Moushitate_RikonKyogiCheck__c;
            IsFuboSitei = tj.Moushitate_FuboSiteishaCheck__c;

            if (tj.Bekkyo_Tanshifunin__c) {
                BekkyoRiyu = System.label.EX_TJD_Bekkyo_Tanshinfunin;
            } else if (tj.Bekkyo_Shingaku__c) {
                BekkyoRiyu = System.label.EX_TJD_Bekkyo_Shingaku;
            } else if (tj.Bekkyo_Sonota__c) {
                BekkyoRiyu = System.label.EX_TJD_Bekkyo_Sonota;
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

            // 受取口座区分
            if (tj.UketoriKouzaKubun_Seikyusha__c) {
                UketoriKouzaKubun = '認定請求者の名義';
                IsSelectedTaishosha = false;
            } else if (tj.UketoriKouzaKubun_Taishosha__c) {
                UketoriKouzaKubun = SITE_MODE == ExLwcUtil.MODE_SATOYA ? '子供(対象者・認定請求者)の名義' : '対象者(子供)の名義';
                IsSelectedTaishosha = true;
            }

            // 口座情報（ゆうちょ）
            if (String.isNotEmpty(tj.YuchoBango__c)) {
                IsYucho = true;
                if (tj.TJ_Yucho_Shumoku01__c) {
                    YuchoBunrui = '総合口座';
                } else if (tj.TJ_Yucho_Shumoku02__c) {
                    YuchoBunrui = '通常貯金';
                } else if (tj.TJ_Yucho_Shumoku03__c) {
                    YuchoBunrui = '通常貯蓄貯金';
                } else if (tj.TJ_Yucho_Shumoku04__c) {
                    YuchoBunrui = '振替口座';
                }
                YuchoKigo = tj.YuchoKigo__c;
                YuchoBango = tj.YuchoBango__c;
                YuchoKouzaMeigi = tj.YuchoKouzaMeigi__c;

            // 口座情報（ゆうちょ以外）
            } else {
                IsYucho = false;
                KinyuKikan = tj.KinyuKikan__r.Name;
                KinyuKikanCode = tj.KinyuKikan__r.KinyuKikanCode__c;
                Shiten = tj.Shiten__r.Name;
                ShitenCode = tj.Shiten__r.TempoCode__c;
                if (tj.TJ_Shumoku01__c) {
                    Bunrui = '普通';
                } else if (tj.TJ_Shumoku02__c) {
                    Bunrui = '当座';
                } else if (tj.TJ_Shumoku03__c) {
                    Bunrui = '貯蓄';
                }
                KouzaBangou = tj.KouzaBangou__c;
                KouzaMeigi = tj.KouzaMeigi__c;
            }

            // DVのみの項目
            KonnendochuShinkiSochi = tj.TaishoShinkiSochi__c;
            Biko = tj.Shisetsu_TaishoBiko__c;
            IsBetsuJusho = tj.Moushitate_BetsuJushoCheck__c;

            TaishoJidoFileList = new List<String>();
        }
    }

    /**
     * 対象児童のデータを取得
     */
    @AuraEnabled
    public static List<TaishoJidoWrapper> getTaishoJidoData(String recordId){

        List<TaishoJidoWrapper> tjwList;
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            tjwList = getTaishoJidoDataIppan(recordId);
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            tjwList = getTaishoJidoDataDv(recordId);
        }

        Set<String> tjIdSet = new Set<String>();
        for (TaishoJidoWrapper tjw : tjwList) {
            tjIdSet.add(tjw.Id);
        }

        // 紐づくファイルを取得
        Map<String, Map<String, List<String>>> allCvIdLists = ExTaishoJidoUtil.getFilteringFileLists(tjIdSet);
        for (TaishoJidoWrapper tjw : tjwList) {
            Map<String, List<String>> cvIdLists = allCvIdLists.get(tjw.Id);
            tjw.TaishoJidoFileList.addAll(cvIdLists.get('kazoku'));
            tjw.TaishoJidoFileList.addAll(cvIdLists.get('moushitate'));
            tjw.TaishoJidoFileList.addAll(cvIdLists.get('koza'));
        }

        return tjwList;
    }

    private static List<TaishoJidoWrapper> getTaishoJidoDataIppan(String ninteiSeikyuId) {
        List<TaishoJido__c> tjList = [
            SELECT
                Id
                ,TaishoshaKubun__r.Name
                ,Shimei__c
                ,ShimeiFurigana__c
                ,SeinenGappiDate__c
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
                ,TaishoshaKubun__r.IsMoushitate__c
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
                ,UketoriKouzaKubun_Seikyusha__c
                ,UketoriKouzaKubun_Taishosha__c
                ,TJ_Yucho_Shumoku01__c
                ,TJ_Yucho_Shumoku02__c
                ,TJ_Yucho_Shumoku03__c
                ,TJ_Yucho_Shumoku04__c
                ,YuchoBango__c
                ,YuchoKigo__c
                ,YuchoKouzaMeigi__c
                ,KinyuKikan__r.Name
                ,KinyuKikan__r.KinyuKikanCode__c
                ,Shiten__r.Name
                ,Shiten__r.TempoCode__c
                ,TJ_Shumoku01__c
                ,TJ_Shumoku02__c
                ,TJ_Shumoku03__c
                ,KouzaBangou__c
                ,KouzaMeigi__c
                ,NinteiSeikyu__c
                ,NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c
            FROM TaishoJido__c
            WHERE NinteiSeikyu__c = :ninteiSeikyuId
            ORDER BY Name
        ];

        List<TaishoJidoWrapper> tjwList = new List<TaishoJidoWrapper>();
        for (TaishoJido__c tj : tjList) {

            // 対象児童情報をセット
            TaishoJidoWrapper tjw = new TaishoJidoWrapper();
            tjw.set(tj);

            tjwList.add(tjw);
        }
        return tjwList;
    }

    private static List<TaishoJidoWrapper> getTaishoJidoDataDv(String ninteiSeikyuId) {
        List<DV_TaishoJido__c> tjList = [
            SELECT
                Id
                ,TaishoshaKubun__r.Name
                ,Shimei__c
                ,ShimeiFurigana__c
                ,SeinenGappiDate__c
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
                ,toLabel(TaishoShinkiSochi__c)
                ,Shisetsu_TaishoBiko__c
                ,TaishoshaKubun__r.IsMoushitate__c
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
                ,UketoriKouzaKubun_Seikyusha__c
                ,UketoriKouzaKubun_Taishosha__c
                ,TJ_Yucho_Shumoku01__c
                ,TJ_Yucho_Shumoku02__c
                ,TJ_Yucho_Shumoku03__c
                ,TJ_Yucho_Shumoku04__c
                ,YuchoBango__c
                ,YuchoKigo__c
                ,YuchoKouzaMeigi__c
                ,KinyuKikan__r.Name
                ,KinyuKikan__r.KinyuKikanCode__c
                ,Shiten__r.Name
                ,Shiten__r.TempoCode__c
                ,TJ_Shumoku01__c
                ,TJ_Shumoku02__c
                ,TJ_Shumoku03__c
                ,KouzaBangou__c
                ,KouzaMeigi__c
                ,NinteiSeikyu__c
                ,NinteiSeikyu__r.SeikyushaKubun_18saiFukumu__c
            FROM DV_TaishoJido__c
            WHERE NinteiSeikyu__c = :ninteiSeikyuId
            ORDER BY Name
        ];

        List<TaishoJidoWrapper> tjwList = new List<TaishoJidoWrapper>();
        for (DV_TaishoJido__c tj : tjList) {

            // 対象児童情報をセット
            TaishoJidoWrapper tjw = new TaishoJidoWrapper();
            tjw.set(tj);

            tjwList.add(tjw);
        }
        return tjwList;
    }

    /**
     * 必要情報のチェックを行う
     */
    @AuraEnabled
    public static List<ExValidationUtil.ErrorLog> validationTaishoJido(String ninteiSeikyuId) {
        try {
            Map<String, List<String>> errorMap = new Map<String, List<String>>();

            // 対象児童のデータ取得
            List<ExTaishoJidoController.TaishoJidoWrapper> tjwList = ExTaishoJidoController.getTaishoJidoList(ninteiSeikyuId);

            for (ExTaishoJidoController.TaishoJidoWrapper tjw : tjwList) {
                // 対象者情報 ファイルアップロード
                if ((Boolean)ObjectUtil.nvl(tjw.needKazokuKakuninFile, false)) {
                    errorMap.put(tjw.Shimei, new List<String>{System.label.EX_TJD_NeedKazokuKakuninFile});
                }

                // 申立書入力
                if ((Boolean)ObjectUtil.nvl(tjw.isNotMoushitateFinished, false)) {
                    if (errorMap.containsKey(tjw.Shimei)) {
                        errorMap.get(tjw.Shimei).add(System.label.EX_TJD_IsNotMoushitateFinished);
                    } else {
                        errorMap.put(tjw.Shimei, new List<String>{System.label.EX_TJD_IsNotMoushitateFinished});
                    }
                }

                // 申立書 ファイルアップロード
                if ((Boolean)ObjectUtil.nvl(tjw.needMoushitateFile, false)) {
                    if (errorMap.containsKey(tjw.Shimei)) {
                        errorMap.get(tjw.Shimei).add(System.label.EX_TJD_NeedMoushitateFile);
                    } else {
                        errorMap.put(tjw.Shimei, new List<String>{System.label.EX_TJD_NeedMoushitateFile});
                    }
                }

                // 口座情報 入力
                if ((Boolean)ObjectUtil.nvl(tjw.isNotKozaJohoFinished, false)) {
                    if (errorMap.containsKey(tjw.Shimei)) {
                        errorMap.get(tjw.Shimei).add(System.label.EX_TJD_IsNotKozaJohoFinished);
                    } else {
                        errorMap.put(tjw.Shimei, new List<String>{System.label.EX_TJD_IsNotKozaJohoFinished});
                    }
                }

                // 口座情報 ファイルアップロード
                if ((Boolean)ObjectUtil.nvl(tjw.needKozaKakuninFile, false)) {
                    if (errorMap.containsKey(tjw.Shimei)) {
                        errorMap.get(tjw.Shimei).add(System.label.EX_TJD_NeedKozaKakuninFile);
                    } else {
                        errorMap.put(tjw.Shimei, new List<String>{System.label.EX_TJD_NeedKozaKakuninFile});
                    }
                }

                // 請求者の口座情報 入力
                if ((Boolean)ObjectUtil.nvl(tjw.isNotSeikyushaKozaFilled, false)) {
                    if (errorMap.containsKey(tjw.Shimei)) {
                        errorMap.get(tjw.Shimei).add(System.label.EX_TJD_IsNotSeikyushaKozaJohoFinished);
                    } else {
                        errorMap.put(tjw.Shimei, new List<String>{System.label.EX_TJD_IsNotSeikyushaKozaJohoFinished});
                    }
                }
            }

            return convertErrorMapToLogs(errorMap);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<ExValidationUtil.ErrorLog> convertErrorMapToLogs(Map<String, List<String>> errorMap) {
        ExValidationUtil.ErrorLogs eLogs = new ExValidationUtil.ErrorLogs();

        for (String key : errorMap.keyset()) {
            eLogs.add(
                '【' + key + '】'
                ,String.join(errorMap.get(key), '\n')
            );
        }

        return eLogs.errorLogs;
    }

    /**
     * 認定請求を申請する
     */
    @AuraEnabled
    public static void submitRequest(String ninteiSeikyuId) {
        try {

            // 既に申請済だった場合、処理を中断
            if (ExLwcUtil.isNinteiSeikyuDisabled(ninteiSeikyuId)) {
                throw new AuraHandledException('');
            }

            // 各種データを更新
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                submitRequestIppan(ninteiSeikyuId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                submitRequestDv(ninteiSeikyuId);
            }

            // 申請完了メール送信
            sendSubmitMail(ninteiSeikyuId);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void submitRequestIppan(String ninteiSeikyuId) {

        if (ExLwcUtil.isNinteiSeikyuDisabled(ninteiSeikyuId)) {
            throw new AuraHandledException('');
        }

        // 認定請求の情報を取得
        NinteiSeikyu__c ns = [
            SELECT
                Id
                ,Seikyusha__c
                ,ShinsaStatus__c
            FROM
                NinteiSeikyu__c
            WHERE
                Id = :ninteiSeikyuId
        ];

        // 請求者の情報を取得
        Seikyusha__c s = [
            SELECT
                Id
                ,YubinBangou__c
                ,Jusho__c
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
            FROM
                Seikyusha__c
            WHERE
                Id = :ns.Seikyusha__c
        ];

        // 対象児童の情報を取得
        List<TaishoJido__c> tjList = [
            SELECT
                Id
                ,SeikyushaDoukyoShubetsu_Doukyo__c
                ,SeikyushaDoukyoShubetsu_Honnin__c
                ,UketoriKouzaKubun_Seikyusha__c
                ,ShinsaKekkaSaishu__c
                ,Moushitate_KokenninCheck__c
                ,Moushitate_BekkyoKango__c
                ,Moushitate_KaigaiRyugakuCheck__c
                ,Moushitate_RikonKyogiCheck__c
                ,Moushitate_FuboSiteishaCheck__c
            FROM
                TaishoJido__c
            WHERE
                NinteiSeikyu__c = :ninteiSeikyuId
        ];

        for (TaishoJido__c tj : tjList) {

            // 同居、もしくは本人の場合請求者の住所をコピー
            if (tj.SeikyushaDoukyoShubetsu_Doukyo__c || tj.SeikyushaDoukyoShubetsu_Honnin__c) {
                tj.YubinBangou__c = s.YubinBangou__c;
                tj.Jusho__c = s.Jusho__c;
            }

            // 認定請求者の口座の場合、請求者の口座情報をコピー
            if (tj.UketoriKouzaKubun_Seikyusha__c) {
                tj.SK_Yucho_Shumoku01__c = s.Yucho_Shumoku01__c;
                tj.SK_Yucho_Shumoku02__c = s.Yucho_Shumoku02__c;
                tj.SK_Yucho_Shumoku03__c = s.Yucho_Shumoku03__c;
                tj.SK_Yucho_Shumoku04__c = s.Yucho_Shumoku04__c;
                tj.SK_YuchoBango__c = s.YuchoBango__c;
                tj.SK_YuchoKigo__c = s.YuchoKigo__c;
                tj.SK_YuuchoKouzaMeigi__c = s.YuchoKouzaMeigi__c;
                tj.SK_KinyuKikan__c = s.KinyuKikan__c;
                tj.SK_KinyuKikanCode__c = s.KinyuKikan__r.KinyuKikanCode__c;
                tj.SK_Shiten__c = s.Shiten__c;
                tj.SK_ShitenCode__c = s.Shiten__r.TempoCode__c;
                tj.SK_Shumoku01__c = s.Shumoku01__c;
                tj.SK_Shumoku02__c = s.Shumoku02__c;
                tj.SK_Shumoku03__c = s.Shumoku03__c;
                tj.SK_KouzaBango__c = s.KouzaBango__c;
                tj.SK_KouzaMeigi__c = s.KouzaMeigi__c;
            }

            // 編集可能データの場合
            if (tj.ShinsaKekkaSaishu__c != 'OK' && tj.ShinsaKekkaSaishu__c != 'NG') {

                // 申出日を更新
                if (tj.Moushitate_KokenninCheck__c
                    || tj.Moushitate_BekkyoKango__c
                    || tj.Moushitate_KaigaiRyugakuCheck__c
                    || tj.Moushitate_RikonKyogiCheck__c
                    || tj.Moushitate_FuboSiteishaCheck__c
                ) {
                    tj.MoushideDate__c = Date.today();
                }
            }
        }

        update tjList;

        // 紐づくファイルの削除可能フラグをOFFに変更
        Set<Id> linkedEntitySet = new Set<Id>();
        linkedEntitySet.add(ns.Id);
        linkedEntitySet.add(s.Id);
        linkedEntitySet.addAll(new Map<Id, TaishoJido__c>(tjList).keySet());
        ExLwcUtil.updateFileDeletableFlg(linkedEntitySet);

        // 審査ステータスを変更
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.ShinseiKanryoDateTime__c = Datetime.now();
        update ns;
    }

    private static void submitRequestDv(String ninteiSeikyuId) {

        if (ExLwcUtil.isNinteiSeikyuDisabled(ninteiSeikyuId)) {
            throw new AuraHandledException('');
        }

        // 認定請求の情報を取得
        DV_NinteiSeikyu__c ns = [
            SELECT
                Id
                ,Seikyusya__c
                ,ShinsaStatus__c
            FROM DV_NinteiSeikyu__c
            WHERE
                Id = :ninteiSeikyuId
        ];

        // 請求者の情報を取得
        DV_Seikyusha__c s = [
            SELECT
                Id
                ,YubinBangou__c
                ,Jusho__c
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
            FROM DV_Seikyusha__c
            WHERE
                Id = :ns.Seikyusya__c
        ];

        // 対象児童の情報を取得
        List<DV_TaishoJido__c> tjList = [
            SELECT
                Id
                ,SeikyushaDoukyoShubetsu_Doukyo__c
                ,SeikyushaDoukyoShubetsu_Honnin__c
                ,UketoriKouzaKubun_Seikyusha__c
                ,ShinsaKekkaSaishu__c
                ,Moushitate_KokenninCheck__c
                ,Moushitate_BekkyoKango__c
                ,Moushitate_KaigaiRyugakuCheck__c
                ,Moushitate_RikonKyogiCheck__c
                ,Moushitate_FuboSiteishaCheck__c
            FROM DV_TaishoJido__c
            WHERE
                NinteiSeikyu__c = :ninteiSeikyuId
        ];

        for (DV_TaishoJido__c tj : tjList) {

            // 同居、もしくは本人の場合請求者の住所をコピー
            if (tj.SeikyushaDoukyoShubetsu_Doukyo__c || tj.SeikyushaDoukyoShubetsu_Honnin__c) {
                tj.YubinBangou__c = s.YubinBangou__c;
                tj.Jusho__c = s.Jusho__c;
            }

            // 認定請求者の口座の場合、請求者の口座情報をコピー
            if (tj.UketoriKouzaKubun_Seikyusha__c) {
                tj.SK_Yucho_Shumoku01__c = s.Yucho_Shumoku01__c;
                tj.SK_Yucho_Shumoku02__c = s.Yucho_Shumoku02__c;
                tj.SK_Yucho_Shumoku03__c = s.Yucho_Shumoku03__c;
                tj.SK_Yucho_Shumoku04__c = s.Yucho_Shumoku04__c;
                tj.SK_YuchoBango__c = s.YuchoBango__c;
                tj.SK_YuchoKigo__c = s.YuchoKigo__c;
                tj.SK_YuuchoKouzaMeigi__c = s.YuchoKouzaMeigi__c;
                tj.SK_KinyuKikan__c = s.KinyuKikan__c;
                tj.SK_KinyuKikanCode__c = s.KinyuKikan__r.KinyuKikanCode__c;
                tj.SK_Shiten__c = s.Shiten__c;
                tj.SK_ShitenCode__c = s.Shiten__r.TempoCode__c;
                tj.SK_Shumoku01__c = s.Shumoku01__c;
                tj.SK_Shumoku02__c = s.Shumoku02__c;
                tj.SK_Shumoku03__c = s.Shumoku03__c;
                tj.SK_KouzaBango__c = s.KouzaBango__c;
                tj.SK_KouzaMeigi__c = s.KouzaMeigi__c;
            }

            // 編集可能データの場合
            if (tj.ShinsaKekkaSaishu__c != 'OK' && tj.ShinsaKekkaSaishu__c != 'NG') {

                // 申出日を更新
                if (tj.Moushitate_KokenninCheck__c
                    || tj.Moushitate_BekkyoKango__c
                    || tj.Moushitate_KaigaiRyugakuCheck__c
                    || tj.Moushitate_RikonKyogiCheck__c
                    || tj.Moushitate_FuboSiteishaCheck__c
                ) {
                    tj.MoushideDate__c = Date.today();
                }
            }
        }

        update tjList;

        // 紐づくファイルの削除可能フラグをOFFに変更
        Set<Id> linkedEntitySet = new Set<Id>();
        linkedEntitySet.add(ns.Id);
        linkedEntitySet.add(s.Id);
        linkedEntitySet.addAll(new Map<Id, DV_TaishoJido__c>(tjList).keySet());
        ExLwcUtil.updateFileDeletableFlg(linkedEntitySet);

        // 審査ステータスを変更
        ns.ShinsaStatus__c = 'OCR処理中';
        ns.ShinseiKanryoDateTime__c = Datetime.now();
        update ns;
    }

    /**
     * 認定請求申請完了メールを送信
     */
    private static void sendSubmitMail(String ninteiSeikyuId) {

        // 返信先メールアドレス(組織のアドレス)を取得
        OrgWideEmailAddress replyAddress;
        if (!Test.isRunningTest()) {
            apexMailSetting__mdt ssmdt = [SELECT displayName__c FROM apexMailSetting__mdt LIMIT 1];
            replyAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :ssmdt.displayName__c LIMIT 1];
        }

        // メールテンプレート取得
        String etDeveloperName = '';
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            etDeveloperName = 'ExSubmitNinteiSeikyu';
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            etDeveloperName = 'DVExSubmitNinteiSeikyuDv';
        }
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :etDeveloperName];

        // メールを作成する
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, UserInfo.getUserId(), ninteiSeikyuId);
        mail.setSaveAsActivity(false); // 送信メールを活動に保存しない
        if (!Test.isRunningTest()) {
            mail.setOrgWideEmailAddressId(replyAddress.Id);
        }

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}