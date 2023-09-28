@isTest
global class MockGoogleGeoCode implements HttpCalloutMock {

    public Boolean isSuccess {get;set;}
    public YubinBango__c yb {get;set;}

    public MockGoogleGeoCode(Boolean isSuccess, YubinBango__c yb) {
        this.isSuccess = isSuccess;
        this.yb = yb;
    }

    /**
     * 郵便番号オブジェクトをJSONに変更
     */
    private List<Map<String, Object>> convertYbToAddressComponents() {

        List<Map<String, Object>> addressComponents = new List<Map<String, Object>>();
        addressComponents.add(new Map<String, Object>{
            'long_name' => yb.YubinBango8__c
            ,'types' => new List<String>{'postal_code'}
        });
        if (String.isNotEmpty(yb.TodofukenKanji__c)) {
            addressComponents.add(new Map<String, Object>{
                'long_name' => yb.TodofukenKanji__c
                ,'types' => new List<String>{'administrative_area_level_1', 'political'}
            });
        }
        if (String.isNotEmpty(yb.Gun1__c)) {
            addressComponents.add(new Map<String, Object>{
                'long_name' => yb.Gun1__c
                ,'types' => new List<String>{'administrative_area_level_2', 'political'}
            });
        }
        if (String.isNotEmpty(yb.Gun2__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.Gun2__c
            ,'types' => new List<String>{'administrative_area_level_3', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ShikuchosonKanji__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ShikuchosonKanji__c
            ,'types' => new List<String>{'locality', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ChoBanchi1__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ChoBanchi1__c
            ,'types' => new List<String>{'sublocality_level_1', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ChoBanchi2__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ChoBanchi2__c
            ,'types' => new List<String>{'sublocality_level_2', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ChoBanchi3__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ChoBanchi3__c
            ,'types' => new List<String>{'sublocality_level_3', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ChoBanchi4__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ChoBanchi4__c
            ,'types' => new List<String>{'sublocality_level_4', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ChoBanchi5__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ChoBanchi5__c
            ,'types' => new List<String>{'sublocality_level_5', 'political'}
            });
        }
        if (String.isNotEmpty(yb.ChoBanchi6__c)) {
            addressComponents.add(new Map<String, Object>{
            'long_name' => yb.ChoBanchi6__c
            ,'types' => new List<String>{'premise', 'political'}
            });
        }

        return addressComponents;
    }

    /**
     * 住所データJSONを更に包む
     */
    private String getJsonBody() {
        Map<String, Object> resultItem = new Map<String, Object>();
        resultItem.put('address_components', convertYbToAddressComponents());
        List<Object> results = new List<Object>{resultItem};
        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('results', results);
        return JSON.serialize(jsonMap);
    }

    /**
     * モックレスポンスを返す
     */
    global HTTPResponse respond(HTTPRequest req) {

        if (!isSuccess) {
            throw new System.CalloutException('住所検索エラー');
        }

        // HTTPResponseオブジェクトを作成し、適切なステータスコードやレスポンスボディを設定します
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody(getJsonBody());
        return res;
    }
}