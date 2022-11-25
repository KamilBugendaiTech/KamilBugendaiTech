@isTest
public class SurveyWebhookTest {
    
    @isTest
	public static void Test_Success() {

        // Data setup
        Test.setMock(HttpCalloutMock.class, new MacorvaTest.MockClass());
        
        Contact cnt = new Contact();
        cnt.LastName = 'Test873263';
        cnt.Email = 'test873263@test.com';
        cnt.Phone = '9876543210';
        insert cnt;

        Survey__c survey = new Survey__c();
        //cv:survey.Contact__c = cnt.Id;
        survey.Status__c = 'Sent';
        survey.Survey_Id__c = '12345';
        insert survey;
		
		// Run the code
        Test.startTest();
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('{"id": 25, "event_type": "survey.completed", "object_id": 12345, "survey_rating":4}');
        RestContext.response = new RestResponse();

        SurveyWebhook.HandlePost();
		
		Test.stopTest();
		
        // Verify Results
        System.assertEquals(200, RestContext.response.statusCode);
		System.assertEquals('Completed', [SELECT Status__c FROM Survey__c WHERE Id = :survey.Id].Status__c);

    }

}