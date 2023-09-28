public without sharing class SfSeikyushaUpdateNameTriggerHandler {
    public void beforeUpdate(Map<Id, Seikyusha__c> newSeikyushaMap, Map<Id, Seikyusha__c> oldSeikyushaMap) {
        // 請求者「氏名」が更新されたら、個人取引先の「氏名」も更新する
        updateAccountName(newSeikyushaMap, oldSeikyushaMap);
    }
    /**
     * 請求者「氏名」が更新されたら、個人取引先の「氏名」も更新する
     */
    private void updateAccountName(Map<Id, Seikyusha__c> newSeikyushaMap, Map<Id, Seikyusha__c> oldSeikyushaMap) {
        // 「氏名」が変更された個人取引先のIDを保持するリストを作成
        List<Id> accountIdsToUpdate = new List<Id>();
        List<Id> updatedSeikyushaIdList = new List<id>();
        for (Seikyusha__c updatedSeikyusha : newSeikyushaMap.values()) {
            // 請求者の氏名が更新された場合に個人取引先も更新対象として追加
            if (oldSeikyushaMap.get(updatedSeikyusha.Id).Shimei__c != updatedSeikyusha.Shimei__c) {
               updatedSeikyushaIdList.add(updatedSeikyusha.OwnerId);
            }
        }
System.debug(updatedSeikyushaIdList);
        List<User> contactIDList= [select id,contactID from User where id in: updatedSeikyushaIdList];
        Map<id,String> contactIDMap = new Map<id,String>();
        System.debug(contactIDList);
        for(User user : contactIDList){
            contactIDMap.put(user.id, user.contactID);
        }
System.debug(contactIDMap);
        // 更新対象の個人取引先リスト
        List<Contact> contactsToUpdateList = new List<Contact>();
        for (Seikyusha__c updatedSeikyusha : newSeikyushaMap.values()) {
            // 請求者の氏名が更新された場合に個人取引先も更新対象として追加
            if (contactIDMap.containsKey(updatedSeikyusha.OwnerId)) {
                String contactID= contactIDMap.get(updatedSeikyusha.OwnerId);
                if(String.isBlank(contactID)){
                    continue;
                }
                Contact newContact = new Contact();
                newContact.id = contactID;
                newContact.LastName = updatedSeikyusha.Shimei__c;
                contactsToUpdateList.add(newContact);
            }
        }
        // 更新した個人取引先を保存
        System.debug(contactsToUpdateList);
        if(contactsToUpdateList.size() > 0){
            update contactsToUpdateList;
        }
    }
}