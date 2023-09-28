import { LightningElement, api, wire, track } from 'lwc';
import getChofukuKohoJido from '@salesforce/apex/sfChofukuKohoHyojiController.getChofukuKohoJido';

export default class sfChofukuKohoHyoji extends LightningElement {

    @api
    recordId;

    @track chofukuJidoList = [];
    errorMessage = '';

    connectedCallback() {
        getChofukuKohoJido({currentJidoId: this.recordId}).then(result => {

            result.forEach(element => {
                let record = {};
                record.id                = element.Id;
                record.name              = element.Name;
                record.url               = '/lightning/r/TaishoJido__c/' + element.Id + '/view';
                record.seikyuNameKana    = element.NinteiSeikyu__r?.Seikyusha__r?.ShimeiFurigana__c;
                record.ShinseiKanryoDate = element.NinteiSeikyu__r?.ShinseiKanryoDate__c;
                
                this.chofukuJidoList.push(record);
            });
        });
    }

    @api
    get isError() {
        return false; // 本番ではエラー起きていない場合以外はtrueにする
    }

    @api
    get isPermissionError() {
        return false; // 本番では権限がないユーザに見せないよう制御する
    }

    @api
    get isEmpty() {
        return false; // 本番では重複レコードない場合にtrueにする
    }

}