public without sharing class ExShinseiShoruiTeigiUtil {

    public static List<ShinseiShoruiTeigi__c> getListByKojinNinsho() {
        return getList('KojinNinsho');
    }

    public static List<ShinseiShoruiTeigi__c> getListByTaishoJido() {
        return getList('TaishoJido');
    }

    public static List<ShinseiShoruiTeigi__c> getListByMoushitatesho() {
        return getList('Moushitate');
    }

    public static List<ShinseiShoruiTeigi__c> getKozaKakunin() {
        return getList('KozaKakunin');
    }

    @TestVisible
    private static List<ShinseiShoruiTeigi__c> getList(String recordTypeDeveloperName) {
        List<ShinseiShoruiTeigi__c> objList = [
            SELECT
                Id
                ,Name
                ,ShoruiTeigiKey__c
                ,IsMyNumber__c
                ,IsKenkoHoken__c
                ,IsJuminHyo__c
                ,IsNiniTeisyutsu__c
                ,ShoruiSetsumei__c
            FROM ShinseiShoruiTeigi__c
            WHERE recordType.DeveloperName =: recordTypeDeveloperName
            ORDER BY Order__c ASC];

        return objList;
    }

    /**
     * Idに一致する申請書類定義を取得する
     */
    public static List<ShinseiShoruiTeigi__c> getListByIdSet(Set<String> idSet) {
        List<ShinseiShoruiTeigi__c> objList = [
            SELECT
                Id
                ,Name
                ,ShoruiTeigiKey__c
                ,IsMyNumber__c
                ,IsKenkoHoken__c
                ,IsRequiredDairinin__c
                ,IsNiniTeisyutsu__c
            FROM ShinseiShoruiTeigi__c
            WHERE Id in :idSet
            ORDER BY RecordTypeId, Order__c asc
            ];

        return objList;
    }

    /**
     * 指定された申立書区分の申請書類定義を取得する
     */
    public static List<ShinseiShoruiTeigi__c> getRequiredMoushitateShorui(String moushitateKubun) {
        return getRequiredMoushitateShorui(new List<String>{moushitateKubun});
    }

    /**
     * 指定された申立書区分の申請書類定義を取得する
     */
    public static List<ShinseiShoruiTeigi__c> getRequiredMoushitateShorui(List<String> moushitateKubun) {
        return [
            SELECT
                Id
                ,Name
                ,ShoruiSetsumei__c
                ,IsNiniTeisyutsu__c
                ,MoushitateshoKubun__c
            FROM ShinseiShoruiTeigi__c
            WHERE RecordType.DeveloperName = 'Moushitate'
            AND MoushitateshoKubun__c in :moushitateKubun
            ORDER BY MoushitateshoKubun__c asc, Order__c asc
        ];
    }

    @AuraEnabled
    public static Boolean isKenkoHoken(String recordId) {
        ShinseiShoruiTeigi__c sst = [
            SELECT
                Id
                ,IsKenkoHoken__c
            FROM ShinseiShoruiTeigi__c
            WHERE Id = :recordId
        ];

        return sst.IsKenkoHoken__c;
    }

    @AuraEnabled
    public static Boolean isJuminHyo(String recordId) {
        ShinseiShoruiTeigi__c sst = [
            SELECT
                Id
                ,IsJuminHyo__c
            FROM ShinseiShoruiTeigi__c
            WHERE Id = :recordId
        ];

        return sst.IsJuminHyo__c;
    }
}