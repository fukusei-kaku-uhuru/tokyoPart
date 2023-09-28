trigger NinteiSeikyuTrigger on NinteiSeikyu__c (before insert, before update, after insert, after update) {

    // 呼び出すトリガハンドラ
    SfNinteiSeikyuTriggerHandler handler = new SfNinteiSeikyuTriggerHandler();
    SfNinteiSeikyuUketsukeNoTriggerHandler uketsukeNohandler = new SfNinteiSeikyuUketsukeNoTriggerHandler();

    // before insert
    if(Trigger.isInsert && Trigger.isBefore) {
        handler.beforeInsert(Trigger.new);
        uketsukeNohandler.onBeforeInsert(Trigger.new, Trigger.oldMap);
        SfNinteiSeikyuBeforeInsertProcess.setUketsukeBangoShimo2Keta(Trigger.new);
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