public with sharing class ExMyNumberController {
    
    private static Boolean isGeneral = ExLwcUtil.getSiteMode() == ExLwcUtil.MODE_IPPAN;

    private static Map<String, String> errorMessageMap = new Map<String, String>{
        'wrong_document' => System.Label.EX_KKN2_WRONG_DOCUMENT,
        'blurred' => System.Label.EX_KKN2_BLURRED,
        'partly_hidden' => System.Label.EX_KKN2_PARTLY_HIDDEN,
        'missing_issuer' => System.Label.EX_KKN2_MISSING_ISSUER,
        'missing_address' => System.Label.EX_KKN2_MISSING_ADDRESS,
        'expired' => System.Label.EX_KKN2_EXPIRED,
        'contains_individual_number' => System.Label.EX_KKN2_CONTAINS_INDIVIDUAL_NUMBER,
        'address_is_not_specified' => System.Label.EX_KKN2_ADDRESS_IS_NOT_SPECIFIED,
        'copy_or_scanned_data' => System.Label.EX_KKN2_COPY_OR_SCANNED_DATA,
        'out_of_frame' => System.Label.EX_KKN2_OUT_OF_FRAME,
        'missing_thickness' => System.Label.EX_KKN2_MISSING_THICKNESS,
        'other' => System.Label.EX_KKN2_OTHER
    };

    public class ResponseWrapper{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public Map<String, String> resultMap;
    }

    public static final Trustdock__mdt apiinfo;
    static{
        // TRUSTUDOCKのAPI情報（カスタムメタデータ）取得
        apiInfo = Trustdock__mdt.getAll().values().get(0);
    }

    @AuraEnabled
    public static ResponseWrapper doInit(String ninteiId){
        
        // 請求者のTRUSTDOCKに関する情報をクリア
        if(isGeneral){
            String seikyushaId = getSeikyushaId(ninteiId);
            update new Seikyusha__c(
                Id = seikyushaId,
                TrustdocErrorMessage__c = null,
                TrustdocKekka__c = null,
                TrustdocPhase__c = null
            );
        }
        else{
            String seikyushaId = getSeikyushaId_DV(ninteiId);
            update new DV_Seikyusha__c(
                Id = seikyushaId,
                TrustdocErrorMessage__c = null,
                TrustdocKekka__c = null,
                TrustdocPhase__c = null
            );
        }

        // コミュニティサイトのオリジンをセット（LWCとiframe内のVFとの通信に必要）
        ResponseWrapper result = new ResponseWrapper();
        result.isSuccess = true;
        result.resultMap = new Map<String, String>{
            'prefix' => Site.getPathPrefix().removeEnd('/s')
        };
        return result;
    }

    @AuraEnabled
    public static ResponseWrapper executeTrustdockUploader(String ninteiId){
        String seikyushaId = isGeneral ? getSeikyushaId(ninteiId) : getSeikyushaId_DV(ninteiId);

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(apiInfo.ApiEndpoint__c + '/verifications');

        request.setMethod('POST');

        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + apiInfo.ApiToken__c);

        // リクエストボディ構築
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('external_id', seikyushaId);

        request.setBody(JSON.serialize(bodyMap));

        // 身元確認依頼API実行
        HttpResponse response = http.send(request);

        // 結果をセット
        ResponseWrapper resultInfo =  new ResponseWrapper();
        // ステータスコード202：Acceptedでない場合、エラー
        if(response.getStatusCode() != 202) {
            resultInfo.isSuccess = false;
            resultInfo.message = '身元確認の依頼APIで想定外のエラーが発生しました。';
            return resultInfo;
        }
        else {

            Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            // 署名対象元データAPI実行
            Boolean isSuccess = requestTbsData((String)body.get('id'));

            if(isSuccess){
                // 取得したid(身元確認ID), public-idを請求者OBJに保存
                if(isGeneral){
                    saveIdAndPid(ninteiId, body);
                }
                else{
                    saveIdAndPid_DV(ninteiId, body);
                }

                resultInfo.isSuccess = true;
                resultInfo.resultMap = new Map<String, String>{
                    'publicId' => (String)body.get('public_id')
                };
                return resultInfo;
            }
            resultInfo.isSuccess = false;
            resultInfo.message = '署名対象元データAPIで想定外のエラーが発生しました。';
            return resultInfo;
        }
    }

    /**
     * @description requestTbsData description
     * @param  id id description
     * @return    return description
     */
    private static Boolean requestTbsData(String id){
        system.debug('Id: ' + id);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiInfo.ApiEndpoint__c + '/verifications/' + id + '/tbs_raw_data');   

        request.setMethod('PUT');

        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + apiInfo.ApiToken__c);

        // リクエストボディ構築
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('value', apiInfo.TbsRawData__c);

        request.setBody(JSON.serialize(bodyMap));

        // API実行
        HttpResponse response = http.send(request);

        // ステータスコード204：No Contentでない場合、エラー
        if(response.getStatusCode() != 204) {
            return false;
        }
        return true;
    }

    /**
     * @description saveIdAndPid description
     * @param  ninteiId ninteiId description
     * @param  body     body description
     */
    private static void saveIdAndPid(String ninteiId, Map<String, Object> body){
        String seikyushaId = getSeikyushaId(ninteiId);

        Seikyusha__c seikyusha = [SELECT Id, TrustdocIdRireki__c FROM Seikyusha__c WHERE Id = :seikyushaId];

        String rireki;
        if(String.isBlank(seikyusha.TrustdocIdRireki__c)){
            rireki = (String)body.get('id');
        }
        else{
            rireki = seikyusha.TrustdocIdRireki__c + ',' + (String)body.get('id');
        }

        update new Seikyusha__c(
            Id = seikyusha.Id,
            TRUSTDOCPublicID__c = (String)body.get('public_id'),
            TRUSTDOCID__c = (String)body.get('id'),
            TrustdocIdRireki__c = rireki
        );
    }

    @AuraEnabled
    public static List<SeikyushaInfo> querySeikyusha(String ninteiId){
        List<SeikyushaInfo> infos = new List<SeikyushaInfo>();

        if(isGeneral){
            Id seikyushaId = getSeikyushaId(ninteiId);

            List<Seikyusha__c> seikyushas = [SELECT Id, TrustdocPhase__c, TrustdocKekka__c, TrustdocErrorMessage__c, TRUSTDOCID__c, TRUSTDOCPublicID__c 
                    FROM Seikyusha__c
                    WHERE Id =: seikyushaId
            ];

            if(!seikyushas.isEmpty()){
                infos.add(new SeikyushaInfo(seikyushas[0]));
            }
        }else{
            Id seikyushaId = getSeikyushaId_DV(ninteiId);

            List<DV_Seikyusha__c> seikyushas = [SELECT Id, TrustdocPhase__c, TrustdocKekka__c, TrustdocErrorMessage__c, TRUSTDOCID__c, TRUSTDOCPublicID__c 
                    FROM DV_Seikyusha__c
                    WHERE Id =: seikyushaId
            ];

            if(!seikyushas.isEmpty()){
                infos.add(new SeikyushaInfo(seikyushas[0]));
            }
        }

        return infos;
    }

    @AuraEnabled
    public static void updateSeikyusha(String recordId) {
        if(isGeneral){
            List<NinteiSeikyu__c> seikyuList = [SELECT Id,Seikyusha__c FROM NinteiSeikyu__c WHERE Id = :recordId];
            NinteiSeikyu__c seikyu = seikyuList.get(0);

            Seikyusha__c updateObj = new Seikyusha__c();
            updateObj.Id = seikyu.Seikyusha__c;
            updateObj.HonninKakuninHoho__c = '公的個人認証';
            update updateObj;
        }else{
            List<DV_NinteiSeikyu__c> seikyuList = [SELECT Id,Seikyusya__c FROM DV_NinteiSeikyu__c WHERE Id = :recordId];
            DV_NinteiSeikyu__c seikyu = seikyuList.get(0);

            DV_Seikyusha__c updateObj = new DV_Seikyusha__c();
            updateObj.Id = seikyu.Seikyusya__c;
            updateObj.HonninKakuninHoho__c = '公的個人認証';
            update updateObj;
        }

        return;
    }

    /**
     * @description getSeikyushaId description
     * @param  ninteiId ninteiId description
     * @return          return description
     */
    @TestVisible
    private static String getSeikyushaId(String ninteiId){
        List<NinteiSeikyu__c> ninteiseikyu = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c WHERE Id =:ninteiId];

        if(ninteiseikyu.size() == 0){
            return '';
        }

        return ninteiseikyu.get(0).Seikyusha__c;
    }

    /**
     * @description saveIdAndPid description
     * @param  ninteiId ninteiId description
     * @param  body     body description
     */
    private static void saveIdAndPid_DV(String ninteiId, Map<String, Object> body){
        String seikyushaId = getSeikyushaId_DV(ninteiId);

        DV_Seikyusha__c seikyusha = [SELECT Id, TrustdocIdRireki__c FROM DV_Seikyusha__c WHERE Id = :seikyushaId];

        String rireki;
        if(String.isBlank(seikyusha.TrustdocIdRireki__c)){
            rireki = (String)body.get('id');
        }
        else{
            rireki = seikyusha.TrustdocIdRireki__c + ',' + (String)body.get('id');
        }

        update new DV_Seikyusha__c(
            Id = seikyusha.Id,
            TRUSTDOCPublicID__c = (String)body.get('public_id'),
            TRUSTDOCID__c = (String)body.get('id'),
            TrustdocIdRireki__c = rireki
        );
    }

    /**
     * @description getSeikyushaId description
     * @param  ninteiId ninteiId description
     * @return          return description
     */
    @TestVisible
    private static String getSeikyushaId_DV(String ninteiId){
        List<DV_NinteiSeikyu__c> ninteiseikyu = [SELECT Id, Seikyusya__c FROM DV_NinteiSeikyu__c WHERE Id =:ninteiId];

        if(ninteiseikyu.size() == 0){
            return '';
        }

        return ninteiseikyu.get(0).Seikyusya__c;
    }

    /**
     * @description マイナンバー認証エラー画面から呼び出される
     * @param  ninteiId ninteiId description
     * @return          return description
     */
    @AuraEnabled
    public static String getErrorMessage(String ninteiId){
        String errorName;
        if(isGeneral){
            String seikyushaId = getSeikyushaId(ninteiId);
            errorName = [SELECT Id, Name, TrustdocErrorMessage__c FROM Seikyusha__c WHERE Id = :seikyushaId LIMIT 1].TrustdocErrorMessage__c;
        }
        else{
            String seikyushaId = getSeikyushaId_DV(ninteiId);
            errorName = [SELECT Id, Name, TrustdocErrorMessage__c FROM DV_Seikyusha__c WHERE Id = :seikyushaId LIMIT 1].TrustdocErrorMessage__c;
        }
        return errorMessageMap.get(errorName);
    }

    public class SeikyushaInfo{
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String trustdocPhase {get; set;}
        @AuraEnabled public String trustdocKekka {get; set;}
        @AuraEnabled public String trustdocErrorMessage {get; set;}
        @AuraEnabled public String trustdocId {get; set;}
        @AuraEnabled public String trustdocPublicId {get; set;}

        public SeikyushaInfo(Seikyusha__c seikyusha){
            this.id = seikyusha.Id;
            this.trustdocPhase = seikyusha.TrustdocPhase__c;
            this.trustdocKekka = seikyusha.TrustdocKekka__c;
            this.trustdocErrorMessage = seikyusha.TrustdocErrorMessage__c;
            this.trustdocId = seikyusha.TRUSTDOCID__c;
            this.trustdocPublicId = seikyusha.TRUSTDOCPublicID__c;
        }

        public SeikyushaInfo(DV_Seikyusha__c seikyusha){
            this.id = seikyusha.Id;
            this.trustdocPhase = seikyusha.TrustdocPhase__c;
            this.trustdocKekka = seikyusha.TrustdocKekka__c;
            this.trustdocErrorMessage = seikyusha.TrustdocErrorMessage__c;
            this.trustdocId = seikyusha.TRUSTDOCID__c;
            this.trustdocPublicId = seikyusha.TRUSTDOCPublicID__c;
        }
    }
}