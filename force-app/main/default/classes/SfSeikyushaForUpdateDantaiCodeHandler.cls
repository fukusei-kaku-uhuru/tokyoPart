public without sharing class SfSeikyushaForUpdateDantaiCodeHandler {
    /**
     * 認定請求の地方公共団体コードを更新
     */
    public void updateChihouKoukyouDantaiCode(Map<Id, Seikyusha__c> newSeikyushaMap, Map<Id, Seikyusha__c> oldSeikyushaMap) {
        System.debug('認定請求の地方公共団体コードを更新');
        List<id> differentJushoIdList = new List<id>();
        List<Seikyusha__c> differentJushoSeikyushaList = new List<Seikyusha__c>();

        // 住所が変更した請求者レコードを洗い出す
        for (Id recordId : newSeikyushaMap.keySet()) {
            Seikyusha__c newSeikyusha = newSeikyushaMap.get(recordId);
            Seikyusha__c oldSeikyusha = oldSeikyushaMap.get(recordId);
            if (newSeikyusha.Jusho__c != oldSeikyusha.Jusho__c) {
                differentJushoIdList.add(newSeikyusha.id);
                differentJushoSeikyushaList.add(newSeikyusha);
            }
        }
        System.debug(differentJushoIdList);
        System.debug(differentJushoSeikyushaList);
        // 住所が変更した認定請求レコードを取得する
        List<NinteiSeikyu__c> ninteiSeikyuUpdateList= [select id,ChihouKoukyouDantaiCode__c,Seikyusha__c 
                                   from NinteiSeikyu__c 
                                  where Seikyusha__c in: differentJushoIdList];
        Map<Id,NinteiSeikyu__c> ninteiSeikyuUpdateMap = new Map<Id,NinteiSeikyu__c>();
        if(ninteiSeikyuUpdateList.size() > 0){
            for(NinteiSeikyu__c ninteiSeikyu : ninteiSeikyuUpdateList){
                ninteiSeikyuUpdateMap.put(ninteiSeikyu.Seikyusha__c , ninteiSeikyu);
            }    
        }
        System.debug(ninteiSeikyuUpdateList);
        System.debug(ninteiSeikyuUpdateMap);
        // 東京都の地方公共団体コードリスト取得
        List<ChihoKokyoDantai__c> tokyoDantaiList = [select TodofukenKanji__c,ShikuchosonKanji__c,DantaiCode__c
                                                       from ChihoKokyoDantai__c
                                                      where TodofukenKanji__c = '東京都'];
        System.debug(tokyoDantaiList);                                         
        System.debug(differentJushoSeikyushaList);    

        for(Seikyusha__c seikyusha : differentJushoSeikyushaList){
            Boolean isRealAddress = false;
            for (ChihoKokyoDantai__c tokyoDantai : tokyoDantaiList) {
                String DantaiAddress = tokyoDantai.TodofukenKanji__c+tokyoDantai.ShikuchosonKanji__c;
                System.debug(DantaiAddress);
                if(String.isNotEmpty(seikyusha.Jusho__c) && seikyusha.Jusho__c.startsWith(DantaiAddress)){
                    System.debug('一致する');
                    System.debug(tokyoDantai.DantaiCode__c);
                    ninteiSeikyuUpdateMap.get(seikyusha.id).ChihouKoukyouDantaiCode__c = tokyoDantai.DantaiCode__c;
                    isRealAddress = true;
                }
            }
            System.debug(isRealAddress);
            if(!isRealAddress){
                System.debug('変更後の住所が存在しない');
                // 変更後の住所が存在しない場合、地方公共団体コードをクリアする
                ninteiSeikyuUpdateMap.get(seikyusha.id).ChihouKoukyouDantaiCode__c = null;
            }    
        }
        for(NinteiSeikyu__c n :ninteiSeikyuUpdateList){
           System.debug(n.ChihouKoukyouDantaiCode__c) ;
        }
        update ninteiSeikyuUpdateList;
    }
}