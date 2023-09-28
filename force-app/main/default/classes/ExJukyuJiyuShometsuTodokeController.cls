public with sharing class ExJukyuJiyuShometsuTodokeController {
    
    @AuraEnabled(cacheable=false)
    public static String getSiteMode() {
        
        String siteMode = ExLwcUtil.getSiteMode();
        system.debug('siteMOde:'+siteMode);
        if(siteMode == ExLwcUtil.MODE_IPPAN){ // 一般
            return '一般';
        }else if(siteMode == ExLwcUtil.MODE_DV){ // DV OR 里親
            return 'DV';
        }else if(siteMode == ExLwcUtil.MODE_SATOYA){ // DV OR 里親
            return '里親';
        }

        return '';

    }
}