import { LightningElement, api, track } from 'lwc';

import { showToast } from 'c/exShowToast';
import { errorHandle } from 'c/exErrorHandler';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';

import getMoushitateData from '@salesforce/apex/ExTjMoushitateController.getMoushitateData';
import updateTaishoJido from '@salesforce/apex/ExTjMoushitateController.updateTaishoJido';

import EX_TJD_Bekkyo_Tanshinfunin from '@salesforce/label/c.EX_TJD_Bekkyo_Tanshinfunin';
import EX_TJD_Bekkyo_Shingaku from '@salesforce/label/c.EX_TJD_Bekkyo_Shingaku';
import EX_TJD_Bekkyo_Sonota from '@salesforce/label/c.EX_TJD_Bekkyo_Sonota';

import EX_CMN_INPUT_ERROR from '@salesforce/label/c.EX_CMN_INPUT_ERROR';


export default class ExTjMoushitate extends LightningElement {

	@api pageNo;
	@api recordId;
	@api taishoJidoId;

	/**
	 * 項目ラベル
	 */
	taishoJidoLbl = {
		Shimei__c : ''
		,Moushitate_KokenninCheck__c : ''
		,Moushitate_BekkyoKango__c : ''
		,Moushitate_KaigaiRyugakuCheck__c : ''
		,Moushitate_RikonKyogiCheck__c : ''
		,Moushitate_FuboSiteishaCheck__c : ''
		,Moushitate_BekkyoRiyuSonota__c : ''
		,Moushitate_BekkyoKaishiDate__c : ''
		,Moushitate_BekkyoShuryoDate__c : ''
		,Moushitate_KangoJokyo__c : ''
		,Moushitate_RyugakusakiMei__c : ''
		,Moushitate_RyugakumaeKyojuKaishiDate__c : ''
		,Moushitate_RyugakumaeKyojuShuryoDate__c : ''
		,Moushitate_RyugakumaeKyojuYubinBango__c : ''
		,Moushitate_RyugakumaeJusho__c : ''
	};

	/**
	 * 項目ラベル
	 */
	taishoJidoDvLbl = {
		Moushitate_BetsuJushoCheck__c : ''
	};

	@track
	moushitateData = {};

	isSiteModeDv = false;

	isLoading = true;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getColumnLabels({objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl)})
				,getColumnLabels({objectName: 'DV_TaishoJido__c', columnNames: Object.keys(this.taishoJidoDvLbl)})
				,isSiteModeDv({})
				,getMoushitateData({taishoJidoId: this.taishoJidoId})
			]);

			this.taishoJidoLbl = values[0];
			this.taishoJidoDvLbl = values[1];
			this.isSiteModeDv = values[2];
			this.moushitateData = values[3];

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		if (!!this.moushitateData.RyugakumaeKyojuYubinBango) {
			this.isJushoSearchSuccess = true;
		}

		this.isLoading = false;
	}

	get isBekkyoOrRyugaku() {
		return this.moushitateData.IsBekkyo || this.moushitateData.IsRyugaku;
	}

	get isBekkyoRiyuSonota() {
		return this.moushitateData.BekkyoRiyu == this.moushitateData.RIYU_SONOTA;
	}

	get bekkyoRiyuOptions() {
		return [
			{ label: EX_TJD_Bekkyo_Tanshinfunin, value: this.moushitateData.RIYU_TANSHIN}
			,{ label: EX_TJD_Bekkyo_Shingaku, value: this.moushitateData.RIYU_SHINGAKU}
			,{ label: EX_TJD_Bekkyo_Sonota, value: this.moushitateData.RIYU_SONOTA}
		];
	}

	isJushoSearchSuccess = false;
	/**
	 * 住所変更時処理
	 */
	changeJusho(event) {
		this.moushitateData.RyugakumaeKyojuYubinBango = event.detail.yubinBango;
		this.moushitateData.RyugakumaeKyojuJusho = event.detail.jusho;
	}

	/**
	 * 値変更時処理
	 */
	changeInput(event) {
		if (typeof event.detail.checked != "undefined") {
			this.moushitateData[event.target.dataset.id] = event.detail.checked;
			return;
		}
		this.moushitateData[event.target.dataset.id] = event.detail.value;
	}

	/**
	 * 次へボタン押下時
	 */
	async goNext() {

		if (!this.moushitateData.isDisabled) {
			const isSuccess = await this.updateProc();
			if (!isSuccess) {
				return;
			}
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_MOUSHITATE_FILE }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 更新処理
	 */
	async updateProc() {
		// 入力チェック
		if(this.isError()) {
			this.dispatchEvent(showToast(EX_CMN_INPUT_ERROR, '', 'error'));
			return false;
		}

		// 申立書情報更新 呼び出し
		try{
			const errors = await updateTaishoJido({mw: this.moushitateData});

			// 入力チェックでエラーがあった場合、項目に設定する
			if (errors) {
				for (const error of errors) {
					const errorField = this.template.querySelector('[data-id="' + error.field + '"]');
					if (!!errorField) {
						errorField.setCustomValidity(error.message);
						errorField.reportValidity();
					}
				}

				const jushoForm = this.template.querySelector('c-ex-jusho-form');
				if (!!jushoForm) {
					jushoForm.setCustomValidity(errors);
				}

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
								,...this.template.querySelectorAll('lightning-combobox')]
            .reduce((checkResult, inputFields) => {
				inputFields.setCustomValidity(''); // 登録時に発生したエラー内容を消去
                inputFields.reportValidity();	// 入力チェックを実施、画面側に反映させる
                return checkResult && inputFields.checkValidity(); // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);

		const jushoForm = this.template.querySelector('c-ex-jusho-form');
		let jushoValid = true;
		if (jushoForm) {
			jushoValid = jushoForm.inputValid();
		}

		return !(allInputValid && jushoValid);
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
}