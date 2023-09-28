import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import isSiteModeDv from '@salesforce/apex/ExLwcUtil.isSiteModeDv';
import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';
import getColumnLabels from '@salesforce/apex/ExLwcUtil.getColumnLabels';
import getNinteiSeikyuNo from '@salesforce/apex/ExShinseiKanryoController.getNinteiSeikyuNo';

export default class ExShinseiKanryo extends NavigationMixin(LightningElement) {
	@api recordId = '';

	isLoading = true;

	isSiteModeDv = false;
	isSiteModeSatoya = false;

	/**
	 * 項目ラベル（認定請求）
	 */
	ninteiSeikyuLbl = {
		NinteiSeikyuUketsukeBangou__c : ''
	};

	ninteiSeikyuNo;

	/**
	 * 読み込み時処理
	 */
	async connectedCallback() {
		try {
			this.ninteiSeikyuNo = await getNinteiSeikyuNo({recordId: this.recordId});

			this.ninteiSeikyuLbl = await getColumnLabels({objectName: 'NinteiSeikyu__c', columnNames: Object.keys(this.ninteiSeikyuLbl)});

			this.isSiteModeDv = await isSiteModeDv({});

			this.isSiteModeSatoya = await isSiteModeSatoya({});

			this.isLoading = false;

		} catch (error) {
			this.dispatchEvent(errorHandle(error));
		}
	}

	goHome(){
		this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home',
            },
        });
	}
}