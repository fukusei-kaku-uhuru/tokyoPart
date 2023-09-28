import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ExModal from 'c/exModal';
import { errorHandle } from 'c/exErrorHandler';
import { publish, MessageContext } from "lightning/messageService";
import SAMPLEMESSAGECHANNEL from "@salesforce/messageChannel/FilePreviewLMS__c";

import getDocument from '@salesforce/apex/ExFileListController.getDocument';
import deleteContentDocument from '@salesforce/apex/ExFileListController.deleteContentDocument';

export default class ExFileList extends NavigationMixin(LightningElement) {
    // contentVersionIdのみの一覧、Listの順番通りに画面に表示する
	@api contentVersionIdList;
    // true/false。trueだと強制的に削除不可、falseだとContentVersionの削除可能フラグによって削除可否切り替え
    // 削除時にfinishdeleteを発砲、呼出元は削除後の処理が必要な場合onfinishdeleteを実装
	@api unDeletable;

    @api hiddenHeader = false;
    get headerClass() {
        if (this.hiddenHeader) {
            return 'slds-var-m-top_x-small';
        }
        return 'slds-var-m-top_x-small ex-border-base_top'
    }

    @wire(MessageContext)
    messageContext;

    viewFileList = [];

    get hasViewFiles(){
        return this.viewFileList.length > 0;
    }

    @wire(getDocument, { contentVersionIdList: '$contentVersionIdList' })
    wiredDocument({ error, data }) {
        if (data) {
            const fileList = JSON.parse(JSON.stringify(data.fileList));
            this.viewFileList = fileList.map(x => {
                if (this.unDeletable) {
                    x.isDeletable = false;
                }
                return x;
            });
        }
        else if (error) {
            this.dispatchEvent(errorHandle(error));
        }
    }

    navigateToFiles(event) {
        // AuraコンポーネントにLMSでcontentDocumentIdを送信（Auraでファイルプレビュー表示）
        const payload = { contentDocumentId: event.target.dataset.contentDocumentId };
        publish(this.messageContext, SAMPLEMESSAGECHANNEL, payload);
    }

    async onclickDelete(event) {

        const contentDocumentId = event.target.dataset.contentDocumentId;

        const result = await ExModal.open({
            size: 'small'
            ,content: '削除してもよろしいですか？'
            ,type: 2
        });
        if (!result) {
            return;
        }

        // 削除開始
        const startEvent = new CustomEvent(
            'startdelete',
            {
                detail: '',
            }
        );
        this.dispatchEvent(startEvent);

        const file = this.viewFileList.find(file => file.contentDocumentId === contentDocumentId);
        deleteContentDocument({contentDocumentId: contentDocumentId})
            .then(result => {
				// 再読み込み
				const finishEvent = new CustomEvent(
					'finishdelete',
                    {
                        detail: JSON.stringify(file),
                    }
				);
				this.dispatchEvent(finishEvent);
            })
            .catch(error => {
                const finishEvent = new CustomEvent(
					'finishdelete',
                    {
                        detail: '',
                    }
				);
				this.dispatchEvent(finishEvent);
                this.dispatchEvent(errorHandle(error));
            });

    }
}