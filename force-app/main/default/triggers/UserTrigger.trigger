trigger UserTrigger on User (before insert, before update) {
    if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			// Communityユーザサインアップ時、個人取引先を紐づける
			ExUserTriggerHandler.setContactId(Trigger.new);
		}else if(Trigger.isUpdate){
			// メールアドレス重複チェック
			ExUserTriggerHandler.checkDuplicateEmail(Trigger.oldMap, Trigger.new);
		}
	}
}