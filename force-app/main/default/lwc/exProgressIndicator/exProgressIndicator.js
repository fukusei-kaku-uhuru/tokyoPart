import { LightningElement, api, track } from 'lwc';

export default class ExProgressIndicator extends LightningElement {

	/**
	 * 下記のオブジェクト群で渡すこと
	 * {label: 表示する値, id: 押下時等に利用する}
	 */
	@api steps = [];

	/**
	 * ShinseiOyaにて定義されている、ページ番号リスト
	 */
	@api pageNo = [];

	/**
	 * 到達済のステップId
	 */
	@api doneStepId = '';

	/**
	 * 現在のステップId
	 */
	@api currentStepId = '';
	_currentStepId;

	/**
	 * 表示用に加工したステップの配列
	 */
	get progressSteps(){
		const progressSteps = [];

		// 渡された値リストに存在する画面IDだった場合、そのIDを設定する
		for (const [name, no] of  Object.entries(this.pageNo)) {
			if (this.steps.some(step => step.id == no)) {
				this._currentStepId = no;
			}

			if (no == this.currentStepId) {break;}
		}

		let isFinished = true;
		for (const [index, step] of Object.entries(this.steps)) {
			const progressStep = {
				label: step.label
				,id: step.id
				,isActive: false
				,isCompleted: false
			};
			progressSteps.push(progressStep);

			// 到達している中で一番奥のステップ
			if (progressStep.id === this.doneStepId && index != this.steps.length - 1) {
				isFinished = false;
			}

			// 現在表示しているステップ（一番奥かつ現在表示しているステップの場合、is-activeで表示）
			if (progressStep.id === this._currentStepId && index != this.steps.length - 1) {
				progressStep.isActive = true;
				continue;
			}

			// 現在表示していない、到達しているステップまではすべて完了
			if(isFinished){
				progressStep.isCompleted = true;
			}
		};

		return progressSteps;
	}

	/**
	 * Accessibility用
	 */
	get valueMax(){
		return this.steps.length;
	}
	get valueNow(){
		return this.steps.indexOf(this.steps.find(step => step.id === this.currentStepId)) + 1;
	}
}