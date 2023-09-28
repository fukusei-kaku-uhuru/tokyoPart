import { LightningElement, api, track, wire } from 'lwc';

import { showToast } from 'c/exShowToast';
import { errorHandle } from 'c/exErrorHandler';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import getPickList from '@salesforce/apex/ExLwcUtil.getPickList';

import getTaishoJidoNyuryokuData from '@salesforce/apex/ExTaishoJidoNyuryokuController.getTaishoJidoNyuryokuData';
import upsertTaishoJido from '@salesforce/apex/ExTaishoJidoNyuryokuController.upsertTaishoJido';
import isKyufuKahi from '@salesforce/apex/ExTaishoJidoNyuryokuController.isKyufuKahi';

import EX_TJD2_URL1 from '@salesforce/label/c.EX_TJD2_URL1';

import EX_TJD_DoukyoShubetsu from '@salesforce/label/c.EX_TJD_DoukyoShubetsu';
import EX_TJD_DoukyoShubetsu_Doukyo from '@salesforce/label/c.EX_TJD_DoukyoShubetsu_Doukyo';
import EX_TJD_DoukyoShubetsu_Bekkyo from '@salesforce/label/c.EX_TJD_DoukyoShubetsu_Bekkyo';
import EX_TJD_DoukyoShubetsu_Honnin from '@salesforce/label/c.EX_TJD_DoukyoShubetsu_Honnin';
import EX_TJD_Tsudukigara from '@salesforce/label/c.EX_TJD_Tsudukigara';
import EX_TJD_Tsudukigara_Chichi from '@salesforce/label/c.EX_TJD_Tsudukigara_Chichi';
import EX_TJD_Tsudukigara_Haha from '@salesforce/label/c.EX_TJD_Tsudukigara_Haha';
import EX_TJD_Tsudukigara_Sonota from '@salesforce/label/c.EX_TJD_Tsudukigara_Sonota';
import EX_TJD_SeikyushaKubun from '@salesforce/label/c.EX_TJD_SeikyushaKubun';
import EX_TJD_Kokuseki from '@salesforce/label/c.EX_TJD_Kokuseki';
import EX_TJD_Kokuseki_Nihon from '@salesforce/label/c.EX_TJD_Kokuseki_Nihon';
import EX_TJD_Kokuseki_NihonIgai from '@salesforce/label/c.EX_TJD_Kokuseki_NihonIgai';
import EX_CMN_INPUT_ERROR from '@salesforce/label/c.EX_CMN_INPUT_ERROR';

export default class ExTaishoJidoNyuryoku extends LightningElement {

	@api pageNo;
	@api recordId;
	@api taishoJidoId;

	/**
	 * カスタム表示ラベル
	 */
	label = {
		EX_TJD_DoukyoShubetsu
		,EX_TJD_DoukyoShubetsu_Doukyo
		,EX_TJD_DoukyoShubetsu_Bekkyo
		,EX_TJD_DoukyoShubetsu_Honnin
		,EX_TJD_Tsudukigara
		,EX_TJD_Tsudukigara_Chichi
		,EX_TJD_Tsudukigara_Haha
		,EX_TJD_Tsudukigara_Sonota
		,EX_TJD_SeikyushaKubun
		,EX_TJD_Kokuseki
		,EX_TJD2_URL1
	};

	/**
	 * 項目ラベル
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
	};

	/**
	 * 対象児童データ
	 */
	@track
	taishoJidoData = {};

	/**
	 * 画面用データ
	 */
	taishoJidoNyuryokuData = {};

