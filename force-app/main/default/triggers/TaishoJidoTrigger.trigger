trigger TaishoJidoTrigger on TaishoJido__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfTaishoJidoTriggerHandler handler = new SfTaishoJidoTriggerHandler();
    SfTaishoJidoUpdateDantaiCDTriggerHandler updateDantaiCDhandler = new SfTaishoJidoUpdateDantaiCDTriggerHandler();

    // before insert
    if(Trigger.isInsert && Trigger.isBefore) {
        handler.beforeInsert(Trigger.new);
		ExTaishoJidoTriggerHandler.convertWebValueToOcrValue(Trigger.new);
    }

    // after insert
    if(Trigger.isInsert && Trigger.isAfter) {
        handler.afterInsert(Trigger.new);
    }

    // before update
    if(Trigger.isUpdate && Trigger.isBefore) {
        handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        updateDantaiCDhandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
		ExTaishoJidoTriggerHandler.convertWebValueToOcrValue(Trigger.new);
    }

    // after update
    if(Trigger.isUpdate && Trigger.isAfter) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}