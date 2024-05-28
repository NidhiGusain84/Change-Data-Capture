public with sharing class PublishPlatformEventCallback implements EventBus.EventPublishFailureCallback, EventBus.EventPublishSuccessCallback{
    public void onFailure(EventBus.FailureResult result){
        // Get event UUIDs from the result
        List<String> eventUuids = result.getEventUuids();
        insertTask(eventUuids, true);
    }

    public void onSuccess(EventBus.SuccessResult result){
        // Get event UUIDs from the result
        List<String> eventUuids = result.getEventUuids();
        insertTask(eventUuids, false);
    }

    public void insertTask(List<String> eventUuidsList, Boolean isSuccess){
        String eventUuidString = '';
        for (String eventUuid : eventUuidsList){
            eventUuidString = eventUuidString + eventUuid + '';
        }
        Task taskDetail = new Task();
        if (isSuccess == true){
            taskDetail.Subject = 'Platform Event Published Successfully';
            taskDetail.Description = 'Total Platform Events Published Successfully' + eventUuidsList.size() + ' List of Event UUID Published Successfully' + eventUuidString;
        } else{
            taskDetail.Subject = 'Platform Event Published Failed';
            taskDetail.Description = 'Total Platform Events Publish Failed' + eventUuidsList.size() + ' List of Event UUID Published Failed' + eventUuidString;
        }
        taskDetail.ActivityDate = Date.today();
        User userDetail = [SELECT Id
                           FROM User
                           WHERE username = 'nidhigusain@company.com'];
        taskDetail.OwnerId = userDetail.Id;
        try{
            insert taskDetail;
        } catch (Exception ex){
            System.debug('Task Insertion Failed' + ex.getMessage());
        }
    }

}