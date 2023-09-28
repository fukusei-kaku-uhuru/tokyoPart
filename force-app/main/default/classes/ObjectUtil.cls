public with sharing class ObjectUtil {

    /**
     * nullの場合は、第二引数の値を返す
     */
    public static Object nvl(Object checkVal, Object returnVal) {
        if (checkVal == null) {
            return returnVal;
        }
        return checkVal;
    }

	/**
	 * nullの場合は空文字を返す
	 */
	public static String nvlStr(String str) {
		return (String)nvl(str, '');
	}

	/**
	 * nullの場合は0を返す
	 */
	public static Integer nvlInt(Integer num) {
		return (Integer)nvl(num, 0);
	}

	/**
	 * nullの場合は0を返す
	 */
	public static Decimal nvlDecimal(Decimal num) {
		return (Decimal)nvl(num, Decimal.valueOf(0));
	}

	/**
	 * 指定された項目の選択リスト一覧を返す
	 */
	public static List<Schema.PicklistEntry> getPickList(String objectName, String columnName) {
		Map<String, Schema.sObjectField> sofMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		return sofMap.get(columnName).getDescribe().getPicklistValues();
	}

	/**
	 * 指定された項目をキーとするListを保持するMapに変換する
	 */
	public static Map<String, List<sObject>> convertMapList(List<sObject> allObjList, Sobjectfield field){
		Map<String, List<sObject>> objMap = new Map<String, List<sObject>>();
		for(sObject obj : allObjList){

			// キーとなる項目の値を取得
			String key = (String)obj.get(field.getDescribe().getName());
			if(String.isBlank(key)) {
				continue;
			}

			// セットされていない場合、リストを新たに追加する
			if (!objMap.containsKey(key)) {
				objMap.put(key, new List<sObject>());
			}
			objMap.get(key).add(obj);
		}
		return objMap;
	}
}