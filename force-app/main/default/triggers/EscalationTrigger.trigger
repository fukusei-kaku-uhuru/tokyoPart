trigger EscalationTrigger on Escalation__c (before insert, before update, after insert, after update) {

    SfEscalationTriggerHandler handler = new SfEscalationTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}