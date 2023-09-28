import { LightningElement, api, track } from 'lwc';
import getUserProfile from '@salesforce/apex/SfTaishoJidoCheckController.getUserProfile';
import getUserPermissionSetAssignment from '@salesforce/apex/SfTaishoJidoCheckController.getUserPermissionSetAssignment';
import getTaishoJido from '@salesforce/apex/SfTaishoJidoCheckController.getTaishoJido';
import getContentVersion from '@salesforce/apex/SfTaishoJidoCheckController.getContentVersion';
import updateTaishoJidoShinsaKekka from '@salesforce/apex/SfTaishoJidoCheckController.updateTaishoJidoShinsaKekka';
import getTeikeiCommentOptions from '@salesforce/apex/SfTaishoJidoCheckController.getTeikeiCommentOptions';
import loginUserId from '@salesforce/user/Id';

const saishuPermissionErrorProfile = ['審査'];
const saishuPermissionSetAllowed = ['Shinsa_LD', 'Shinsa_SV'];

const shinsachuStatusList    = ['0次審査中', '1次審査中', '2次審査中', 'アンマッチ判定'];
const shinsachuStatus_00     = '0次審査中';
const shinsachuStatus_01     = '1次審査中';
const shinsachuStatus_02     = '2次審査中';
const shinsachuStatus_Saishu = 'アンマッチ判定';

const optionKekkaOk = 'OK';

export default class SfTaishoJidoCheck extends LightningElement {

    @api recordId;

    @track loginUserProfileName    = '';
    @track hasAllowedPermissionSet = false;

    @track shinsaKekka = '';

    @track shoruiList        = [];
    @track teikeiCommentList = [];

    @track checkedWebTaishoshaJoho   = false;
    @track checkedWebSeikyushaKouza  = false;
    @track checkedWebTaishoshaKouza  = false;
    @track checkedWebIninjo          = false;
    @track checkedWebMoushitatesho   = false;
    @track checkedYusoTaishoshaJoho  = false;
    @track checkedYusoSeikyushaKouza = false;
    @track checkedYusoTaishoshaKouza = false;
    @track checkedYusoMoushitatesho  = false;

    @track shinsaStatus;
    @track isShinsachu      = false;
    @track isShinsaKanryo   = false;
    @track hasCheckList     = false;

    @track isShinsachu0      = false;
    @track isShinsachu1      = false;
    @track isShinsachu2      = false;
    @track isShinsachuSaishu = false;

    @track isTantosha    = false;
    @track isAbleToCheck = false;

    @track isWebShinsei     = false;
    @track isYusoShinsei    = false;
    @track isIninjo         = false;
    @track isMoushitate     = false;
    @track isTaishoshaKouza = false;
    @track isSeikyushaKouza = false;
    @track teikeiComment    = '';
    @track comment          = '';
    @track hasError         = false;
    @track errorMessage     = '';

