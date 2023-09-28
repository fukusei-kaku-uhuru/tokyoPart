import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import registJob from '@salesforce/apex/JobKanriControl.registJob';

export default class JobKanriRegist extends NavigationMixin(LightningElement) {
        @api recordId;
        @api objectApiName;
    
        @api invoke() {
            console.log('RecordId=' + this.recordId);
            registJob( { recordId : this.recordId} )
            .then(result => {
                if (result.status == 'OK' ) {
                    getRecordNotifyChange([{recordId: this.recordId}]);
                }
            })
            
        }
}