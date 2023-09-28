import { LightningElement, api } from 'lwc';

import BACK from '@salesforce/label/c.EX_CMN_BACK';
import NEXT from '@salesforce/label/c.EX_CMN_NEXT';

export default class ExFooter extends LightningElement {
    @api backLabel = BACK;
    @api nextLabel = NEXT;
    @api hasBack = false;
    @api hasNext = false;
    @api isNextDisabled = false;

    get hasMultipleButtons(){
        return this.hasBack && this.hasNext;
    }

    goNext(){
        const clickEvent = new CustomEvent(
			'next',
		);
		this.dispatchEvent(clickEvent);
    }

    goBack(){
        const clickEvent = new CustomEvent(
			'back',
		);
		this.dispatchEvent(clickEvent);
    }
}