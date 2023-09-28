public with sharing class ExHonninKakuninController {

    private static String siteMode = ExLwcUtil.getSiteMode();

    @TestVisible private static final List<ApprovedByOption> APPROVED_BY_OPTIONS = new List<ApprovedByOption>{
        // 公的個人認証はDVでは不使用
        new ApprovedByOption('マイナンバーカードによる申請（公的個人認証）', '公的個人認証', siteMode == ExLwcUtil.MODE_IPPAN || siteMode == ExLwcUtil.MODE_SATOYA),
        new ApprovedByOption('その他の本人確認書類による申請（本人確認書類アップロード）', '券面アップロード')
    };

    @AuraEnabled(cacheable=false)
    public static HonninKakuninWrapper getHonninKakunin(String recordId) {
        HonninKakuninWrapper wrapper = new HonninKakuninWrapper();

        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            List<NinteiSeikyu__c> seikyuList = [
                SELECT
                    Id,
                    Seikyusha__r.HonninKakuninHoho__c,
                    Seikyusha__r.ShinsaKekkaSaishu__c
                FROM
                    NinteiSeikyu__c
                WHERE
                    Id = :recordId
            ];
            NinteiSeikyu__c seikyu = seikyuList.get(0);

            wrapper.approvedBy = seikyu.Seikyusha__r.HonninKakuninHoho__c;
            if (
                wrapper.approvedBy == APPROVED_BY_OPTIONS[0].value
                || wrapper.approvedBy ==  APPROVED_BY_OPTIONS[1].value
            ){ // 本人確認済
                wrapper.hasApproved = true;
            }else{ // 未確認
                // 初期値をセット
                wrapper.approvedBy = APPROVED_BY_OPTIONS[0].value;
            }
            wrapper.validShinsaKekka = seikyu.Seikyusha__r.ShinsaKekkaSaishu__c != 'OK' && seikyu.Seikyusha__r.ShinsaKekkaSaishu__c != 'NG';

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV・里親
            List<DV_NinteiSeikyu__c> seikyuList = [
                SELECT
                    Id,
                    Seikyusya__r.HonninKakuninHoho__c,
                    Seikyusya__r.ShinsaKekkaSaishu__c
                FROM
                    DV_NinteiSeikyu__c
                WHERE
                    Id = :recordId
                AND
                    RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
            ];
            DV_NinteiSeikyu__c seikyu = seikyuList.get(0);

            wrapper.approvedBy = seikyu.Seikyusya__r.HonninKakuninHoho__c;
            if (
                wrapper.approvedBy == APPROVED_BY_OPTIONS[0].value
                || wrapper.approvedBy ==  APPROVED_BY_OPTIONS[1].value
            ){ // 本人確認済
                wrapper.hasApproved = true;
            }else{ // 未確認
                // 初期値をセット
                wrapper.approvedBy = APPROVED_BY_OPTIONS[0].isAvailable ? APPROVED_BY_OPTIONS[0].value : APPROVED_BY_OPTIONS[1].value;
            }
            wrapper.validShinsaKekka = seikyu.Seikyusya__r.ShinsaKekkaSaishu__c != 'OK' && seikyu.Seikyusya__r.ShinsaKekkaSaishu__c != 'NG';
        }

        return wrapper;
    }

    /**
     * @description 請求者の本人確認方法をクリア
     */ 
    @AuraEnabled(cacheable=false)
    public static void clearHonninKakunin(String recordId){
        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            NinteiSeikyu__c seikyu = [
                SELECT
                    Id,
                    Seikyusha__c
                FROM
                    NinteiSeikyu__c
                WHERE
                    Id = :recordId
                LIMIT 1
            ];

            update new Seikyusha__c(
                Id = seikyu.Seikyusha__c,
                HonninKakuninHoho__c = null
            );

        }else if(siteMode == ExLwcUtil.MODE_DV || siteMode == ExLwcUtil.MODE_SATOYA){ // DV・里親
            DV_NinteiSeikyu__c seikyu = [
                SELECT
                    Id,
                    Seikyusya__c
                FROM
                    DV_NinteiSeikyu__c
                WHERE
                    Id = :recordId
                AND
                    RecordTypeId = :ExLwcUtil.getSeikyuRecordTypeId()
            ];

            update new DV_Seikyusha__c(
                Id = seikyu.Seikyusya__c,
                HonninKakuninHoho__c = null
            );
        }
    }

    public class HonninKakuninWrapper {
        @AuraEnabled public List<ApprovedByOption> approvedByOptions {get; set;}

        @AuraEnabled public String approvedBy {get; set;}
        @AuraEnabled public Boolean hasApproved {get; set;}
        @AuraEnabled public Boolean validShinsaKekka {get; set;}

        public HonninKakuninWrapper(){
            this.approvedByOptions = APPROVED_BY_OPTIONS;

            this.hasApproved = false;
        }
    }

    public class ApprovedByOption {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean isAvailable {get; set;}

        public ApprovedByOption(String label, String value){
            this.label = label;
            this.value = value;
            this.isAvailable = true;
        }

        public ApprovedByOption(String label, String value, Boolean isAvailable){
            this.label = label;
            this.value = value;
            this.isAvailable = isAvailable;
        }
    }
}