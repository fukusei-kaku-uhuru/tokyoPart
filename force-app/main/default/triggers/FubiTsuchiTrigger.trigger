trigger FubiTsuchiTrigger on FubiTsuchi__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfFubiTsuchiTriggerHandler handler = new SfFubiTsuchiTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.newMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}