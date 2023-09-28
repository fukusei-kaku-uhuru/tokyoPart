import { LightningElement, api } from 'lwc';
import { errorHandle } from 'c/exErrorHandler';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';

import getAddressByPostalCode from '@salesforce/apex/ExJushoFormController.getAddressByPostalcode';

export default class ExJushoForm extends LightningElement {
	@api yubinBango;
	@api jusho;
	@api isJushoSearchSuccess = false;
	@api yubinBangoDisabled = false;
	@api jushoDisabled = false;
	@api yubinBangoLabel = '郵便番号';
	@api jushoLabel = '住所';
	@api identifier = '';

	get yubinBangoDataId() {
		return `${this.identifier}yubinBango`;
	}

	get jushoDataId() {
		return `${this.identifier}jusho`;
	}

	isSiteModeDv = false;
	isSiteModeSatoya = false;
	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				isSiteModeDv({})
				,isSiteModeSatoya({})
			]);

			this.isSiteModeDv = values[0];
			this.isSiteModeSatoya = values[1];

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}
	}

	async searchJusho() {
		try {
			if (this.yubinBango.length == 7) {
				this.yubinBango = this.yubinBango.slice(0, 3) + '-' + this.yubinBango.slice(3);
			}
			const result = await getAddressByPostalCode({postalCode: this.yubinBango});

			// 住所が非活性でなければ、値をセットする
			if (!this.jushoDisabled) {
				this.jusho = result.todoFuken;
				this.jusho += result.shikuChoson;
				this.jusho += result.chiban;

				this.dispatchChangeJusho();

				this.checkValidity = true;
			}

			this.isJushoSearchSuccess = true;
			this.yubinBangoFieldValid();

		} catch(error) {

			this.isJushoSearchSuccess = false;
			this.yubinBangoFieldValid();
		}
	}

	// 郵便番号検索後、入力チェックを再度行う
	// 再描画後で実行しないとうまく値チェックができない
	checkValidity = false;
	renderedCallback() {
		if (this.checkValidity) {
			[...this.template.querySelectorAll('lightning-input')]
			.forEach((inputField) => {
				inputField.reportValidity();
			});

			this.checkValidity = false;
		}

	}

	changeYubinBango(event) {

		this.yubinBango = event.detail.value;
		this.isJushoSearchSuccess = false;
		this.dispatchChangeJusho();

		event.target.setCustomValidity('');
		event.target.reportValidity();
	}

	get jushoPlaceHolder() {
		if (this.isSiteModeDv) {
			return '東京都新宿区';
		}
		return '東京都新宿区西新宿２−８−１';
	}

	changeJusho(event) {
		this.jusho = event.detail.value;
		this.dispatchChangeJusho();
	}

	/**
	 * 住所変更を親コンポーネントに伝える
	 */
	dispatchChangeJusho() {
		const detailObj = {
			yubinBango : this.yubinBango
			,jusho : this.jusho
		};

		const customEvent = new CustomEvent(
			'changejusho',
			{ detail : detailObj }
		);

		this.dispatchEvent(customEvent);
	}

	@api
	inputValid() {
		// 1件でもエラー項目があった場合false
        const allInputValid = [	...this.template.querySelectorAll('lightning-input')]
            .reduce((checkResult, inputFields) => {
                inputFields.reportValidity();	// 入力チェックを実施、画面側に反映させる
                return checkResult && inputFields.checkValidity(); // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);

		this.yubinBangoFieldValid();

		// DV被害者の場合は郵便番号検索を実施しない
		if (this.isSiteModeDv) {
			this.isJushoSearchSuccess = true;
		}

		return allInputValid && this.isJushoSearchSuccess;
	}

	/**
	 * 郵便番号項目の検索結果をセットする
	 */
	yubinBangoFieldValid() {
		const jushoField = this.template.querySelector(`[data-id="${this.identifier}yubinBango"]`);
		if (this.isSiteModeDv) { return; }

		if (this.isJushoSearchSuccess) {
			jushoField.setCustomValidity('');
		} else {
			jushoField.setCustomValidity('住所が見つかりませんでした');
		}
		jushoField.reportValidity();
	}

	@api setCustomValidity(errors) {
		// 入力チェックでエラーがあった場合、項目に設定する
		if (errors) {
			for (const error of errors) {
				const errorField = this.template.querySelector('[data-id="' + error.field + '"]');
				if (!!errorField) {
					errorField.setCustomValidity(error.message);
					errorField.reportValidity();
				}
			}
		}
	}
}