@isTest
private class ExMyNumberControllerTest {

    @TestSetup
    private static void makeData(){
        Account acc1 = new Account(
            LastName = 'TestAccount_generalUser'
        );
        Account acc2 = new Account(
            LastName = 'TestAccount_dvUser'
        );
        insert new List<Account>{acc1, acc2};

        User generalUser = ExTestUtil.getGeneralUser('TestAccount_generalUser', acc1.Id);
        User dvUser = ExTestUtil.getDvUser('TestAccount_dvUser', acc2.Id);
        insert new List<User>{generalUser, dvUser};

        System.runAs(generalUser){
            Seikyusha__c seikyusha = new Seikyusha__c(
                TrustdocErrorMessage__c = 'wrong_document',
                TrustdocKekka__c = 'denied',
                TrustdocPhase__c = 'in_progress'
            );
            insert seikyusha;

            NinteiSeikyu__c nintei = new NinteiSeikyu__c(
                Seikyusha__c = seikyusha.Id
            );
            insert nintei;
        }

        System.runAs(dvUser){
            DV_Seikyusha__c dv_seikyusha = new DV_Seikyusha__c(
                TrustdocErrorMessage__c = 'wrong_document',
                TrustdocKekka__c = 'denied',
                TrustdocPhase__c = 'in_progress'
            );
            insert dv_seikyusha;

            DV_NinteiSeikyu__c dv_nintei = new DV_NinteiSeikyu__c(
                RecordTypeId = ExTestUtil.DV_SEIKYU_ID,
                Seikyusya__c = dv_seikyusha.Id
            );
            insert dv_nintei;
        }
    }

    @isTest
    private static void doInit(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];
        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        ExMyNumberController.ResponseWrapper result;
        System.runAs(generalUser){
            result = ExMyNumberController.doInit(nintei.Id);
        }

        Test.stopTest();

