import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import getOshiraseZentai from '@salesforce/apex/ExOshiraseZentaiController.getLast5Record';

export default class ExOshiraseZentai extends NavigationMixin(LightningElement) {

    dispList = [];

	connectedCallback() {
        getOshiraseZentai({})
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
                objectApiName: 'ZentaiOshirase__c',
                actionName: 'view'
            }
        });
    }

    goAllData(event) {
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ZentaiOshirase__c',
                actionName: 'list'
            },
            state: {
                'ZentaiOshirase__c-filterId': 'All'
            }
        });
    }

    // goAllData(event) {
    //     const id = event.target.dataset.id;
    //     this[NavigationMixin.Navigate]({
    //         type: 'comm__namedPage',
    //         attributes: {
    //             name: 'custom_application_result__c'
    //         },
    //         state: {
    //             recordId: 'a001y000006ak8UAAQ'
    //         }
    //     });
    // }
    
}