import { LightningElement, api } from 'lwc';
import { errorHandle } from 'c/exErrorHandler';

import getNinteiSeikyu from '@salesforce/apex/ExKakunin18Controller.getNinteiSeikyu';
import updateNinteiSeikyu from '@salesforce/apex/ExKakunin18Controller.updateNinteiSeikyu';

import isNinteiSeikyuDisabled from '@salesforce/apex/ExLwcUtil.isNinteiSeikyuDisabled';

export default class ExKakunin18 extends LightningElement {
	@api pageNo;
	@api recordId;

	isLoading = true;
	isEditDisabled = true;
	isNextDisabled = true;

    checkedInclude18 = false;
    checkedIncludeNot18 = false;

	async connectedCallback() {
		this.isEditDisabled = await isNinteiSeikyuDisabled({recordId: this.recordId});
        await getNinteiSeikyu({recordId: this.recordId})
            .then(result => {
                this.checkedInclude18 = result.include18;
                this.checkedIncludeNot18 = result.includeNot18;
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
        await this.visibleControl();
        this.isLoading = false;
	}

    onchangeRadio(event) {
        if (event.target.value == "include18") {
            this.checkedInclude18 = true;
            this.checkedIncludeNot18 = false;
        }
        else {
            this.checkedInclude18 = false;
            this.checkedIncludeNot18 = true;
        }
        this.visibleControl();
    }

    async visibleControl() {
        // 次へボタン制御
        if (this.checkedIncludeNot18 || this.checkedInclude18) {
            this.isNextDisabled = false;
        }
        else {
            this.isNextDisabled = true;
        }
    }

	goBack() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.SEIYAKU }
		);
		this.dispatchEvent(clickEvent);
	}

	async goNext() {
		this.isLoading = true;
		let isError = false;
		if (!this.isEditDisabled) {
            await updateNinteiSeikyu({
                recordId: this.recordId,
                isInclude18: this.checkedInclude18
            })
            .then(result => {
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
                isError = true;
            });
        }
		if (isError) {
			this.isLoading = false;
			return;
		}

        const clickEvent = new CustomEvent(
            'submit',
            { detail : this.pageNo.HONNIN_KAKUNIN }
        );
        this.dispatchEvent(clickEvent);
	}
}