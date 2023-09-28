public without sharing class SfYusoShinseiTriggerHandler {

    private final String YUSO_STATUS_STR_KAIFUZUMI = '開封済み';

    public SfYusoShinseiTriggerHandler() {

    }

    public void beforeUpdate(Map<Id, YusoShinsei__c> newYusoShinseiMap, Map<Id, YusoShinsei__c> oldYusoShinseiMap) {

        // 郵送申請の開封受付時にステータスを開封済みに変更する
        setYusoShinseiKaifuzumi(newYusoShinseiMap, oldYusoShinseiMap);
    }

    /**
     * 郵送申請の開封受付時にステータスを開封済みに変更する
     */
    private void setYusoShinseiKaifuzumi(Map<Id, YusoShinsei__c> newYusoShinseiMap, Map<Id, YusoShinsei__c> oldYusoShinseiMap) {

        for(YusoShinsei__c yusoShinsei :newYusoShinseiMap.values()) {
            if(yusoShinsei.KaifuUketsukeDate__c != null
            && oldYusoShinseiMap.get(yusoShinsei.Id).KaifuUketsukeDate__c == null) {
                yusoShinsei.Status__c = YUSO_STATUS_STR_KAIFUZUMI;
            }
        }
    }
}