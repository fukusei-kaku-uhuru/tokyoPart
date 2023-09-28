import { LightningElement, api } from 'lwc';

import { errorHandle } from 'c/exErrorHandler';
import ExModal from 'c/exModal';

import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import getFileLimit from '@salesforce/apex/ExLwcUtil.getFileLimit';

import getMoushitateData from '@salesforce/apex/ExTjMoushitateFileController.getMoushitateData';
import getMoushitateShoruiList from '@salesforce/apex/ExTjMoushitateFileController.getMoushitateShoruiList';
import needUploadShinseiShorui from '@salesforce/apex/ExTjMoushitateFileController.needUploadShinseiShorui';

export default class ExTjMoushitateFile extends LightningElement {

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
	};

	fileLimit = {};

	moushitateData = {};

	kokenninShoruiList = [];
	bekkyoShoruiList = [];
	ryugakuShoruiList = [];
	rikonShoruiList = [];
	fuboShoruiList = [];

	isLoading = true;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getColumnLabels({objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl)})
				,getFileLimit({})
				,getMoushitateData({taishoJidoId: this.taishoJidoId})
			]);

			this.taishoJidoLbl = values[0];
			this.fileLimit = values[1];
			this.moushitateData = values[2];

			this.kokenninShoruiList = this.moushitateData.KokenninShoruiList;
			this.bekkyoShoruiList = this.moushitateData.BekkyoShoruiList;
			this.ryugakuShoruiList = this.moushitateData.RyugakuShoruiList;
			this.rikonShoruiList = this.moushitateData.RikonShoruiList;
			this.fuboShoruiList = this.moushitateData.FuboShoruiList;

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		this.isLoading = false;
	}

	get isNeedFileUpload() {
		return this.moushitateData.IsKokennin
			|| this.moushitateData.IsBekkyo
			|| this.moushitateData.IsRyugaku
			|| this.moushitateData.IsRikon
			|| this.moushitateData.IsFuboSitei
		;
	}

	/**
	 * 後見人であることの申立 ファイル操作後処理
	 */
	async handleKokenninUploaded() {
		this.kokenninShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_KOKENNIN});
	}
	async handleKokenninDeleted() {
		this.kokenninShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_KOKENNIN});
	}

	/**
	 * 後見人であることの申立 ファイル操作後処理
	 */
	async handleBekkyoUploaded() {
		this.bekkyoShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_BEKKYO});
	}
	async handleBekkyoDeleted() {
		this.bekkyoShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_BEKKYO});
	}

	/**
	 * 海外留学に関する申立 ファイル操作後処理
	 */
	async handleRyugakuUploaded() {
		this.ryugakuShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_RYUGAKU});
	}
	async handleRyugakuDeleted() {
		this.ryugakuShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_RYUGAKU});
	}

	/**
	 * 離婚協議中の同居父母であることの申立 ファイル操作後処理
	 */
	async handleRikonUploaded() {
		this.rikonShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_RIKON});
	}
	async handleRikonDeleted() {
		this.rikonShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_RIKON});
	}

	/**
	 * 父母指定者指定の届 ファイル操作後処理
	 */
	async handleFuboUploaded() {
		this.fuboShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_FUBOSITEI});
	}
	async handleFuboDeleted() {
		this.fuboShoruiList = await getMoushitateShoruiList({taishoJidoId: this.taishoJidoId, moushitateKubun: this.moushitateData.KUBUN_FUBOSITEI});
	}

	/**
	 * 戻るボタン押下時
	 */
	async goBack() {

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

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_KOZA }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 必要書類があり、遷移しないを選ばれた場合trueを返す
	 */
	async checkNeedUpload() {
		const needUploadList = await needUploadShinseiShorui({mw: this.moushitateData});

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