    async connectedCallback(){

        // ユーザプロファイルを取得
        let result = await getUserProfile({userId:loginUserId});
        this.loginUserProfileName = result.Name;

        // ユーザの権限セット情報取得
        result = await getUserPermissionSetAssignment({userId:loginUserId});
        JSON.parse(result).forEach(element => {
            if(saishuPermissionSetAllowed.includes(element.PermissionSet.Name)) {
                this.hasAllowedPermissionSet = true;
            }
        });

        // 認定請求情報や対象児童情報を取得
        // 各種フラグの設定
        result = await getTaishoJido({currentRecordId:this.recordId});
        this.shinsaStatus = result.NinteiSeikyu__r.ShinsaStatus__c;
        this.isShinsachu  = shinsachuStatusList.includes(this.shinsaStatus);
    
        if(this.shinsaStatus === shinsachuStatus_00) {
            this.isShinsachu0 = true;
            this.isTantosha   = result.NinteiSeikyu__r.Is0thShinsasya__c;
            this.hasCheckList = true;
            this.shinsaKekka  = result.ShinsaKekka_00__c;
            if(result.ShinsaKekkaComment_00__c) {
                this.comment = result.ShinsaKekkaComment_00__c;
            }
        }
        if(this.shinsaStatus === shinsachuStatus_01) {
            this.isShinsachu1 = true;
            this.isTantosha   = result.NinteiSeikyu__r.Is1stShinsasya__c;
            this.hasCheckList = true;
            this.shinsaKekka  = result.ShinsaKekka_01__c;
            if(result.ShinsaKekkaComment_01__c) {
                this.comment = result.ShinsaKekkaComment_01__c;
            }
        }
        if(this.shinsaStatus === shinsachuStatus_02) {
            this.isShinsachu2 = true;
            this.isTantosha   = result.NinteiSeikyu__r.Is2ndShinsasya__c;
            this.hasCheckList = true;
            this.shinsaKekka  = result.ShinsaKekka_02__c;
            if(result.ShinsaKekkaComment_02__c) {
                this.comment = result.ShinsaKekkaComment_02__c;
            }
        }
        if(this.shinsaStatus === shinsachuStatus_Saishu) {
            this.isShinsachuSaishu = true;
            this.isTantosha        = result.NinteiSeikyu__r.IsSaishuShinsasya__c;
            this.shinsaKekka       = result.ShinsaKekkaSaishu__c;
            if(result.ShinsaKekkaComment_Saishu__c) {
                this.comment = result.ShinsaKekkaComment_Saishu__c;
            }
        }
    
        if(result.NinteiSeikyu__r.IsYusoShinsei__c === true) {
            this.isYusoShinsei = true;
        }
        if(result.NinteiSeikyu__r.IsYusoShinsei__c === false) {
            this.isWebShinsei = true;
        }
    
        if(result.NinteiSeikyu__r.SeikyushaKubun_Dairinin__c === true) {
            this.isIninjo = true;
        }
    
        if(result.UketoriKouzaKubun_Seikyusha__c === true) {
            this.isSeikyushaKouza = true;
        }
        if(result.UketoriKouzaKubun_Taishosha__c === true) {
            this.isTaishoshaKouza = true;
        }
    
        if((result.Moushitate_KokenninCheck__c      === true)
        || (result.Moushitate_RikonKyogiCheck__c    === true)
        || (result.Moushitate_BekkyoKango__c        === true)
        || (result.Moushitate_KaigaiRyugakuCheck__c === true)
        || (result.Moushitate_FuboSiteishaCheck__c  === true)) {
            this.isMoushitate = true;
        }

        this.isAbleToCheck = this.isShinsachu && this.isTantosha;

        // 定型コメントの取得
        result = await getTeikeiCommentOptions({isYuso:this.isYusoShinsei, is0th:this.isShinsachu0});
        let tmpTeikeiCommentList = [];
        JSON.parse(result).forEach(element => {
            let option = {};
            option.label = element.label;
            option.value = element.value;

            tmpTeikeiCommentList.push(option);
        });
        this.teikeiCommentList = tmpTeikeiCommentList;

        // 添付書類情報の取得（チェックリストに使用）
        result = await getContentVersion({currentRecordId:this.recordId});
        result.forEach(element => {
            let record = {};
            record.id  = element.Id;

            if(element.ShinseiShoruiTeigiName__c === undefined) {
                record.ShinseiShoruiTeigiName = "未分類";
            } else {
                record.ShinseiShoruiTeigiName = element.ShinseiShoruiTeigiName__c;
            }

            this.shoruiList.push(record);
        });
        
    }

    setCheckedWebTaishoshaJoho(event) {
        this.checkedWebTaishoshaJoho = event.target.checked;
    }
    setCheckedWebSeikyushaKouza(event) {
        this.checkedWebSeikyushaKouza = event.target.checked;
    }
    setCheckedWebTaishoshaKouza(event) {
        this.checkedWebTaishoshaKouza = event.target.checked;
    }
    setCheckedWebIninjo(event) {
        this.checkedWebIninjo = event.target.checked;
    }
    setCheckedWebMoushitatesho(event) {
        this.checkedWebMoushitatesho = event.target.checked;
    }

    setCheckedYusoTaishoshaJoho(event) {
        this.checkedYusoTaishoshaJoho = event.target.checked;
    }
    setCheckedYusoSeikyushaKouza(event) {
        this.checkedYusoSeikyushaKouza = event.target.checked;
    }
    setCheckedYusoTaishoshaKouza(event) {
        this.checkedYusoTaishoshaKouza = event.target.checked;
    }
    setCheckedYusoMoushitatesho(event) {
        this.checkedYusoMoushitatesho = event.target.checked;
    }

