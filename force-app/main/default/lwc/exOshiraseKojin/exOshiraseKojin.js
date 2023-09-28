import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import getOshiraseKojin from '@salesforce/apex/ExOshiraseKojinController.getLast5Record';

export default class ExOshiraseKojin extends NavigationMixin(LightningElement) {

    dispList = [];

	connectedCallback() {
        getOshiraseKojin({})
            .then(result => {
                const oshiraseList = JSON.parse(JSON.stringify(result.oshiraseList));
                this.dataList = result.oshiraseList;
                this.dispList = oshiraseList.map(x => {
                    const data = {
                        dataId: x.dataId,
                        title: x.title,
                        kokaiKaishiDate: x.kokaiKaishiDate,
                    }
                    return data;
                })
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
    }

    goOshirase(event) {
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'KojinOshirase__c',
                actionName: 'view'
            }
        });
    }

    goAllData(event) {
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'KojinOshirase__c',
                actionName: 'list'
            },
            state: {
                'KojinOshirase__c-filterId': 'All'
            }
        });
    }

}