import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import getFubiTsuchi from '@salesforce/apex/ExFubiTsuchiContloller.getFubiTsuchi';

export default class ExNinteiKekka extends NavigationMixin(LightningElement) {

    parentList = [];
    recordId = '';

	connectedCallback() {
        // URLを取得
        const url = new URL(window.location.href);
        // URLSearchParamsオブジェクトを取得
        const params = url.searchParams;
        this.recordId = params.get('recordId');
        getFubiTsuchi({ ninteiSeikyuId: this.recordId })
            .then(result => {
                const fubiTsuchiList = JSON.parse(JSON.stringify(result.fubiTsuchiList));
                this.dataList = result.fubiTsuchiList;
                this.parentList = fubiTsuchiList.map(x => {
                    const data = {
                        parentId: x.parentId,
                        fubiTaishoshaShimei: x.fubiTaishoshaShimei,
                        kofuDate: x.kofuDate,
                    }
                    return data;
                })
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
    }

    goDetail(event) {
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'FubiTsuchi__c',
                actionName: 'view'
            }
        });
    }

    goBack(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_application_list__c',
            },
        });
    }

}