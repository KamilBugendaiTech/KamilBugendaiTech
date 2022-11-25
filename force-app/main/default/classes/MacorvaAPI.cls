public class MacorvaAPI {

    private static List<Macorva_Call_Log__c> logs = new List<Macorva_Call_Log__c>();
    //private static MacorvaCallResult response;

    private static Macorva_API__mdt settingsPrivate;
    public static Macorva_API__mdt Settings { 
        get {
            if (settingsPrivate == null)
                settingsPrivate = [SELECT Base_URL__c, Username__c, Password__c, Save_Logs__c 
                                        FROM Macorva_API__mdt LIMIT 1];
            return settingsPrivate;
        }
    }

    public static string TestConnection() {
        
        String requestUrl = '/api/v1/customer/surveys/';


        MacorvaCallResult response = MakeAPICall(requestUrl, 'GET', null);

        return response.result;
        
    }

    public static MacorvaCallResult SendSurvey(Map<String, Object> reqMap) {

        String requestUrl = '/api/v1/customer/feedback-requests/deliver/';
        System.debug('Call body');
        System.debug(JSON.serialize(reqMap));
        MacorvaCallResult response =MakeAPICall(requestUrl, 'POST', JSON.serialize(reqMap));
        return response;

    }

    public static MacorvaCallResult GetSurvey(string surveyId) {

        String requestUrl = '/api/v1/customer/feedback-requests/' + surveyId + '/';
        MacorvaCallResult response =MakeAPICall(requestUrl, 'GET', null);
        return response;

    }

    public static MacorvaCallResult GetListOfHooks() {

        String requestUrl = '/api/v1/customer/hooks/';

        MacorvaCallResult response = MakeAPICall(requestUrl, 'GET', null);
        
        return response;

    }

    public static MacorvaCallResult CreateSurveyHook(string url) {

        string jsonReq = '{ "url": "' + url + '", "event_type": "survey.completed" }';

        String requestUrl = '/api/v1/customer/hooks/';

        MacorvaCallResult response =MakeAPICall(requestUrl, 'POST', jsonReq);
        
        return response;

    }

    private static MacorvaCallResult MakeAPICall(string url, string method, string body) {

        System.debug('--MakeAPICall--');
        System.debug(url);
        System.debug(method);
        System.debug(body);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Settings.Username__c + ':' + Settings.Password__c)));
        req.setEndpoint(Settings.Base_Url__c + url);
        req.setMethod(method);
        if (body != null)
            req.setBody(body);
        system.debug('before http post');
        HttpResponse res = h.send(req);
        system.debug('after http post');

        System.debug(res);

        if (Settings.Save_Logs__c) {
            Macorva_Call_Log__c log = new Macorva_Call_Log__c();
            log.Direction__c = 'Outbound';
            log.URL__c = Settings.Base_Url__c + url;
            log.Method__c = method;
            log.Success__c = res.getStatusCode() >= 200 && res.getStatusCode() < 300;
            log.Response_Code__c = res.getStatusCode();
            if (body != null)
                log.Request_Body__c = body;
            log.Response_Body__c = res.getBody();
            logs.add(log);
        }

        MacorvaCallResult response;
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300)
            response = new MacorvaCallResult(true, res.getBody());
        else
            response = new MacorvaCallResult(false, res.getBody());
        return response;
    }

    public static Macorva_Call_Log__c LastLog() {
        if (logs != null && logs.size() > 0)
            return logs[logs.size() - 1];
        return null;
    }

    public static void SaveLogs() {
        if (Settings.Save_Logs__c) {
            insert logs;
        }
        logs = new List<Macorva_Call_Log__c>();
    }

    public class MacorvaCallResult {
        public boolean success { get; set; }
        public string result { get; set; }

        public Object resultMap {
            get {
                try {
                    return JSON.deserializeUntyped(result);
                } catch(Exception ex) { return null; }
            }
        }

        public MacorvaCallResult(boolean success, string result) {
            this.success = success;
            this.result = result;
        }
    }

}