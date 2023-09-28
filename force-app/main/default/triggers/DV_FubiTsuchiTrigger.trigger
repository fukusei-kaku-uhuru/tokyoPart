trigger DV_FubiTsuchiTrigger on DV_FubiTsuchi__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfDVFubiTsuchiTriggerHandler handler = new SfDVFubiTsuchiTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.newMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}