public class SendSurvey {
    
    @AuraEnabled
    public static Contact GetContactDetails(Id contactId) {

        return [SELECT Name, Email, Phone FROM Contact WHERE Id = :contactId];
        
    }
    
    @AuraEnabled
    public static void SendSurvey(string surveyID, id contactid, string firstName, string lastName, string email,
                                                string phone, integer delayInMinutes,  string employeeNameID, string employeeName, string productID,  string notes) {
        
        MacorvaHelper.SendSurvey(surveyID, contactid, firstName, lastName, email, phone, delayInMinutes, employeeNameID,employeeName,productID, notes);
    }

    public class SendSurveyResponse {

        @AuraEnabled
        public string url { get; set; }
        @AuraEnabled
        public string request { get; set; }
        @AuraEnabled
        public integer responseCode { get; set; }
        @AuraEnabled
        public string response { get; set; }
        
        @AuraEnabled
        public string surveyId { get; set; }

        public SendSurveyResponse(Macorva_Call_Log__c log, Id surveyId) {
            this.url = log.URL__c;
            this.request = log.Request_Body__c;
            this.responseCode = (integer)log.Response_Code__c;
            this.response = log.Response_Body__c;

            this.surveyId = surveyId;
        }
    }
}