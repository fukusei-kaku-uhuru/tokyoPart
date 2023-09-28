@isTest
public  class SfTestUtil {

    // ユーザ作成時のドメイン
    public static final String TEST_DOMAIN = '@example.com';

    // 郵送申請の初期ステータス
    public static final String YUSO_STATUS_STR_UKETSUKE = '受付';

    /**
     * 審査ユーザ作成
     */
    public static User getShinsaUser(String uniqueName){
        User u = new User(
            Alias = uniqueName.length() > 8 ? uniqueName.substring(0,8) : uniqueName,
            Email = uniqueName + TEST_DOMAIN,
            EmailEncodingKey='ISO-2022-JP',
            LastName = uniqueName,
            LanguageLocaleKey='ja',
            LocaleSidKey='ja_JP',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '審査'].Id,
            TimeZoneSidKey='Asia/Tokyo',
            UserName = uniqueName + TEST_DOMAIN
        );
        return u;
    }

    /**
     * 請求者
     */
    public static Seikyusha__c getSeikyusha() {
        return new Seikyusha__c(
            Shimei__c = 'テスト　請求者'
        );
    }

    /**
     * 認定請求
     */
    public static NinteiSeikyu__c getNinteiSeikyu(Id seikyushaId) {
        return new NinteiSeikyu__c(
            Seikyusha__c = seikyushaId,
            Nendo__c     = '2023'
        );
    }

    /**
     * 対象児童
     */
    public static TaishoJido__c getTaishoJido(Id ninteiSeikyuId) {
        return new TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyuId,
            ShimeiFurigana__c  = 'テストタロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
    }

    /**
     * 郵送申請
     */
    public static YusoShinsei__c getYusoShinsei() {
        return new YusoShinsei__c(
            Status__c = YUSO_STATUS_STR_UKETSUKE
        );
    }

    /**
     * ContentVersion
     */
    public static ContentVersion getContentVersion() {
        return new ContentVersion(
            Title = 'テストファイル',
            PathOnClient = 'テストファイル.png',
            VersionData = Blob.valueOf('TEST')
            // FirstPublishLocationId = targetId,
            // ShinseiShoruiTeigiId__c = sst.Id
            // NetworkId = networkId
        );
    }

    /**
     * 申請書類定義
     */
    public static ShinseiShoruiTeigi__c getShinseiShoruiTeigi(Integer no) {
        Schema.DescribeSObjectResult recordTypeDescribe = ShinseiShoruiTeigi__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfoList = recordTypeDescribe.getRecordTypeInfos();
        return new ShinseiShoruiTeigi__c(
            Name = 'テスト申請書類定義' + no,
            RecordTypeId = recordTypeInfoList[0].getRecordTypeId(),
            Order__c = no
        );
    }

    /**
     * 不備通知
     */
    /*
    public static ShinseiShoruiTeigi__c getFubiTsuchi() {
        return new ShinseiShoruiTeigi__c(
            
        );
    }
    */

    /**
     * 請求者(DV被害者)
     */
    public static DV_Seikyusha__c getSeikyushaDV() {
        return new DV_Seikyusha__c(
            Shimei__c = 'テスト　請求者'
        );
    }

    /**
     * 認定請求(DV被害者)
     */
    public static DV_NinteiSeikyu__c getNinteiSeikyuDV(Id seikyushaId) {
        return new DV_NinteiSeikyu__c(
            Seikyusya__c = seikyushaId,
            Nendo__c     = '2023'
        );
    }

    /**
     * 対象児童(DV被害者)
     */
    public static DV_TaishoJido__c getTaishoJidoDV(Id ninteiSeikyuId) {
        return new DV_TaishoJido__c(
            NinteiSeikyu__c    = ninteiSeikyuId,
            ShimeiFurigana__c  = 'テストタロウ',
            SeinenGappiDate__c = Date.newInstance(2020, 1, 1)
        );
    }
}