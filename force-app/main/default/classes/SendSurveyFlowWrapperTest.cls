@isTest
public class SendSurveyFlowWrapperTest {

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
    public static void test1() {
        // Data setup
        Test.setMock(HttpCalloutMock.class, new MockClass());

        List<SendSurveyFlowWrapper.FlowInputs> inputs = new List<SendSurveyFlowWrapper.FlowInputs>();
        SendSurveyFlowWrapper.FlowInputs input = new SendSurveyFlowWrapper.FlowInputs();

        Contact theContact = new Contact();
        theContact.LastName = 'Test873263';
        theContact.Email = 'test873263@test.com';
        theContact.Phone = '9876543210';
        insert theContact;

        input.contactId = theContact.Id;
        input.surveyId = 'tl1';
        input.delayInMinutes = 0;
        input.notes ='These are the notes';
        inputs.add(input);

        Test.startTest();
        SendSurveyFlowWrapper.SendSurvey(inputs);
        Test.stopTest();

        System.debug([SELECT id, name, Contact__c from Survey__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Survey__c WHERE Contact__c = :theContact.Id]);

    }
}