@isTest
public class MacorvaTest {
    
    public class MockClass implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Locations
            if (req.getEndpoint().contains('/customer/locations/')) {
                res.setBody('[ { "id": 12345, "id_external": "test", "name": "Test" } ]');
            }

            // Surveys
            if (req.getEndpoint().contains('/customer/feedback-requests/deliver/')) {
                res.setBody('{ "survey_id": 12345, "survey_url": "https://example.macorva.com/cx/1234567890" }');
            } else if (req.getEndpoint().contains('/customer/feedback-requests/')) {
                res.setBody('{ "id": 12345, "survey_rating": 4, "comments": "string" }');
            }

            // Hooks
            if (req.getEndpoint().contains('/customer/hooks/')) {
                if (req.getMethod() == 'GET') {
                    res.setBody('[ { "id": 12345, "url": "https://mydomain.com/test/", "event_type": "survey.completed" } ]');
                }
                if (req.getMethod() == 'POST') {
                    res.setBody('{ "id": 12345, "url": "https://mydomain.com/test/", "event_type": "survey.completed" }');
                }
            }

            res.setStatusCode(200);
            return res;
        }
    }

    
	@isTest
	public static void Test_SendSurvey() {
		
		// Data setup
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Contact cnt = new Contact();
        cnt.LastName = 'Test873263';
        cnt.Email = 'test873263@test.com';
        cnt.Phone = '9876543210';
        insert cnt;
		
		// Run the code
        Test.startTest();
        
        MacorvaHelper.SendSurvey('1',cnt.id,'','','','',0,'','','','Notes from the testclass');

		
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Survey__c WHERE Contact__c = :cnt.Id]);
    }

    @isTest
    public static void Test_SendSurvey2() {

        // Data setup
        Test.setMock(HttpCalloutMock.class, new MockClass());

        Contact cnt = new Contact();
        cnt.LastName = 'Test873263';
        cnt.Email = 'test873263@test.com';
        cnt.Phone = '9876543210';
        insert cnt;

        // Run the code
        Test.startTest();

        MacorvaHelper.SendSurvey('1',null,'Jane','Doe','jane@test.com','111-123-4566',0,'123','Jane Doe','123','Notes from the testclass');


        Test.stopTest();

        // Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Survey__c WHERE Contact__c = NULL]);
    }
    
    @isTest
    public static void Test_CreateSurveyHook() {
		
		// Data setup
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
		// Run the code
        Test.startTest();
        
        boolean resp = MacorvaHelper.CreateSurveyHook();
		
		Test.stopTest();
		
		// Verify Results
		System.assertEquals(true, resp);
    }
    
    @isTest
    public static void Test_MacorvaAPI() {
		
		// Data setup
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
		// Run the code
        Test.startTest();
        
        string locations = MacorvaAPI.TestConnection();
        MacorvaAPI.MacorvaCallResult hooksRes = MacorvaAPI.GetListOfHooks();
		
		Test.stopTest();
		
		// Verify Results
		System.assert(hooksRes.result.contains('"https://mydomain.com/test/"'));
    }

}