	konnendochuShinkiSochiOption = [];

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
				,getPickList({objectName: 'DV_TaishoJido__c', columnName: 'TaishoShinkiSochi__c'})
				,isSiteModeDv({})
				,isSiteModeSatoya({})
				,getTaishoJidoNyuryokuData({ninteiSeikyuId: this.recordId, taishoJidoId: this.taishoJidoId})
			]);
			this.taishoJidoLbl = values[0];
			this.konnendochuShinkiSochiOption = values[1];
			this.isSiteModeDv = values[2];
			this.isSiteModeSatoya = values[3];

			this.taishoJidoNyuryokuData = values[4];
			this.taishoJidoData = this.taishoJidoNyuryokuData.taishoJidoData;

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}

		if (!!this.taishoJidoData.YubinBangou) {
			this.isJushoSearchSuccess = true;
		}

		this.isLoading = false;

	}

	kyufuKahi = true;
	/**
	 * 値変更時処理
	 * 選択された対象者区分が給付可能かチェック
	 */
	async changeTaishoshaKubun(event) {
		this.taishoJidoData.TaishoshaKubun = event.detail.selectedId;

		// 給付対象外の場合、メッセージを表示する
		this.kyufuKahi = await isKyufuKahi({recordId: this.taishoJidoData.TaishoshaKubun});
		if (!this.kyufuKahi) {
			this.dispatchEvent(showToast('選択された対象者区分は給付対象外のため、登録できません', '', 'error'));
		}
	}

	get taishoshaKubunParams() {
		let prefix = 'A';
		if (this.isSiteModeDv) {
			prefix = 'B';
		}

		return {
			'prefix' : prefix
		};
	}

	blurInputFullSpace(event) {
		const value = event.target.value.replaceAll(' ', '　');

		this.taishoJidoData[event.target.getAttribute('data-id')] = value;

		// 画面エラーが発生しないように、JS処理内にてvalueを上書き → 警告チェックする
		event.target.value = value;
		event.target.reportValidity();
	}

	get isRequiredFurigana() {
		return this.taishoJidoData.Kokuseki == this.taishoJidoData.KOKUSEKI_JAPAN;
	}

	/**
	 * 請求者区分のオプション
	 */
	get seikyushaKubunOptions() {
		return [
			{ label: '対象者が18歳未満', value: this.taishoJidoData.SEIKYUSHA_18UNDER}
			,{ label: '対象者自身が認定請求を行う', value: this.taishoJidoData.SEIKYUSHA_TAISHOSHA}
			,{ label: '対象者の代理人が認定請求を行う', value: this.taishoJidoData.SEIKYUSHA_DAIRININ}
		];
	}

	/**
	 * 認定請求者の同居種別オプション
	 */
	get seikyushaShubetsuOptions() {
		let options = [
			{ label: EX_TJD_DoukyoShubetsu_Doukyo, value: this.taishoJidoData.DOUKYOSHUBETSU_DOUKYO }
			,{ label: EX_TJD_DoukyoShubetsu_Bekkyo, value: this.taishoJidoData.DOUKYOSHUBETSU_BEKKYO }
		];
		if (!this.isSiteModeDv) {
			options.push({ label: EX_TJD_DoukyoShubetsu_Honnin, value: this.taishoJidoData.DOUKYOSHUBETSU_HONNIN });
		}
		return options;
	}

	/**
	 * 同居種別変更時処理
	 */
	changeDoukyoShubetsu(event) {
		// 本人からそれ以外を選択された場合、裏でセットした値をクリアする
		if (!this.isNotDoukyoShubetsuHonnin) {
			this.taishoJidoData.SeikyushaTsudukigara = '';
			this.taishoJidoData.SonotaShousai = '';
		}

		this.changeInput(event);

		// 本人が選択された場合、裏で値をセットする
		if (!this.isNotDoukyoShubetsuHonnin) {
			this.taishoJidoData.SeikyushaTsudukigara = this.taishoJidoData.TSUDUKIGARA_SONOTA;
			this.taishoJidoData.SonotaShousai = '本人';
		}
	}
	get isDoukyoShubetsuBekkyo() {
		return this.taishoJidoData.SeikyushaDoukyoShubetsu == this.taishoJidoData.DOUKYOSHUBETSU_BEKKYO;
	}
	get isNotDoukyoShubetsuHonnin() {
		return this.taishoJidoData.SeikyushaDoukyoShubetsu != this.taishoJidoData.DOUKYOSHUBETSU_HONNIN;
	}

	isJushoSearchSuccess = false;

	/**
	 * 値変更時処理
	 * 住所フォームコンポーネントからの値を受け取り設定する
	 */
	changeJusho(event) {
		const jusho = event.detail;

		this.taishoJidoData.YubinBangou = jusho.yubinBango;
		this.taishoJidoData.Jusho = jusho.jusho;
	}

	/**
	 * 認定請求者の続柄オプション
	 */
	get seikyushaTsudukigaraOptions() {
		return [
			{ label: EX_TJD_Tsudukigara_Chichi, value: this.taishoJidoData.TSUDUKIGARA_CHICHI }
			,{ label: EX_TJD_Tsudukigara_Haha, value: this.taishoJidoData.TSUDUKIGARA_HAHA }
			,{ label: EX_TJD_Tsudukigara_Sonota, value: this.taishoJidoData.TSUDUKIGARA_SONOTA }
		];
	}
	get isTsudukigaraSonota() {
		return this.taishoJidoData.SeikyushaTsudukigara == this.taishoJidoData.TSUDUKIGARA_SONOTA;
	}

	get isNotTochuTenshutsu() {
		return !this.taishoJidoData.IsTochuTenshutsu || this.taishoJidoData.isDisabled;;
	}

	get kokusekiOptions() {
		return [
			{ label: EX_TJD_Kokuseki_Nihon, value: this.taishoJidoData.KOKUSEKI_JAPAN }
			,{ label: EX_TJD_Kokuseki_NihonIgai, value: this.taishoJidoData.KOKUSEKI_OTHER }
		];
	}

	get isNextDisabled() {
		return !this.kyufuKahi || this.isUpserting;
	}

	/**
	 * 値変更時処理
	 */
	changeInput(event) {
		if (typeof event.detail.checked != "undefined") {
			this.taishoJidoData[event.target.dataset.id] = event.detail.checked;
			return;
		}
		this.taishoJidoData[event.target.dataset.id] = event.detail.value;
	}

	/**
	 * 次へボタン押下時
	 */
	isUpserting = false;
	async goNext() {

		if (!this.taishoJidoData.isDisabled) {
			this.isUpserting = true;
			const isSuccess = await this.upsertProc();
			this.isUpserting = false;
			if (!isSuccess) {
				return;
			}
		}

		const taishoJidoEvent = new CustomEvent(
			'taishojidoid',
			{ detail : this.taishoJidoId }
		);

		this.dispatchEvent(taishoJidoEvent);

		const customEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO_FILE }
		);

		this.dispatchEvent(customEvent);
	}

	/**
	 * 保存処理
	 */
	async upsertProc() {

		// 入力チェック
		if (this.isError()) {
			this.dispatchEvent(showToast(EX_CMN_INPUT_ERROR, '', 'error'));
			return false;
		}

		// 対象児童登録処理呼び出し
		try {
			const result = await upsertTaishoJido({recordId: this.recordId, tjw: this.taishoJidoData});

			// 入力チェックでエラーがあった場合、項目に設定する
			if (!result.taishoJidoId) {
				for (const error of result.errorLog) {
					const errorField = this.template.querySelector('[data-id="' + error.field + '"]');
					if (!!errorField) {
						errorField.setCustomValidity(error.message);
						errorField.reportValidity();
					}
				}

				const jushoForm = this.template.querySelector('c-ex-jusho-form');
				if (!!jushoForm) {
					jushoForm.setCustomValidity(result.errorLog);
				}

				// メッセージを表示して処理終了
				this.dispatchEvent(showToast(EX_CMN_INPUT_ERROR, '', 'error'));
				return false;
			}

			this.taishoJidoId = result.taishoJidoId;

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
								,...this.template.querySelectorAll('lightning-radio-group')
								,...this.template.querySelectorAll('lightning-combobox')]
            .reduce((checkResult, inputFields) => {
				inputFields.setCustomValidity(''); // 登録時に発生したエラー内容を消去
                inputFields.reportValidity();	// 入力チェックを実施、画面側に反映させる
                return checkResult && inputFields.checkValidity(); // これまでのチェック結果 && 入力規則が問題ないか → 1回でもエラーがあった場合、以降全てfalseとなる
            }, true);

		let jushoValid = true;
		const jushoForm = this.template.querySelector('c-ex-jusho-form');
		if (jushoForm) {
			jushoValid = jushoForm.inputValid();
		}

		let customLookupValid = true;
		const customLookup = this.template.querySelector('c-ex-custom-lookup');
		if (customLookup) {
			customLookupValid = customLookup.inputValid();
		}

		return !(allInputValid && jushoValid && customLookupValid);
	}

	/**
	 * 対象児童一覧に戻る
	 */
	async goList() {

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.TAISHO_JIDO }
		);

		this.dispatchEvent(clickEvent);
	}
}