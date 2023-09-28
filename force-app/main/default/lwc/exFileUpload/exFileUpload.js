import { LightningElement, api } from 'lwc';

import { showToast } from 'c/exShowToast';
import { errorHandle } from 'c/exErrorHandler';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getFileLimit from '@salesforce/apex/ExLwcUtil.getFileLimit';
import changeDocumentOwner from '@salesforce/apex/ExLwcUtil.changeDocumentOwner';
import checkFileUploadLimit from '@salesforce/apex/ExLwcUtil.checkFileUploadLimit';

import getFileType from '@salesforce/apex/ExFileUploadController.getFileType';
import updateContentVersion from '@salesforce/apex/ExFileUploadController.updateContentVersion';
import updateNinteiSeikyu from '@salesforce/apex/ExFileUploadController.updateNinteiSeikyu';
import updateSeikyusha from '@salesforce/apex/ExFileUploadController.updateSeikyusha';
import getDocument from '@salesforce/apex/ExFileUploadController.getDocument';

import ImgExFileUpload from '@salesforce/resourceUrl/ExFileUpload';
import ImgExMaskingKenkoHoken from '@salesforce/resourceUrl/ExMaskingKenkoHoken';

import EX_CMN_FILE_LIMIT from '@salesforce/label/c.EX_CMN_FILE_LIMIT';

export default class ExFileUpload extends LightningElement {
	@api pageNo;
	@api recordId;

	isLoading = true;
	isNextDisabled = true;

	isSiteModeDv = false;
	isSiteModeSatoya = false;

	fileTypeOptions = [];

	contentVersionIdList = [];
	checkOk = true;

	selectedFileTeigiId = '';
	selectedFileTeigiSetsumei = '';
	checkedMyNumberOmote = false;
	checkedKenkoHokenMask = false;
	checkedAddressMask = false;
	checkedJuminHyoMask = false;
	visibleMyNumber = false;
	visibleKenkoHoken = false;
	visibleAddressMask = false;
	visibleJuminHyoMask = false
	visibleUpload = false;
	disableUpload = false;

	acceptExtensions = [];
	extensionMessage;
	sizeMessage;

	get ImgExFileUploadUrl(){
		return ImgExFileUpload;
	}
	get ImgExMaskingKenkoHokenUrl() {
		return ImgExMaskingKenkoHoken;
	}

