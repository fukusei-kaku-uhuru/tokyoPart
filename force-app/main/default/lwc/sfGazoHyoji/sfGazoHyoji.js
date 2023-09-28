import { LightningElement, api, wire, track } from 'lwc';
import getContentVersion from '@salesforce/apex/sfGazoHyojiController.getContentVersion';
import setJidoHanteiKekka from '@salesforce/apex/sfGazoHyojiController.setJidoHanteiKekka';
import updateContentVersionCheck from '@salesforce/apex/sfGazoHyojiController.updateContentVersionCheck';
import updateContentVersionHantei from '@salesforce/apex/sfGazoHyojiController.updateContentVersionHantei';
import getShinseiShoruiTeigiPickList from '@salesforce/apex/sfGazoHyojiController.getShinseiShoruiTeigiPickList';
import updateContentVersionTeigi from '@salesforce/apex/sfGazoHyojiController.updateContentVersionTeigi';

const shinsachuStatus_00 = '0次審査中';
const shinsachuStatus_01 = '1次審査中';
const shinsachuStatus_02 = '2次審査中';

const hanteiOk           = 'OK';

export default class SfGazoHyoji extends LightningElement {

    @api
    recordId;

    @track gazouList          = [];
    @track shinseiShoruiList  = [];
    @track mibunruiShoruiList = [];

    @track shinseiShoruiTeigiOptions = [];

    errorMessage             = '';
    isSaved                  = false;
    isSavedTeigi             = false;

    @track isNot0thShinsa    = true;
    @track isNot1stShinsa    = true;
    @track isNot2ndShinsa    = true;

    @track isNotCheckStatus  = true;
    @track hasMibunruiShorui = false;

