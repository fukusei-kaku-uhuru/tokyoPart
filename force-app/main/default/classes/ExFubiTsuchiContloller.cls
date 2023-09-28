public with sharing class ExFubiTsuchiContloller {
    @AuraEnabled(cacheable=false)
    public static fubitsuchiWrapper getFubiTsuchi(Id ninteiSeikyuId) {
        fubitsuchiWrapper wrapper = new fubitsuchiWrapper();
        wrapper.fubiTsuchiList = getFubiTsuchiList(ninteiSeikyuId);
        return wrapper;
    }

    private static List<fubiTsuchiDetail> getFubiTsuchiList(Id ninteiSeikyuId){

        String siteMode = ExLwcUtil.getSiteMode();

        // 不備通知の取得
        List<fubiTsuchiDetail> detailList = new List<fubiTsuchiDetail>();
        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<FubiTsuchi__c> objList = [
                SELECT
                Id
                ,FubiTaishoshaShimei__c // 不備対象者氏名
                ,KofuDate__c // 交付日
                FROM FubiTsuchi__c
                WHERE NinteiSeikyu__c = :ninteiSeikyuId
                OR TaishoJido__r.NinteiSeikyu__c = :ninteiSeikyuId
                ORDER BY Name ASC];

            for (FubiTsuchi__c obj:objList) {
                fubiTsuchiDetail detail = new fubiTsuchiDetail();
                detail.parentId = obj.Id;
                detail.fubiTaishoshaShimei = obj.FubiTaishoshaShimei__c;
                if(obj.KofuDate__c != null) {
                    detail.kofuDate = obj.KofuDate__c.format();
                }

                detailList.add(detail);
            }
        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV OR 里親
            List<DV_FubiTsuchi__c> objList = [
                SELECT
                Id
                ,FubiTaishoshaShimei__c // 不備対象者氏名
                ,KofuDate__c // 交付日
                FROM DV_FubiTsuchi__c
                WHERE NinteiSeikyu__c = :ninteiSeikyuId
                OR TaishoJido__r.NinteiSeikyu__c = :ninteiSeikyuId
                ORDER BY Name ASC];

            for (DV_FubiTsuchi__c obj:objList) {
                fubiTsuchiDetail detail = new fubiTsuchiDetail();
                detail.parentId = obj.Id;
                detail.fubiTaishoshaShimei = obj.FubiTaishoshaShimei__c;
                if(obj.KofuDate__c != null) {
                    detail.kofuDate = obj.KofuDate__c.format();
                }

                detailList.add(detail);
            }
        }

        return detailList;
    }

    public class fubitsuchiWrapper{
        @AuraEnabled public List<fubiTsuchiDetail> fubiTsuchiList {get; set;}
    }
    public class fubiTsuchiDetail{
        @AuraEnabled public String parentId {get; set;}
        @AuraEnabled public String fubiTaishoshaShimei {get; set;}
        @AuraEnabled public String kofuDate {get; set;}
    }
}