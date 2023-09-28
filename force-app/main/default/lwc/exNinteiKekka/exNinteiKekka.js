import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import { loadStyle } from 'lightning/platformResourceLoader';
import STYLE_SHEET from '@salesforce/resourceUrl/ExStyleSheet';

import getTaishoJido from '@salesforce/apex/ExNinteiKekkaController.getTaishoJido';
import { generateUrl } from 'lightning/fileDownload';
import { getPathPrefix } from 'lightning/configProvider';

export default class ExNinteiKekka extends NavigationMixin(LightningElement) {

    parentList = [];
    recordId = '';

	async connectedCallback() {
        await loadStyle(this, STYLE_SHEET);
        // URLを取得
        const url = new URL(window.location.href);
        // URLSearchParamsオブジェクトを取得
        const params = url.searchParams;
        this.recordId = params.get('recordId');
        getTaishoJido({ ninteiSeikyuId: this.recordId })
            .then(result => {
                this.parentList = JSON.parse(JSON.stringify(result.taishoJidoList));
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
    }

    tsuchishoDownload(event) {
        const id = event.target.dataset.id;
        let url = generateUrl(id);

        // /sfサイトだとダウンロード用URLの生成がうまくいかない標準バグがあるため、分岐させる
        const siteUrlPrefix = getPathPrefix();
        if (siteUrlPrefix === '/sf') {
            url = url.startsWith(`${siteUrlPrefix}/`) ? url : siteUrlPrefix + url; // 頭にプレフィクスをつける
        }

        window.open(url);
    }

    goBack(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_application_list__c',
            },
        });
    }

    goJukyuJiyuShometsuTodoke(event) {
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_jukyu_jiyu_shometsu_todoke__c'
            },
            state: {
                recordId: id,
                parentId: this.recordId,
            }
        });
    }
}