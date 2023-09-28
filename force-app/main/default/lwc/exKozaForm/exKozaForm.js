import { LightningElement, api, track } from 'lwc';

import { errorHandle } from 'c/exErrorHandler';

import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';

import EX_TJD_Shumoku from '@salesforce/label/c.EX_TJD_Shumoku';
import EX_TJD_YuchoShumoku from '@salesforce/label/c.EX_TJD_YuchoShumoku';

export default class ExKozaForm extends LightningElement {

	@track
	_kfw = {};

	@api get kfw(){
		return this._kfw;
	}
	set kfw(kfw) {
		this._kfw = JSON.parse(JSON.stringify(kfw));
	}

	@api isDisabled = false;
	@api required = false;

	/**
	 * カスタム表示ラベル
	 */
	label = {
		EX_TJD_Shumoku
		,EX_TJD_YuchoShumoku
	};

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
		,Shiten__c : ''
	};

	isLoading = true;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getColumnLabels({objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl)})
			]);

			this.taishoJidoLbl = values[0];

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
		if (this._kfw.TaishoshaSelectable) {
			options.push({ label: this.taishoJidoLbl.UketoriKouzaKubun_Taishosha__c, value: this._kfw.KOUZAKUBUN_TAISHOSHA });
		}
		if (this._kfw.DairininSelectable) {
			options.push({ label: this.taishoJidoLbl.UketoriKouzaKubun_Seikyusha__c, value: this._kfw.KOUZAKUBUN_DAIRININ });
		}

		return options;
	}

	/**
	 * 銀行の選択オプション
	 */
	get ginkoKubunOptions() {
		return [
			{ label: 'ゆうちょ銀行', value: this._kfw.GINKOKUBUN_YUCHO }
			,{ label: 'その他の銀行', value: this._kfw.GINKOKUBUN_OTHER }
		];
	}
	get isYucho() {
		return this._kfw.GinkoKubun == this._kfw.GINKOKUBUN_YUCHO;
	}

	get bunruiOptions() {
		let options = [];
		if (!this.required) {
			options.push({ label: '', value: '' });
		}

		return options.concat([
			{ label: '普通', value: this._kfw.SHUMOKU_FUTSU }
			,{ label: '当座', value: this._kfw.SHUMOKU_TOZA }
			,{ label: '貯蓄', value: this._kfw.SHUMOKU_TYOCHIKU }
		]);
	}

	get yuchoBunruiOptions() {
		let options = [];
		if (!this.required) {
			options.push({ label: '', value: '' });
		}

		return options.concat([
			{ label: '総合口座', value: this._kfw.YUCHO_SHUMOKU_SOGO }
			,{ label: '通常貯金', value: this._kfw.YUCHO_SHUMOKU_TSUJYO }
			,{ label: '通常貯蓄貯金', value: this._kfw.YUCHO_SHUMOKU_TYOCHIKU }
			,{ label: '振替口座', value: this._kfw.YUCHO_SHUMOKU_FURIKAE }
		]);
	}

	/**
	 * 値変更時処理
	 * 支店ルックアップの条件文を更新する
	 */
	async changeKinyuKikan(event) {
		this._kfw.KinyuKikan = event.detail.selectedId;
		this._kfw.KinyuKikanDispName = event.detail.selectedName;

		// 支店をリセット
		const customLookup = this.template.querySelector('[data-id="Shiten"]');
		if (this._kfw.KinyuKikan == '') {
			customLookup.value = '';
		}
	}

	get shitenParams() {
		return {
			'kinyuKikan' : this._kfw.KinyuKikan
		}
	}

	/**
	 * 値変更時処理
	 * 支店ルックアップ選択
	 */
	async changeShiten(event) {
		this._kfw.Shiten = event.detail.selectedId;
		this._kfw.ShitenDispName = event.detail.selectedName;
	}

	/**
	 * 値変更時処理
	 */
	changeInput(event) {
		if (typeof event.detail.checked != "undefined") {
			this._kfw[event.target.dataset.id] = event.detail.checked;
			return;
		}
		this._kfw[event.target.dataset.id] = event.detail.value;
	}

	/**
	 * 入力チェック
	 */
	@api inputValid() {

		// 1件でもエラー項目があった場合false
        const allInputValid = [	...this.template.querySelectorAll('lightning-input')
								,...this.template.querySelectorAll('lightning-radio-group')
								,...this.template.querySelectorAll('lightning-combobox')]
            .reduce((checkResult, inputFields) => {
				inputFields.setCustomValidity(''); // 登録時に発生したエラー内容を消去
                inputFields.reportValidity();	// 入力チェックを実施、画面側に反映させる
                return checkResult && inputFields.checkValidity(); // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);

		let customLookupValid = true;
		const customLookup = this.template.querySelectorAll('c-ex-custom-lookup');
		if (customLookup) {
			customLookupValid = [...customLookup].reduce((checkResult, inputFields) => {
                return inputFields.inputValid() && checkResult; // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);
		}

		return allInputValid && customLookupValid;
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