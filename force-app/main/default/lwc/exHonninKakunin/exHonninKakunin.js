import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import ExConfirmTrustdock from 'c/exConfirmTrustdock';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getHonninKakunin from '@salesforce/apex/ExHonninKakuninController.getHonninKakunin';
import clearHonninKakunin from '@salesforce/apex/ExHonninKakuninController.clearHonninKakunin';

import TRUSTDOCK_LINK_FOR_ANDROID from '@salesforce/label/c.EX_HKH1_TRUSTDOCK_GOOGLE_PLAY';
import TRUSTDOCK_LINK_FOR_APPLE from '@salesforce/label/c.EX_HKH1_TRUSTDOCK_APPLE_STORE';

import ImgExTrustDock from '@salesforce/resourceUrl/ExTrustDock';
import ImgExFileUpload from '@salesforce/resourceUrl/ExFileUploadForKakunin';

export default class ExHonninKakunin extends NavigationMixin(LightningElement) {
	@api pageNo;
	@api recordId;

	isLoading = true;

	_approvedByOptions = [];
	approvedByOptions = [];
	approvedBy;
	hasApproved = false;
	validShinsaKekka = false;

	isSiteModeDv = false;
	isSiteModeSatoya = false;

	get isNotSiteModeDv() {
		return !this.isSiteModeDv;
	}

	get isNotSiteModeSatoya() {
		return !this.isSiteModeSatoya;
	}

	get approvedByMyNumber() {
		if (this._approvedByOptions.length) {
			return this.hasApproved && this.approvedBy === this._approvedByOptions[0].value;
		}
	}

	get approvedByFileUpload() {
		if (this._approvedByOptions.length) {
			return this.hasApproved && this.approvedBy === this._approvedByOptions[1].value;
		}
	}

	get ImgExTrustDock() {
		return ImgExTrustDock;
	}

	get ImgExFileUpload() {
		return ImgExFileUpload;
	}

	async connectedCallback() {
		this.isSiteModeDv = await isSiteModeDv({});

		this.isSiteModeSatoya = await isSiteModeSatoya({});

        await getHonninKakunin({recordId: this.recordId})
			.then(result => {
				this._approvedByOptions = result.approvedByOptions;
				this.approvedByOptions = result.approvedByOptions.filter(approvedByOption => approvedByOption.isAvailable);
				this.approvedBy = result.approvedBy;
				this.hasApproved = result.hasApproved;
				this.validShinsaKekka = result.validShinsaKekka;
            })
			.catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
		this.isLoading = false;
	}

	changeApprovedBy(event) {
        this.approvedBy = event.detail.value;
    }

	openAndroidLink(){
		this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: TRUSTDOCK_LINK_FOR_ANDROID,
			}
		});
	}

	openAppleLink(){
		this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: TRUSTDOCK_LINK_FOR_APPLE,
			}
		});
	}

	goBack() {
		let customEvent;
		if (this.isSiteModeSatoya) { // 里親の場合は画面をスキップして利用規約に遷移
			customEvent = new CustomEvent(
				'submit',
				{ detail : this.pageNo.AGREEMENT }
			);
		} else {
			customEvent = new CustomEvent(
				'submit',
				{ detail : this.pageNo.KAKUNIN_18 }
			);
		}
		this.dispatchEvent(customEvent);
	}

	async goNext() {
		let pageNo;
		if(this.hasApproved){
			pageNo = this.pageNo.SEIKYUSHA;
		} else if (this.approvedBy === this._approvedByOptions[0].value) { // 公的個人認証

			// TRUSTDOCKインストール済かを確認する
			const result = await ExConfirmTrustdock.open({
				size: 'small'
			});
			if (!result) {
				return;
			}
			pageNo = this.pageNo.MY_NUMBER;
		} else if (this.approvedBy === this._approvedByOptions[1].value) { // 券面アップロード
			pageNo = this.pageNo.FILE_UPLOAD;
		}

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : pageNo }
		);
		this.dispatchEvent(clickEvent);
	}

	get canReUpload() {
		return this.approvedByFileUpload && this.validShinsaKekka;
	}

	reUpload() {
		clearHonninKakunin({recordId: this.recordId})
		.then(result => {
			this.hasApproved = false;
		})
		.catch(error => {
			this.dispatchEvent(errorHandle(error));
		});
	}
}