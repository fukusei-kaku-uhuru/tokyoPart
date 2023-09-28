trigger SeikyushaTrigger on Seikyusha__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfSeikyushaTriggerHandler handler = new SfSeikyushaTriggerHandler();
    SfSeikyushaForUpdateDantaiCodeHandler updateDantaiCodeHandler = new SfSeikyushaForUpdateDantaiCodeHandler();
    SfSeikyushaUpdateNameTriggerHandler updateNameTriggerHandler = new SfSeikyushaUpdateNameTriggerHandler();
    // before insert
    if(Trigger.isInsert && Trigger.isBefore) {
        handler.beforeInsert(Trigger.new);
    }

    // after insert
    if(Trigger.isInsert && Trigger.isAfter) {
        handler.afterInsert(Trigger.new);
    }

    // before update
    if(Trigger.isUpdate && Trigger.isBefore) {
        handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        updateNameTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }

    // after update
    if(Trigger.isUpdate && Trigger.isAfter) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        updateDantaiCodeHandler.updateChihouKoukyouDantaiCode(Trigger.newMap, Trigger.oldMap);
    }
}