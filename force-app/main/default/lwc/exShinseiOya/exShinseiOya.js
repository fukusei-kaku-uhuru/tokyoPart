import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { errorHandle } from 'c/exErrorHandler';

import { loadStyle } from 'lightning/platformResourceLoader';
import STYLE_SHEET from '@salesforce/resourceUrl/ExStyleSheet';

import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getHensyuPhase from '@salesforce/apex/ExLwcUtil.getHensyuPhase';
import updateHensyuPhase from '@salesforce/apex/ExLwcUtil.updateHensyuPhase';
import isNinteiSeikyuDisabled from '@salesforce/apex/ExLwcUtil.isNinteiSeikyuDisabled';

export default class ExShinseiOya extends LightningElement {
	// 画面ID定数
	PAGE_NO = {
		AGREEMENT	: "SDI1"
		,SEIYAKU	: "SDI2"
		,KAKUNIN_18	: "K181"
		,HONNIN_KAKUNIN	: "HKH1"
		,MY_NUMBER : "KKN1"
		,MY_NUMBER_ERROR : "KKN2"
		,MY_NUMBER_SUCCESS : "KKN3"
		,FILE_UPLOAD : "KUP1"
		,SEIKYUSHA : "SKS1"
		,TAISHO_JIDO : "TJD1"
		,TAISHO_JIDO_INPUT : "TJD2"
		,TAISHO_JIDO_FILE : "TJD3"
		,TAISHO_JIDO_MOUSHITATE : "TJD4"
		,TAISHO_JIDO_MOUSHITATE_FILE : "TJD5"
		,TAISHO_JIDO_KOZA : "TJD6"
		,TAISHO_JIDO_KOZA_FILE : "TJD7"
		,KAKUNIN : "SKN"
		,KANRYO : "KNR"
	};

	get PROGRESS_STEP() {
		let array = [];

		array.push({label: '規約・誓約同意', id: this.PAGE_NO.AGREEMENT});

		if (!this.isSiteModeSatoya) {
			array.push({label: '18歳確認', id: this.PAGE_NO.KAKUNIN_18});
		}

		array.push(
			{label: '本人確認方法選択', id: this.PAGE_NO.HONNIN_KAKUNIN}
			,{label: '請求者', id: this.PAGE_NO.SEIKYUSHA}
			,{label: '対象児童', id: this.PAGE_NO.TAISHO_JIDO}
			,{label: '最終確認', id: this.PAGE_NO.KAKUNIN}
			,{label: '完了', id: this.PAGE_NO.KANRYO}
		);

		return array;
	}

	// 認定請求ID
	recordId;
	// 対象児童ID
	taishoJidoId = '';

	// 表示画面
	displayTemplate = this.PAGE_NO.AGREEMENT;
	hensyuPhase = '';

	hasStyleLoaded = false;

	isNinteiSeikyuDisabled = false;
	isSiteModeSatoya = false;

	async connectedCallback(){
		try {
			if(!this.hasStyleLoaded){
				await loadStyle(this, STYLE_SHEET);
				this.hasStyleLoaded = true;
			}

			const values = await Promise.all([
				getHensyuPhase({ninteiSeikyuId: this.recordId})
				,isNinteiSeikyuDisabled({recordId: this.recordId})
				,isSiteModeSatoya({})
			]);
			this.hensyuPhase = values[0];
			this.isNinteiSeikyuDisabled = values[1];
			this.isSiteModeSatoya = values[2];

			// 携帯でファイルアップロード時に、画面を制御するための処理
			const phone = document.querySelector('.PHONE');
			if (!!phone) {
				let mo = new MutationObserver(this.toggleCommSectionMasking);
				const config = {childList:true};
				mo.observe(phone, config);
			}
		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}
	}

	// 携帯でファイルアップロード時に、画面を制御するための処理
	toggleCommSectionMasking() {
		const commSection = document.querySelector('.forceCommunitySection');
		if (commSection.classList.contains('ex-comm-section-masking')) {
			commSection.classList.remove('ex-comm-section-masking');
		} else {
			commSection.classList.add('ex-comm-section-masking');
		}
	}

	/**
	 * 画面変更
	 */
	changeDisplayTemplate(event) {
		this.displayTemplate = event.detail.value;
	}

	/**
	 * 画面選択肢
	 */
	get displayTemplateOptions() {
		let options = [];

		for (const [key, value] of Object.entries(this.PAGE_NO)) {
			const option = {
				label : key
				,value : value
			};
			options.push(option);
		}

		return options;
	}