        Seikyusha__c seikyushaResult = [SELECT Id, TrustdocErrorMessage__c, TrustdocKekka__c, TrustdocPhase__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c];
        Assert.isTrue(result.isSuccess);
        Assert.isTrue(result.resultMap.containsKey('prefix'));
        Assert.areEqual(null, seikyushaResult.TrustdocErrorMessage__c);
        Assert.areEqual(null, seikyushaResult.TrustdocKekka__c);
        Assert.areEqual(null, seikyushaResult.TrustdocPhase__c);
    }

    @isTest
    private static void executeTrustdockUploader_success1(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
        update new Seikyusha__c(
            Id = nintei.Seikyusha__c,
            TrustdocIdRireki__c = 'previousId'
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Success());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(generalUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c];
        Assert.isTrue(result.isSuccess);
        Assert.areEqual('sample-public-id', result.resultMap.get('publicId'));
        Assert.areEqual('sample-secret-id', seikyusha.TRUSTDOCID__c);
        Assert.areEqual('sample-public-id', seikyusha.TRUSTDOCPublicID__c);
        Assert.areEqual('previousId,sample-secret-id', seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void executeTrustdockUploader_success2(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Success());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(generalUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c];
        Assert.isTrue(result.isSuccess);
        Assert.areEqual('sample-secret-id', seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void executeTrustdockUploader_fail1(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Fail1());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(generalUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c];
        Assert.isFalse(result.isSuccess);
        Assert.areEqual('身元確認の依頼APIで想定外のエラーが発生しました。', result.message);
        Assert.areEqual(null, result.resultMap);
        Assert.areEqual(null, seikyusha.TRUSTDOCID__c);
        Assert.areEqual(null, seikyusha.TRUSTDOCPublicID__c);
        Assert.areEqual(null, seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void executeTrustdockUploader_fail2(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Fail2());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(generalUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c];
        Assert.isFalse(result.isSuccess);
        Assert.areEqual('署名対象元データAPIで想定外のエラーが発生しました。', result.message);
        Assert.areEqual(null, result.resultMap);
        Assert.areEqual(null, seikyusha.TRUSTDOCID__c);
        Assert.areEqual(null, seikyusha.TRUSTDOCPublicID__c);
        Assert.areEqual(null, seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void querySeikyusha(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        List<ExMyNumberController.SeikyushaInfo> seikyusha;
        System.runAs(generalUser){
            seikyusha = ExMyNumberController.querySeikyusha(nintei.Id);
        }

        Test.stopTest();
        
        Assert.isFalse(seikyusha.isEmpty());
    }

    @isTest
    private static void getSeikyushaId(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        String seikyushaId;
        System.runAs(generalUser){
            seikyushaId = ExMyNumberController.getSeikyushaId(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(nintei.Seikyusha__c, seikyushaId);
    }

    @isTest
    private static void getSeikyushaId_null(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];
        delete nintei;

        Test.startTest();
        String seikyushaId;
        System.runAs(generalUser){
            seikyushaId = ExMyNumberController.getSeikyushaId(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual('', seikyushaId);
    }

    @isTest
    private static void updateSeikyusha(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Test.startTest();
        System.runAs(generalUser){
            ExMyNumberController.updateSeikyusha(nintei.Id);
        }

        Test.stopTest();

        Seikyusha__c seikyusha = [SELECT Id, HonninKakuninHoho__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c LIMIT 1];
        Assert.areEqual('公的個人認証', seikyusha.HonninKakuninHoho__c);
    }

    @isTest
    private static void getErrorMessage(){
        User generalUser = [SELECT Id FROM User WHERE Name = 'TestAccount_generalUser'];

        Ninteiseikyu__c nintei = [SELECT Id, Seikyusha__c FROM NinteiSeikyu__c LIMIT 1];

        Seikyusha__c seikyusha = [SELECT Id, TrustdocErrorMessage__c FROM Seikyusha__c WHERE Id = :nintei.Seikyusha__c];
        seikyusha.TrustdocErrorMessage__c = 'wrong_document';
        update seikyusha;
        
        String errorMessage;
        Test.startTest();
        System.runAs(generalUser){
            errorMessage = ExMyNumberController.getErrorMessage(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(System.Label.EX_KKN2_WRONG_DOCUMENT, errorMessage);
    }

    /*
     * DV・里親対応テストクラス↓
     */

    @isTest
    private static void doInit_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];
        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        ExMyNumberController.ResponseWrapper result;
        System.runAs(dvUser){
            result = ExMyNumberController.doInit(nintei.Id);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyushaResult = [SELECT Id, TrustdocErrorMessage__c, TrustdocKekka__c, TrustdocPhase__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c];
        Assert.isTrue(result.isSuccess);
        Assert.isTrue(result.resultMap.containsKey('prefix'));
        Assert.areEqual(null, seikyushaResult.TrustdocErrorMessage__c);
        Assert.areEqual(null, seikyushaResult.TrustdocKekka__c);
        Assert.areEqual(null, seikyushaResult.TrustdocPhase__c);
    }

    @isTest
    private static void executeTrustdockUploader_success1_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];
        update new DV_Seikyusha__c(
            Id = nintei.Seikyusya__c,
            TrustdocIdRireki__c = 'previousId'
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Success());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(dvUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        DV_Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c];
        Assert.isTrue(result.isSuccess);
        Assert.areEqual('sample-public-id', result.resultMap.get('publicId'));
        Assert.areEqual('sample-secret-id', seikyusha.TRUSTDOCID__c);
        Assert.areEqual('sample-public-id', seikyusha.TRUSTDOCPublicID__c);
        Assert.areEqual('previousId,sample-secret-id', seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void executeTrustdockUploader_success2_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Success());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(dvUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        DV_Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c];
        Assert.isTrue(result.isSuccess);
        Assert.areEqual('sample-secret-id', seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void executeTrustdockUploader_fail1_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Fail1());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(dvUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        DV_Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c];
        Assert.isFalse(result.isSuccess);
        Assert.areEqual('身元確認の依頼APIで想定外のエラーが発生しました。', result.message);
        Assert.areEqual(null, result.resultMap);
        Assert.areEqual(null, seikyusha.TRUSTDOCID__c);
        Assert.areEqual(null, seikyusha.TRUSTDOCPublicID__c);
        Assert.areEqual(null, seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void executeTrustdockUploader_fail2_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrustdockMock_Fail2());
        ExMyNumberController.ResponseWrapper result;
        System.runAs(dvUser){
            result = ExMyNumberController.executeTrustdockUploader(nintei.Id); 
        }
        
        Test.stopTest();

        DV_Seikyusha__c seikyusha = [SELECT Id, TRUSTDOCPublicID__c, TRUSTDOCID__c, TrustdocIdRireki__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c];
        Assert.isFalse(result.isSuccess);
        Assert.areEqual('署名対象元データAPIで想定外のエラーが発生しました。', result.message);
        Assert.areEqual(null, result.resultMap);
        Assert.areEqual(null, seikyusha.TRUSTDOCID__c);
        Assert.areEqual(null, seikyusha.TRUSTDOCPublicID__c);
        Assert.areEqual(null, seikyusha.TrustdocIdRireki__c);
    }

    @isTest
    private static void querySeikyusha_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        List<ExMyNumberController.SeikyushaInfo> seikyusha;
        System.runAs(dvUser){
            seikyusha = ExMyNumberController.querySeikyusha(nintei.Id);
        }

        Test.stopTest();
        
        Assert.isFalse(seikyusha.isEmpty());
    }

    @isTest
    private static void getSeikyushaId_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        String seikyushaId;
        System.runAs(dvUser){
            seikyushaId = ExMyNumberController.getSeikyushaId_DV(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(nintei.Seikyusya__c, seikyushaId);
    }

    @isTest
    private static void getSeikyushaId_DV_null(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];
        delete nintei;

        Test.startTest();
        String seikyushaId;
        System.runAs(dvUser){
            seikyushaId = ExMyNumberController.getSeikyushaId_DV(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual('', seikyushaId);
    }

    @isTest
    private static void updateSeikyusha_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        Test.startTest();
        System.runAs(dvUser){
            ExMyNumberController.updateSeikyusha(nintei.Id);
        }

        Test.stopTest();

        DV_Seikyusha__c seikyusha = [SELECT Id, HonninKakuninHoho__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c LIMIT 1];
        Assert.areEqual('公的個人認証', seikyusha.HonninKakuninHoho__c);
    }

    @isTest
    private static void getErrorMessage_DV(){
        User dvUser = [SELECT Id FROM User WHERE Name = 'TestAccount_dvUser'];

        DV_Ninteiseikyu__c nintei = [SELECT Id, Seikyusya__c FROM DV_Ninteiseikyu__c LIMIT 1];

        DV_Seikyusha__c seikyusha = [SELECT Id, TrustdocErrorMessage__c FROM DV_Seikyusha__c WHERE Id = :nintei.Seikyusya__c];
        seikyusha.TrustdocErrorMessage__c = 'wrong_document';
        update seikyusha;
        
        String errorMessage;
        Test.startTest();
        System.runAs(dvUser){
            errorMessage = ExMyNumberController.getErrorMessage(nintei.Id);
        }

        Test.stopTest();

        Assert.areEqual(System.Label.EX_KKN2_WRONG_DOCUMENT, errorMessage);
    }

    public class TrustdockMock_Success implements HttpCallOutMock {
        public HttpResponse respond(HttpRequest httpReqesut){

            Map<String, String> requestBody = (Map<String, String>)JSON.deserialize(httpReqesut.getBody(), Map<String, String>.class);
            String endpoint = httpReqesut.getEndpoint();

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if(endpoint.endsWith('/verifications')){
                Assert.isTrue(String.isNotBlank(requestBody.get('external_id')));

                String resBody = '{"id": "sample-secret-id", "public_id": "sample-public-id"}';
                response.setBody(resBody);
                response.setStatusCode(202);
            }
            else if(endpoint.endsWith('/tbs_raw_data')){
                Assert.isTrue(String.isNotBlank(requestBody.get('value')));

                response.setBody('{}');
                response.setStatusCode(204);
            }
            else{
                Assert.fail('不正なエンドポイント');
            }

            return response;
        }
    }

    public class TrustdockMock_Fail1 implements HttpCallOutMock {
        public HttpResponse respond(HttpRequest httpReqesut){

            Map<String, String> requestBody = (Map<String, String>)JSON.deserialize(httpReqesut.getBody(), Map<String, String>.class);
            String endpoint = httpReqesut.getEndpoint();

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String resBody = '{"id": "sample-secret-id", "public_id": "sample-public-id"}';
            response.setBody(resBody);
            response.setStatusCode(404);

            return response;
        }
    }
    public class TrustdockMock_Fail2 implements HttpCallOutMock {
        public HttpResponse respond(HttpRequest httpReqesut){

            Map<String, String> requestBody = (Map<String, String>)JSON.deserialize(httpReqesut.getBody(), Map<String, String>.class);
            String endpoint = httpReqesut.getEndpoint();

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            if(endpoint.endsWith('/verifications')){
                Assert.isTrue(String.isNotBlank(requestBody.get('external_id')));

                String resBody = '{"id": "sample-secret-id", "public_id": "sample-public-id"}';
                response.setBody(resBody);
                response.setStatusCode(202);
            }
            else if(endpoint.endsWith('/tbs_raw_data')){
                Assert.isTrue(String.isNotBlank(requestBody.get('value')));

                response.setBody('{"message": "Not Found"}');
                response.setStatusCode(404);
            }
            else{
                Assert.fail('不正なエンドポイント');
            }

            return response;
        }
    }
}