import { LightningElement, api, track } from 'lwc';
import getUserProfile from '@salesforce/apex/SfNinteiSeikyuShinsaCheckController.getUserProfile';
import getUserPermissionSetAssignment from '@salesforce/apex/SfNinteiSeikyuShinsaCheckController.getUserPermissionSetAssignment';
import getNinteiSeikyu from '@salesforce/apex/SfNinteiSeikyuShinsaCheckController.getNinteiSeikyu'
import getTaishoJido from '@salesforce/apex/SfNinteiSeikyuShinsaCheckController.getTaishoJido'
import completeShinsa from '@salesforce/apex/SfNinteiSeikyuShinsaCheckController.completeShinsa'
import loginUserId from '@salesforce/user/Id';

const saishuPermissionErrorProfile = ['審査'];
const saishuPermissionSetAllowed = ['Shinsa_LD', 'Shinsa_SV'];

const STATUS_STR_SHINSACHU_00 = '0次審査中';
const STATUS_STR_SHINSACHU_01 = '1次審査中';
const STATUS_STR_SHINSACHU_02 = '2次審査中';
const STATUS_STR_UNMATCH      = 'アンマッチ判定';

export default class SfNinteiSeikyuShinsaCheck extends LightningElement {

    @api
    recordId;

    @track loginUserProfileName    = '';
    @track hasAllowedPermissionSet = false;

    @track shinsaStatus = '';

    @track record         = {};
    @track seikyusha      = {};
    @track taishoJidoList = [];
    
    @track isShinsachu;
    @track isShinsaKanryo    = false;
    @track hasNoShinsaTarget = false;
    @track isNotAbleKanryo   = false;
    @track hasError          = false;
    @track errorMessage      = '';

    connectedCallback() {

        getUserPermissionSetAssignment({userId:loginUserId}).then(result => {
            JSON.parse(result).forEach(element => {
                if(saishuPermissionSetAllowed.includes(element.PermissionSet.Name)) {
                    this.hasAllowedPermissionSet = true;
                }
            });
        });

        getUserProfile({userId:loginUserId}).then(result => {
            this.loginUserProfileName = result.Name;

            getNinteiSeikyu({currentRecordId:this.recordId}).then(result => {

                // 表示内容を設定
                this.record.status    = result.ShinsaStatus__c;
                this.seikyusha.shimei = result.Seikyusha__r.Shimei__c;
    
                if(result.ShinsaStatus__c === STATUS_STR_SHINSACHU_00) {
                    this.seikyusha.shinsaKekka = result.Seikyusha__r.ShinsaKekka_00__c;
                    this.isShinsachu           = true;
                    this.shinsaStatus          = STATUS_STR_SHINSACHU_00;
                } else if(result.ShinsaStatus__c === STATUS_STR_SHINSACHU_01) {
                    this.seikyusha.shinsaKekka = result.Seikyusha__r.ShinsaKekka_01__c;
                    this.isShinsachu           = true;
                    this.shinsaStatus          = STATUS_STR_SHINSACHU_01;
                } else if(result.ShinsaStatus__c === STATUS_STR_SHINSACHU_02) {
                    this.seikyusha.shinsaKekka = result.Seikyusha__r.ShinsaKekka_02__c;
                    this.isShinsachu           = true;
                    this.shinsaStatus          = STATUS_STR_SHINSACHU_02;
                } else if(result.ShinsaStatus__c === STATUS_STR_UNMATCH) {
                    this.seikyusha.shinsaKekka = result.Seikyusha__r.ShinsaKekkaSaishu__c;
                    this.isShinsachu           = true;
                    this.shinsaStatus          = STATUS_STR_UNMATCH;
                }else {
                    this.isShinsachu = false;
                }
    
                if(!this.seikyusha.shinsaKekka) { this.hasNoShinsaTarget = true;}
    
                getTaishoJido({currentRecordId:this.recordId}).then(result => {
    
                    // 表示内容を設定
                    result.forEach(element => {
                        let jido = {};
        
                        jido.id     = element.Id;
                        jido.shimei = element.Shimei__c;
                        if(this.record.status === STATUS_STR_SHINSACHU_00) {
                            jido.shinsaKekka = element.ShinsaKekka_00__c;
                        } else if(this.record.status === STATUS_STR_SHINSACHU_01) {
                            jido.shinsaKekka = element.ShinsaKekka_01__c;
                        } else if(this.record.status === STATUS_STR_SHINSACHU_02) {
                            jido.shinsaKekka = element.ShinsaKekka_02__c;
                        } else if(this.record.status === STATUS_STR_UNMATCH) {
                            jido.shinsaKekka = element.ShinsaKekkaSaishu__c;
                        }
    
                        if(!jido.shinsaKekka) { this.hasNoShinsaTarget = true;}
        
                        this.taishoJidoList.push(jido);
                    });
    
                    this.isNotAbleKanryo = this.isShinsaKanryo || this.hasNoShinsaTarget;
                });
            });
            console.log('確認record');
        });   
    }

    @api
    get isError() {
        return false; // 本番ではエラー起きていない場合以外はtrueにする
    }

    @api
    get isPermissionError() {
        // 最終審査時に指定されたプロファイルの場合はチェック画面を表示しない
        if(this.shinsaStatus === STATUS_STR_UNMATCH
        && saishuPermissionErrorProfile.includes(this.loginUserProfileName)
        && !this.hasAllowedPermissionSet) {
            console.log('確認チェック画面表示しない');
            return true;
        }
        console.log('確認チェック画面表示する');
        return false; // 本番では権限がないユーザに見せないよう制御する
    }

    @api
    get isEmpty() {
        return false; // 本番では重複レコードない場合にtrueにする
    }

    shinsaKanryo() {
        completeShinsa({ninteiSeikyuId:this.recordId,
                        shinsaStatus:this.record.status}).then(result => {
            if(result) {
                this.hasError     = true;
                this.errorMessage = result;
            } else {
                this.isShinsaKanryo  = true;
                this.isNotAbleKanryo = this.isShinsaKanryo || this.hasNoShinsaTarget;
            }
        });
    }
}