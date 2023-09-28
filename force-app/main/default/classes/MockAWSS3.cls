// AWS S3の呼び出しをモックするためのMockオブジェクトを作成します
@IsTest
global class MockAWSS3 implements HttpCalloutMock {

    // エラー発生フラグ
    public Boolean errorFlg { get; set; }

    /**
    * @param errFlg エラー発生フラグ
    */
    public MockAWSS3(Boolean errFlg) {
        this.errorFlg = errFlg;
    }

    /**
     * モックレスポンスを返します
     */
    global HTTPResponse respond(HTTPRequest req) {

        if (this.errorFlg) {
            throw new System.CalloutException('連携失敗エラー');
        }

        // HTTPResponseオブジェクトを作成し、適切なステータスコードやレスポンスボディを設定します
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"message": "モックレスポンス"}');
        return res;

    }
}