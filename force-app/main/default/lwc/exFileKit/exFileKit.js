import { LightningElement, api } from 'lwc';

import { showToast } from 'c/exShowToast';
import { errorHandle } from 'c/exErrorHandler';

import getFileLimit from '@salesforce/apex/ExLwcUtil.getFileLimit';
import checkFileUploadLimit from '@salesforce/apex/ExLwcUtil.checkFileUploadLimit';
import changeDocumentOwner from '@salesforce/apex/ExLwcUtil.changeDocumentOwner';

import isKenkoHoken from '@salesforce/apex/ExShinseiShoruiTeigiUtil.isKenkoHoken';
import isJuminHyo from '@salesforce/apex/ExShinseiShoruiTeigiUtil.isJuminHyo';

import updateContentVersion from '@salesforce/apex/ExFileKitController.updateContentVersion';

import EX_CMN_FILE_LIMIT from '@salesforce/label/c.EX_CMN_FILE_LIMIT';

import ImgExMaskingKenkoHoken from '@salesforce/resourceUrl/ExMaskingKenkoHoken';

export default class ExFileKit extends LightningElement {
	@api options = [];
	@api recordId;
	@api fileList = [];
	@api unDeletable;
	@api isOptionHidden = false;
	@api shoruiSetsumeiMap = {};

	fileLimit = {};
	isLoading = true;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getFileLimit({})
			]);

			this.fileLimit = values[0];
		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		if (this.options.length == 1) {
			this._comboboxValue = this.options[0].value;
			this.comboboxValue = this.options[0].value;

			// 上限に達している場合はアップロード不可状態にする
			if (!await checkFileUploadLimit({linkedEntityId: this.recordId, shoruiTeigiId: this.comboboxValue})) {
				this.comboboxValue = null;
			}
		}

		this.isLoading = false;
	}

	get isOptionEmpty() {
		return this.options.length == 0;
	}
	get canUpload() {
		return !this.unDeletable && !this.isOptionEmpty;
	}
	// optionsが複数の場合だけ選択肢を表示する
	get isMultiOption() {
		return this.options.length != 1;
	}
	get singleValue() {
		return this.options[0].value;
	}

	comboboxValue;
	_comboboxValue = '';
	isKenkoHoken = false;
	isKenkoHokenMasking = false;
	isJuminHyo = false;
	isJuminHyoMasking = false;
	async changeCombobox(event) {

		this._comboboxValue = event.detail.value;
		this.isKenkoHoken = false;
		this.isJuminHyo = false;

		const checkValues = await Promise.all([
			checkFileUploadLimit({linkedEntityId: this.recordId, shoruiTeigiId: this._comboboxValue})
			,isKenkoHoken({recordId: this._comboboxValue})
			,isJuminHyo({recordId: this._comboboxValue})
		]);

		this.comboboxValue = this._comboboxValue;

		// 上限に達している場合、警告を出してアップロード不可状態にする
		if (!checkValues[0]) {
			this.dispatchEvent(showToast(EX_CMN_FILE_LIMIT, '', 'warning'));
			this.comboboxValue = null;
		}

		// 健康保険証の場合、選択されたIdを仮置きしておく
		if (checkValues[1]) {
			this.isKenkoHoken = true;
			this.isKenkoHokenMasking = false;
			this.comboboxValue = null;
		}

		// 住民票の場合、選択されたIdを仮置きしておく
		if (checkValues[2]) {
			this.isJuminHyo = true;
			this.isJuminHyoMasking = false;
			this.comboboxValue = null;
		}
	}

	get existsShoruiSetsumei() {
		return this.shoruiSetsumeiMap.hasOwnProperty(this._comboboxValue);
	}

	get shoruiSetsumei() {
		if (this.shoruiSetsumeiMap.hasOwnProperty(this._comboboxValue)) {
			return this.shoruiSetsumeiMap[this._comboboxValue].replaceAll('\n', '<br>');
		}
		return '';
	}

	get kenkoHokenMasking() { return ImgExMaskingKenkoHoken; }
	// 健康保険証マスキングチェック
	async changeKenkoHoken(event) {
		this.isKenkoHokenMasking = event.detail.checked;

		if (this.isKenkoHokenMasking && await checkFileUploadLimit({linkedEntityId: this.recordId, shoruiTeigiId: this._comboboxValue})) {
			this.comboboxValue = this._comboboxValue;
		} else {
			this.comboboxValue = null;
		}
	}

	// 住民票マスキングチェック
	async changeJuminHyo(event) {
		this.isJuminHyoMasking = event.detail.checked;

		if (this.isJuminHyoMasking && await checkFileUploadLimit({linkedEntityId: this.recordId, shoruiTeigiId: this._comboboxValue})) {
			this.comboboxValue = this._comboboxValue;
		} else {
			this.comboboxValue = null;
		}
	}

	get fileUploaderDisabled() {
		const isKenkoHokenOk = this.isKenkoHoken ? this.isKenkoHokenMasking : true;
		const isJuminHyoOk = this.isJuminHyo ? this.isJuminHyoMasking : true;
		return !(this.comboboxValue && isKenkoHokenOk && isJuminHyoOk);
	}

	/**
	 * アップロード時処理
	 */
	async handleUploaded(event) {
		const uploadedFiles = event.detail.files;
		const contentVersionId = uploadedFiles[0].contentVersionId;

		// ファイルに選択されていた申請書類の情報をセット
		await updateContentVersion({contentVersionId: contentVersionId, shinseiShoruiTeigiId: this.comboboxValue, isKenkoHoken: this.isKenkoHoken});
		// 所有者を内部ユーザに変更
		await changeDocumentOwner({versionId: contentVersionId});

		// 上限に達した場合、警告を出してアップロード不可状態にする
		if (!await checkFileUploadLimit({linkedEntityId: this.recordId, shoruiTeigiId: this.comboboxValue})) {
			this.dispatchEvent(showToast(EX_CMN_FILE_LIMIT, '', 'warning'));
			this.comboboxValue = null;
		}

		// 親コンポーネントにアップロード終了を知らせる
		const customEvent = new CustomEvent(
			'fileupload',
			{ detail : {
					contentVersionId : contentVersionId
					,shoruiTeigiId : this.comboboxValue
				}
			}
		);

		this.dispatchEvent(customEvent);
	}

	async handleDeleted(event) {

		// 上限に以下になった場合、アップロード可能状態にする
		if (await checkFileUploadLimit({linkedEntityId: this.recordId, shoruiTeigiId: this._comboboxValue})) {
			this.comboboxValue = this._comboboxValue;
		}

		// 親コンポーネントに削除処理終了を知らせる
		const customEvent = new CustomEvent(
			'filedelete',
			{ detail : ''}
		);

		this.dispatchEvent(customEvent);
	}
}