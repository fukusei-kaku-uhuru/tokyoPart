import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ExPrivacyPolicy extends NavigationMixin(LightningElement) {
    openLink(event){
        const url = event.target.dataset.url;
        console.log(url);

        this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: url,
			}
		});
    }
}