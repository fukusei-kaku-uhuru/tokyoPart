import { LightningElement, api } from 'lwc';

import { errorHandle } from 'c/exErrorHandler';
import ExModal from 'c/exModal';

import isSiteModeIppan from '@salesforce/apex/ExLwcUtil.isSiteModeIppan';
import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import getFileLimit from '@salesforce/apex/ExLwcUtil.getFileLimit';

import getTaishoJidoData from '@salesforce/apex/ExTaishoJidoFileController.getTaishoJidoData';
import getKazokuShoruiList from '@salesforce/apex/ExTaishoJidoFileController.getKazokuShoruiList';
import needUploadShinseiShorui from '@salesforce/apex/ExTaishoJidoFileController.needUploadShinseiShorui';
import updateMaskingKenkoHoken from '@salesforce/apex/ExTaishoJidoFileController.updateMaskingKenkoHoken';

export default class ExTaishoJidoFile extends LightningElement {
	@api pageNo;
	@api recordId;
	@api taishoJidoId;

	taishoJidoData = {};

	kazokuShoruiList = [];

	/**
	 * 項目ラベル
	 */
	taishoJidoLbl = {
		Shimei__c : ''
	};

	fileLimit = {};

	isSiteModeIppan = false;
	isSiteModeDv = false;
	isSiteModeSatoya = false;
	isLoading = true;

	async connectedCallback() {

		try {
			const values = await Promise.all([
				getTaishoJidoData({taishoJidoId: this.taishoJidoId})
				,getColumnLabels({objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl)})
				,getFileLimit({})
				,isSiteModeIppan({})
				,isSiteModeDv({})
				,isSiteModeSatoya({})
			]);

			this.taishoJidoData = values[0];
			this.taishoJidoLbl = values[1];
			this.fileLimit = values[2];
			this.isSiteModeIppan = values[3];
			this.isSiteModeDv = values[4];
			this.isSiteModeSatoya = values[5];
		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		// 任意提出の書類1件のみしか提出ファイルとしてひも付きがない場合、対象者書類提出画面をスキップ
		if (!this.taishoJidoData.NeedFileUpload) {
			this.goNext();
			return;
		}

		this.kazokuShoruiList = this.taishoJidoData.kazokuShoruiList;

		this.isLoading = false;
	}

	/**
	 * 家族確認書類 アップロード時処理
	 */
	async handleKazokuKakuninUploaded() {
		const values = await Promise.all([
			getKazokuShoruiList({taishoJidoId: this.taishoJidoId})
			,updateMaskingKenkoHoken({taishoJidoId: this.taishoJidoId})
		]);
		this.kazokuShoruiList = values[0];
	}

	/**
	 * 家族確認書類 削除時処理
	 */
	async handleKazokuShoruiDeleted() {
		const values = await Promise.all([
			getKazokuShoruiList({taishoJidoId: this.taishoJidoId})
			,updateMaskingKenkoHoken({taishoJidoId: this.taishoJidoId})
		]);
		this.kazokuShoruiList = values[0];
	}

	/**
	 * 対象児童一覧に戻る
	 */
	async goList() {

		if (await this.checkNeedUpload()) {
			return;
		}

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

		if (await this.checkNeedUpload()) {
			return;
		}

		let customEvent;
		if (this.taishoJidoData.IsMoushitate) {
			customEvent = new CustomEvent(
				'submit',
				{ detail : this.pageNo.TAISHO_JIDO_MOUSHITATE }
			);
		} else {
			customEvent = new CustomEvent(
				'submit',
				{ detail : this.pageNo.TAISHO_JIDO_KOZA }
			);
		}

		this.dispatchEvent(customEvent);
	}

	/**
	 * 必要書類があり、遷移しないを選ばれた場合trueを返す
	 */
	async checkNeedUpload() {
		const needUploadList = await needUploadShinseiShorui({taishoJidoId: this.taishoJidoId});

		if (needUploadList.length > 0) {
			const needUploadFileNames = needUploadList.map(needUploadFileName => '・' + needUploadFileName).join('\n');
			const result = await ExModal.open({
				size: 'small'
				,content: '下記の必要書類が提出されていないため、後続の処理へは進めませんが\n一覧画面へ戻ってよろしいですか？\n\n' + needUploadFileNames
				,type: 2
			});
			if (!result) { return true; }
		}

		return false;
	}
}