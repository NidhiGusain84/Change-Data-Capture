public with sharing class PublishPlatformEvent{
    public static void publishPlatformEventDemo(){
        List<Order_Detail__e> orderDetailEventList = new List<Order_Detail__e>();
        orderDetailEventList.add(new Order_Detail__e(
            Order_Number__c = 'ORD2000', 
            Generate_Invoice__c = false
        ));

        orderDetailEventList.add(new Order_Detail__e(
            Order_Number__c = 'ORD3000', 
            Generate_Invoice__c = true
        ));


        orderDetailEventList.add(new Order_Detail__e(
            Order_Number__c = 'ORD4000', 
            Generate_Invoice__c = false
        ));
        PublishPlatformEventCallback callbackInstance = new PublishPlatformEventCallback();
        List<Database.SaveResult> srList = EventBus.publish(orderDetailEventList, callbackInstance);
        for (Database.SaveResult srItem : srList){
            if (srItem.isSuccess()){
                System.debug('Platform Event Published Successfully');
            } else{
                List<Database.error> errorList = srItem.getErrors();
                for (Database.error errorDetail : errorList){
                    System.debug('Error Details ' + errorDetail.getMessage());
                }
            }
        }
    }

}