    setCheckedShorui(event) {
        let shoruiId = event.target.dataset.shoruiid;
        let index = this.shoruiList.findIndex(element => {
            return element.id === shoruiId;
        });

        if(index !== -1) {
            this.shoruiList[index].checked = event.target.checked;
        } 
    }


    setShinsaKekka(event) {
        this.shinsaKekka    = event.target.value;
        this.isShinsaKanryo = false;
    }

    setTeikeiComment(event) {
        this.teikeiComment  = event.target.value;
        this.comment       += this.teikeiComment + '\n';
        this.isShinsaKanryo = false;
    }

    setComment(event) {
        this.comment        = event.target.value;
        this.isShinsaKanryo = false;
    }

    shinsaKanryo() {
        if(!this.shinsaKekka) {
            this.hasError     = true;
            this.errorMessage = '審査結果を入力してください。';
            return;
        }
        updateTaishoJidoShinsaKekka({jidoId:this.recordId,
                                     shinsaKekka:this.shinsaKekka,
                                     shinsaComment:this.comment,
                                     shinsaStatus:this.shinsaStatus}).then(result => {
            this.errorMessage = result;
            if(result) {
                this.hasError     = true;
            } else {
                this.isShinsaKanryo = true;
            }
        });
    }

    get hasChecked() {

        // チェックリストが表示されていない場合は無条件で問題なしとする
        if(!this.hasCheckList) {
            return true;
        }

        // チェックリストの制御は結果がOKのときのみ見る、NG/不備の場合はチェックリストは無条件で問題なしとする
        if(this.shinsaKekka !== optionKekkaOk) {
            return true;
        }

        let checked = true;

        if(this.isWebShinsei) {
            if(!this.isIninjo) {
                this.checkedWebIninjo = true;
            }
            if(!this.isSeikyushaKouza) {
                this.checkedWebSeikyushaKouza = true;
            }
            if(!this.isTaishoshaKouza) {
                this.checkedWebTaishoshaKouza = true;
            }
            if(!this.isMoushitate) {
                this.checkedWebMoushitatesho = true;
            }
            checked = this.checkedWebTaishoshaJoho && this.checkedWebSeikyushaKouza && this.checkedWebTaishoshaKouza && this.checkedWebIninjo && this.checkedWebMoushitatesho;

        } else if(this.isYusoShinsei) {
            if(!this.isSeikyushaKouza) {
                this.checkedYusoSeikyushaKouza = true;
            }
            if(!this.isTaishoshaKouza) {
                this.checkedYusoTaishoshaKouza = true;
            }
            if(!this.isMoushitate) {
                this.checkedYusoMoushitatesho = true;
            }
            checked = this.checkedYusoTaishoshaJoho && this.checkedYusoSeikyushaKouza && this.checkedYusoTaishoshaKouza && this.checkedYusoMoushitatesho;
        }

        this.shoruiList.forEach(element => {
            if(!element.checked) {
                checked = false;
            }
        });

        return checked;
    }

    get hasNotComment() {
        let isNeedCommentKekka = false;
        if(this.shinsaKekka === 'NG' || this.shinsaKekka === '不備') {
            isNeedCommentKekka = true;
        }

        return isNeedCommentKekka && (!this.comment || !this.comment.match(/\S/g));
    }

    @api
    get isDisableToKanryo() {
        return !(this.isTantosha && this.shinsaKekka && !this.hasNotComment && this.hasChecked);
    }

    @api
    get isError() {
        return false; // 本番ではエラー起きていない場合以外はtrueにする
    }

    @api
    get isPermissionError() {
        // 最終審査時に指定されたプロファイルの場合はチェック画面を表示しない
        if(this.shinsaStatus === shinsachuStatus_Saishu
        && saishuPermissionErrorProfile.includes(this.loginUserProfileName)
        && !this.hasAllowedPermissionSet) {
            return true;
        }
        return false; // 本番では権限がないユーザに見せないよう制御する
    }

    @api
    get isEmpty() {
        return false; // 本番では重複レコードない場合にtrueにする
    }

    get optionsShinsaKekka() {
        return [
            {label: 'OK', value: 'OK'},
            {label: 'NG', value: 'NG'},
            {label: '不備', value: '不備'}
        ];
    }

}