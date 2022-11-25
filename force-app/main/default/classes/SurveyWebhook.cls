@RestResource(urlMapping='/Webhook')
global class SurveyWebhook {
    
    @HttpPost
    global static void HandlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        string reqStr;
        Map<String, Object> reqMap;
        try {
            reqStr = req.requestBody.toString();
            reqMap = (Map<String, Object>)JSON.deserializeUntyped(reqStr);
        } catch (Exception ex) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(ex.getMessage());
        }
        if (reqMap != null) {
            MacorvaHelper.HandleSurveyUpdateResponse resp = MacorvaHelper.HandleSurveyUpdate(reqMap);
            if (resp.success) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(resp));
            } else {
                res.statusCode = resp.response_code;
                res.responseBody = Blob.valueOf(JSON.serialize(resp));
            }
        }
        
        if (MacorvaAPI.Settings.Save_Logs__c) {
            Macorva_Call_Log__c log = new Macorva_Call_Log__c();
            log.Direction__c = 'Inbound';
            log.URL__c = req.requestURI;
            log.Method__c = 'POST';
            log.Success__c = true;
            log.Response_Code__c = res.statusCode;
            log.Request_Body__c = req.requestBody.toString();
            log.Response_Body__c = res.responseBody.toString();
            insert log;
        }
    }

}