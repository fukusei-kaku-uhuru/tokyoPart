trigger FurikomiTrigger on Furikomi__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfFurikomiTriggerHandler handler = new SfFurikomiTriggerHandler();

    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}