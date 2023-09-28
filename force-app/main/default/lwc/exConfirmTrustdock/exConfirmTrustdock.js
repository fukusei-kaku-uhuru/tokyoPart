import LightningModal from 'lightning/modal'
import { NavigationMixin } from 'lightning/navigation';

import TRUSTDOCK_LINK_FOR_ANDROID from '@salesforce/label/c.EX_HKH1_TRUSTDOCK_GOOGLE_PLAY';
import TRUSTDOCK_LINK_FOR_APPLE from '@salesforce/label/c.EX_HKH1_TRUSTDOCK_APPLE_STORE';

export default class ExConfirmTrustdock extends LightningModal {

	get urlTrustdockAndroid() {
		return TRUSTDOCK_LINK_FOR_ANDROID;
	}
	get urlTrustdockApple() {
		return TRUSTDOCK_LINK_FOR_APPLE;
	}

	handleOk() {
		this.close(true);
	}

	handleCancel() {
		this.close(false);
	}
}