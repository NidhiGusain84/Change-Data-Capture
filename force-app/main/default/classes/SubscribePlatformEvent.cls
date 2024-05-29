public with sharing class SubscribePlatformEvent{
    public static void afterInsert(List<Order_Detail__e> orderDetailPlatformEventList){
        List<Task> taskList = new List<Task>();
        User adminUser = [SELECT Id
                          FROM User
                          WHERE Username = 'nidhigusain@company.com'];
        for (Order_Detail__e orderDetail : orderDetailPlatformEventList){
            Task taskDetail = new Task();
            taskDetail.Subject = 'Platform Event Subscribed Using Trigger';
            taskDetail.Description = orderDetail.Order_Number__c;
            taskDetail.OwnerId = adminUser.Id;
            taskDetail.ActivityDate = Date.today();
            taskList.add(taskDetail);
        }

        if (!taskList.isEmpty()){
            try{
                insert taskList;
            } catch (Exception ex){
                System.debug('Task Creation Failed' + ex.getMessage());
            }
        }
    }

}