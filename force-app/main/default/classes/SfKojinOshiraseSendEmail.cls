public with sharing class SfKojinOshiraseSendEmail {

    // 個人向けお知らせレコード
    public class RequestParam {
        @InvocableVariable(label='個人向けお知らせレコードID') public String KojinOshiraseId;
        @InvocableVariable(label='個人向けお知らせ取引先責任者ID') public String contactId;
        @InvocableVariable(label='メールテンプレートDeveloper名') public String tempDeveloperName;
    }

    /**
    * @description メール送信メソッド
    */
    @InvocableMethod(label='個人向けお知らせメール送付')
    public static void sendEmail(List<RequestParam> requests) {
        
        // 返信先メールアドレス(組織のアドレス)
        OrgWideEmailAddress replyAddressId;
        if (!Test.isRunningTest()) {
            // テスト実行以外
            apexMailSetting__mdt ssmdt = [SELECT displayName__c FROM apexMailSetting__mdt LIMIT 1];
            replyAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :ssmdt.displayName__c LIMIT 1];
        }

        // メールテンプレートリスト
        List<EmailTemplate> tempMailList = [SELECT ID, DeveloperName FROM EmailTemplate];

        // 取引先責任者ID取り出し
        List<String> contactIdList = new List<String>();
        for(RequestParam request : requests) {
            contactIdList.add(request.contactId);
        }

        // ユーザ取得
        List<user> userList = [
            SELECT id, contactId
            FROM User
            WHERE contactId IN :contactIdList
        ];
            
        // ユーザIDの対応付け
        Map<String, String> contactIdAndUserIdMap = new Map<String, String>();
        for (user user : userList) {
            contactIdAndUserIdMap.put(user.contactId, user.id);
        }

        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for (RequestParam request : requests) {
            //メールテンプレート
            ID tempMailId;
            for (EmailTemplate mailTemp : tempMailList) {
                if (mailTemp.DeveloperName == request.tempDeveloperName) {
                    tempMailId = mailTemp.Id;
                }
            }

            //ユーザIDの取り出し
            String userId = contactIdAndUserIdMap.get(request.contactId);
                        
            Messaging.SingleEmailMessage mail= Messaging.renderStoredEmailTemplate(tempMailId, userId, request.KojinOshiraseId);
            if (!Test.isRunningTest()) {
                // テスト実行以外
                mail.setOrgWideEmailAddressId(replyAddressId.Id);
            }
            mail.setSaveAsActivity(false); // 送信メールを活動に保存する。デフォルトはtrue。
            mailList.add(mail);
        }
        Messaging.sendEmail(mailList);
    }
}