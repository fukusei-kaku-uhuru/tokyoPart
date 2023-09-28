({
    openPreview: function(contentDocumentId) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: [contentDocumentId]
        });
    }
})