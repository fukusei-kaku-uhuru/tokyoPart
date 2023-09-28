import { LightningElement, api, wire, track } from 'lwc';
import getChofukuKohoJido from '@salesforce/apex/sfDVChofukuKohoHyojiController.getChofukuKohoJido';
import getChofukuKohoJidoDV from '@salesforce/apex/sfDVChofukuKohoHyojiController.getChofukuKohoJidoDV';

export default class sfDVChofukuKohoHyoji extends LightningElement {

    @api
    recordId;

    @track chofukuJidoList = [];
    errorMessage = '';

    async connectedCallback() {

        let result = await getChofukuKohoJido({currentJidoId: this.recordId});

        result.forEach(element => {
            let record = {};
            record.id                = element.Id;
            record.name              = element.Name;
            record.url               = '/lightning/r/DV_TaishoJido__c/' + element.Id + '/view';
            record.seikyuNameKana    = element.NinteiSeikyu__r?.Seikyusha__r?.ShimeiFurigana__c;
            record.ShinseiKanryoDate = element.NinteiSeikyu__r?.ShinseiKanryoDate__c;
            
            this.chofukuJidoList.push(record);
        });

        result = await getChofukuKohoJidoDV({currentJidoId: this.recordId});

        result.forEach(element => {
            let record = {};
            record.id                = element.Id;
            record.name              = element.Name;
            record.url               = '/lightning/r/DV_TaishoJido__c/' + element.Id + '/view';
            record.seikyuNameKana    = element.NinteiSeikyu__r?.Seikyusya__r?.ShimeiFurigana__c;
            record.ShinseiKanryoDate = element.NinteiSeikyu__r?.ShinseiKanryoDate__c;
            
            this.chofukuJidoList.push(record);
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