	async connectedCallback() {
		this.isSiteModeDv = await isSiteModeDv({});

		this.isSiteModeSatoya = await isSiteModeSatoya({});

		// 利用可能な拡張子取得
		await getFileLimit({})
			.then(result => {
				this.acceptExtensions = result.acceptExtensions;
				this.extensionMessage = result.extensionMessage;
				this.sizeMessage = result.sizeMessage;
			})
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });

		// ファイル種類取得
        await getFileType({})
			.then(result => {
				this.fileTypeOptions = result.fileTypeList.map(x => {
					return {
						label: x.fileViewTeigiName,
						value: x.fileTeigiId,
						fileTeigiId: x.fileTeigiId,
						isMyNumber: x.isMyNumber,
						isKenkoHoken: x.isKenkoHoken,
						isJuminHyo: x.isJuminHyo,
						fileTeigiSetsumei: x.fileTeigiSetsumei,
					}
				});
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
		// ファイル一覧
		await this.getDocumentList();
		this.isLoading = false;
	}

    async handleUploadFinished(event) {
		this.isLoading = true;

        const uploadedFiles = event.detail.files;
		const contentVersionId = uploadedFiles[0].contentVersionId;

		// ContentVersionに付属情報設定
        await updateContentVersion(
			{
				contentVersionId: contentVersionId,
				fileTeigiId:this.selectedFileTeigiId,
				myNumberOmote:this.checkedMyNumberOmote,
				kenkoHokenMask:this.checkedKenkoHokenMask
			})
            .then(result => {
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });

		// マスキング結果更新
        await updateNinteiSeikyu({recordId: this.recordId})
            .then(result => {
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });

		// ファイル権限更新
		await changeDocumentOwner({versionId: contentVersionId})
			.then(result => {
			})
			.catch(error => {
				this.dispatchEvent(errorHandle(error));
			});

		// ファイル一覧表示
		await this.getDocumentList();

		// もろもろ初期化
		this.clear();
		this.isLoading = false;
    }

	handleDeleteStarted() {
		this.isLoading = true;
	}

	async handleDeleteFinished(event) {
		const file = JSON.parse(event.detail);

		// エラーの場合、空で来る
		if (!file) {
			this.isLoading = false;
			return;
		}

		// マスキング結果更新
        await updateNinteiSeikyu({recordId: this.recordId})
            .then(result => {
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
		// ファイル一覧表示
		await this.getDocumentList();

		const ableUpload = await checkFileUploadLimit({
			linkedEntityId: this.recordId,
			shoruiTeigiId: file.fileTeigiId,
		});
		this.disableUpload = !ableUpload;

		this.isLoading = false;
	}

	async getDocumentList() {
        await getDocument({recordId: this.recordId, dummy: new Date().getTime()})
            .then(result => {
				this.contentVersionIdList = result.fileList.map(x => {
					return x.contentVersionId;
				});

				this.checkOK = result.checkOK;
				// 次へボタン制御
				if (this.checkOK) {
					this.isNextDisabled = false;
				}
				else {
					this.isNextDisabled = true;
				}
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
	}

	async onchangeFileType(event) {
		
        console.log('test');
		this.checkedMyNumberOmote = false;
		this.checkedKenkoHokenMask = false;
		this.checkedJuminHyoMask = false;
		this.checkedAddressMask = false;

		const selectedFileTeigiId = event.target.value;
		const selectedOption = this.fileTypeOptions.find(option => option.fileTeigiId === selectedFileTeigiId);
		this.selectedFileTeigiId = selectedFileTeigiId;
		this.selectedFileTeigiSetsumei = selectedOption.fileTeigiSetsumei;
		this.visibleMyNumber = selectedOption.isMyNumber;
		this.visibleKenkoHoken = selectedOption.isKenkoHoken;
		this.visibleJuminHyoMask = selectedOption.isJuminHyo;
		this.visibleAddressMask = this.isSiteModeDv;

		const ableUpload = await checkFileUploadLimit({
			linkedEntityId: this.recordId,
			shoruiTeigiId: selectedFileTeigiId,
		});
		if(!ableUpload){
			this.dispatchEvent(showToast(EX_CMN_FILE_LIMIT, '', 'warning'));
		}
		this.disableUpload = !ableUpload;

		this.changeVisibility();
	}

	onchangeMyNumberOmote(event) {
		this.checkedMyNumberOmote = event.target.checked;
		this.changeVisibility();
	}

	onchangeKenkoHokenMask(event) {
		this.checkedKenkoHokenMask = event.target.checked;
		this.changeVisibility();
	}

	onchangeJuminHyoMask(event) {
		this.checkedJuminHyoMask = event.target.checked;
		this.changeVisibility();
	}

	onchangeAddressMask(event) {
		this.checkedAddressMask = event.target.checked;
		this.changeVisibility();
	}

	changeVisibility() {
		// DV
		if (this.isSiteModeDv) {
			// 住所の番地以降の記載をマスキング
			if (this.checkedAddressMask) {
				// マイナンバー
				if (this.visibleMyNumber) {
					if (this.checkedMyNumberOmote) {
						this.visibleUpload = true;
					}
					else {
						this.visibleUpload = false;
					}
				}
				// 健康保険証
				else if (this.visibleKenkoHoken) {
					if (this.checkedKenkoHokenMask) {
						this.visibleUpload = true;
					}
					else {
						this.visibleUpload = false;
					}
				}
				// 住民票
				else if (this.visibleJuminHyoMask) {
					if (this.checkedJuminHyoMask) {
						this.visibleUpload = true;
					}
					else {
						this.visibleUpload = false;
					}
				}
				// その他
				else {
					this.visibleUpload = true;
				}
			} else {
				this.visibleUpload = false;
			}
		} else {
			// マイナンバー
			if (this.visibleMyNumber) {
				if (this.checkedMyNumberOmote) {
					this.visibleUpload = true;
				}
				else {
					this.visibleUpload = false;
				}
			}
			// 健康保険証
			else if (this.visibleKenkoHoken) {
				if (this.checkedKenkoHokenMask) {
					this.visibleUpload = true;
				}
				else {
					this.visibleUpload = false;
				}
			}
			// 住民票
			else if (this.visibleJuminHyoMask) {
				if (this.checkedJuminHyoMask) {
					this.visibleUpload = true;
				}
				else {
					this.visibleUpload = false;
				}
			}
			// その他
			else {
				this.visibleUpload = true;
			}
		}
	}

	clear() {
		this.selectedFileTeigiId = '';
		this.selectedFileTeigiSetsumei = '';
		this.checkedMyNumberOmote = false;
		this.checkedKenkoHokenMask = false;
		this.checkedAddressMask = false;
		this.checkedJuminHyoMask = false;
		this.visibleMyNumber = false;
		this.visibleKenkoHoken = false;
		this.visibleAddressMask = false;
		this.visibleJuminHyoMask = false;
		this.visibleUpload = false;
		this.disableUpload = false;
	}

	goBack() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.HONNIN_KAKUNIN }
		);
		this.dispatchEvent(clickEvent);
	}

	async goNext() {
		this.isLoading = true;
		let isError = false;

		await updateSeikyusha({recordId: this.recordId})
			.then(result => {
			})
			.catch(error => {
				this.dispatchEvent(errorHandle(error));
				isError = true;
			});
		if (isError) {
			this.isLoading = false;
			return;
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.SEIKYUSHA }
		);
		this.dispatchEvent(clickEvent);
	}
}