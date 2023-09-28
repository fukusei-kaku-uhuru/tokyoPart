import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * トーストを表示する
 */
const showToast = (title, msg, variant) => {
	const evt = new ShowToastEvent({
		title: title
		,message: msg
		,variant: variant
		,mode: 'pester'
	});
	return evt;
}

export { showToast }