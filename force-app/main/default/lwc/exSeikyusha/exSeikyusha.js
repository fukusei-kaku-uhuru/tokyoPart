import { LightningElement, api, track } from 'lwc';

import { showToast } from 'c/exShowToast';
import { errorHandle } from 'c/exErrorHandler';
import ExModal from 'c/exModal';


import isSiteModeIppan from '@salesforce/apex/ExLwcUtil.isSiteModeIppan';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import getPickList from '@salesforce/apex/ExLwcUtil.getPickList';

import getSeikyushaData from '@salesforce/apex/ExSeikyushaController.getSeikyushaData';
import getKozaShoruiList from '@salesforce/apex/ExSeikyushaController.getKozaShoruiList';
import updateSeikyusha from '@salesforce/apex/ExSeikyushaController.updateSeikyusha';
import needUploadShinseiShorui from '@salesforce/apex/ExSeikyushaController.needUploadShinseiShorui';

import ImgExTjKozaSample1 from '@salesforce/resourceUrl/ExTjKozaSample1';
import ImgExTjKozaSample2 from '@salesforce/resourceUrl/ExTjKozaSample2';
import ImgExTjKozaSample3 from '@salesforce/resourceUrl/ExTjKozaSample3';

export default class ExSeikyusha extends LightningElement {

	// 親コンポーネントからのパラメータ
	@api pageNo;
	@api recordId = '';

	/**
	 * 項目ラベル
	 */
	seikyushaLbl = {
		ShimeiFurigana__c : ''
		,Shimei__c : ''
		,SeinenGappiDate__c : ''
		,DenwaBangou__c : ''
		,MailAddress__c : ''
	};

	/**
	 * 請求者データ
	 */
	@track
	seikyushaData = {};

	kozaShoruiList = [];

	shisetsuShuruiOptions = [];

