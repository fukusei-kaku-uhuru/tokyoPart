public without sharing class ExKubunBetsuShinseiShoruiUtil {

    /**
     * 渡された対象者区分に紐づく、区分別申請書類の一覧を取得する
     */
    public static List<KubunBetsuShinseiShorui__c> getKubunBetsuShinseiShoruiList(String taishoshaKubunId) {

        List<KubunBetsuShinseiShorui__c> kbssList = [   select
                                                            Id
                                                            ,ShinseiShoruiTeigi__c
                                                            ,ShinseiShoruiTeigi__r.Name
                                                            ,ShinseiShoruiTeigi__r.IsRequiredDairinin__c
                                                            ,ShinseiShoruiTeigi__r.IsNiniTeisyutsu__c
                                                            ,ShinseiShoruiTeigi__r.ShoruiSetsumei__c
                                                        from KubunBetsuShinseiShorui__c
                                                        where TaishoshaKubun__c = :taishoshaKubunId
                                                        order by ShinseiShoruiTeigi__r.Order__c asc, ShinseiShoruiTeigi__r.Name
        ];

        return kbssList;
    }

    /**
     * 渡された対象者区分に紐づく、区分別申請書類の一覧を取得する
     */
    public static Map<Id, List<KubunBetsuShinseiShorui__c>> getKubunBetsuShinseiShoruiMap(Set<Id> taishoshaKubunIds) {

        List<KubunBetsuShinseiShorui__c> kbssList = [   select
                                                            Id
                                                            ,TaishoshaKubun__c
                                                            ,ShinseiShoruiTeigi__c
                                                            ,ShinseiShoruiTeigi__r.Name
                                                            ,ShinseiShoruiTeigi__r.IsRequiredDairinin__c
                                                            ,ShinseiShoruiTeigi__r.IsNiniTeisyutsu__c
                                                        from KubunBetsuShinseiShorui__c
                                                        where TaishoshaKubun__c in :taishoshaKubunIds
                                                        order by ShinseiShoruiTeigi__r.Name
        ];

        Map<Id, List<KubunBetsuShinseiShorui__c>> kbssMap = new Map<Id, List<KubunBetsuShinseiShorui__c>>();
        for (KubunBetsuShinseiShorui__c kbss : kbssList) {
            List<KubunBetsuShinseiShorui__c> tkKbssList = new List<KubunBetsuShinseiShorui__c>();
            if (kbssMap.containsKey(kbss.TaishoshaKubun__c)) {
                tkKbssList = kbssMap.get(kbss.TaishoshaKubun__c);
            }
            tkKbssList.add(kbss);
            kbssMap.put(kbss.TaishoshaKubun__c, tkKbssList);
        }

        return kbssMap;
    }
}