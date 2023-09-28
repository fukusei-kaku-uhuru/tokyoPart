import { LightningElement, api } from 'lwc';
import { errorHandle } from 'c/exErrorHandler';
import getSeiyaku from '@salesforce/apex/ExSeiyakuDouiController.getSeiyaku';
import register from '@salesforce/apex/ExSeiyakuDouiController.register';

import isNinteiSeikyuDisabled from '@salesforce/apex/ExLwcUtil.isNinteiSeikyuDisabled';

export default class ExSeiyakuDoui extends LightningElement {
	@api pageNo;
	@api recordId;

	isLoading = true;
	isEditDisabled = false;
	isNextDisabled = true;

	input = {};

	async connectedCallback() {
		// 誓約同意取得
        await getSeiyaku({recordId:this.recordId})
            .then(result => {
				const tmp = {};
				if (result == null) {
					tmp.NinteiSeikyuSeiyaku_01 = false;
					tmp.NinteiSeikyuSeiyaku_02 = false;
					tmp.NinteiSeikyuSeiyaku_03 = false;
					tmp.NinteiSeikyuSeiyaku_04 = false;
					tmp.NinteiSeikyuSeiyaku_05 = false;
					tmp.NinteiSeikyuSeiyaku_07 = false;
					tmp.NinteiSeikyuSeiyaku_08 = false;
					tmp.NinteiSeikyuSeiyaku_09 = false;
					tmp.NinteiSeikyuSeiyaku_10 = false;
					tmp.NinteiSeikyuSeiyaku_11 = false;
					tmp.NinteiSeikyuSeiyaku_12 = false;
				}
				else {
					tmp.NinteiSeikyuSeiyaku_01 = result.NinteiSeikyuSeiyaku_01;
					tmp.NinteiSeikyuSeiyaku_02 = result.NinteiSeikyuSeiyaku_02;
					tmp.NinteiSeikyuSeiyaku_03 = result.NinteiSeikyuSeiyaku_03;
					tmp.NinteiSeikyuSeiyaku_04 = result.NinteiSeikyuSeiyaku_04;
					tmp.NinteiSeikyuSeiyaku_05 = result.NinteiSeikyuSeiyaku_05;
					tmp.NinteiSeikyuSeiyaku_07 = result.NinteiSeikyuSeiyaku_07;
					tmp.NinteiSeikyuSeiyaku_08 = result.NinteiSeikyuSeiyaku_08;
					tmp.NinteiSeikyuSeiyaku_09 = result.NinteiSeikyuSeiyaku_09;
					tmp.NinteiSeikyuSeiyaku_10 = result.NinteiSeikyuSeiyaku_10;
					tmp.NinteiSeikyuSeiyaku_11 = result.NinteiSeikyuSeiyaku_11;
					tmp.NinteiSeikyuSeiyaku_12 = result.NinteiSeikyuSeiyaku_12;
				}
				this.input = tmp;
				this.checkedAll();
            })
            .catch(error => {
                this.dispatchEvent(errorHandle(error));
            });
		if(this.recordId){
			this.isEditDisabled = await isNinteiSeikyuDisabled({recordId:this.recordId});
		}
		this.isLoading = false;
	}

	goBack() {
		// 次の画面遷移
		const customEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.AGREEMENT }
		);
		this.dispatchEvent(customEvent);
    }

	async goNext() {
		this.isLoading = true;
		let isError = false;
		if (!this.isEditDisabled) {
			// 登録
			try {
				await register({ recordId: this.recordId, input: this.input });
			} catch (error) {
				this.dispatchEvent(errorHandle(error));
				isError = true;
			}
		}
		if (isError) {
			this.isLoading = false;
			return;
		}

		// 次の画面遷移
		const customEvent = new CustomEvent(
			'submit',
			{ detail : this.pageNo.KAKUNIN_18 }
		);
		this.dispatchEvent(customEvent);
	}

	onclickCheck01() {
		this.input.NinteiSeikyuSeiyaku_01 = !this.input.NinteiSeikyuSeiyaku_01;
		this.checkedAll();

		// checkboxに反映
		const checkbox = this.template.querySelector('.ex-check-01');
		checkbox.checked = this.input.NinteiSeikyuSeiyaku_01;
		checkbox.focus();
	}
	onchangeCheck01(event) {
        this.input.NinteiSeikyuSeiyaku_01 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck02(event) {
        this.input.NinteiSeikyuSeiyaku_02 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck03(event) {
        this.input.NinteiSeikyuSeiyaku_03 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck04(event) {
        this.input.NinteiSeikyuSeiyaku_04 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck05(event) {
        this.input.NinteiSeikyuSeiyaku_05 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck07(event) {
        this.input.NinteiSeikyuSeiyaku_07 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck08(event) {
        this.input.NinteiSeikyuSeiyaku_08 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck09(event) {
        this.input.NinteiSeikyuSeiyaku_09 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck10(event) {
        this.input.NinteiSeikyuSeiyaku_10 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck11(event) {
        this.input.NinteiSeikyuSeiyaku_11 = event.target.checked;
		this.checkedAll();
    }
    onchangeCheck12(event) {
        this.input.NinteiSeikyuSeiyaku_12 = event.target.checked;
		this.checkedAll();
    }
	checkedAll() {
		if (this.input.NinteiSeikyuSeiyaku_01
			&& this.input.NinteiSeikyuSeiyaku_02
			&& this.input.NinteiSeikyuSeiyaku_03
			&& this.input.NinteiSeikyuSeiyaku_04
			&& this.input.NinteiSeikyuSeiyaku_05
			&& this.input.NinteiSeikyuSeiyaku_07
			&& this.input.NinteiSeikyuSeiyaku_08
			&& this.input.NinteiSeikyuSeiyaku_09
			&& this.input.NinteiSeikyuSeiyaku_10
			&& this.input.NinteiSeikyuSeiyaku_11
			&& this.input.NinteiSeikyuSeiyaku_12
		) {
			this.isNextDisabled = false;
		}
		else {
			this.isNextDisabled = true;
		}
	}
}