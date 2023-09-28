public with sharing class ExOshiraseSatooyaController {

    @AuraEnabled(cacheable=false)
    public static OshiraseWrapper getLast5Record() {
        OshiraseWrapper wrapper = new OshiraseWrapper();
        wrapper.oshiraseList = getOshiraseList();
        return wrapper;
    }

    private static List<OshiraseDetail> getOshiraseList(){

        List<OshiraseDetail> detailList = new List<OshiraseDetail>();
            // ログインユーザ所有の認定請求のみ取得
            List<Satooya_ZentaiOshirase__c> objList = [
                SELECT
                Id
                ,Name // タイトル
                ,Satooya_KokaiKaishiDate__c // 公開開始日
                FROM Satooya_ZentaiOshirase__c
                WHERE Satooya_Yukou__c = TRUE
                AND Satooya_KokaiKaishiDate__c <= TODAY
                AND Satooya_KokaiShuryoDate__c >= TODAY
                ORDER BY Satooya_KokaiKaishiDate__c DESC
                limit 5];

            for (Satooya_ZentaiOshirase__c obj:objList) {
                OshiraseDetail detail = new OshiraseDetail();
                detail.dataId = obj.Id;
                detail.title = obj.Name;
                if(obj.Satooya_KokaiKaishiDate__c != null) {
                    detail.kokaiKaishiDate = obj.Satooya_KokaiKaishiDate__c.format();
                }

                detailList.add(detail);
            }

        return detailList;
    }

    public class OshiraseWrapper{
        @AuraEnabled public List<OshiraseDetail> oshiraseList {get; set;}
    }
    public class OshiraseDetail{
        @AuraEnabled public String dataId {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String kokaiKaishiDate {get; set;}

    }
}