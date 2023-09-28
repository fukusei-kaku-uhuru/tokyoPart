public without sharing class ExCustomLookupController {

    // 埋め込みたい条件は{key}で設定する
    private static final Map<String, String> WHERE_STR = new Map<String, String>{
        'KinyuKikan' => ' (Name like \'%{name}%\' '
                            + ' OR KinyuKikanCode__c LIKE \'%{name}%\') '

        ,'Shiten' => ' (Name like \'%{name}%\' '
                        + ' OR TempoCode__c LIKE \'%{name}%\') '
                    + ' AND KinyuKikan__c = \'{kinyuKikan}\''
        ,'TaishoshaKubun' => 'Name LIKE \'%{name}%\' '
                        + ' AND Name LIKE \'{prefix}%\' '
    };

    /**
     * 検索処理実行
     */
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String addField, string objectName, String filterName, Map<String, String> params) {

        String myQuery = ' select Id, Name ';

        if (String.isNotEmpty(addField)) {
            myQuery += ' ,' + addField + ' ';
        }

        // 取得対象オブジェクトの指定
        myQuery += ' from ' + objectName;

        // 条件区の付け足し
        myQuery += ' where ' + getWhereStr(filterName, params);

        myQuery += ' order by Name asc limit 5 ';

        // クエリを実行して返す
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }

    private static String getWhereStr(String filterName, Map<String, String> params) {

        String whereStr;
        // 一致する条件がない場合、名前の曖昧一致で検索
        if (WHERE_STR.containsKey(filterName)) {
            whereStr = WHERE_STR.get(filterName);
        } else {
            whereStr = 'Name like \'%{name}%\'';
        }

        // 条件文の置換
        for (String key : params.keySet()) {
            whereStr = whereStr.replace('{' + key + '}', ObjectUtil.nvlStr(params.get(key)));
        }

        return whereStr;
    }
}