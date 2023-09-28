global without sharing class LightningSelfRegisterController {

    private static final String emailRegEx = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

    private static final Map<String, String> errorMessageMap = new Map<String, String>{
        'Unable to generate security token.' => '予期せぬエラーが発生しました。',
        'Your password must be at least 8 characters long.' => 'パスワードは8文字以上である必要があります。',
        'Your password must include letters and numbers' => 'パスワードはアルファベットと数字が含まれている必要があります。',
        'Your Password cannot equal or contain your user name.' => 'パスワードにはユーザ名を含められません。',
        'パスワードは null にはできません。' => 'パスワードは必須です。',
        'The password you entered is too easy to guess. Enter a different one.' => '推測されやすいパスワードです。より複雑なものに変更してください。',
        'Invalid or expired value for the identifier field.' => '予期せぬエラーが発生しました。',
        'Token not valid' => '確認コードが違います。'
    };

    private static Map<String, String> siteProfileMap;

    static {
        List<Site__mdt> mdts = Site__mdt.getAll().Values();
        siteProfileMap = new Map<String, String>();
        for(Site__mdt mdt: mdts){
            siteProfileMap.put(mdt.MasterLabel__c, mdt.ProfileName__c);
        }
    }

    public class ResponseWrapper{
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String message;
        @AuraEnabled public Map<String, String> responseMap;
    }

    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @AuraEnabled
    public static ResponseWrapper selfRegister(String email, String password, String confirmPassword) {

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // メールアドレスの検証
            if (email == null || String.isEmpty(email)) {
                throw new MyException(Label.Site.email_is_required);
            }
            if (!Pattern.matches(emailRegEx, email)){
                throw new MyException('メールアドレスが無効です。');
            }
            if (isAlreadyExists(email)) {
                throw new MyException('既に登録されたメールアドレスです。');
            }

            // プロファイルID取得
            String profileName = '認定請求者';
            if(!Test.isRunningTest()){
                profileName = siteProfileMap.get(Site.getMasterLabel());
            }

            Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;

            // ユーザ作成
            User u = new User();
            u.ProfileId = profileId;
            u.Alias = email.length() > 8 ? email.substring(0, 8) : email;
            u.Username = email;
            u.LastName = email;
            u.Email = email;
            u.CommunityNickname = email.length() > 40 ? email.substring(0, 40) : email;

            // ロケール設定
            u.languagelocalekey = 'ja';
            u.localesidkey = 'ja_JP';
            u.emailEncodingKey = 'UTF-8';
    		u.timeZoneSidKey = Timezone.getTimezone('Asia/Tokyo').getID();
            
            String networkId = Network.getNetworkId();
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            // パスワードの検証
            if (!isValidPassword(password, confirmPassword)) {
                throw new MyException(Label.Site.passwords_dont_match);
            }
            validatePassword(u, password, confirmPassword);
            
            String selfRegId;
            // メールアドレスの検証サービス実行
            if(!Test.isRunningTest()){
                selfRegId = System.UserManagement.initSelfRegistration(Auth.VerificationMethod.EMAIL, u);
            }

            ResponseWrapper response = new ResponseWrapper();
            response.isError = false;
            response.responseMap = new Map<String, String>{
                'selfRegId' => selfRegId
            };
            return response;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            ResponseWrapper response = new ResponseWrapper();
            response.isError = true;
            response.message = errorMessageMap.containsKey(ex.getMessage()) ? errorMessageMap.get(ex.getMessage()) : ex.getMessage();

            return response;            
        }
    }
    
    @AuraEnabled
    public static ResponseWrapper verifyUser(String selfRegId, String code, String email, String password){
        try {
            // 確認コードの検証
            Auth.VerificationResult res = new Auth.VerificationResult(null, false, null);
            if(!Test.isRunningTest()){
                res = System.UserManagement.verifySelfRegistration(Auth.VerificationMethod.EMAIL, selfRegId, code, null);
            }
            if(!res.success){
                throw new MyException(res.message);
            }

            // パスワードを設定
            if(!Test.isRunningTest()){
                User user = [SELECT Id FROM User WHERE UserName = :email LIMIT 1];
                System.setPassword(user.Id, password);
            }
            
            // ホーム画面に遷移
            if(!Test.isRunningTest()) {
                aura.redirect(res.redirect);
            }

            return new ResponseWrapper();

        } catch (Exception ex) {
            ResponseWrapper response =  new ResponseWrapper();

            response.isError = true;
            response.message = errorMessageMap.containsKey(ex.getMessage()) ? errorMessageMap.get(ex.getMessage()) : '予期せぬエラーが発生しました。';
            return response;
        }
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }

    /**
     * 設定されたメールアドレスが既に利用されている場合、trueを返す
     */
    @TestVisible
    private static Boolean isAlreadyExists(String email) {
        List<User> uList = [SELECT Id FROM User WHERE Email = :email];
        return uList.size() > 0;
    }

    public class MyException extends Exception{}
}