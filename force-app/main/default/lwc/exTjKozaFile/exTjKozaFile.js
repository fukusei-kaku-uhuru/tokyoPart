import { LightningElement, api } from 'lwc';

import { errorHandle } from 'c/exErrorHandler';
import ExModal from 'c/exModal';

import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import getFileLimit from '@salesforce/apex/ExLwcUtil.getFileLimit';

import getKozaData from '@salesforce/apex/ExTjKozaFileController.getKozaData';
import getKozaShoruiList from '@salesforce/apex/ExTjKozaFileController.getKozaShoruiList';
import needUploadShinseiShorui from '@salesforce/apex/ExTjKozaFileController.needUploadShinseiShorui';

import ImgExTjKozaSample1 from '@salesforce/resourceUrl/ExTjKozaSample1';
import ImgExTjKozaSample2 from '@salesforce/resourceUrl/ExTjKozaSample2';
import ImgExTjKozaSample3 from '@salesforce/resourceUrl/ExTjKozaSample3';


export default class ExTjKozaFile extends LightningElement {

	@api pageNo;
	@api recordId;
	@api taishoJidoId;

	/**
	 * 項目ラベル
	 */
	taishoJidoLbl = {
		Shimei__c : ''
	};

	fileLimit = {};

	kozaData = {};

	kozaShoruiList = [];

	isLoading = true;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getColumnLabels({objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl)})
				,getFileLimit({})
				,getKozaData({ taishoJidoId: this.taishoJidoId })
				,isSiteModeSatoya({})
			]);

			this.taishoJidoLbl = values[0];
			this.fileLimit = values[1];
			this.kozaData = values[2];
			this.isSiteModeSatoya = values[3];

			this.kozaShoruiList = this.kozaData.KozaShoruiList;

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		this.isLoading = false;
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

	/**
	 * 口座確認書類 ファイル操作後処理
	 */
	async handleKozaUploaded() {
		this.kozaShoruiList = await getKozaShoruiList({taishoJidoId: this.taishoJidoId});
	}
	async handleKozaDeleted() {
		this.kozaShoruiList = await getKozaShoruiList({taishoJidoId: this.taishoJidoId});
	}

	/**
	 * 戻るボタン押下時
	 */
	async goBack() {

		if (this.kozaData.isSelectedTaishosha && await this.checkNeedUpload()) {
			return;
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO }
		);

		this.dispatchEvent(clickEvent);
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