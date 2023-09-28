({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        const action = component.get("c.selfRegister");

        const email = component.find("email").get("v.value");
        const password = component.find("password").get("v.value");
        const confirmPassword = component.find("confirmPassword").get("v.value");
        
        action.setParams({email:email, password:password, confirmPassword:confirmPassword});
        action.setCallback(this, function(a){
            const rtnValue = a.getReturnValue();

            if (rtnValue.isError) {
                console.log('error occur');
                component.set("v.showError", true);
                component.set("v.errorMessage", rtnValue.message);
            }
            else{
                component.set("v.selfRegId", rtnValue.responseMap['selfRegId']);
                component.set("v.showError", false);
                component.set("v.errorMessage", '');
                component.set("v.emailValue", email);
                component.set("v.isConfirm", true);
                component.set("v.isInput", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helpler) {        
        const expId = component.get("v.expid");
        if (expId) {
            const action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },

    handleVerifyUser: function (component, event, helper) {
        const selfRegId = component.get("v.selfRegId");
        const code = component.find("verifyCode").get("v.value");
        const email = component.find("email").get("v.value");
        const password = component.find("password").get("v.value");
        const action = component.get("c.verifyUser");

        action.setParams({selfRegId:selfRegId, code:code, email:email, password:password});
        action.setCallback(this, function(a){
            const rtnValue = a.getReturnValue();
            if(rtnValue.isError){
                component.set("v.showError", true);
                component.set("v.errorMessage", rtnValue.message);
            }
        });
        
        $A.enqueueAction(action);
    },

    handleCancelVerification: function (component, event, helper) {
        component.set("v.isConfirm",false);
        component.set("v.isInput",true);
    },
})