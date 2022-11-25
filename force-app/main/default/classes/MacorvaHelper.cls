public class MacorvaHelper {

    public static HandleSurveyUpdateResponse HandleSurveyUpdate(Map<String, Object> surveyMap) {

        if (!surveyMap.containsKey('object_id')) {
            return new HandleSurveyUpdateResponse('object_id not found in the request', 400);
        }

        string objectId = String.valueOf((Integer)surveyMap.get('object_id'));

        List<Survey__c> surveys = [SELECT Id, Survey_Id__c FROM Survey__c WHERE Survey_Id__c = :objectId];

        if (surveys.size() == 0) {
            return new HandleSurveyUpdateResponse('Survey with id ' + objectId + ' not found in Salesforce', 400);
        }

        MacorvaAPI.MacorvaCallResult getRes = MacorvaAPI.GetSurvey(surveys[0].Survey_Id__c);
        MacorvaAPI.SaveLogs();

        if (!getRes.success) {
            return new HandleSurveyUpdateResponse('Call to get survey details failed', 500);
        }

        try {
            surveys[0].Status__c = 'Completed';
            Map<String, Object> getResMap = (Map<String, Object>)getRes.resultMap;
            system.debug('--getResMap--');
            system.debug(getResMap);
            if (getResMap.containsKey('survey_rating')) {
                surveys[0].survey_rating__c = (Decimal)getResMap.get('survey_rating');
            }
            if (getResMap.containsKey('survey_attributes_flattened')) {
                surveys[0].survey_attributes_flattened__c = (string)getResMap.get('survey_attributes_flattened');
            }
            if (getResMap.containsKey('comments')) {
                surveys[0].Comments__c = (String)getResMap.get('comments');
                if (surveys[0].Comments__c.length() > 2000) {
                    surveys[0].Comments__c = surveys[0].Comments__c.substring(0, 1995) + '...';
                }
            }

            update surveys[0];
        } catch (Exception ex) {
            return new HandleSurveyUpdateResponse(ex.getMessage(), 500);
        }

        return new HandleSurveyUpdateResponse();

    }

    public static boolean CreateSurveyHook() {

        Site site = [SELECT Id FROM Site WHERE Name = 'Macorva'];

        SiteDetail siteDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :site.Id];

        string url = siteDetail.SecureUrl + '/services/apexrest/Webhook';

        MacorvaAPI.MacorvaCallResult res = MacorvaAPI.CreateSurveyHook(url);

        MacorvaAPI.SaveLogs();

        return res.success && ((Map<String, Object>)res.resultMap).containsKey('id');
    }

    @Future(Callout=true)
    public static void SendSurvey(string surveyID, id contactId, string firstName, string lastName, string email,
                                  string phone, Integer delayInMinutes,
                                  string employeeNameID, string employeeName, string productID, string notes) {

        Map<String, Object> reqMap = new Map<String, Object>();

        reqMap.put('survey_id', surveyID);

        if (contactId != null) {
            Contact contact = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Id = :contactId];
            reqMap.put('customer_firstname', contact.firstName);
            reqMap.put('customer_lastname', contact.LastName);
            reqMap.put('customer_email', contact.Email);
            reqMap.put('customer_phone_number', contact.Phone);
        }
        else{
            reqMap.put('customer_firstname', firstName);
            reqMap.put('customer_lastname', LastName);
            reqMap.put('customer_email', Email);
            reqMap.put('customer_phone_number', Phone);
        }


        if ( delayInMinutes != null)
            reqMap.put('communication_delay_in_minutes', delayInMinutes);


        if (string.isNotBlank(employeeName)){
            string[] employeeNameList = new String[]{employeeName};
            reqMap.put('employee_names', employeeNameList);
        }
        if (string.isNotBlank(employeeNameID)){
            string[] employeeNameIDLIst = new String[]{employeeNameID};
            reqMap.put('employee_ids', employeeNameIDLIst);
        }

        if (string.isNotBlank(productID)){
            string[] productIDLIst = new String[]{'productID'};
            reqMap.put('product_ids', productIDLIst );
        }

        if (string.isNotBlank(notes)){
            reqMap.put('notes', notes);
        }

        MacorvaAPI.MacorvaCallResult res = MacorvaAPI.SendSurvey(reqMap);

        System.debug('SendSurveyResponse SendSurvey');
        System.debug(res);
        SendSurveyResponse toReturn = new SendSurveyResponse();
        Macorva_Call_Log__c lastLog = MacorvaAPI.LastLog();
        MacorvaAPI.SaveLogs();
        if (lastLog != null)
            toReturn.logId = lastLog.Id;

        if ((res!= null) && (res.success)) {

            Map<String, Object> resultMap = (Map<String, Object>)res.resultMap;
            System.debug(resultMap);

            Survey__c survey = new Survey__c();
            if (contactId != null) {
                survey.Contact__c = contactId;
            }
            survey.Survey_Id__c = String.valueOf((Integer)resultMap.get('survey_id'));
            survey.Survey_URL__c = (String) resultMap.get('survey_url');
            survey.Status__c = 'Sent';
            insert survey;
        }

        //return toReturn;
    }

    public class HandleSurveyUpdateResponse {
        public boolean success { get; set; }
        public string error { get; set; }
        public integer response_code { get; set; }

        public HandleSurveyUpdateResponse() {
            this.success = true;
        }

        public HandleSurveyUpdateResponse(string error, integer response_code) {
            this.success = false;
            this.error = error;
            this.response_code = response_code;
        }
    }

    public class SendSurveyResponse {
        public Id logId { get; set; }
        public Id surveyId { get; set; }
    }
    
}