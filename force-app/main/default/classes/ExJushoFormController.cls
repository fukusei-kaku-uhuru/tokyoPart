public without sharing class ExJushoFormController {

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAddressByPostalcode(String postalCode){
        try {

            // キャッシュされているデータでヒットするかチェック
            List<YubinBango__c> ybList = [  select
                                                Id
                                                ,TodofukenKanji__c
                                                ,Gun1__c
                                                ,Gun2__c
                                                ,ShikuchosonKanji__c
                                                ,ChoBanchi1__c
                                                ,ChoBanchi2__c
                                                ,ChoBanchi3__c
                                                ,ChoBanchi4__c
                                                ,ChoBanchi5__c
                                                ,ChoBanchi6__c
                                            from YubinBango__c
                                            where YubinBango8__c = :postalCode
                                            limit 1
            ];

            // キャッシュ済であれば、取得できたデータを返す
            if (ybList.size() == 1) {
                return convertReturnData(ybList[0]);
            }

            // リクエストを作成
            GoogleApiKey__mdt apiKey = GoogleApiKey__mdt.getInstance('ApiKey');
            String endpoint =   'https://maps.googleapis.com/maps/api/geocode/json?address=' + postalCode
                                + '&language=ja&components=country:JP&key=' + apiKey.MasterLabel;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');

            // リクエストを送信
            Http http = new Http();
            HttpResponse res = http.send(req);

            // 受信結果を取り出す
            String jsonStr = res.getBody();
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            List<Object> results = (List<Object>)jsonMap.get('results');
            Map<String, Object> resultItem = (Map<String, Object>)results[0];
            List<Object> addressComponents = (List<Object>)resultItem.get('address_components');

            // 郵便番号オブジェクトに設定する
            YubinBango__c yb = convertJushoData(addressComponents);
            // 郵便番号が設定されていない場合、検索エラー
            if (String.isEmpty(yb.YubinBango8__c)) {
                throw new AuraHandledException('');
            }

            // 取得した住所情報をキャッシュ
            insert yb;

            // LWC用に整形した値を返す
            return convertReturnData(yb);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Responseの値をキャッシュする値に変換する
     */
    private static YubinBango__c convertJushoData(List<Object> addressComponents) {

        YubinBango__c yb = new YubinBango__c();

        // 都道府県、市区町村等の項目ごとのリストになっているため、ループで取得
        for(Object addressComponentObj : addressComponents){
            Map<String, Object> addressComponentJson = (Map<String, Object>)addressComponentObj;
            List<Object> types = (List<Object>)addressComponentJson.get('types');

            Boolean isPostalCode = false;
            Boolean isPolitical = false;
            Boolean isAdministrativeAreaLevel1 = false;
            Boolean isAdministrativeAreaLevel2 = false;
            Boolean isAdministrativeAreaLevel3 = false;
            Boolean isLocality = false;
            Boolean isSublocalityLevel1 = false;
            Boolean isSublocalityLevel2 = false;
            Boolean isSublocalityLevel3 = false;
            Boolean isSublocalityLevel4 = false;
            Boolean isSublocalityLevel5 = false;
            Boolean isPremise = false;

            // typeの一覧を確認 politicalな情報のみ保存する
            for(Object typeObj : types){
                String value = (String)typeObj;
                if(value.equals('postal_code')){ isPostalCode = true;}
                if(value.equals('political')){ isPolitical = true;}
                if(value.equals('administrative_area_level_1')){ isAdministrativeAreaLevel1 = true;}
                if(value.equals('administrative_area_level_2')){ isAdministrativeAreaLevel2 = true;}
                if(value.equals('administrative_area_level_3')){ isAdministrativeAreaLevel3 = true;}
                if(value.equals('locality')){ isLocality = true;}
                if(value.equals('sublocality_level_1')){ isSublocalityLevel1 = true;}
                if(value.equals('sublocality_level_2')){ isSublocalityLevel2 = true;}
                if(value.equals('sublocality_level_3')){ isSublocalityLevel3 = true;}
                if(value.equals('sublocality_level_4')){ isSublocalityLevel4 = true;}
                if(value.equals('sublocality_level_5')){ isSublocalityLevel5 = true;}
                if(value.equals('premise')){ isPremise = true;}
            }

            if(isPostalCode){ yb.YubinBango8__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isAdministrativeAreaLevel1){ yb.TodofukenKanji__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isAdministrativeAreaLevel2){ yb.Gun1__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isAdministrativeAreaLevel3){ yb.Gun2__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isLocality){ yb.ShikuchosonKanji__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isSublocalityLevel1){ yb.ChoBanchi1__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isSublocalityLevel2){ yb.ChoBanchi2__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isSublocalityLevel3){ yb.ChoBanchi3__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isSublocalityLevel4){ yb.ChoBanchi4__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isSublocalityLevel5){ yb.ChoBanchi5__c = (String)addressComponentJson.get('long_name');}
            if(isPolitical && isPremise){ yb.ChoBanchi6__c = (String)addressComponentJson.get('long_name');}
        }

        return yb;
    }

    /**
     * LWC用に値を整形する
     */
    private static Map<String, String> convertReturnData(YubinBango__c yb) {
        Map<String, String> returnMap = new Map<String, String>();

        // 都道府県
        returnMap.put('todoFuken', yb.TodofukenKanji__c);

        // 市区町村
        String shikuChoson = '';
        if (String.isNotEmpty(yb.Gun1__c)) { shikuChoson += yb.Gun1__c; }
        if (String.isNotEmpty(yb.Gun2__c)) { shikuChoson += yb.Gun2__c; }
        shikuChoson += yb.ShikuchosonKanji__c;
        returnMap.put('shikuChoson', shikuChoson);

        // 町名番地
        String chiban = '';
        if (String.isNotEmpty(yb.ChoBanchi1__c)){ chiban += yb.ChoBanchi1__c; }
        if (String.isNotEmpty(yb.ChoBanchi2__c)){ chiban += yb.ChoBanchi2__c; }
        if (String.isNotEmpty(yb.ChoBanchi3__c)){ chiban += yb.ChoBanchi3__c; }
        if (String.isNotEmpty(yb.ChoBanchi4__c)){ chiban += yb.ChoBanchi4__c; }
        if (String.isNotEmpty(yb.ChoBanchi5__c)){ chiban += yb.ChoBanchi5__c; }
        if (String.isNotEmpty(yb.ChoBanchi6__c)){ chiban += yb.ChoBanchi6__c; }
        returnMap.put('chiban', chiban);

        return returnMap;
    }
}