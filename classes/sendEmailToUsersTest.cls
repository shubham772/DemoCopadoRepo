@isTest
public class sendEmailToUsersTest {

    @testSetup
    static void setupData() {
        // Use a standard profile that definitely has a UserLicense associated
        Profile p = [SELECT Id FROM Profile WHERE UserLicense.Name != null LIMIT 1];
        
        User testUser = new User(
            Alias = 'grztest', 
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'unique_grz_user_' + DateTime.now().getTime() + '@example.com',
            Country = 'India',
            Approver__c = false,
            IsActive = true
        );
        insert testUser;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        
        sendEmailToUsers batch = new sendEmailToUsers();
        Id batchId = Database.executeBatch(batch);
        //testing the copado
        
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :batchId];
        System.assertEquals('Completed', job.Status);
    }
}