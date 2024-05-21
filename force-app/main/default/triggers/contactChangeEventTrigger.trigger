trigger contactChangeEventTrigger on ContactChangeEvent(after insert ){
    if (Trigger.isAfter && Trigger.isInsert){
        ContactChangeEventTriggerHelper.afterInsert(Trigger.New );
    }
}