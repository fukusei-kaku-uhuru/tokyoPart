({
    handleMessage: function (component, message, helper) {

        const contentDocumentId = message.getParam("contentDocumentId");
        helper.openPreview(contentDocumentId);
    }
})