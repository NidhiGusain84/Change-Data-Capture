public with sharing class ContactChangeEventTriggerHelper{
    public static void afterInsert(List<ContactChangeEvent> contactChangeEventList){
        List<Task> taskList = new List<Task>();
        for (ContactChangeEvent event : contactChangeEventList){
            System.debug('Event ==> ' + event);
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            System.debug('Header ==>' + header);
            if (header.changetype == 'CREATE'){
                //create the task
                for (String recordId : header.recordids){
                    Task task = new Task();
                    task.Subject = 'New Contact is Created - Kindly take required action';
                    task.OwnerId = header.commituser;
                    task.WhoId = recordId;
                    taskList.add(task);
                }


            } else if (header.changetype == 'UPDATE'){
                for (String field : header.changedfields){
                    if (field == 'Email'){
                        //create the task
                        for (String recordId : header.recordids){
                            Task task = new Task();
                            task.Subject = 'Email address of contact is updated - Kindly take required action';
                            task.OwnerId = header.commituser;
                            task.WhoId = recordId;
                            taskList.add(task);
                        }
                    }
                }
            }
        }

        if (taskList.size() > 0){
            try{
                insert taskList;
            } catch (Exception ex){
                System.debug('Task creation failed' + ex.getMessage());
            }
        }
    }

}