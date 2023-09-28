import { LightningElement, api } from 'lwc';

import getErrorMessage from '@salesforce/apex/ExMyNumberController.getErrorMessage'

export default class ExMyNumberError extends LightningElement {

	@api pageNo;
	@api recordId;

	errorMessage;

	isLoading = true;

	async connectedCallback(){
		this.errorMessage = await getErrorMessage({ninteiId: this.recordId}).catch((error) => console.log(error));
		this.isLoading = false;
	}

	goBack() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.HONNIN_KAKUNIN }
		);

		this.dispatchEvent(clickEvent);
	}
}