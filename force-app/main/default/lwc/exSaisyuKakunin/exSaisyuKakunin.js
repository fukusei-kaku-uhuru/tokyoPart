import { LightningElement, api } from 'lwc';

import { errorHandle } from 'c/exErrorHandler';
import ExModal from 'c/exModal';

import EX_TJD_SeikyushaKubun from '@salesforce/label/c.EX_TJD_SeikyushaKubun';
import EX_TJD_DoukyoShubetsu from '@salesforce/label/c.EX_TJD_DoukyoShubetsu';
import EX_TJD_Tsudukigara from '@salesforce/label/c.EX_TJD_Tsudukigara';
import EX_TJD_UketoriKouzaKubun from '@salesforce/label/c.EX_TJD_UketoriKouzaKubun';
import EX_CMN_ShinseiShoruiIchiran from '@salesforce/label/c.EX_CMN_ShinseiShoruiIchiran';
import EX_CMN_REQUEST from '@salesforce/label/c.EX_CMN_REQUEST';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import isNinteiSeikyuDisabled from '@salesforce/apex/ExLwcUtil.isNinteiSeikyuDisabled';

import getNinteiSeikyuData from '@salesforce/apex/ExSaisyuKakuninController.getNinteiSeikyuData';
import getSeikyushaData from '@salesforce/apex/ExSaisyuKakuninController.getSeikyushaData';
import getTaishoJidoData from '@salesforce/apex/ExSaisyuKakuninController.getTaishoJidoData';
import validationTaishoJido from '@salesforce/apex/ExSaisyuKakuninController.validationTaishoJido';
import submitRequest from '@salesforce/apex/ExSaisyuKakuninController.submitRequest';

export default class ExSaisyuKakunin extends LightningElement {

	@api pageNo = {};
	@api recordId = '';

	/**
	 * カスタム表示ラベル
	 */
	label = {
		EX_TJD_SeikyushaKubun
		,EX_TJD_DoukyoShubetsu
		,EX_TJD_Tsudukigara
		,EX_TJD_UketoriKouzaKubun
		,EX_CMN_ShinseiShoruiIchiran
		,EX_CMN_REQUEST
	};

	/**
	 * 項目ラベル（請求者）
	 */
	seikyushaLbl = {
		ShimeiFurigana__c : ''
		,Shimei__c : ''
		,SeinenGappiDate__c : ''
		,YubinBangou__c : ''
		,Jusho__c : ''
		,DenwaBangou__c : ''
		,MailAddress__c : ''
	};

	/**
	 * 項目ラベル（対象児童）
	 */
	taishoJidoLbl = {
		TaishoshaKubun__c : ''
		,Shimei__c : ''
		,ShimeiFurigana__c : ''
		,SeinenGappiDate__c : ''
		,YubinBangou__c : ''
		,Jusho__c : ''
		,SonotaShousai__c : ''
		,IsTochuTennyuShussei__c : ''
		,TennyuShusseiDate__c : ''
		,TennyuShusseiDateSonota__c : ''
		,IsTochuTenshutsu__c : ''
		,TenshutsuDate__c : ''
		,TenshutsuDateSonota__c : ''
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
		,UketoriKouzaKubun_Seikyusha__c : ''
		,UketoriKouzaKubun_Taishosha__c : ''
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

	/**
	 * 項目ラベル（対象児童DV）
	 */
	taishoJidoDvLbl = {
		Moushitate_BetsuJushoCheck__c : ''
	};

	ninteiSeikyuData = {};

	seikyushaData = {};

	taishoJidoList = [];

	isSiteModeDv = false;
	isSiteModeSatoya = false;

	isDisabled = true;
	isLoading = true;
	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			const values = await Promise.all([
				getNinteiSeikyuData({recordId: this.recordId})
				,getSeikyushaData({recordId: this.recordId})
				,getTaishoJidoData({recordId: this.recordId})
				,getColumnLabels({objectName: 'Seikyusha__c', columnNames: Object.keys(this.seikyushaLbl)})
				,getColumnLabels({objectName: 'TaishoJido__c', columnNames: Object.keys(this.taishoJidoLbl)})
				,getColumnLabels({objectName: 'DV_TaishoJido__c', columnNames: Object.keys(this.taishoJidoDvLbl)})
				,isSiteModeDv({})
				,isSiteModeSatoya({})
				,isNinteiSeikyuDisabled({recordId: this.recordId})
			]);

			this.ninteiSeikyuData = values[0];
			this.seikyushaData = values[1];
			this.taishoJidoList = values[2];

			this.seikyushaLbl = values[3];
			this.taishoJidoLbl = values[4];
			this.taishoJidoDvLbl = values[5];
			this.isSiteModeDv = values[6];
			this.isSiteModeSatoya = values[7];
			this.isDisabled = values[8];

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		this.isLoading = false;
	}

	get isNotSelectedSatoya() {
		return this.isSiteModeSatoya && this.seikyushaData.ShisetsuShurui != '里親';
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

	get isFileUploaded() {
		return this.ninteiSeikyuData.HonninKakuninHoho == '券面アップロード';
	}

	get unDeletableTrue() {
		return true;
	}

	goList() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO }
		);

		this.dispatchEvent(clickEvent);
	}

	goBack() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO }
		);

		this.dispatchEvent(clickEvent);
	}

	get isRequestDisabled() {
		return this.taishoJidoList.length == 0;
	}

	/**
	 * 申請処理を実行
	 */
	async request() {

		try {
			// データの整合性チェック
			if (!await this.validation()) {
				return;
			}

			// 申請処理実行
			await submitRequest({ninteiSeikyuId: this.recordId});

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
			return;
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.KANRYO }
		);

		this.dispatchEvent(clickEvent);
	}

	async validation() {
		try {
			// 必要書類が提出できているかチェック
			const result = await validationTaishoJido({ninteiSeikyuId: this.recordId});
			if (result.length > 0) {
				this.displayErrorMessage(result);
				return false;
			}
		} catch (error) {
			this.dispatchEvent(errorHandle(error));
			return false;
		}

		return true;
	}

	async displayErrorMessage(errors) {
		let message = '下記の入力で不備があります。ご確認ください。\n\n';
		for (const error of errors) {
			message += error.field + '\n' + error.message + '\n\n';
		}

		await ExModal.open({
			size: 'small'
			,content: message
			,type: 1
			,theme: 'error'
		});
	}
}