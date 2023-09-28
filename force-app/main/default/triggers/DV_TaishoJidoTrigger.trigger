trigger DV_TaishoJidoTrigger on DV_TaishoJido__c (before insert, before update, after insert, after update) {

	// 呼び出すトリガハンドラ
    SfDVTaishoJidoTriggerHandler handler = new SfDVTaishoJidoTriggerHandler();

	// before insert
	if(Trigger.isInsert && Trigger.isBefore) {
		handler.beforeInsert(Trigger.new);
		ExDVTaishoJidoTriggerHandler.convertWebValueToOcrValue(Trigger.new);
	}

	// after insert
    if(Trigger.isInsert && Trigger.isAfter) {
        handler.afterInsert(Trigger.new);
    }

	// before update
	if(Trigger.isUpdate && Trigger.isBefore) {
		handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
		ExDVTaishoJidoTriggerHandler.convertWebValueToOcrValue(Trigger.new);
	}

	// after update
    if(Trigger.isUpdate && Trigger.isAfter) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}