import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import getSiteMode from '@salesforce/apex/ExJukyuJiyuShometsuTodokeController.getSiteMode';

export default class ExJukyuJiyuShometsuTodoke extends NavigationMixin(LightningElement) {

    recordId = '';
    parentId = '';
    isDisplay = true;
    isIppan = false;
    isDV = false;

    connectedCallback() {
        getSiteMode({})
            .then(result => {
                if(result == '一般') {
                    this.isIppan = true;
                }else if(result == 'DV' || result == '里親') {
                    this.isDV = true;
                }
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
        // URLを取得
        const url = new URL(window.location.href);
        // URLSearchParamsオブジェクトを取得
        const params = url.searchParams;
        this.recordId = params.get('recordId');
        this.parentId = params.get('parentId');
    }

    // フローに渡す値
    get inputVariables() {
        return [
        {
            name : 'recordId', // フローの変数 API参照名
            type : 'String', // フローの変数型
            value : this.recordId // 値
        }
        ];
    }

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.isDisplay = false;
        }
    }

    goBack() {
        console.log(this.parentId);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_application_result__c'
            },
            state: {
                recordId: this.parentId,
            }
        });
    }
}