import { LightningElement, api } from 'lwc';
import doInit from '@salesforce/apex/ExMyNumberController.doInit';
import executeTrustdockUploader from '@salesforce/apex/ExMyNumberController.executeTrustdockUploader';
import querySeikyusha from '@salesforce/apex/ExMyNumberController.querySeikyusha';
import updateSeikyusha from '@salesforce/apex/ExMyNumberController.updateSeikyusha';

export default class ExMyNumber extends LightningElement {

	@api pageNo;
    @api recordId;

	result;
	prefix;
	timerId;

//TODO:デバッグ用
consoleLog = '';

	async connectedCallback() {
		// すでに成功している場合は、成功画面に遷移する
		const seikyushaInfo = await querySeikyusha({ ninteiId: this.recordId });

		if(!seikyushaInfo.length){
			return;
		}
		if (seikyushaInfo[0].trustdocPhase === 'verified' && seikyushaInfo[0].trustdocKekka == 'approved') {
			await updateSeikyusha({recordId : this.recordId});
			this.goSuccess();
			return;
		}

		window.addEventListener("message", this.handleVFResponse.bind(this));

		const result = await doInit({ninteiId: this.recordId});

		this.prefix = result.resultMap['prefix'];

		await this.executeTrustdock();
	}
	
    async executeTrustdock(){
		const result = await executeTrustdockUploader({ninteiId: this.recordId}).catch((error) => console.log(error));
		if(!result.isSuccess){
			alert(result.message);
			return;
		}

		const publicId = result.resultMap['publicId'];		
		this.template.querySelector("iframe").src = `${this.prefix}/apex/TrustdockIframe?recordId=dummyId&publicId=${publicId}`;
		this.isWaiting = true;
		this.timerId = setInterval(async() => {
			await this.checkVerificationResult();
		}, 1000);
    }

	async checkVerificationResult(){
		const seikyushaInfo = await querySeikyusha({ninteiId: this.recordId}).catch((error) => clearInterval(this.timerId));
		
		//TODO：デバッグ用
		this.consoleLog += '\n';
		const now = new Date();
		this.consoleLog += `${now.getHours()}:${now.getMinutes()}:${now.getSeconds()} ${seikyushaInfo[0].trustdocPhase}`;

		if(!seikyushaInfo.length){
			clearInterval(this.timerId);
			return;
		}

		if(seikyushaInfo[0].trustdocPhase === 'verified'){
			clearInterval(this.timerId);

			if(seikyushaInfo[0].trustdocKekka == 'approved'){
				await updateSeikyusha({recordId : this.recordId});
				this.goSuccess();
			}
			else{
				this.goError();
			}
		}
		else{
			console.log('continue');
		}
	}

	isWaiting = false;
	handleVFResponse(message) {
		if(message.data === 'close'){
			this.goBack();
		} else if (message.data === 'completed') {
			this.isWaiting = true;
			this.timerId = setInterval(async() => {
				await this.checkVerificationResult();
			}, 1000);
		}
	}

    goBack() {
		clearInterval(this.timerId);

		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.HONNIN_KAKUNIN }
		);

		this.dispatchEvent(clickEvent);
	}

	goError() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.MY_NUMBER_ERROR }
		);

		this.dispatchEvent(clickEvent);
	}

	goSuccess() {
		const clickEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.MY_NUMBER_SUCCESS }
		);

		this.dispatchEvent(clickEvent);
	}
}