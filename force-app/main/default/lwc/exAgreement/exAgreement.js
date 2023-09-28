import { LightningElement, api } from 'lwc';

import isSiteModeIppan from '@salesforce/apex/ExLwcUtil.isSiteModeIppan';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';

import register from '@salesforce/apex/ExAgreementController.register';

export default class ExAgreement extends LightningElement {
	@api pageNo;
	@api recordId;

	isSiteModeIppan = false;
	isSiteModeSatoya = false;

	isLoading = true;
	async connectedCallback() {
		const values = await Promise.all([
			this.isSiteModeIppan = await isSiteModeIppan({})
			,this.isSiteModeSatoya = await isSiteModeSatoya({})
		]);
		this.isSiteModeIppan = values[0];
		this.isSiteModeSatoya = values[1];

        this.isLoading = false;
	}

	async goNext() {

		const recordId = await register({recordId: this.recordId});

		// レコードId設定
		const recordIdEvent = new CustomEvent(
			'recordid',
			{ detail : recordId }
		);
		this.dispatchEvent(recordIdEvent);

		// 次の画面遷移
		let customEvent;
		if (this.isSiteModeSatoya) { // 里親の場合は画面をスキップして本人確認方法選択に遷移
			customEvent = new CustomEvent(
				'submit',
				{ detail : this.pageNo.HONNIN_KAKUNIN }
			);
		} else {
			customEvent = new CustomEvent(
				'submit',
				{ detail : this.pageNo.SEIYAKU }
			);
		}
		this.dispatchEvent(customEvent);
    }
}