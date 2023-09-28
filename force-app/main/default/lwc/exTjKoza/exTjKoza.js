import { LightningElement, api, track } from 'lwc';

import { showToast } from 'c/exShowToast';
import { errorHandle } from 'c/exErrorHandler';

import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import isNotSeikyushaKozaFilled from '@salesforce/apex/ExTaishoJidoUtil.isNotSeikyushaKozaFilled';

import getKozaData from '@salesforce/apex/ExTjKozaController.getKozaData';
import updateKozaData from '@salesforce/apex/ExTjKozaController.updateKozaData';

import EX_CMN_INPUT_ERROR from '@salesforce/label/c.EX_CMN_INPUT_ERROR';

export default class ExTjKoza extends LightningElement {

	@api pageNo;
	@api recordId;
	@api taishoJidoId;

	/**
	 * 項目ラベル
	 */
	taishoJidoLbl = {
		Shimei__c : ''
		,UketoriKouzaKubun_Taishosha__c : ''
		,UketoriKouzaKubun_Seikyusha__c : ''
		,YuchoKigo__c : ''
		,YuchoBango__c : ''
		,YuchoKouzaMeigi__c : ''
		,KinyuKikan__c : ''
		,KinyuKikanMei__c : ''
		,KinyuKikanCode__c : ''
		,Shiten__c : ''
		,ShitenMei__c : ''
		,ShitenCode__c : ''
		,KouzaBangou__c : ''
		,KouzaMeigi__c : ''
	};

	@track
	kozaData = {};

	isLoading = true;

	isSiteModeSatoya = false;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getKozaData({taishoJidoId: this.taishoJidoId})
				,getColumnLabels({ objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl) })
				,isSiteModeSatoya({})
			]);

			this.kozaData = values[0];
			this.taishoJidoLbl = values[1];
			this.isSiteModeSatoya = values[2];

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		this.isLoading = false;
	}

	/**
	 * 受取口座についてオプション
	 */
	get kouzaKubunOptions() {
		let options = [];

		if (this.kozaData.DairininSelectable) {
			options.push({ label: this.isSiteModeSatoya ? '認定請求援助者の名義' : '申請者の名義', value: this.kozaData.KOUZAKUBUN_DAIRININ });
		}
		if (this.kozaData.TaishoshaSelectable) {
			options.push({ label: this.isSiteModeSatoya ? '子供(対象者・認定請求者)の名義' : '対象者(子供)の名義', value: this.kozaData.KOUZAKUBUN_TAISHOSHA });
		}

		return options;
	}

	get isSelectedTaishosha() {
		return this.kozaData.UketoriKouzaKubun == this.kozaData.KOUZAKUBUN_TAISHOSHA;
	}

	async changeUketoriKouzaKubun(event) {
		this.changeInput(event);
		if (!this.isSelectedTaishosha && await isNotSeikyushaKozaFilled({ninteiSeikyuId: this.recordId})) {
			this.dispatchEvent(showToast('請求者の口座情報が登録されていません。後ほどご登録ください。', '', 'warning'));
		}
	}

	/**
	 * 値変更時処理
	 */
	changeInput(event) {
		if (typeof event.detail.checked != "undefined") {
			this.kozaData[event.target.dataset.id] = event.detail.checked;
			return;
		}
		this.kozaData[event.target.dataset.id] = event.detail.value;
	}

	/**
	 * 戻るボタン押下時
	 */
	goBack() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 次へボタン押下時
	 */
	async goNext() {

		if (!this.kozaData.isDisabled) {
			const isSuccess = await this.updateProc();
			if (!isSuccess) {
				return;
			}
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_KOZA_FILE }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 更新処理
	 */
	async updateProc() {

		// 入力チェック
		if (this.isError()) {
			this.dispatchEvent(showToast(EX_CMN_INPUT_ERROR, '', 'error'));
			return false;
		}

		// 口座情報更新処理呼び出し
		try {
			const kozaForm = this.template.querySelector('c-ex-koza-form');
			if (!!kozaForm) {
				this.kozaData.kfw = kozaForm.kfw;
			}
			const errors = await updateKozaData({kw: this.kozaData});

			// 入力チェックでエラーがあった場合、項目に設定する
			if (errors) {
				for (const error of errors) {
					const errorField = this.template.querySelector('[data-id="' + error.field + '"]');
					if (!!errorField) {
						errorField.setCustomValidity(error.message);
						errorField.reportValidity();
					}
				}

				kozaForm.setCustomValidity(errors);

				// メッセージを表示して処理終了
				this.dispatchEvent(showToast(EX_CMN_INPUT_ERROR, '', 'error'));
				return false;
			}
		} catch (error) {
			this.dispatchEvent(errorHandle(error));
			return false;
		}

		return true;
	}

	/**
	 * 入力チェック
	 * true:エラーあり false:問題なし
	 */
	isError() {

		// 1件でもエラー項目があった場合false
        const allInputValid = [	...this.template.querySelectorAll('lightning-input')
								,...this.template.querySelectorAll('lightning-radio-group')
								,...this.template.querySelectorAll('lightning-combobox')]
            .reduce((checkResult, inputFields) => {
				inputFields.setCustomValidity(''); // 登録時に発生したエラー内容を消去
                inputFields.reportValidity();	// 入力チェックを実施、画面側に反映させる
                return checkResult && inputFields.checkValidity(); // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);

		let kozaFormValid = true;
		const kozaForm = this.template.querySelector('c-ex-koza-form');
		if (kozaForm) {
			kozaFormValid = kozaForm.inputValid();
		}

		return !(allInputValid && kozaFormValid);
	}
}