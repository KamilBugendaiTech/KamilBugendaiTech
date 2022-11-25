({
    doInit : function(component, event, helper) {
        helper.loadContactDetails(component, event, helper);
    },

    SendTheSurvey : function(component, event, helper) {
        helper.SendTheSurvey(component, event, helper);
    },

    GoToSurvey : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": component.get('v.sendResponse').surveyId,
        "slideDevName": "detail"
        });
        navEvt.fire();
    }
})