    connectedCallback() {
        getContentVersion({currentRecordId:this.recordId}).then(result => {

            let hikakuNaiyoList = [];
            result.forEach(element => {

                let record = {};
                let hikakuNaiyo = {};
            
                // 表示内容を設定
                record.id                = element.Id;
                record.src               = element.VersionDataUrl;
                hikakuNaiyo.id           = element.Id;

                record.ShinseiShoruiTeigiId    = element.ShinseiShoruiTeigiId__c;
                record.ShinseiShoruiTeigiName  = element.ShinseiShoruiTeigiName__c;
                record.Yoto                    = element.Yoto__c;
                record.IsDeletable             = element.IsDeletable__c;
                record.MaskingFubi             = element.MaskingFubi__c;

                record.OCR_Shimei      = element.OCR_Shimei__c;
                record.OCR_SeinenGappi = element.OCR_SeinenGappi__c;
                record.OCR_Jusho       = element.OCR_Jusho__c;
                record.OCR_YukoKigen   = element.OCR_YukoKigen__c;
                record.OCR_TextZembun  = element.OCR_TextZembun__c;

                hikakuNaiyo.shimeiOcr          = element.OCR_Shimei__c;
                hikakuNaiyo.seinenGappiDateOcr = element.OCR_SeinenGappi__c;
                hikakuNaiyo.jushoOcr           = element.OCR_Jusho__c;
                hikakuNaiyo.yukoKigenDateOcr   = element.OCR_YukoKigen__c;

                record.JidoHantei_Shimei      = false;
                record.JidoHantei_SeinenGappi = false;
                record.JidoHantei_Jusho       = false;
                record.JidoHantei_YukoKigen   = false;

                record.ShudoCheck_Shimei      = element.ShudoCheck_Shimei__c;
                record.ShudoCheck_SeinenGappi = element.ShudoCheck_SeinenGappi__c;
                record.ShudoCheck_Jusho       = element.ShudoCheck_Jusho__c;
                record.ShudoCheck_YukoKigen   = element.ShudoCheck_YukoKigen__c;
                record.ShudoCheck_TextZembun  = element.ShudoCheck_TextZembun__c;

                record.Hantei_Shimei      = element.Hantei_Shimei__c;
                record.Hantei_SeinenGappi = element.Hantei_SeinenGappi__c;
                record.Hantei_Jusho       = element.Hantei_Jusho__c;
                record.Hantei_YukoKigen   = element.Hantei_YukoKigen__c;

                record.createdDate       = element.CreatedDate;
                record.link              = '/lightning/r/ContentDocument/' + element.ContentDocumentId + '/view';

                this.gazouList.push(record);
                hikakuNaiyoList.push(hikakuNaiyo);
            });

            let hikakuNaiyoJsonStr = JSON.stringify(hikakuNaiyoList);
            setJidoHanteiKekka({currentRecordId:this.recordId, hikakuNaiyoJson:hikakuNaiyoJsonStr}).then(kekka => {
                let kekkaArray = {};
                JSON.parse(kekka).forEach(element => {
                    kekkaArray[element.id] = element;
                });

                this.gazouList.forEach(element => {
                    element.JidoHantei_Shimei      = kekkaArray[element.id].shimeiKekka;
                    element.JidoHantei_SeinenGappi = kekkaArray[element.id].seinenGappiDateKekka;
                    element.JidoHantei_Jusho       = kekkaArray[element.id].jushoKekka;
                    element.JidoHantei_YukoKigen   = kekkaArray[element.id].yukokigenDateKekka;
                    element.shinsaStatus           = kekkaArray[element.id].shinsaStatus;

                    // 申請書類定義IDが空の場合はshinseiShoruiListではなくmibunruiShoruiListに入れる
                    if(element.ShinseiShoruiTeigiId) {
                        // shinseiShoruiListに書類の種類ごとにまとめていく
                        if(!this.shinseiShoruiList.some((shorui) => { return shorui.ShinseiShoruiTeigiId && shorui.ShinseiShoruiTeigiId === element.ShinseiShoruiTeigiId})) {
                            let shoruiGroup = {};
                            shoruiGroup.ShinseiShoruiTeigiId   = element.ShinseiShoruiTeigiId;
                            shoruiGroup.ShinseiShoruiTeigiName = element.ShinseiShoruiTeigiName;
                            shoruiGroup.shoruiList             = [];
                            this.shinseiShoruiList.push(shoruiGroup);
                        }
                        this.shinseiShoruiList.find(shorui => shorui.ShinseiShoruiTeigiId === element.ShinseiShoruiTeigiId).shoruiList.push(element);
                    } else {
                        this.mibunruiShoruiList.push(element);
                    }
                });

                // 未分類書類がある場合未分類書類タブを表示
                console.log('動作確認mibunruiShoruiList.length:' + this.mibunruiShoruiList.length);
                if(this.mibunruiShoruiList.length > 0) {
                    this.hasMibunruiShorui = true;
                }

                // 各リストをソート
                if(this.shinseiShoruiList) {
                    this.shinseiShoruiList.forEach(group => {
                        group.shoruiList = this.sortContentVersionList(group.shoruiList);
                    });
                }
                if(this.shinseiShoruiList[0] && this.shinseiShoruiList[0].shoruiList[0]) {
                    this.isNot0thShinsa = this.shinseiShoruiList[0].shoruiList[0].shinsaStatus !== shinsachuStatus_00;
                    this.isNot1stShinsa = this.shinseiShoruiList[0].shoruiList[0].shinsaStatus !== shinsachuStatus_01;
                    this.isNot2ndShinsa = this.shinseiShoruiList[0].shoruiList[0].shinsaStatus !== shinsachuStatus_02;

                    this.isNotCheckStatus = (this.isNot0thShinsa && this.isNot1stShinsa && this.isNot2ndShinsa);
                }
                
                // 判定項目を更新
                let hanteiKekkaJsonStr = this.setHanteiKekkaJSONStr();
                updateContentVersionHantei({checkKekkaJson:hanteiKekkaJsonStr}).then(hantei => {
                    if(hantei.message) {
                        this.errorMessage = message;
                    } else {
                        let hanteiArray = {};
                        JSON.parse(hantei).forEach(element => {
                            hanteiArray[element.id] = element;
                        });
                        if(this.shinseiShoruiList) {
                            this.shinseiShoruiList.forEach(group => {
                                group.shoruiList.forEach(record => {
                                    record.Hantei_Shimei      = hanteiArray[record.id].Hantei_Shimei      ? hanteiOk : '';
                                    record.Hantei_SeinenGappi = hanteiArray[record.id].Hantei_SeinenGappi ? hanteiOk : '';
                                    record.Hantei_Jusho       = hanteiArray[record.id].Hantei_Jusho       ? hanteiOk : '';
                                    record.Hantei_YukoKigen   = hanteiArray[record.id].Hantei_YukoKigen   ? hanteiOk : '';
                                });
                            });
                        }
                    }
                });
            });
        });

        getShinseiShoruiTeigiPickList().then(teigi => {
            JSON.parse(teigi).forEach(element => {
                let option = {};
                option.label = element.label;
                option.value = element.value;

                this.shinseiShoruiTeigiOptions.push(option);
            });
        });
    }