	@wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.recordId = currentPageReference.state.recordId;
        }
    }

	/**
	 * レコードID設定
	 */
	setRecordId(event) {
		this.recordId = event.detail;
		return;
	}

	setTaishoJidoId(event) {
		this.taishoJidoId = event.detail;
		return;
	}

	// 画面ナビゲーションにて、どこまで遷移可能とするかを制御する
	_doneStepId = this.PAGE_NO.AGREEMENT;
	get doneStepId() {
		if (!!this.hensyuPhase) {
			return this.hensyuPhase;
		}
		return this._doneStepId;
	}

	/**
	 * 子コンポーネントにて次へ/前へ画面押下時の処理
	 */
	async finishProcess(event) {
		this.displayTemplate = event.detail;
		window.scroll({
            left: 0,
            top: 0,
        });

		// 必要に応じて、遷移可能ステップIdを更新する
		const displayTemplateIndex = this.PROGRESS_STEP.findIndex((step) => {return step.id === this.displayTemplate;});
		const doneStepIndex = this.PROGRESS_STEP.findIndex((step) => {return step.id === this._doneStepId});
		if (displayTemplateIndex > doneStepIndex) {
			this._doneStepId = this.displayTemplate;
		}

		// 必要に応じて、編集フェーズを更新する
		await updateHensyuPhase({recordId: this.recordId, steps: this.PROGRESS_STEP, displayTemplateId: this.displayTemplate});
		this.hensyuPhase = await getHensyuPhase({ninteiSeikyuId: this.recordId});

		return;
	}

	/**
	 * 各種規約同意画面を表示するか
	 */
	get displayAgreement() {
		return this.checkDisplayTemplate(this.PAGE_NO.AGREEMENT);
	}

	/**
	 * 誓約同意画面を表示するか
	 */
	get displaySeiyaku() {
		return this.checkDisplayTemplate(this.PAGE_NO.SEIYAKU);
	}

	/**
	 * 18歳確認を表示するか
	 */
	get displayKakunin18() {
		return this.checkDisplayTemplate(this.PAGE_NO.KAKUNIN_18);
	}

	/**
	 * 本人確認方法選択を表示するか
	 */
	get displayHonninKakunin() {
		return this.checkDisplayTemplate(this.PAGE_NO.HONNIN_KAKUNIN);
	}

	/**
	 * マイナンバーカード登録を表示するか
	 */
	get displayMyNumber() {
		return this.checkDisplayTemplate(this.PAGE_NO.MY_NUMBER);
	}

	/**
	 * マイナンバーカード登録 エラーを表示するか
	 */
	get displayMyNumberError() {
		return this.checkDisplayTemplate(this.PAGE_NO.MY_NUMBER_ERROR);
	}

	/**
	 * マイナンバーカード登録 正常を表示するか
	 */
	get displayMyNumberSuccess() {
		return this.checkDisplayTemplate(this.PAGE_NO.MY_NUMBER_SUCCESS);
	}

	/**
	 * 券面アップロードを表示するか
	 */
	get displayFileUpload() {
		return this.checkDisplayTemplate(this.PAGE_NO.FILE_UPLOAD);
	}

	/**
	 * 請求書入力を表示するか
	 */
	get displaySeikyusha() {
		return this.checkDisplayTemplate(this.PAGE_NO.SEIKYUSHA);
	}

	/**
	 * 対象児童一覧を表示するか
	 */
	get displayTaishoJido() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO);
	}

	/**
	 * 対象者情報入力を表示するか
	 */
	get displayTaishoJidoNyuryoku() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO_INPUT);
	}

	/**
	 * 対象者情報ファイルを表示するか
	 */
	get displayTaishoJidoFile() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO_FILE);
	}

	/**
	 * 申立書入力を表示するか
	 */
	get displayTjMoushitate() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO_MOUSHITATE);
	}

	/**
	 * 対象者情報ファイルを表示するか
	 */
	get displayTjMoushitateFile() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO_MOUSHITATE_FILE);
	}

	/**
	 * 対象者情報入力を表示するか
	 */
	get displayTjKoza() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO_KOZA);
	}

	/**
	 * 対象者情報ファイルを表示するか
	 */
	get displayTjKozaFile() {
		return this.checkDisplayTemplate(this.PAGE_NO.TAISHO_JIDO_KOZA_FILE);
	}

	/**
	 * 最終確認を表示するか
	 */
	get displaySaisyuKakunin() {
		return this.checkDisplayTemplate(this.PAGE_NO.KAKUNIN);
	}

	/**
	 * 申請完了を表示するか
	 */
	get displayShinseiKanryo() {
		return this.checkDisplayTemplate(this.PAGE_NO.KANRYO);
	}

	checkDisplayTemplate(targetDisplay) {
		if (this.displayTemplate == targetDisplay) {
			return true;
		}
		return false;
	}
}