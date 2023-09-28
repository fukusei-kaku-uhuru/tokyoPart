import { LightningElement, api } from 'lwc';
import { errorHandle } from 'c/exErrorHandler';

import ExModal from 'c/exModal';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';

import getTaishoJidoList from '@salesforce/apex/ExTaishoJidoController.getTaishoJidoList';
import deleteTaishoJido from '@salesforce/apex/ExTaishoJidoController.deleteTaishoJido';

import canAddTaishoJido from '@salesforce/apex/ExTaishoJidoUtil.canAddTaishoJido';

import EX_TJD_NeedKazokuKakuninFile from '@salesforce/label/c.EX_TJD_NeedKazokuKakuninFile';
import EX_TJD_IsNotMoushitateFinished from '@salesforce/label/c.EX_TJD_IsNotMoushitateFinished';
import EX_TJD_NeedMoushitateFile from '@salesforce/label/c.EX_TJD_NeedMoushitateFile';
import EX_TJD_IsNotSeikyushaKozaJohoFinished from '@salesforce/label/c.EX_TJD_IsNotSeikyushaKozaJohoFinished';
import EX_TJD_IsNotKozaJohoFinished from '@salesforce/label/c.EX_TJD_IsNotKozaJohoFinished';
import EX_TJD_NeedKozaKakuninFile from '@salesforce/label/c.EX_TJD_NeedKozaKakuninFile';

export default class ExTaishoJido extends LightningElement {

	@api pageNo;
	@api recordId;

	/**
	 * カスタム表示ラベル
	 */
	label = {
		EX_TJD_NeedKazokuKakuninFile
		,EX_TJD_IsNotMoushitateFinished
		,EX_TJD_NeedMoushitateFile
		,EX_TJD_IsNotSeikyushaKozaJohoFinished
		,EX_TJD_IsNotKozaJohoFinished
		,EX_TJD_NeedKozaKakuninFile
	};

	/**
	 * 項目ラベル
	 */
	taishoJidoLbl = {
		TaishoshaKubun__c : ''
		,Shimei__c : ''
		,ShimeiFurigana__c : ''
		,UketoriKouzaKubun_Seikyusha__c : ''
		,UketoriKouzaKubun_Taishosha__c : ''
		,Moushitate_KokenninCheck__c : ''
		,Moushitate_BekkyoKango__c : ''
		,Moushitate_KaigaiRyugakuCheck__c : ''
		,Moushitate_RikonKyogiCheck__c : ''
		,Moushitate_FuboSiteishaCheck__c : ''
	};

	/**
	 * 項目ラベル
	 */
	taishoJidoDvLbl = {
		Moushitate_BetsuJushoCheck__c : ''
	};

	taishoJidoList = [];

	isSiteModeDv = false;
	isSiteModeSatoya = false;

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
				,canAddTaishoJido({recordId: this.recordId})
				,getTaishoJidoList({ recordId: this.recordId })
				,isSiteModeSatoya({})
			]);

			this.taishoJidoLbl = values[0];
			this.taishoJidoDvLbl = values[1];
			this.isSiteModeDv = values[2];
			this.canAddTaishoJido = values[3];

			this.taishoJidoList = values[4];
			this.isSiteModeSatoya = values[5];

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		this.isLoading = false;
	}

	/**
	 * 対象者情報入力画面に遷移する
	 */
	goNyuryoku(event) {
		const recordId = event.target.dataset.id;

		const taishoJidoEvent = new CustomEvent(
			'taishojidoid',
			{ detail : recordId }
		);

		this.dispatchEvent(taishoJidoEvent);

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_INPUT }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 申立書入力画面に遷移する
	 */
	goMoushitate(event) {
		const recordId = event.target.dataset.id;

		const taishoJidoEvent = new CustomEvent(
			'taishojidoid',
			{ detail : recordId }
		);

		this.dispatchEvent(taishoJidoEvent);

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_MOUSHITATE }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 申立書入力画面に遷移する
	 */
	goKoza(event) {
		const recordId = event.target.dataset.id;

		const taishoJidoEvent = new CustomEvent(
			'taishojidoid',
			{ detail : recordId }
		);

		this.dispatchEvent(taishoJidoEvent);

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_KOZA }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 対象児童の削除処理を呼び出す
	 */
	async procDelete(event) {
		const taishoJidoId = event.target.getAttribute('data-id');
		const name = event.target.getAttribute('data-name');

		const result = await ExModal.open({
			size: 'small'
			,content: name + 'を削除してよろしいですか？'
			,type: 2
		});
		if (!result) { return true; }

		// 対象児童を削除する
		await deleteTaishoJido({ninteiSeikyuId: this.recordId, taishoJidoId: taishoJidoId});

		// リストを再読み込みする
		this.taishoJidoList = await getTaishoJidoList({recordId: this.recordId});
		this.canAddTaishoJido = await canAddTaishoJido({recordId: this.recordId});
	}

	canAddTaishoJido = false;

	get addTaishoJidoButtonText() {
		const taishosha = this.isSiteModeSatoya ? '対象者・認定請求者' : '対象者';
		return this.taishoJidoList.length == 0 ? taishosha + '情報の入力' : taishosha + 'の追加';
	}

	/**
	 * 対象児童の登録画面に遷移する
	 */
	goInput() {

		const taishoJidoEvent = new CustomEvent(
			'taishojidoid',
			{ detail : '' }
		);

		this.dispatchEvent(taishoJidoEvent);

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_INPUT }
		);

		this.dispatchEvent(clickEvent);
	}

	goBack() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.SEIKYUSHA }
		);

		this.dispatchEvent(clickEvent);
	}

	/**
	 * 1つでもデータに不足があればtrueを返す
	 */
	get isNotAllDataFinished() {
		return this.taishoJidoList.some(taishoJido =>
			taishoJido.needUploadRequiredFile
			|| taishoJido.isNotMoushitateFinished
			|| taishoJido.needMoushitateFile
			|| taishoJido.isNotSeikyushaKozaFilled
			|| taishoJido.isNotKozaJohoFinished
			|| taishoJido.needKozaKakuninFile
		);
	}

	get isNextDisabled() {
		return this.isNotAllDataFinished || this.taishoJidoList.length == 0;
	}

	goNext() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.KAKUNIN }
		);

		this.dispatchEvent(clickEvent);
	}
}