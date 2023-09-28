public with sharing class ExShinseiIchiranController {

    @TestVisible private static final String EM_DASH = '－';

    @AuraEnabled(cacheable=false)
    public static ShinseiWrapper getNinteiSeikyu() {
        ShinseiWrapper wrapper = new ShinseiWrapper();
        wrapper.shinseiList = getShinseiList();
        return wrapper;
    }

    private static List<ShinseiDetail> getShinseiList(){
        Id userId = UserInfo.getUserId();
        String siteMode = ExLwcUtil.getSiteMode();

        List<ShinseiDetail> detailList = new List<ShinseiDetail>();
        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            // ログインユーザ所有の認定請求のみ取得
            List<NinteiSeikyu__c> objList = [
                SELECT
                Id
                ,NinteiSeikyuUketsukeBangou__c // 認定請求受付番号
                ,NinteiSeikyuStatus__c // 認定請求ステータス
                ,ShinsaStatus__c // 審査ステータス
                ,CreatedDate
                ,(SELECT
                    Id
                    ,Shimei__c
                    ,ShoninKekka_Community__c // 承認結果（コミュニティ用）
                FROM TaishoJido__r
                ORDER BY Name ASC)
                FROM NinteiSeikyu__c
                WHERE OwnerId = :userId
                ORDER BY Name DESC];

            for (NinteiSeikyu__c obj:objList) {
                ShinseiDetail detail = new ShinseiDetail();
                detail.parentId = obj.Id;
                detail.parentNo = obj.NinteiSeikyuUketsukeBangou__c;
                detail.status = obj.NinteiSeikyuStatus__c;
                detail.createdDate = obj.CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString());
                detail.isEditDisabled = ExLwcUtil.isNotStatusMishinsei(obj.ShinsaStatus__c);

                List<ChildDetail> childList = new List<ChildDetail>();
                for (TaishoJido__c childObj:obj.TaishoJido__r) {
                    ChildDetail child = new ChildDetail();
                    child.childId = childObj.Id;
                    child.childName = childObj.Shimei__c;
                    child.shoninKekka = childObj.ShoninKekka_Community__c;
                    childList.add(child);
                }
                // 0件だと画面の都合上表示できないので空を追加
                if (childList.size() == 0) {
                    ChildDetail child = new ChildDetail();
                    child.childId = '';
                    child.childName = EM_DASH;
                    child.shoninKekka = EM_DASH;
                    childList.add(child);
                }
                detail.childList = childList;
                detailList.add(detail);
            }
        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV OR 里親
            // ログインユーザ所有の認定請求のみ取得
            List<DV_NinteiSeikyu__c> objList = [
                SELECT
                Id
                ,NinteiSeikyuUketsukeBangou__c // 認定請求受付番号
                ,NinteiSeikyuStatus__c // 認定請求ステータス
                ,ShinsaStatus__c // 審査ステータス
                ,CreatedDate
                ,(SELECT
                    Id
                    ,Shimei__c
                    ,ShoninKekka_Community__c // 承認結果（コミュニティ用）
                FROM DV_TaishoJido__r
                ORDER BY Name ASC)
                FROM DV_NinteiSeikyu__c
                WHERE
                    OwnerId = :userId
                AND
                    RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
                ORDER BY Name DESC];

            for (DV_NinteiSeikyu__c obj:objList) {
                ShinseiDetail detail = new ShinseiDetail();
                detail.parentId = obj.Id;
                detail.parentNo = obj.NinteiSeikyuUketsukeBangou__c;
                detail.status = obj.NinteiSeikyuStatus__c;
                detail.createdDate = obj.CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString());
                detail.isEditDisabled = ExLwcUtil.isNotStatusMishinsei(obj.ShinsaStatus__c);

                List<ChildDetail> childList = new List<ChildDetail>();
                for (DV_TaishoJido__c childObj:obj.DV_TaishoJido__r) {
                    ChildDetail child = new ChildDetail();
                    child.childId = childObj.Id;
                    child.childName = childObj.Shimei__c;
                    child.shoninKekka = childObj.ShoninKekka_Community__c;
                    childList.add(child);
                }
                // 0件だと画面の都合上表示できないので空を追加
                if (childList.size() == 0) {
                    ChildDetail child = new ChildDetail();
                    child.childId = '';
                    child.childName = EM_DASH;
                    child.shoninKekka = EM_DASH;
                    childList.add(child);
                }
                detail.childList = childList;
                detailList.add(detail);
            }
        }

        return detailList;
    }

    public class ShinseiWrapper{
        @AuraEnabled public List<ShinseiDetail> shinseiList {get; set;}
    }
    public class ShinseiDetail{
        @AuraEnabled public String parentId {get; set;}
        @AuraEnabled public String parentNo {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String createdDate {get; set;}
        @AuraEnabled public Boolean isEditDisabled {get; set;}
        @AuraEnabled public List<ChildDetail> childList {get; set;}
    }
    public class ChildDetail{
        @AuraEnabled public String childId {get; set;}
        @AuraEnabled public String childName {get; set;}
        @AuraEnabled public String shoninKekka {get; set;}
    }

}