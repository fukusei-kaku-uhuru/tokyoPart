public with sharing class ExKozaFormController {

    public class KozaFormWrapper {
        @AuraEnabled public final String GINKOKUBUN_YUCHO = 'yucho';
        @AuraEnabled public final String GINKOKUBUN_OTHER = 'other';
        @AuraEnabled public final String SHUMOKU_FUTSU = 'futsu'; // 01
        @AuraEnabled public final String SHUMOKU_TOZA = 'toza'; // 02
        @AuraEnabled public final String SHUMOKU_TYOCHIKU = 's_tyochiku'; // 03
        @AuraEnabled public final String YUCHO_SHUMOKU_SOGO = 'sogo'; // 01
        @AuraEnabled public final String YUCHO_SHUMOKU_TSUJYO = 'tsujyo'; // 02
        @AuraEnabled public final String YUCHO_SHUMOKU_TYOCHIKU = 'y_tyochiku'; // 03
        @AuraEnabled public final String YUCHO_SHUMOKU_FURIKAE = 'furikae'; // 04

        @AuraEnabled public String GinkoKubun {get;set;}
        @AuraEnabled public String YuchoBunrui {get;set;}
        @AuraEnabled public String YuchoKigo {get;set;}
        @AuraEnabled public String YuchoBango {get;set;}
        @AuraEnabled public String YuchoKouzaMeigi {get;set;}
        @AuraEnabled public String KinyuKikan {get;set;}
        @AuraEnabled public String KinyuKikanDispName {get;set;}
        @AuraEnabled public String Shiten {get;set;}
        @AuraEnabled public String ShitenDispName {get;set;}
        @AuraEnabled public String Bunrui {get;set;}
        @AuraEnabled public String KouzaBangou {get;set;}
        @AuraEnabled public String KouzaMeigi {get;set;}

        public Boolean isInputYucho() {
            return (
                GinkoKubun == GINKOKUBUN_YUCHO
                && (
                    String.isNotEmpty(YuchoBunrui)
                    || String.isNotEmpty(YuchoKigo)
                    || String.isNotEmpty(YuchoBango)
                    || String.isNotBlank(YuchoKouzaMeigi)
                )
            );
        }

        public Boolean isInputOther() {
            return (
                GinkoKubun == GINKOKUBUN_OTHER
                && (
                    String.isNotEmpty(KinyuKikan)
                    || String.isNotEmpty(Shiten)
                    || String.isNotEmpty(Bunrui)
                    || String.isNotEmpty(KouzaBangou)
                    || String.isNotBlank(KouzaMeigi)
                )
            );
        }
    }
}