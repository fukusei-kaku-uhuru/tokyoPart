trigger DV_SeikyushaTrigger on DV_Seikyusha__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfDVSeikyushaTriggerHandler handler = new SfDVSeikyushaTriggerHandler();

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
    }

    // after update
    if(Trigger.isUpdate && Trigger.isAfter) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}