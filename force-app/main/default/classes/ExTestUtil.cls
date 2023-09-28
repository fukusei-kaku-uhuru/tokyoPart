public class ExTestUtil {

    // ExperienceサイトのIDの取得
    private static Map<String, Id> networkIdByName;
    static {
        List<Site__mdt> mdts = Site__mdt.getAll().values();

        Map<String, Site__mdt> mdtBySiteName = new Map<String, Site__mdt>();
        for(Site__mdt mdt: mdts){
            mdtBySiteName.put(mdt.MasterLabel__c, mdt);
        }

        List<Network> networks = [
            SELECT
                Id
                ,Name
            FROM
                Network
            WHERE
                Name IN :mdtBySiteName.keySet()
        ];

        Map<String, Id> networkIdBySiteName = new Map<String, Id>();
        for(Network network: networks){
            networkIdBySiteName.put(network.Name, network.Id);
        }

        networkIdByName = new Map<String, Id>();
        for(String siteName: mdtBySiteName.keySet()){
            networkIdByName.put(
                mdtBySiteName.get(siteName).DeveloperName.toLowerCase()
                ,networkIdBySiteName.get(siteName)
            );
        }
    }

    // ユーザ作成時のドメイン
    public static final String TEST_DOMAIN = '@example.com';

    // ユーザ作成時の接頭辞
    public static final String GENERAL_PREFIX = 'general';
    public static final String DV_PREFIX = 'dv';
    public static final String SATOYA_PREFIX = 'satoya';

    // System.runAsで使用するユーザ取得用の検索語
    public static final String GENERAL_QUERY_STRING = GENERAL_PREFIX + '%' + TEST_DOMAIN;
    public static final String DV_QUERY_STRING = DV_PREFIX + '%' + TEST_DOMAIN;
    public static final String SATOYA_QUERY_STRING = SATOYA_PREFIX + '%' + TEST_DOMAIN;

    // ExperienceサイトのID（ContentVerionのNetworkIdに設定する）
    public static Id GENERAL_NETWORK_ID = networkIdByName.get(GENERAL_PREFIX);
    public static Id DV_NETWORK_ID = networkIdByName.get(DV_PREFIX);
    public static Id SATOYA_NETWORK_ID = networkIdByName.get(SATOYA_PREFIX);

    // OBJ(DV/里親)のレコードタイプ
    private static final String DV_RECORD_TYPE_NAME = 'DvHigaisha';
    private static final String SATOYA_RECORD_TYPE_NAME = 'Satooya';
    private static final Map<String, Schema.RecordTypeInfo> SEIKYU_TYPES = Schema.SObjectType.DV_NinteiSeikyu__c.getRecordTypeInfosByDeveloperName();
    private static final Map<String, Schema.RecordTypeInfo> SEIKYUSHA_TYPES = Schema.SObjectType.DV_Seikyusha__c.getRecordTypeInfosByDeveloperName();
    private static final Map<String, Schema.RecordTypeInfo> JIDO_TYPES = Schema.SObjectType.DV_TaishoJido__c.getRecordTypeInfosByDeveloperName();

    // 認定請求のレコードタイプ
    public static final Id DV_SEIKYU_ID = SEIKYU_TYPES.get(DV_RECORD_TYPE_NAME).getRecordTypeId();
    public static final Id SATOYA_SEIKYU_ID = SEIKYU_TYPES.get(SATOYA_RECORD_TYPE_NAME).getRecordTypeId();

    // 請求者のレコードタイプ
    public static final Id DV_SEIKYUSHA_ID = SEIKYUSHA_TYPES.get(DV_RECORD_TYPE_NAME).getRecordTypeId();
    public static final Id SATOYA_SEIKYUSHA_ID = SEIKYUSHA_TYPES.get(SATOYA_RECORD_TYPE_NAME).getRecordTypeId();

    // 対象児童のレコードタイプ
    public static final Id DV_JIDO_ID = JIDO_TYPES.get(DV_RECORD_TYPE_NAME).getRecordTypeId();
    public static final Id SATOYA_JIDO_ID = JIDO_TYPES.get(SATOYA_RECORD_TYPE_NAME).getRecordTypeId();

    // 申請書類定義のレコードタイプ
    private static final Map<String, Schema.RecordTypeInfo> TEIGI_TYPES = Schema.SObjectType.ShinseiShoruiTeigi__c.getRecordTypeInfosByDeveloperName();
    public static final Id KOJIN_NINSHO_TEIGI_ID = TEIGI_TYPES.get('KojinNinsho').getRecordTypeId();
    public static final Id TAISHO_JIDO_TEIGI_ID = TEIGI_TYPES.get('TaishoJido').getRecordTypeId();
    public static final Id MOUSHITATE_TEIGI_ID = TEIGI_TYPES.get('Moushitate').getRecordTypeId();
    public static final Id KOZA_KAKUNIN_TEIGI_ID = TEIGI_TYPES.get('KozaKakunin').getRecordTypeId();

    /**
     * 重複回避のためのユニークキー取得
     */
    public static String getUniqueKey(){
        return String.valueOf(DateTime.now().getTime());
    }

    /**
     * 個人取引先の取得
     */
    public static Account getPersonAccount(String uniqueName){
        Account acc = new Account(
            LastName = uniqueName,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        return acc;
    }

    /**
     * 取引先責任者IDの取得
     */
    public static Id getContactId(Id accId){
        return [SELECT Id FROM Contact WHERE AccountId = :accId LIMIT 1].Id;
    }

    /**
     * 一般ユーザの取得
     */
    public static User getGeneralUser(String uniqueName, Id accId){
        User u = new User(
            Alias = uniqueName.substring(0,8),
            ContactId = getContactId(accId),
            Email = uniqueName + TEST_DOMAIN,
            EmailEncodingKey='UTF-8',
            LastName = uniqueName,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName = uniqueName + TEST_DOMAIN
        );
        return u;
    }

    /**
     * DVユーザの取得
     */
    public static User getDvUser(String uniqueName, Id accId){
        User u = new User(
            Alias = uniqueName.substring(0,8),
            ContactId = getContactId(accId),
            Email = uniqueName + TEST_DOMAIN,
            EmailEncodingKey='UTF-8',
            LastName = uniqueName,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者（DV)'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName = uniqueName + TEST_DOMAIN
        );
        return u;
    }

    /**
     * 里親・ファミリーホームユーザの取得
     */
    public static User getSatoyaUser(String uniqueName, Id accId){
        User u = new User(
            Alias = uniqueName.substring(0,8),
            ContactId = getContactId(accId),
            Email = uniqueName + TEST_DOMAIN,
            EmailEncodingKey='UTF-8',
            LastName = uniqueName,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = '認定請求者（里親・ファミリーホーム）'].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName = uniqueName + TEST_DOMAIN
        );
        return u;
    }

    /**
     * 請求者を取得
     */
    public static Seikyusha__c getSeikyusha() {
        return new Seikyusha__c(
            Shimei__c = '請求者氏名'
        );
    }

    /**
     * 請求者（DV）を取得
     */
    public static DV_Seikyusha__c getSeikyushaDv() {
        return new DV_Seikyusha__c(
            Shimei__c = '請求者氏名'
            ,RecordTypeId = DV_SEIKYUSHA_ID
        );
    }

    /**
     * 請求者（里親）を取得
     */
    public static DV_Seikyusha__c getSeikyushaSatoya() {
        return new DV_Seikyusha__c(
            Shimei__c = '請求者氏名'
            ,RecordTypeId = SATOYA_SEIKYUSHA_ID
        );
    }

    /**
     * 認定請求を取得
     */
    public static NinteiSeikyu__c getNinteiSeikyu(Seikyusha__c s) {
        return new NinteiSeikyu__c(
            ShinsaStatus__c = '未申請'
            ,Seikyusha__c = s.Id
        );
    }

    /**
     * 認定請求（DV）を取得
     */
    public static DV_NinteiSeikyu__c getNinteiSeikyuDv(DV_Seikyusha__c s) {
        return new DV_NinteiSeikyu__c(
            ShinsaStatus__c = '未申請'
            ,Seikyusya__c = s.Id
            ,RecordTypeId = DV_SEIKYU_ID
        );
    }

    /**
     * 認定請求（里親）を取得
     */
    public static DV_NinteiSeikyu__c getNinteiSeikyuSatoya(DV_Seikyusha__c s) {
        return new DV_NinteiSeikyu__c(
            ShinsaStatus__c = '未申請'
            ,Seikyusya__c = s.Id
            ,RecordTypeId = SATOYA_SEIKYU_ID
        );
    }

    /**
     * 対象者区分を取得
     */
    public static TaishoshaKubun__c getTaishoshaKubun() {
        return getTaishoshaKubun('A0');
    }

    public static TaishoshaKubun__c getTaishoshaKubun(String name) {
        return new TaishoshaKubun__c(
            Name = name
            ,KyufuKahi__c = true
            ,Meigi_Taishosha__c = true
            ,Meigi_Dairinin__c = true
            ,IsMoushitate__c = true
        );
    }

    public static List<TaishoshaKubun__c> getTaishoshaKubuns(Integer count){
        List<TaishoshaKubun__c> a = new List<TaishoshaKubun__c>();
        for(Integer i=0; i<count; i++){
            a.add(getTaishoshaKubun('A' + i));
        }
        return a;
    }

    /**
     * 区分別申請書類定義を取得
     */
    public static List<KubunBetsuShinseiShorui__c> getKbssList(TaishoshaKubun__c tk, List<ShinseiShoruiTeigi__c> sstList) {
        List<KubunBetsuShinseiShorui__c> kbssList = new List<KubunBetsuShinseiShorui__c>();
        for (ShinseiShoruiTeigi__c sst : sstList) {
            kbssList.add(new KubunBetsuShinseiShorui__c(
                TaishoshaKubun__c = tk.Id
                ,ShinseiShoruiTeigi__c = sst.Id
            ));
        }
        return kbssList;
    }

    /**
     * 申請書類定義（個人認証用）を取得
     */
    public static List<ShinseiShoruiTeigi__c> getSstListKojinNinsho(Integer count) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        for (Integer i = 1; i <= count; i++) {
            sstList.add(new ShinseiShoruiTeigi__c(
                RecordTypeId = KOJIN_NINSHO_TEIGI_ID
                ,Name = '書類定義' + i
                ,Order__c = i
            ));
        }
        return sstList;
    }

    /**
     * 申請書類定義（対象児童用）を取得
     */
    public static List<ShinseiShoruiTeigi__c> getSstListTaishoJido(Integer count) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        for (Integer i = 1; i <= count; i++) {
            sstList.add(new ShinseiShoruiTeigi__c(
                RecordTypeId = TAISHO_JIDO_TEIGI_ID
                ,Name = '書類定義' + i
                ,Order__c = i
            ));
        }
        return sstList;
    }

    /**
     * 申請書類定義（申立書用）を取得
     */
    public static List<ShinseiShoruiTeigi__c> getSstListMoushitate(Integer count) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        List<String> moushitateKubuns = new List<String>{'1','2','3','4','5'};
        for (Integer i = 1; i <= count; i++) {
            sstList.add(new ShinseiShoruiTeigi__c(
                RecordTypeId = MOUSHITATE_TEIGI_ID
                ,Name = '書類定義' + i
                ,ShoruiSetsumei__c = '書類説明' + i
                ,MoushitateshoKubun__c = moushitateKubuns[Math.mod(i-1, 5)]
                ,Order__c = i
            ));
        }
        return sstList;
    }

    /**
     * 申請書類定義（口座確認用）を取得
     */
    public static ShinseiShoruiTeigi__c getSstKozaKakunin() {
        return new ShinseiShoruiTeigi__c(
            RecordTypeId = KOZA_KAKUNIN_TEIGI_ID
            ,Name = '書類定義'
            ,Order__c = 1
        );
    }

    public static List<ShinseiShoruiTeigi__c> getSstListKozaKakunin(Integer count) {
        List<ShinseiShoruiTeigi__c> sstList = new List<ShinseiShoruiTeigi__c>();
        for (Integer i = 1; i <= count; i++) {
            sstList.add(new ShinseiShoruiTeigi__c(
                RecordTypeId = KOZA_KAKUNIN_TEIGI_ID
                ,Name = '書類定義' + i
                ,Order__c = i
            ));
        }
        return sstList;
    }

    /**
     * コンテンツバージョンを取得
     */
    public static ContentVersion getContentVersion(ShinseiShoruiTeigi__c sst, String targetId, String networkId) {
        return new ContentVersion(
            Title = 'テストファイル'
            ,PathOnClient = 'テストファイル.png'
            ,VersionData = Blob.valueOf('TEST')
            ,FirstPublishLocationId = targetId
            ,ShinseiShoruiTeigiId__c = sst.Id
            ,NetworkId = networkId
            ,IsDeletable__c = true
        );
    }
}