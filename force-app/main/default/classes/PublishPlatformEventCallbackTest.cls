@isTest
public with sharing class PublishPlatformEventCallbackTest{
    @isTest
    static void testFailedEvents(){
        Order_Detail__e orderDetais = new Order_Detail__e(
            Order_Number__c = 'ORD900', 
            Generate_Invoice__c = false
        );
        PublishPlatformEventCallback cb = new PublishPlatformEventCallback();
        EventBus.publish(orderDetais, cb);
        Test.getEventBus().fail();
        List<Task> taskList = [SELECT Id, Subject, Description
                               FROM Task
                               WHERE Subject = 'Platform Event Published Failed'];
        System.Assert.areEqual(0, taskList.size(), 'Task creation failed');
    }

    @isTest
    static void testSuccessEvents(){
        Order_Detail__e orderDetais = new Order_Detail__e(
            Order_Number__c = 'ORD900', 
            Generate_Invoice__c = false
        );
        PublishPlatformEventCallback cb = new PublishPlatformEventCallback();
        Test.startTest();
        EventBus.publish(orderDetais, cb);
        Test.stopTest();
        List<Task> taskList = [SELECT Id, Subject, Description
                               FROM Task
                               WHERE Subject = 'Platform Event Published Successfully'];
        System.Assert.areEqual(0, taskList.size(), 'Task creation failed');
    }

}