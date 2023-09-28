public with sharing class ExNinteiKekkaController {

    @AuraEnabled(cacheable=false)
    public static taishoJidoWrapper getTaishoJido(Id ninteiSeikyuId) {
        taishoJidoWrapper wrapper = new taishoJidoWrapper();
        wrapper.taishoJidoList = getTaishoJidoList(ninteiSeikyuId);
        return wrapper;
    }

    private static List<jidoDetail> getTaishoJidoList(Id ninteiSeikyuId){

        String siteMode = ExLwcUtil.getSiteMode();

        List<jidoDetail> detailList = new List<jidoDetail>();

        // 一般
        if (siteMode == ExLwcUtil.MODE_IPPAN) {
            // 対象児童の取得
            List<TaishoJido__c> objList = [
                SELECT
                Id
                ,Shimei__c // 氏名
                ,ShoninKekka__c // 承認結果
                ,NinteiTsuchishoHakkoDate__c // 認定通知書発行日
                ,Shometsu_Date__c //消滅事由の発生した年月日
                ,(SELECT
                    Id
                    ,ContentDocument.LatestPublishedVersionId
                    ,ContentDocument.LatestPublishedVersion.Title
                    ,ContentDocument.LatestPublishedVersion.FileExtension
                    ,ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c
                FROM ContentDocumentLinks
                ORDER BY ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c, SystemModstamp Desc
                )
                FROM TaishoJido__c
                WHERE NinteiSeikyu__c = :ninteiSeikyuId
                ORDER BY Name ASC];

            for (TaishoJido__c obj:objList) {

                // 対象児童の情報をセット
                jidoDetail detail = new jidoDetail();
                detail.parentId = obj.Id;
                detail.Shimei = obj.Shimei__c;
                if(obj.ShoninKekka__c == '保留') {
                    detail.ShoninKekka = '－';
                }else {
                    detail.ShoninKekka = obj.ShoninKekka__c;
                }
                if(obj.NinteiTsuchishoHakkoDate__c != null) {
                    detail.NinteiTsuchishoHakkoDate = obj.NinteiTsuchishoHakkoDate__c.format();
                }
                detail.isNintei = obj.ShoninKekka__c == '認定';
                detail.isNotShometsu = obj.Shometsu_Date__c == null;
                detail.isDownload = (obj.ShoninKekka__c == '認定' || obj.ShoninKekka__c == '不認定');

                // 紐づくファイルをセット
                detail.fileList = convertFileDetailList(obj.ContentDocumentLinks);
                detailList.add(detail);
            }

        // DV OR 里親
        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){
            // 対象児童の取得
            List<DV_TaishoJido__c> objList = [
                SELECT
                Id
                ,Shimei__c // 氏名
                ,ShoninKekka__c // 承認結果
                ,NinteiTsuchishoHakkoDate__c // 認定通知書発行日
                ,Shometsu_Date__c //消滅事由の発生した年月日
                ,(SELECT
                    Id
                    ,ContentDocument.LatestPublishedVersionId
                    ,ContentDocument.LatestPublishedVersion.Title
                    ,ContentDocument.LatestPublishedVersion.FileExtension
                    ,ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c
                FROM ContentDocumentLinks
                ORDER BY ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c, SystemModstamp Desc
                )
                FROM DV_TaishoJido__c
                WHERE NinteiSeikyu__c = :ninteiSeikyuId
                ORDER BY Name ASC];

            for (DV_TaishoJido__c obj:objList) {

                // 対象児童の情報をセット
                jidoDetail detail = new jidoDetail();
                detail.parentId = obj.Id;
                detail.Shimei = obj.Shimei__c;
                if(obj.ShoninKekka__c == '保留') {
                    detail.ShoninKekka = '－';
                }else {
                    detail.ShoninKekka = obj.ShoninKekka__c;
                }
                if(obj.NinteiTsuchishoHakkoDate__c != null) {
                    detail.NinteiTsuchishoHakkoDate = obj.NinteiTsuchishoHakkoDate__c.format();
                }
                detail.isNintei = obj.ShoninKekka__c == '認定';
                detail.isNotShometsu = obj.Shometsu_Date__c == null;
                detail.isDownload = (obj.ShoninKekka__c == '認定' || obj.ShoninKekka__c == '不認定');

                // 紐づくファイルをセット
                detail.fileList = convertFileDetailList(obj.ContentDocumentLinks);
                detailList.add(detail);
            }
        }

        return detailList;
    }

    private static List<FileDetail> convertFileDetailList(List<ContentDocumentLink> cdlList) {

        List<FileDetail> fileList = new List<FileDetail>();

        for (ContentDocumentLink cdl : cdlList) {
            if (cdl.ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c == '認定通知'
                || cdl.ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c == '認定却下通知'
                || cdl.ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c == '受給資格消滅通知'
                || cdl.ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c == '支給認定取消通知'
            ) {
                FileDetail file = new FileDetail();
                file.contentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
                file.fileName = cdl.ContentDocument.LatestPublishedVersion.Title +'.'+ cdl.ContentDocument.LatestPublishedVersion.FileExtension;
                file.syubetsu = cdl.ContentDocument.LatestPublishedVersion.ChohyoShutsuryokuShubetsu__c;
                fileList.add(file);
            }
        }

        return fileList;
    }

    public class taishoJidoWrapper{
        @AuraEnabled public List<jidoDetail> taishoJidoList {get; set;}
    }
    public class jidoDetail{
        @AuraEnabled public String parentId {get; set;}
        @AuraEnabled public String shimei {get; set;}
        @AuraEnabled public String shoninKekka {get; set;}
        @AuraEnabled public String ninteiTsuchishoHakkoDate {get; set;}
        @AuraEnabled public Boolean isDownload {get; set;}
        @AuraEnabled public Boolean isNintei {get; set;}
        @AuraEnabled public Boolean isNotShometsu {get; set;}
        @AuraEnabled public List<FileDetail> fileList {get; set;}
    }

    public class fileDetail{
        @AuraEnabled public String contentVersionId {get; set;}
        @AuraEnabled public String fileName {get; set;}
        @AuraEnabled public String syubetsu {get; set;}
        @AuraEnabled public String getLabel() {
            return '【' + syubetsu + '】' + fileName;
        }
    }

}