    onchangeShinseiShoruiTeigi(event) {
        let idx     = event.target.dataset.idx;
        let teigiId = event.target.value;

        this.mibunruiShoruiList[idx].ShinseiShoruiTeigiId = teigiId;
        this.isSavedTeigi = false;
    }

    onchangeShudoCheck_Shimei(event) {
        let groupidx = event.target.dataset.groupidx;
        let idx = event.target.dataset.idx;
        let checked  = event.target.checked;

        this.shinseiShoruiList[groupidx].shoruiList[idx].ShudoCheck_Shimei = checked;
        this.isSaved = false;
    }

    onchangeShudoCheck_SeinenGappi(event) {
        let groupidx = event.target.dataset.groupidx;
        let idx = event.target.dataset.idx;
        let checked  = event.target.checked;

        this.shinseiShoruiList[groupidx].shoruiList[idx].ShudoCheck_SeinenGappi = checked;
        this.isSaved = false;
    }

    onchangeShudoCheck_Jusho(event) {
        let groupidx = event.target.dataset.groupidx;
        let idx = event.target.dataset.idx;
        let checked  = event.target.checked;

        this.shinseiShoruiList[groupidx].shoruiList[idx].ShudoCheck_Jusho = checked;
        this.isSaved = false;
    }

    onchangeShudoCheck_YukoKigen(event) {
        let groupidx = event.target.dataset.groupidx;
        let idx = event.target.dataset.idx;
        let checked  = event.target.checked;

        this.shinseiShoruiList[groupidx].shoruiList[idx].ShudoCheck_YukoKigen = checked;
        this.isSaved = false;
    }

    onchangeShudoCheck_TextZembun(event) {
        let groupidx = event.target.dataset.groupidx;
        let idx = event.target.dataset.idx;
        let checked  = event.target.checked;

        this.shinseiShoruiList[groupidx].shoruiList[idx].ShudoCheck_TextZembun = checked;
        this.isSaved = false;
    }

    onchangeMaskingFubi(event) {
        let groupidx = event.target.dataset.groupidx;
        let idx = event.target.dataset.idx;
        let checked  = event.target.checked;

        this.shinseiShoruiList[groupidx].shoruiList[idx].MaskingFubi = checked;
        this.isSaved = false;
    }

    saveTeigi() {
        let teigiList = [];
        this.mibunruiShoruiList.forEach(record => {
            let teigi = {};
            teigi.id                   = record.id;
            teigi.shinseiShoruiTeigiId = record.ShinseiShoruiTeigiId;

            teigiList.push(teigi);
        });

        let teigiListStr = JSON.stringify(teigiList);
        updateContentVersionTeigi({setTeigiJson:teigiListStr}).then(message => {
            if(message) {
                this.errorMessage = message;
            } else {
                this.isSavedTeigi = true;
            }
        });
    }

