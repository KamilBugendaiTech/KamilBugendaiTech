public with sharing class SendSurveyFlowWrapper {
    
    @InvocableMethod (label='Send Macorva Survey')
    public static void SendSurvey(List<FlowInputs> inputs){
        MacorvaHelper.SendSurvey( inputs[0].surveyID,
                                    inputs[0].contactID,
                                    inputs[0].firstName,
                                    inputs[0].lastName,
                                    inputs[0].email,
                                    inputs[0].phone,
                                    inputs[0].delayInMinutes,
                                    inputs[0].employeeNameID,
                                    inputs[0].employeeName,
                                    inputs[0].productID,
                                    inputs[0].notes

                );
    }

    public class FlowInputs{
        @InvocableVariable public Id contactId;
        @InvocableVariable public string surveyId;
        @InvocableVariable public string firstName;
        @InvocableVariable public string lastName;
        @invocableVariable public string email;
        @invocableVariable public string phone;
        @invocableVariable public integer delayInMinutes;
        @invocableVariable public string notes;
        @invocableVariable public string employeeNameID;
        @invocableVariable public string employeeName;
        @invocableVariable public string productID;

    }

    /*public class FlowOutputs{
        @InvocableVariable public string url;
        @InvocableVariable public string request;
        @InvocableVariable public integer responseCode;
        @InvocableVariable public string response;
        @InvocableVariable public string surveyId;
        public FlowOutputs(SendSurvey.SendSurveyResponse response){
            this.url = response.url;
            this.request = response.request;
            this.responseCode = response.responseCode;
            this.response = response.response;
            this.surveyId = response.surveyId;
        }
    }*/

}