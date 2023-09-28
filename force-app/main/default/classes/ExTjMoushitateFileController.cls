public with sharing class ExTjMoushitateFileController {

    private static final String SITE_MODE = ExLwcUtil.getSiteMode();
    private static final String KUBUN_KOKENNIN = '1';
    private static final String KUBUN_BEKKYO = '2';
    private static final String KUBUN_RYUGAKU = '3';
    private static final String KUBUN_RIKON = '4';
    private static final String KUBUN_FUBOSITEI = '5';

    public class MoushitateWrapper {
        @AuraEnabled public final String KUBUN_KOKENNIN = '1';
        @AuraEnabled public final String KUBUN_BEKKYO = '2';
        @AuraEnabled public final String KUBUN_RYUGAKU = '3';
        @AuraEnabled public final String KUBUN_RIKON = '4';
        @AuraEnabled public final String KUBUN_FUBOSITEI = '5';

        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public String SeikyushaShimei {get;set;}
        @AuraEnabled public Boolean IsKokennin {get;set;}
        @AuraEnabled public Boolean IsBekkyo {get;set;}
        @AuraEnabled public Boolean IsRyugaku {get;set;}
        @AuraEnabled public Boolean IsRikon {get;set;}
        @AuraEnabled public Boolean IsFuboSitei {get;set;}
        @AuraEnabled public List<Map<String, String>> KokenninShoruiOptions {get;set;}
        @AuraEnabled public List<Map<String, String>> BekkyoShoruiOptions {get;set;}
        @AuraEnabled public List<Map<String, String>> RyugakuShoruiOptions {get;set;}
        @AuraEnabled public List<Map<String, String>> RikonShoruiOptions {get;set;}
        @AuraEnabled public List<Map<String, String>> FuboShoruiOptions {get;set;}
        @AuraEnabled public List<String> KokenninShoruiList {get;set;}
        @AuraEnabled public List<String> BekkyoShoruiList {get;set;}
        @AuraEnabled public List<String> RyugakuShoruiList {get;set;}
        @AuraEnabled public List<String> RikonShoruiList {get;set;}
        @AuraEnabled public List<String> FuboShoruiList {get;set;}
        @AuraEnabled public Map<String, String> ShoruiSetsumeiMap {get;set;}
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

            KokenninShoruiList = new List<String>();
            BekkyoShoruiList = new List<String>();
            RyugakuShoruiList = new List<String>();
            RikonShoruiList = new List<String>();
            FuboShoruiList = new List<String>();

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

            KokenninShoruiList = new List<String>();
            BekkyoShoruiList = new List<String>();
            RyugakuShoruiList = new List<String>();
            RikonShoruiList = new List<String>();
            FuboShoruiList = new List<String>();

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
     * 申立書ファイルアップロード画面用の情報を取得する
     */
    @AuraEnabled
    public static MoushitateWrapper getMoushitateData(String taishoJidoId){
        try {

            MoushitateWrapper mw;

            // 対象児童の情報取得
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                mw = getTaishoJidoDataIppan(taishoJidoId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                mw = getTaishoJidoDataDv(taishoJidoId);
            }

            // 必要な書類オプション/説明/提出済み書類の情報取得
            mw = setShoruiData(mw);

            return mw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static MoushitateWrapper getTaishoJidoDataIppan(String taishoJidoId) {
        TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,Moushitate_KokenninCheck__c
                ,Moushitate_BekkyoKango__c
                ,Moushitate_KaigaiRyugakuCheck__c
                ,Moushitate_RikonKyogiCheck__c
                ,Moushitate_FuboSiteishaCheck__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,NinteiSeikyu__r.Seikyusha__r.Shimei__c
                ,ShinsaKekkaSaishu__c
            FROM TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new MoushitateWrapper(tj);
    }

    private static MoushitateWrapper getTaishoJidoDataDv(String taishoJidoId) {
        DV_TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,Moushitate_KokenninCheck__c
                ,Moushitate_BekkyoKango__c
                ,Moushitate_KaigaiRyugakuCheck__c
                ,Moushitate_RikonKyogiCheck__c
                ,Moushitate_FuboSiteishaCheck__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,NinteiSeikyu__r.Seikyusya__r.Shimei__c
                ,ShinsaKekkaSaishu__c
            FROM DV_TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        return new MoushitateWrapper(tj);
    }

    /**
     * 必要な書類オプション/説明/提出済み書類の情報取得
     */
    private static MoushitateWrapper setShoruiData(MoushitateWrapper mw) {

        // 対象児童に紐づく書類一覧を取得
        List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(mw.Id);

        Map<String, String> shoruiSetsumeiMap = new Map<String, String>();

        // 未成年後見人であることの申立
        if (mw.IsKokennin) {
            GetShoruiDataResult result = getShoruiData(KUBUN_KOKENNIN);
            mw.KokenninShoruiOptions = result.options;
            shoruiSetsumeiMap = putShoruiSetsumei(shoruiSetsumeiMap, result.sstList);
            mw.KokenninShoruiList = filteringUploadedShoruiList(cdlList, result.sstList);
        }

        // 別居監護の申立
        if (mw.IsBekkyo) {
            GetShoruiDataResult result = getShoruiData(KUBUN_BEKKYO);
            mw.BekkyoShoruiOptions = result.options;
            shoruiSetsumeiMap = putShoruiSetsumei(shoruiSetsumeiMap, result.sstList);
            mw.BekkyoShoruiList = filteringUploadedShoruiList(cdlList, result.sstList);
        }

        // 海外留学に関する申立
        if (mw.IsRyugaku) {
            GetShoruiDataResult result = getShoruiData(KUBUN_RYUGAKU);
            mw.RyugakuShoruiOptions = result.options;
            shoruiSetsumeiMap = putShoruiSetsumei(shoruiSetsumeiMap, result.sstList);
            mw.RyugakuShoruiList = filteringUploadedShoruiList(cdlList, result.sstList);
        }

        // 離婚協議中の同居父母であることの申立
        if (mw.IsRikon) {
            GetShoruiDataResult result = getShoruiData(KUBUN_RIKON);
            mw.RikonShoruiOptions = result.options;
            shoruiSetsumeiMap = putShoruiSetsumei(shoruiSetsumeiMap, result.sstList);
            mw.RikonShoruiList = filteringUploadedShoruiList(cdlList, result.sstList);
        }

        // 父母指定者指定の届
        if (mw.IsFuboSitei) {
            GetShoruiDataResult result = getShoruiData(KUBUN_FUBOSITEI);
            mw.FuboShoruiOptions = result.options;
            shoruiSetsumeiMap = putShoruiSetsumei(shoruiSetsumeiMap, result.sstList);
            mw.FuboShoruiList = filteringUploadedShoruiList(cdlList, result.sstList);
        }

        mw.ShoruiSetsumeiMap = shoruiSetsumeiMap;
        return mw;
    }

    public class GetShoruiDataResult {
        public List<ShinseiShoruiTeigi__c> sstList {get;set;}
        public List<Map<String, String>> options {get;set;}
    }
    private static GetShoruiDataResult getShoruiData(String moushitateKubun) {
        GetShoruiDataResult result = new GetShoruiDataResult();

        // 申立書区分に紐づく書類を取得
        result.sstList = ExShinseiShoruiTeigiUtil.getRequiredMoushitateShorui(moushitateKubun);

        // 選択リストを作成
        List<Map<String, String>> options = new List<Map<String, String>>();
        for (ShinseiShoruiTeigi__c sst : result.sstList) {
            String required = sst.IsNiniTeisyutsu__c ? '' : '* ';
            options.add(new Map<String, String>{
                'label' => required + sst.Name
                ,'value' => sst.Id
            });
        }
        result.options = options;

        return result;
    }

    private static Map<String, String> putShoruiSetsumei(Map<String, String> shoruiSetsumeiMap, List<ShinseiShoruiTeigi__c> sstList) {

        for (ShinseiShoruiTeigi__c sst : sstList) {
            shoruiSetsumeiMap.put(sst.Id, sst.ShoruiSetsumei__c);
        }

        return shoruiSetsumeiMap;
    }

    private static List<String> filteringUploadedShoruiList(List<ContentDocumentLink> cdlList, List<ShinseiShoruiTeigi__c> sstList) {

        Set<Id> sstIdSet = new Map<Id, ShinseiShoruiTeigi__c>(sstList).keySet();
        List<String> cvIdList = new List<String>();
        for (ContentDocumentLink cdl : cdlList) {
            if (sstIdSet.contains(cdl.ContentDocument.LatestPublishedVersion.ShinseiShoruiTeigiId__c)) {
                cvIdList.add(cdl.ContentDocument.LatestPublishedVersionId);
            }
        }

        return cvIdList;
    }

    /**
     * 渡された区分に紐づく提出済み書類を取得する
     */
    @AuraEnabled
    public static List<String> getMoushitateShoruiList(String taishoJidoId, String moushitateKubun){
        try {

            // 対象児童に紐づく書類一覧を取得
            List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(taishoJidoId);

            GetShoruiDataResult result = getShoruiData(moushitateKubun);
            return filteringUploadedShoruiList(cdlList, result.sstList);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 提出が必要な申請書類の一覧を返す
     */
    @AuraEnabled
    public static List<String> needUploadShinseiShorui(MoushitateWrapper mw){
        try {
            // 対象児童に紐づく書類一覧を取得
            List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(mw.Id);

            // 対象児童に設定されている申立区分を取得
            List<String> moushitateKubuns = new List<String>();
            if (mw.IsKokennin) {
                moushitateKubuns.add(KUBUN_KOKENNIN);
            }
            if (mw.IsBekkyo) {
                moushitateKubuns.add(KUBUN_BEKKYO);
            }
            if (mw.IsRyugaku) {
                moushitateKubuns.add(KUBUN_RYUGAKU);
            }
            if (mw.IsRikon) {
                moushitateKubuns.add(KUBUN_RIKON);
            }
            if (mw.IsFuboSitei) {
                moushitateKubuns.add(KUBUN_FUBOSITEI);
            }

            // 必要な申請書類を取得
            List<ShinseiShoruiTeigi__c> sstList = ExShinseiShoruiTeigiUtil.getRequiredMoushitateShorui(moushitateKubuns);

            return ExValidationUtil.needUploadShinseiShorui(cdlList, sstList);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}