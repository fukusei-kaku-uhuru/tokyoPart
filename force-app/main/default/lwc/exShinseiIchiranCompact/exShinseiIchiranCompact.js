import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { errorHandle } from 'c/exErrorHandler';
import getNinteiSeikyu from '@salesforce/apex/ExShinseiIchiranController.getNinteiSeikyu';

export default class ExShinseiIchiranCompact extends NavigationMixin(LightningElement) {

	@track
	shinseiList = [];

	async connectedCallback() {
        try{
            const result = await getNinteiSeikyu();

            const dataList = JSON.parse(JSON.stringify(result.shinseiList));
			dataList.forEach((data, index) => {
				if (index >= 4) {
					return;
				}

				const shinsei = {
                    parentId: data.parentId,
                    parentNo: data.parentNo,
                    status: data.status,
                    isEditDisabled: data.isEditDisabled,
					createdDate: data.createdDate
                }

                // 0件の場合、Idが空のchildが渡されてしまうため抽出
                const childList = data.childList.filter(child => !!child.childId);
                shinsei.childrenSize = childList.length;
				this.shinseiList.push(shinsei);
			});

        }catch(error){
            this.dispatchEvent(errorHandle(error));
        }
    }

	/**
	 * 受付番号押下時処理
	 */
    goEditShinsei(event) {
        const id = event.target.dataset.id;

		// 対象の認定請求編集画面に遷移
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

	/**
	 * すべて表示押下時処理
	 */
	goAllData() {

		// 申請履歴画面に遷移
		this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_application_list__c',
            }
        });
	}
}