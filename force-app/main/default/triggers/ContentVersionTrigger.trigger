trigger ContentVersionTrigger on ContentVersion (before update, before insert, after insert, after update) {

	if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			ExContentVersionTriggerHandler.updateShinseiShoruiTeigiData(Trigger.new);
		}

		if (Trigger.isInsert || Trigger.isUpdate){
			SfContentVersionBeforeTriggerProcess.setIsDeletable(Trigger.new);
		}
	}

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			System.debug('--------------------------Trigger.isInsert:'+Trigger.new);
			// 必要書類がアップロードによりS3へバックアップするTrigger10MB/ファイルが制限。
			SfContentVersionTriggerHandler.backupFile(Trigger.new);

			// 郵送申請の際にスキャンしたデータを取り込む場合、
			// ファイル名に含まれるIDをキーに郵送申請のレコードを取得して、ContentDocumentLinkに登録する
			SfContentVersionTriggerHandler.insertContentDocumentLink(Trigger.new);

			// 郵送申請の必要書類がアップロードされたらOCRを起動するTrigger（OPROARTSアクション）
			SfContentVersionTriggerHandler.startOrcServiceAPIForYusou(Trigger.new);
		}
		
		if (Trigger.isUpdate) {
			System.debug('--------------------------Trigger.isUpdate:'+Trigger.new);
			// 請求者の必要書類がアップロードされたらOCRを起動するTrigger（OPROARTSアクション）
			// 対象児童の必要書類がアップロードされたらOCRを起動するTrigger（OPROARTSアクション）
			// SfContentVersionTriggerHandler.startOrcServiceAPIForWeb(Trigger.old,Trigger.new);
		}
	}
}