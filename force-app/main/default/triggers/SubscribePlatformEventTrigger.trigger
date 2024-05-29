trigger SubscribePlatformEventTrigger on Order_Detail__e(after insert ){
    if (trigger.isAfter && trigger.isInsert){
        SubscribePlatformEvent.afterInsert(trigger.new );
    }
}