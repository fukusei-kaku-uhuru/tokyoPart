import { LightningElement, api, track } from 'lwc';
import getUserProfile from '@salesforce/apex/SfSeikyushaCheckController.getUserProfile';
import getUserPermissionSetAssignment from '@salesforce/apex/SfSeikyushaCheckController.getUserPermissionSetAssignment';
import getNinteiSeikyu from '@salesforce/apex/SfSeikyushaCheckController.getNinteiSeikyu';
import getContentVersion from '@salesforce/apex/SfSeikyushaCheckController.getContentVersion';
import updateSeikyushaShinsaKekka from '@salesforce/apex/SfSeikyushaCheckController.updateSeikyushaShinsaKekka';
import getTeikeiCommentOptions from '@salesforce/apex/SfSeikyushaCheckController.getTeikeiCommentOptions';
import loginUserId from '@salesforce/user/Id';

const saishuPermissionErrorProfile = ['審査'];
const saishuPermissionSetAllowed = ['Shinsa_LD', 'Shinsa_SV'];

const shinsachuStatusList    = ['0次審査中', '1次審査中', '2次審査中', 'アンマッチ判定'];
const shinsachuStatus_00     = '0次審査中';
const shinsachuStatus_01     = '1次審査中';
const shinsachuStatus_02     = '2次審査中';
const shinsachuStatus_saishu = 'アンマッチ判定';

const optionKekkaOk = 'OK';

const KotekiKojinNinsho = '公的個人認証';
const KenmenUpload      = '券面アップロード';

export default class SfSeikyushaCheck extends LightningElement {

    @api recordId;

    @track loginUserProfileName       = '';
    @track hasAllowedPermissionSet    = false;

    @track shinsaKekka = '';
    @track seikyushaId;

    @track shoruiList        = [];
    @track teikeiCommentList = [];

    @track checkedYusoSeiyakusho  = false;
    @track checkedYusoSeikyusha   = false;
    @track checkedYusoInin        = false;
    @track checkedYusoKoza        = false;
    @track checkedYusoKozaKakunin = false;
    @track checkedWebSeiyakusho   = false;
    @track checkedWebKojinNinsho  = false;

    @track shinsaStatus;
    @track isShinsachu;    
    @track isShinsaKanryo       = false;
    @track hasCheckList         = false;

    @track isShinsachu0         = false;
    @track isShinsachu1         = false;
    @track isShinsachu2         = false;
    @track isShinsachuSaishu    = false;

    @track isTantosha           = false;
    @track isAbleToCheck        = false;

    @track honninKakuninHoho     = '';
    @track isKotekiKojinNinsho   = false;
    @track isKenmenUpload        = false;
    @track isYusoShinsei         = false;
    @track isWebShinsei          = false;
    @track teikeiComment         = '';
    @track teikeiCommentSelected = '';
    @track comment               = '';
    @track hasError              = false;
    @track errorMessage          = '';

    async connectedCallback() {

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

        // 認定請求情報や請求者情報を取得
        // 各種フラグの設定
        result = await getNinteiSeikyu({currentRecordId:this.recordId});
        this.seikyushaId        = result.Seikyusha__c;
        this.shinsaStatus       = result.ShinsaStatus__c;
        this.isShinsachu        = shinsachuStatusList.includes(this.shinsaStatus);
        this.honninKakuninHoho  = result.Seikyusha__r.HonninKakuninHoho__c;

        if(this.shinsaStatus === shinsachuStatus_00) {
            this.isShinsachu0 = true;
            this.isTantosha   = result.Is0thShinsasya__c;
            this.hasCheckList = true;
            this.shinsaKekka  = result.Seikyusha__r.ShinsaKekka_00__c;
            if(result.Seikyusha__r.ShinsaKekkaComment_00__c) {
                this.comment = result.Seikyusha__r.ShinsaKekkaComment_00__c;
            }
        }
        if(this.shinsaStatus === shinsachuStatus_01) {
            this.isShinsachu1 = true;
            this.isTantosha   = result.Is1stShinsasya__c;
            this.hasCheckList = true;
            this.shinsaKekka  = result.Seikyusha__r.ShinsaKekka_01__c;
            if(result.Seikyusha__r.ShinsaKekkaComment_01__c) {
                this.comment = result.Seikyusha__r.ShinsaKekkaComment_01__c;
            }
        }
        if(this.shinsaStatus === shinsachuStatus_02) {
            this.isShinsachu2 = true;
            this.isTantosha   = result.Is2ndShinsasya__c;
            this.hasCheckList = true;
            this.shinsaKekka  = result.Seikyusha__r.ShinsaKekka_02__c;
            if(result.Seikyusha__r.ShinsaKekkaComment_02__c) {
                this.comment = result.Seikyusha__r.ShinsaKekkaComment_02__c;
            }
        }
        if(this.shinsaStatus === shinsachuStatus_saishu) {
            this.isShinsachuSaishu = true;
            this.isTantosha        = result.IsSaishuShinsasya__c;
            this.shinsaKekka  = result.Seikyusha__r.ShinsaKekkaSaishu__c;
            if(result.Seikyusha__r.ShinsaKekkaComment_Saishu__c) {
                this.comment = result.Seikyusha__r.ShinsaKekkaComment_Saishu__c;
            }
        }
    
        if(this.honninKakuninHoho === KotekiKojinNinsho) {
            this.isKotekiKojinNinsho = true;
        }
        if(this.honninKakuninHoho === KenmenUpload) {
            this.isKenmenUpload = true;
        }
    
        if(result.IsYusoShinsei__c === true) {
            this.isYusoShinsei = true;
        }
        if(result.IsYusoShinsei__c === false) {
            this.isWebShinsei = true;                
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
            record.id      = element.Id;
            record.checked = false;

            if(element.ShinseiShoruiTeigiName__c === undefined) {
                record.ShinseiShoruiTeigiName = "未分類書類";
            } else {
                record.ShinseiShoruiTeigiName = element.ShinseiShoruiTeigiName__c;
            }

            this.shoruiList.push(record);
        });
    }

    setCheckedYusoSeiyakusho(event) {
        this.checkedYusoSeiyakusho = event.target.checked;
    }

    setCheckedYusoSeikyusha(event) {
        this.checkedYusoSeikyusha = event.target.checked;
    }

    setCheckedYusoInin(event) {
        this.checkedYusoInin = event.target.checked;
    }

    setCheckedYusoKoza(event) {
        this.checkedYusoKoza = event.target.checked;
    }

    setCheckedYusoKozaKakunin(event) {
        this.checkedYusoKozaKakunin = event.target.checked;
    }

    setCheckedWebSeiyakusho(event) {
        this.checkedWebSeiyakusho = event.target.checked;
    }

    setCheckedWebKojinNinsho(event) {
        this.checkedWebKojinNinsho = event.target.checked;
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

        updateSeikyushaShinsaKekka({seikyushaId:this.seikyushaId,
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

        if(this.isYusoShinsei) {
            checked = this.checkedYusoSeiyakusho && this.checkedYusoSeikyusha && this.checkedYusoInin && this.checkedYusoKoza && this.checkedYusoKozaKakunin;
        } else if(this.isWebShinsei) {
            if(this.isKotekiKojinNinsho) {
                checked = this.checkedWebSeiyakusho && this.checkedWebKojinNinsho;
            } else {
                checked = this.checkedWebSeiyakusho;
            }
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
        if(this.shinsaStatus === shinsachuStatus_saishu
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