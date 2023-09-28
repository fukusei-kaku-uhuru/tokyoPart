import { LightningElement, api } from 'lwc';

export default class ExMyNumberSuccess extends LightningElement {

	@api pageNo;

	goNext() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.SEIKYUSHA }
		);

		this.dispatchEvent(clickEvent);
	}
}