import { api } from 'lwc';
import LightningModal from 'lightning/modal'

const TYPE_ALERT = 1, TYPE_CONFIRM = 2;

export default class ExModal extends LightningModal {
	@api theme = '';
	@api header = '';
	@api content = '';
	@api type = TYPE_ALERT;

	get headerClass() {
		if (this.theme == 'error') {
			return 'header-error';
		}

		return '';
	}

	get isConfirm() {
		return this.type == TYPE_CONFIRM;
	}

	handleOk() {
		this.close(true);
	}

	handleCancel() {
		this.close(false);
	}
}