    saveCheck() {
        let checkList = [];
        this.shinseiShoruiList.forEach(element => {
            element.shoruiList.forEach(record => {
                let check = {};
                check.id                     = record.id;
                check.shimeiCheck            = record.ShudoCheck_Shimei;
                check.seinenGappiCheck       = record.ShudoCheck_SeinenGappi;
                check.jushoCheck             = record.ShudoCheck_Jusho;
                check.yukokigenDateCheck     = record.ShudoCheck_YukoKigen;
                check.textZembunCheck        = record.ShudoCheck_TextZembun;
                check.maskingFubiCheck       = record.MaskingFubi;

                checkList.push(check);
            });
        });
        let checkListStr = JSON.stringify(checkList);
        updateContentVersionCheck({checkKekkaJson:checkListStr}).then(message => {
            if(message) {
                this.errorMessage = message;
            } else {
                this.isSaved = true;
                // 判定項目を更新
                let hanteiKekkaJsonStr = this.setHanteiKekkaJSONStr();
                updateContentVersionHantei({checkKekkaJson:hanteiKekkaJsonStr}).then(hantei => {
                    if(hantei.message) {
                        this.errorMessage = message;
                    } else {
                        let hanteiArray = {};
                        JSON.parse(hantei).forEach(element => {
                            hanteiArray[element.id] = element;
                        });
                        if(this.shinseiShoruiList) {
                            this.shinseiShoruiList.forEach(group => {
                                group.shoruiList.forEach(record => {
                                    record.Hantei_Shimei      = hanteiArray[record.id].Hantei_Shimei      ? hanteiOk : '';
                                    record.Hantei_SeinenGappi = hanteiArray[record.id].Hantei_SeinenGappi ? hanteiOk : '';
                                    record.Hantei_Jusho       = hanteiArray[record.id].Hantei_Jusho       ? hanteiOk : '';
                                    record.Hantei_YukoKigen   = hanteiArray[record.id].Hantei_YukoKigen   ? hanteiOk : '';
                                });
                            });
                        }
                    }
                });
            }
        });
    }

    setHanteiKekkaJSONStr() {
        let checkList = [];
        this.shinseiShoruiList.forEach(element => {
            element.shoruiList.forEach(record => {
                let check = {};
                check.id                         = record.id;
                check.shimeiKekkaAuto            = record.JidoHantei_Shimei;
                check.seinenGappiDateKekkaAuto   = record.JidoHantei_SeinenGappi;
                check.jushoKekkaAuto             = record.JidoHantei_Jusho;
                check.yukokigenDateKekkaAuto     = record.JidoHantei_YukoKigen;
                check.shimeiKekkaManual          = record.ShudoCheck_Shimei;
                check.seinenGappiDateKekkaManual = record.ShudoCheck_SeinenGappi;
                check.jushoKekkaManual           = record.ShudoCheck_Jusho;
                check.yukokigenDateKekkaManual   = record.ShudoCheck_YukoKigen;

                checkList.push(check);
            });
        });
        let checkListStr = JSON.stringify(checkList);
        return checkListStr;
    }

    sortContentVersionList(contentVersionList) {
        contentVersionList.sort(function(first, second){
            let firstCreateDateStr = first.createdDate;
            let firstYear   = Number(firstCreateDateStr.slice(0,4));
            let firstMonth  = Number(firstCreateDateStr.slice(5,7));
            let firstDay    = Number(firstCreateDateStr.slice(8,10));
            let firstHour   = Number(firstCreateDateStr.slice(11,13));
            let firstMinute = Number(firstCreateDateStr.slice(14,16));
            let firstSecond = Number(firstCreateDateStr.slice(17,19));
            let firstDate   = new Date(firstYear, firstMonth, firstDay, firstHour, firstMinute, firstSecond);
            console.log('確認firstDate:' + firstDate);
    
            let secondCreateDateStr = second.createdDate;
            let secondYear   = Number(secondCreateDateStr.slice(0,4));
            let secondMonth  = Number(secondCreateDateStr.slice(5,7));
            let secondDay    = Number(secondCreateDateStr.slice(8,10));
            let secondHour   = Number(secondCreateDateStr.slice(11,13));
            let secondMinute = Number(secondCreateDateStr.slice(14,16));
            let secondSecond = Number(secondCreateDateStr.slice(17,19));
            let secondDate   = new Date(secondYear, secondMonth, secondDay, secondHour, secondMinute, secondSecond);
            console.log('確認secondDate:' + secondDate);
    
            if(firstDate.getTime() > secondDate.getTime()) {
                return -1;
            } else if(firstDate.getTime() < secondDate.getTime()) {
                return 1;
            } else {
                return 0;
            }
        });
        return contentVersionList;
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