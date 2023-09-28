trigger DV_EscalationTrigger on DV_Escalation__c (before insert, before update, after insert, after update) {

    SfDVEscalationTriggerHandler handler = new SfDVEscalationTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}