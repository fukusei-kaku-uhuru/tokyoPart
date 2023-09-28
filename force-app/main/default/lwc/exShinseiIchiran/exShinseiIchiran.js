import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import { loadStyle } from 'lightning/platformResourceLoader';
import STYLE_SHEET from '@salesforce/resourceUrl/ExStyleSheet';

import isSiteModeSatoya from '@salesforce/apex/ExLwcUtil.isSiteModeSatoya';

import getNinteiSeikyu from '@salesforce/apex/ExShinseiIchiranController.getNinteiSeikyu';

export default class ExShinseiIchiran extends NavigationMixin(LightningElement) {

    parentList = [];

    // 申請情報の確認表示用
    displayShinseiIchiran = true;
    selectedId;

    hasStyleLoaded = false;
    isLoading = true;

    isSiteModeSatoya = false;

    get isParentListEmpty(){
        return this.parentList.length === 0;
    }

	async connectedCallback() {
        try{
            if(!this.hasStyleLoaded){
                await loadStyle(this, STYLE_SHEET);
                this.hasStyleLoaded = true;
            }

            this.isSiteModeSatoya = await isSiteModeSatoya({});

            const result = await getNinteiSeikyu();

            const shinseiList = JSON.parse(JSON.stringify(result.shinseiList));
            this.dataList = result.shinseiList;
            this.parentList = shinseiList.map(x => {
                const data = {
                    parentId: x.parentId,
                    parentNo: x.parentNo,
                    status: x.status,
                    isEditDisabled: x.isEditDisabled,
                }
                data.childList = x.childList.map(y => {
                    return {
                        childId: y.childId,
                        childName: y.childName,
                        shoninKekka: y.shoninKekka,
                    }
                })
                return data;
            })
        }catch(error){
            this.dispatchEvent(errorHandle(error));
        }finally{
            this.isLoading = false;
        }
    }

    goShinseiResults(event){
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_application_result__c',
            },
            state: {
                recordId: id
            }
        });
    }

    goFubiTsuchi(event){
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_fubi_tsuchi__c',
            },
            state: {
                recordId: id
            }
        });
    }

    goEditShinsei(event) {
        const id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_application__c',
            },
            state: {
                recordId: id
            }
        });
    }

    openSaisyuKakunin(event) {
        this.selectedId = event.target.dataset.id;
        this.displayShinseiIchiran = false;

        this.scrollTop();
    }

    closeSaisyuKakunin() {
        this.displayShinseiIchiran = true;

        this.scrollTop();
    }

    scrollTop(){
        window.scroll({
            left: 0,
            top: 0,
        });
    }
}