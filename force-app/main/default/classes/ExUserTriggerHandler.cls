public without sharing class ExUserTriggerHandler {

    // ExperienceユーザのプロファイルIDセット
    private static final Set<Id> communityProfileIdSet;

    static{
        Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name in ('認定請求者', '認定請求者（DV)', '認定請求者（里親・ファミリーホーム）') ]);
        communityProfileIdSet = profileMap.keySet();
    }

    /**
     * @description 個人取引先を作成し、ユーザに紐づける
     * @param  userList userList description
     */
    public static void setContactId(List<User> userList){
        // マップ作成 ( key: メールアドレス、value: ユーザ )
        Map<String, User> emailUserMap = new Map<String, User>();
        for(User user : userList){
            emailUserMap.put(user.Email, user);
        }

        // 個人取引先insert、マップ作成 ( key: メールアドレス、value: 個人取引先 )
        Map<String, Account> emailAccountMap = new Map<String, Account>();
        for(User user : userList){
            if(!isExperienceUser(user)){
                continue;
            }

            Account acc = new Account(
                LastName = user.Email,
                PersonEmail = user.Email,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
            );
            emailAccountMap.put(user.Email, acc);
        }
		insert emailAccountMap.values();

        Set<Id> accountIdSet = new Set<Id>();
        for(Account acc : emailAccountMap.values()){
            accountIdSet.add(acc.Id);
        }

        // 取引先責任者 (個人取引先作成時に自動生成) をSELECTし、マップ作成 ( key: 個人取引先ID、value: 取引先責任者 )
        List<Contact> conList = [SELECT Id, Email, AccountId FROM Contact WHERE AccountId = :accountIdSet];
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact con : conList){
            contactMap.put(con.AccountId, con);
        }

        // ユーザ．取引先責任者に取引先責任者IDをセット
        for(String email : emailAccountMap.keySet()){
            Account acc = emailAccountMap.get(email);

            emailUserMap.get(email).ContactId = contactMap.get(acc.Id).Id;
        }
    }


    /**
     * @description checkDuplicateEmail 更新時のメールアドレス重複チェック
     * @param oldUserById UserトリガのoldMap
     *        newUsers Userトリガのnew
     * @return なし
     */
    public static void checkDuplicateEmail(Map<Id, User> oldUserById, List<User> newUsers){
        // マップ作成 ( key: メールアドレス、value: ユーザ )
        Map<String, User> userByEmail = new Map<String, User>();

        // 絞り込み
        for(User newUser : newUsers){
            // エクスペリエンスユーザでなければ対象外
            if(!isExperienceUser(newUser)){
                continue;
            }

            // メールアドレスの変更がなければ対象外
            if(oldUserById.get(newUser.Id).Email == newUser.Email){
                continue;
            }

            // 対象のユーザをマップに詰め替え
            userByEmail.put(newUser.Email, newUser);
        }

        // チェック対象が存在しない場合、処理終了
        if(userByEmail.isEmpty()){
            return;
        }

        // 既存ユーザ取得
        // 条件：メールアドレス = チェック対象のメールアドレス
        List<User> userList = [
            SELECT
                Email
            FROM
                User
            WHERE
                Email IN :userByEmail.keySet()
        ];

        // 既存メールアドレス
        Set<String> duplicateEmails = new Set<String>();
        for(User user: userList){
            duplicateEmails.add(user.Email);
        }

        // 対象のユーザのメールアドレス重複チェック
        for(String email: userByEmail.keySet()){
            // 既存メールアドレスが存在する場合、重複のため更新エラー
            if(duplicateEmails.contains(email)){
                User user = userByEmail.get(email);
                // エクスペリエンスの私の設定でエラーメッセージを表示させる場合、項目に設定する
                user.Email.addError('既に登録されたメールアドレスです。');
            }
        }
    }

    /**
     * エクスペリエンスユーザかどうかを判定
     * @description isExperienceUser description
     * @param  user user description
     * @return      return description
     */
    @TestVisible
    private static Boolean isExperienceUser(User user){
        return communityProfileIdSet.contains(user.ProfileId);
    }
}