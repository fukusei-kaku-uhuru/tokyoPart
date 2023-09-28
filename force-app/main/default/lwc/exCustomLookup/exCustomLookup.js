import { api, LightningElement, wire } from 'lwc';

import search from '@salesforce/apex/ExCustomLookupController.search';


export default class customLookUp extends LightningElement {

	/**
	 * 対象オブジェクト名
	 */
    @api objName;
	/**
	 * 一覧に表示するアイコン名
	 */
    @api iconName;
    /**
     * 追加で表示したい項目
     */
    @api addField = '';
	/**
	 * 取得SOQLの条件
	 */
    @api filter = '';
    @api params = {};

    @api label='Search';

    @api selectedName;

    _required;
    @api get required(){return this._required;}
    set required(value){
        this._required = value === 'true';
    }

	_value;

	@api get value(){
		return this._value;
	}
	set value(value){
		this._value = value;

		if(value == '' && this.isValueSelected == true){
			this.isValueSelected = false;
		}

		if(value != null && value != '' && this.selectedId != value){
			this.isValueSelected = true;
		}
	}

    isValueSelected;
    blurTimeout;

    searchTerm = '';

    //css
    boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    inputClass = '';

    /**
     * 入力値変更に合わせて、検索条件を変更する
     */
    onChange(event) {
        this.searchTerm = event.target.value;
    }

    _records = [];

    get _params() {
        let _params = JSON.parse(JSON.stringify(this.params));
        _params['name'] = this.searchTerm;
        return _params;
    }
    /**
     * 選択リストの取得/表示
     */
    @wire(search, {addField: '$addField', objectName : '$objName', filterName : '$filter', params: '$_params'})
    wiredRecords({ error, data }) {

        // 文字が設定されていない場合、候補を表示しない
        if (data && !!this.searchTerm) {
            this._records = data;

        } else {
            this._records = [];
        }
    }

    get records() {
        let records = [];
        if (this.addField) {
            for (const record of this._records) {
                records.push({
                    Id : record.Id
                    ,Name : record.Name
                    ,DisplayName : record[this.addField] + '：' + record.Name
                });
            }
        } else {
            for (const record of this._records) {
                records.push({
                    Id : record.Id
                    ,Name : record.Name
                    ,DisplayName : record.Name
                });
            }
        }

        return records;
    }

    /**
     * 入力フォーム押下時処理
     */
    handleClick() {
		if(this.searchTerm == null){
			this.searchTerm = '';
		}

        if (this.disabled) {
            return;
        }
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    /**
     * blur時、選択リストを非表示にする
     */
    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);

        // 選択肢が1つのみだったら、選択した際と同様の動きをする
        if (this.records.length === 1) {
            this.selectedProcess(this.records[0].Id, this.records[0].DisplayName);
        }
    }

    /**
     * 選択リストから値を選択
     */
    onSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedName = event.currentTarget.dataset.name;

        this.selectedProcess(selectedId, selectedName);
    }

    selectedProcess(selectedId, selectedName) {
        const valueSelectedEvent = new CustomEvent('lookupselected', {
            detail: {
                selectedId: selectedId,
                selectedName: selectedName,
            }
        });
        this.dispatchEvent(valueSelectedEvent);

        this.isValueSelected = true;
		this.selectedId = selectedId;
		this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
		this.searchTerm = '';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    /**
     * pill削除時の処理
     */
    handleRemovePill() {
        this.isValueSelected = false;
        const valueRemoveEvent = new CustomEvent('lookupselected', {
            detail: {
                selectedId: '',
                selectedName: '',
            }
        });
        this.dispatchEvent(valueRemoveEvent);
    }

    /**
     * 問題なければtrueを返す
     */
    @api
    inputValid() {
        const input = this.template.querySelector('lightning-input');
        if (!input) {
            return true;
        }

        // 必須なのに入力されていない場合、false
        if (this.required && !this.isValueSelected) {
            input.setCustomValidity('この項目を選択してください。');
            input.reportValidity();
            return false;
        }

        return true;
    }

    @api
    setCustomValidity(message) {
        const input = this.template.querySelector('lightning-input');
        if (!input) {
            return;
        }

        input.setCustomValidity(message);
    }

    @api
    reportValidity() {
        const input = this.template.querySelector('lightning-input');
        if (!input) {
            return;
        }

        input.reportValidity();
    }
}