	isSiteModeIppan = false;
	isSiteModeSatoya = false;
	isLoading = true;
	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getSeikyushaData({id: this.recordId})
				,getColumnLabels({objectName: 'Seikyusha__c', columnNames: Object.keys(this.seikyushaLbl)})
				,isSiteModeIppan({})
				,isSiteModeSatoya({})
				,getPickList({objectName: 'DV_Seikyusha__c', columnName: 'Shisetsu_Shurui__c'})
			]);

			this.seikyushaData = values[0];
			this.seikyushaLbl = values[1];
			this.isSiteModeIppan = values[2];
			this.isSiteModeSatoya = values[3];
			this.shisetsuShuruiOptions = values[4];

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		this.isLoading = false;

		this.kozaShoruiList = this.seikyushaData.KozaShoruiList;

		// 住所入力済、もしくは公的個人認証の場合は住所検索成功フラグをtrueとする
		if (!!this.seikyushaData.YubinBangou || this.seikyushaData.isTrustdocApproved) {
			this.isJushoSearchSuccess = true;
		}
	}

	get imgSample1() {
		return ImgExTjKozaSample1;
	}
	get imgSample2() {
		return ImgExTjKozaSample2;
	}
	get imgSample3() {
		return ImgExTjKozaSample3;
	}

	get isNotSelectedSatoya() {
		return this.isSiteModeSatoya && this.seikyushaData.ShisetsuShurui != '里親';
	}

	blurInputFullSpace(event) {
		const value = event.target.value.replaceAll(' ', '　');

		this.seikyushaData[event.target.getAttribute('data-id')] = value;

		// 画面エラーが発生しないように、JS処理内にてvalueを上書き → 警告チェックする
		event.target.value = value;
		event.target.reportValidity();
	}

	get shimeiLbl() {
		if (this.isSiteModeSatoya) {
			return '里親等氏名';
		}
		return '氏名';
	}
	get shimeiFuriganaLbl() {
		if (this.isSiteModeSatoya) {
			return '里親等氏名(フリガナ)';
		}
		return '氏名(フリガナ)';
	}

	get isEditableMyNumberColumn() {
		return this.seikyushaData.isTrustdocApproved || this.seikyushaData.isDisabled;
	}

	get yubinBangoLbl() {
		if (this.isSiteModeSatoya) {
			return '施設等所在地または里親住所地 郵便番号';
		}
		return '郵便番号';
	}
	get jushoLbl() {
		if (this.isSiteModeSatoya) {
			return '施設等所在地または里親住所地 住所';
		}
		return '住所';
	}
	isJushoSearchSuccess = false;
	/**
	 * 値変更時処理
	 * 住所フォームコンポーネントからの値を受け取り設定する
	 */
	changeJusho(event) {
		const jusho = event.detail;

		this.seikyushaData.YubinBangou = jusho.yubinBango;
		this.seikyushaData.Jusho = jusho.jusho;
	}

	/**
	 * 口座確認書類 ファイル操作後処理
	 */
	async handleKozaUploaded() {
		this.kozaShoruiList = await getKozaShoruiList({seikyushaId: this.seikyushaData.Id});
	}
	async handleKozaDeleted() {
		this.kozaShoruiList = await getKozaShoruiList({seikyushaId: this.seikyushaData.Id});
	}

	/**
	 * 値変更時処理
	 */
	changeInput(event) {
		this.seikyushaData[event.target.getAttribute('data-id')] = event.detail.value;
	}

	/**
	 * 戻るボタン押下時
	 */
	async goBack() {

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.HONNIN_KAKUNIN }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 次へボタン押下時
	 */
	async goNext() {

		if (!this.seikyushaData.isDisabled) {
			const isSuccess = await this.upsertProc();
			if (!isSuccess) {
				return;
			}

			if (await this.checkNeedUpload()) {
				return;
			}
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO }
		);

		this.dispatchEvent(clickEvent);
	}

	async upsertProc() {

		// 入力チェック
		if(this.isError()) {
			this.dispatchEvent(showToast('入力エラーがあります', '', 'error'));
			return false;
		}

		// 請求者登録処理呼び出し
		try{
			const kozaForm = this.template.querySelector('c-ex-koza-form');
			if (!!kozaForm) {
				this.seikyushaData.kfw = kozaForm.kfw;
			}
			const errors = await updateSeikyusha({param: this.seikyushaData});

			// 入力チェックでエラーがあった場合、項目に設定する
			if (errors) {
				for (const error of errors) {
					const errorField = this.template.querySelector('[data-id="' + error.field + '"]');
					if (!!errorField) {
						errorField.setCustomValidity(error.message);
						errorField.reportValidity();
					}
				}

				const jushoForms = this.template.querySelectorAll('c-ex-jusho-form');
				for (const jushoForm of jushoForms) {
					jushoForm.setCustomValidity(errors);
				}
				kozaForm.setCustomValidity(errors);

				this.dispatchEvent(showToast('入力エラーがあります', '', 'error'));
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
								,...this.template.querySelectorAll('lightning-combobox')
								,...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((checkResult, inputFields) => {
				inputFields.setCustomValidity(''); // 登録時に発生したエラー内容を消去
                inputFields.reportValidity();	// 入力チェックを実施、画面側に反映させる
                return checkResult && inputFields.checkValidity(); // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);

		const jushoValid = [ ...this.template.querySelectorAll('c-ex-jusho-form')]
			.reduce((checkResult, jushoForm) => {
				return jushoForm.inputValid() && checkResult;
			}, true);

		const kozaForm = this.template.querySelector('c-ex-koza-form');
		let kozaFormValid = true;
		if (!!kozaForm) {
			kozaFormValid = kozaForm.inputValid();
		}

		return !(allInputValid && jushoValid && kozaFormValid);
	}

	/**
	 * 必要書類があり、遷移しないを選ばれた場合trueを返す
	 */
	async checkNeedUpload() {
		const needUploadList = await needUploadShinseiShorui({sw: this.seikyushaData});

		if (needUploadList.length > 0) {
			const needUploadFileNames = needUploadList.map(needUploadFileName => '・' + needUploadFileName).join('\n');
			const result = await ExModal.open({
				size: 'small'
				,content: '下記の必要書類が提出されていないため、後続の処理へは進めませんが\n画面を移動してよろしいですか？\n\n' + needUploadFileNames
				,type: 2
			});
			if (!result) { return true; }
		}

		return false;
	}
}