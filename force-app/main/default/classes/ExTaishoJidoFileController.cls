public with sharing class ExTaishoJidoFileController {

    private static final String SITE_MODE = ExLwcUtil.getSiteMode();

    public class TaishoJidoWrapper {
        @AuraEnabled public String Shimei {get;set;}
        @AuraEnabled public Boolean IsMoushitate {get;set;}
        @AuraEnabled public Boolean NeedFileUpload {get;set;} // falseの場合はファイル提出画面をスキップ
        @AuraEnabled public List<String> kazokuShoruiList {get;set;}
        @AuraEnabled public List<Map<String, String>> kazokuKakuninOptions {get;set;}
        @AuraEnabled public Map<String, String> ShoruiSetsumeiMap {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}

        public String TaishoshaKubun {get;set;}
        public Boolean IsDairinin {get;set;}

        public void set(TaishoJido__c tj) {
            Shimei = tj.Shimei__c;
            TaishoshaKubun = tj.TaishoshaKubun__c;
            IsMoushitate = tj.TaishoshaKubun__r.IsMoushitate__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }

            IsDairinin = tj.SeikyushaKubun_Dairinin__c;
        }
        public void set(DV_TaishoJido__c tj) {
            Shimei = tj.Shimei__c;
            TaishoshaKubun = tj.TaishoshaKubun__c;
            IsMoushitate = tj.TaishoshaKubun__r.IsMoushitate__c;

            // 審査ステータスに応じて値を変更
            if (tj.Ninteiseikyu__r.ShinsaStatus__c == '未申請'
                && tj.ShinsaKekkaSaishu__c != 'OK'
                && tj.ShinsaKekkaSaishu__c != 'NG') {
                isDisabled = false;
            } else {
                isDisabled = true;
            }

            IsDairinin = tj.SeikyushaKubun_Dairinin__c;
        }
    }

    /**
     * 対象児童のデータ取得
     */
    @AuraEnabled
    public static TaishoJidoWrapper getTaishoJidoData(String taishoJidoId){
        try {
            TaishoJidoWrapper tjw = new TaishoJidoWrapper();
            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                tjw = getTaishoJidoDataIppan(taishoJidoId);
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                tjw = getTaishoJidoDataDv(taishoJidoId);
            }

            tjw = setOptionData(tjw);
            tjw.kazokuShoruiList = getKazokuShoruiList(taishoJidoId);

            return tjw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static TaishoJidoWrapper getTaishoJidoDataIppan(String taishoJidoId) {

        TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,TaishoshaKubun__c
                ,TaishoshaKubun__r.IsMoushitate__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,ShinsaKekkaSaishu__c
                ,SeikyushaKubun_Dairinin__c
            FROM TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        TaishoJidoWrapper tjw = new TaishoJidoWrapper();
        tjw.set(tj);
        return tjw;
    }

    private static TaishoJidoWrapper getTaishoJidoDataDv(String taishoJidoId) {

        DV_TaishoJido__c tj = [
            SELECT
                Id
                ,Shimei__c
                ,TaishoshaKubun__c
                ,TaishoshaKubun__r.IsMoushitate__c
                ,Ninteiseikyu__r.ShinsaStatus__c
                ,ShinsaKekkaSaishu__c
                ,SeikyushaKubun_Dairinin__c
            FROM DV_TaishoJido__c
            WHERE Id = :taishoJidoId
        ];

        TaishoJidoWrapper tjw = new TaishoJidoWrapper();
        tjw.set(tj);
        return tjw;
    }

    /**
     * 提出が必要な申請書類一覧、書類説明を取得
     * また、提出が必要な書類があるかどうかもチェック
     */
    private static TaishoJidoWrapper setOptionData(TaishoJidoWrapper tjw) {

        List<KubunBetsuShinseiShorui__c> requiredKbssList = getRequiredShinseiShorui(tjw);

        Boolean needFileUpload = false;

        // 選択リスト用のマップに変換
        List<Map<String, String>> options = new List<Map<String, String>>();
        Map<String, String> shoruiSetsumeiMap = new Map<String, String>();
        for (KubunBetsuShinseiShorui__c kbss : requiredKbssList) {

            // 書類選択肢
            String required = kbss.ShinseiShoruiTeigi__r.IsNiniTeisyutsu__c ? '' : '* ';
            needFileUpload = !kbss.ShinseiShoruiTeigi__r.IsNiniTeisyutsu__c ? true : needFileUpload;

            options.add(new Map<String, String>{
                'label' => required + kbss.ShinseiShoruiTeigi__r.Name
                ,'value' => kbss.ShinseiShoruiTeigi__c
            });

            // 書類説明
            shoruiSetsumeiMap.put(kbss.ShinseiShoruiTeigi__c, kbss.ShinseiShoruiTeigi__r.ShoruiSetsumei__c);
        }

        tjw.kazokuKakuninOptions = options;
        tjw.ShoruiSetsumeiMap = shoruiSetsumeiMap;
        tjw.NeedFileUpload = needFileUpload || options.size() > 1; // 全てが任意提出でも、2件以上あれば画面を表示する

        return tjw;
    }

    /**
     * 提出が必要な申請書類一覧を取得
     */
    private static List<KubunBetsuShinseiShorui__c> getRequiredShinseiShorui(TaishoJidoWrapper tjw) {
        // 紐づく申請書類定義のIDを取得
        List<KubunBetsuShinseiShorui__c> kbssList = ExKubunBetsuShinseiShoruiUtil.getKubunBetsuShinseiShoruiList(tjw.TaishoshaKubun);

        // 必要な書類一覧を取得
        return ExTaishoJidoUtil.getRequiredShinseiShorui(tjw.IsDairinin, kbssList);
    }

    /**
     * 提出済の家族関係確認書類を取得
     */
    @AuraEnabled
    public static List<String> getKazokuShoruiList(String taishoJidoId){
        try {
            Map<String, List<String>> allCvIdLists = ExTaishoJidoUtil.getFilteringFileList(taishoJidoId);
            return allCvIdLists.get('kazoku');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 保険証マスキングフラグを更新
     */
    @AuraEnabled
    public static void updateMaskingKenkoHoken(String taishoJidoId){
        try {
            // 紐づく必要書類を取得
            List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(taishoJidoId);

            Boolean maskingKenkoHoken = false;
            for (ContentDocumentLink cdl : cdlList) {
                if (cdl.ContentDocument.LatestPublishedVersion.HoninKakuninShoruiMaskKenkoHoken__c) {
                    maskingKenkoHoken = true;
                    break;
                }
            }

            if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
                update new TaishoJido__c(
                    Id = taishoJidoId
                    ,HokenshoMaskingZumi__c = maskingKenkoHoken
                );
            } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
                update new DV_TaishoJido__c(
                    Id = taishoJidoId
                    ,HokenshoMaskingZumi__c = maskingKenkoHoken
                );
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 必要書類が全て登録されているかチェック
     * 不足している書類名の一覧を返す
     */
    @AuraEnabled
    public static List<String> needUploadShinseiShorui(String taishoJidoId){

        // 対象児童情報を取得
        TaishoJidoWrapper tjw = new TaishoJidoWrapper();
        if (SITE_MODE == ExLwcUtil.MODE_IPPAN) {
            tjw = getTaishoJidoDataIppan(taishoJidoId);
        } else if (SITE_MODE == ExLwcUtil.MODE_DV || SITE_MODE == ExLwcUtil.MODE_SATOYA) {
            tjw = getTaishoJidoDataDv(taishoJidoId);
        }

        // 提出が必要な書類一覧を取得
        List<KubunBetsuShinseiShorui__c> kbssList = getRequiredShinseiShorui(tjw);
        List<ShinseiShoruiTeigi__c> sstList = convertKbssToSstList(kbssList);

        // 提出済ファイル一覧を取得
        List<ContentDocumentLink> cdlList = ExTaishoJidoUtil.getFileList(taishoJidoId);

        return ExValidationUtil.needUploadShinseiShorui(cdlList, sstList);
    }

    /**
     * 区分別申請書類 → 申請書類定義Obj
     */
    private static List<ShinseiShoruiTeigi__c> convertKbssToSstList(List<KubunBetsuShinseiShorui__c> kbssList) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        for (KubunBetsuShinseiShorui__c kbss : kbssList) {
            sstList.add(new ShinseiShoruiTeigi__c(
                Id = kbss.ShinseiShoruiTeigi__c
                ,Name = kbss.ShinseiShoruiTeigi__r.Name
                ,IsNiniTeisyutsu__c = kbss.ShinseiShoruiTeigi__r.IsNiniTeisyutsu__c
            ));
        }

        return sstList;
    }
}