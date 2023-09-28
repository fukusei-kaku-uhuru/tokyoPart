import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import cancleJob from '@salesforce/apex/JobKanriControl.cancleJob';

export default class JobKanriCancel extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @api invoke() {
        console.log('RecordId=' + this.recordId);
        cancleJob( { recordId : this.recordId} )
        .then(result => {
            if (result.status == 'OK' ) {
                getRecordNotifyChange([{recordId: this.recordId}]);
            }
        })
    }
}