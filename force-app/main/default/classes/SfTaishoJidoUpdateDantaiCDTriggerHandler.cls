public without sharing class SfTaishoJidoUpdateDantaiCDTriggerHandler {
    
    public void beforeUpdate(Map<Id, TaishoJido__c> newTaishoJidoMap, Map<Id, TaishoJido__c> oldTaishoJidoMap) {
        // 地方公共団体コードを更新
        updateChihouKoukyouDantaiCode(newTaishoJidoMap, oldTaishoJidoMap);
    }

    /**
     * 地方公共団体コードを更新
     */
    public void updateChihouKoukyouDantaiCode(Map<Id, TaishoJido__c> newTaishoJidoMap, Map<Id, TaishoJido__c> oldTaishoJidoMap) {
        System.debug('対象児童の地方公共団体コードを更新');
        List<id> differentJushoIdList = new List<id>();
        List<TaishoJido__c> differentJushoTaishoJidoList = new List<TaishoJido__c>();

        // 住所が変更した対象児童レコードを洗い出す
        for (Id recordId : newTaishoJidoMap.keySet()) {
            TaishoJido__c newTaishoJido = newTaishoJidoMap.get(recordId);
            TaishoJido__c oldTaishoJido = oldTaishoJidoMap.get(recordId);
            if (newTaishoJido.Jusho__c != oldTaishoJido.Jusho__c) {
                differentJushoIdList.add(newTaishoJido.id);
                differentJushoTaishoJidoList.add(newTaishoJido);
            }
        }
        // 東京都の地方公共団体コードリスト取得
        List<ChihoKokyoDantai__c> tokyoDantaiList = [select TodofukenKanji__c,ShikuchosonKanji__c,DantaiCode__c
                                                       from ChihoKokyoDantai__c
                                                      where TodofukenKanji__c = '東京都'];                                      
       
        for(TaishoJido__c TaishoJido : differentJushoTaishoJidoList){
            Boolean isRealAddress = false;
            for (ChihoKokyoDantai__c tokyoDantai : tokyoDantaiList) {
                String DantaiAddress = tokyoDantai.TodofukenKanji__c+tokyoDantai.ShikuchosonKanji__c;
                if(String.isNotEmpty(TaishoJido.Jusho__c) && TaishoJido.Jusho__c.startsWith(DantaiAddress)){
                    TaishoJido.ChihouKoukyouDantaiCode__c = tokyoDantai.DantaiCode__c;
                    isRealAddress = true;
                }
            }
            if(!isRealAddress){
                // 変更後の住所が存在しない場合、地方公共団体コードをクリアする
                TaishoJido.ChihouKoukyouDantaiCode__c = null;
            }            
        }
    }
}