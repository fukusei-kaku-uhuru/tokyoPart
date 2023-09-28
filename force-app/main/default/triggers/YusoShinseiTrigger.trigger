trigger YusoShinseiTrigger on YusoShinsei__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfYusoShinseiTriggerHandler handler = new SfYusoShinseiTriggerHandler();

    // before update
    if(Trigger.isUpdate && Trigger.isBefore) {
        handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}