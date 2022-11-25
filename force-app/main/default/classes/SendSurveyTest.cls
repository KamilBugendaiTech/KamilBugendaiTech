@isTest
public class SendSurveyTest {
    
    @isTest
	public static void Test_Success() {
		
		// Data setup
        Test.setMock(HttpCalloutMock.class, new MacorvaTest.MockClass());
        
        Contact cnt = new Contact();
        cnt.LastName = 'Test873263';
        cnt.Email = 'test873263@test.com';
        cnt.Phone = '9876543210';
        insert cnt;
		
		// Run the code
        Test.startTest();
        
        Contact cnt2 = SendSurvey.GetContactDetails(cnt.Id);
        /*SendSurvey.SendSurvey('tl1', cnt2.id,'',cnt2.Email,'',
        '', boolean byEmail, integer delayInMinutes, string employeeName, string notes)*/
		
		Test.stopTest();
		
		// Verify Results
		System.assertEquals(cnt.Email, cnt2.Email);
		System.assertEquals(1, [SELECT COUNT() FROM Survey__c WHERE Contact__c = :cnt.Id]);


    }

}