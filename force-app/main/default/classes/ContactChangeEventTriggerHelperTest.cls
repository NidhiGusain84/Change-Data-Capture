@isTest
private class ContactChangeEventTriggerHelperTest{
    @isTest
    static void validateChangeEventNotification(){
        Test.enableChangeDataCapture();

        Contact con = new Contact(
            FirstName = 'Riyansh', 
            LastName = 'Jain', 
            Email = 'riyanshJain@gmail.com'
        );
        insert con;
        Test.getEventBus().deliver();

        Task[] taskList = [SELECT Id
                           FROM task
                           WHERE Subject = 'New Contact is Created - Kindly take required action'];
        System.assertEquals(1, taskList.size(), 'During Insertion - Change Event is failed');

        Contact queriedContact = [SELECT Id, FirstName, LastName, Email
                                  FROM Contact
                                  WHERE Id = :con.Id];

        queriedContact.Email = 'riyanshtechJourney@gmail.com';
        update queriedContact;
        Test.getEventBus().deliver();

        taskList = [SELECT Id
                    FROM task
                    WHERE Subject = 'Email address of contact is updated - Kindly take required action'];
        System.assertEquals(1, taskList.size(), 'During Updation - Change Event is failed');
    }

}