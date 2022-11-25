({
    loadContactDetails : function(component, event, helper) {

        var action = component.get("c.GetContactDetails");
        action.setParams({ contactId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = response.getReturnValue();
                
                component.set('v.contact', retValue);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            component.set('v.waiting', false);
        });

        component.set('v.waiting', true);
        $A.enqueueAction(action);

    },

    SendTheSurvey : function(component, event, helper) {

        var action = component.get("c.SendSurvey");
        action.setParams({ 
                contactId : component.get("v.recordId"),
                byEmail : component.get("v.sendBy") == 'email'
            });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = response.getReturnValue();
                
                component.set('v.sendResponse', retValue);

                component.set('v.sent', true);

                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            component.set('v.waiting', false);
        });

        component.set('v.waiting', true);
        $A.enqueueAction(action);

    }
})