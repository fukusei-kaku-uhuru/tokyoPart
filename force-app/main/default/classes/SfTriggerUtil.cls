public class SfTriggerUtil {

    private static final String NENGO_STR_REIWA  = '令和';
    private static final String NENGO_STR_HEISEI = '平成';
    private static final String NENGO_STR_SHOWA  = '昭和';
    private static final String NENGO_STR_TAISHO = '大正';
    private static final String NENGO_STR_NEN    = '年';
    private static final String NENGO_STR_GANNEN = '元年';

    private static final String MONTH_STR = '月';
    private static final String DAY_STR   = '日';

    private static final String ENGLISH_MONTH_SHORT_01 = 'JAN';
    private static final String ENGLISH_MONTH_SHORT_02 = 'FEB';
    private static final String ENGLISH_MONTH_SHORT_03 = 'MAR';
    private static final String ENGLISH_MONTH_SHORT_04 = 'APR';
    private static final String ENGLISH_MONTH_SHORT_05 = 'MAY';
    private static final String ENGLISH_MONTH_SHORT_06 = 'JUN';
    private static final String ENGLISH_MONTH_SHORT_07 = 'JUL';
    private static final String ENGLISH_MONTH_SHORT_08 = 'AUG';
    private static final String ENGLISH_MONTH_SHORT_09 = 'SEP';
    private static final String ENGLISH_MONTH_SHORT_10 = 'OCT';
    private static final String ENGLISH_MONTH_SHORT_11 = 'NOV';
    private static final String ENGLISH_MONTH_SHORT_12 = 'DEC';

    public static String convertToEmailAddressString(String targetStr) {
        
        String returnStr = convertZenkakuToHankaku(targetStr);
        
        if(Pattern.matches('^[A-Z0-9._%+-/!#$%&\'*=?^_`{|}~]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$', returnStr.toUpperCase())) {
            return returnStr;
        }

        return null;
    }

    public static Date convertStringToDate(String targetDateStr) {
        
        String targetStr = convertNumberToHankaku(targetDateStr);
        Integer year;
        Integer month;
        Integer day;
        Boolean isWareki = false;

        // 和暦：令和
        if(targetStr.contains(NENGO_STR_REIWA)) {
            year = getWarekiYear(targetStr, 2019);
            isWareki = true;
            // 読み取り不能の場合空で返す
            if(year == null) {
                return null;
            }
        }
        // 和暦：平成
        else if(targetStr.contains(NENGO_STR_HEISEI)) {
            year = getWarekiYear(targetStr, 1989);
            isWareki = true;
            // 読み取り不能の場合空で返す
            if(year == null) {
                return null;
            }
        }
        // 和暦：昭和
        else if(targetStr.contains(NENGO_STR_SHOWA)) {
            year = getWarekiYear(targetStr, 1926);
            isWareki = true;
            // 読み取り不能の場合空で返す
            if(year == null) {
                return null;
            }
        }
        // 和暦：大正
        else if(targetStr.contains(NENGO_STR_TAISHO)) {
            year = getWarekiYear(targetStr, 1912);
            isWareki = true;
            // 読み取り不能の場合空で返す
            if(year == null) {
                return null;
            }
        }

        // 和暦の処理が行われた場合
        if(isWareki) {
            String tempStr = targetStr.substringAfterLast(NENGO_STR_NEN);
            List<String> tempStrCommaList = tempStr.replaceAll('[^0-9]', ',').split(',');

            // 「月」がある場合は月の手前の数値を見る
            if(tempStr.contains(MONTH_STR)) {
                String monthStr = tempStr.substringBefore(MONTH_STR).deleteWhitespace().right(2).replaceAll('[^0-9]', '');
                month = Integer.valueOf(monthStr);
                tempStrCommaList = tempStr.substringAfterLast(MONTH_STR).deleteWhitespace().replaceAll('[^0-9]', ',').split(',');
                // 「日」もある場合は日の手前の数値を見る
                if(tempStr.contains(DAY_STR)) {
                    String dayStr = tempStr.substringBefore(DAY_STR).deleteWhitespace().right(2).replaceAll('[^0-9]', '');
                    day   = Integer.valueOf(dayStr);
                } else {
                    for(String tempStrComma :tempStrCommaList) {
                        if(tempStrComma.length() > 0 && tempStrComma.length() < 3 && day == null) {
                            day = Integer.valueOf(tempStrComma);
                            break;
                        }
                    }
                }
            } else {
                for(String tempStrComma :tempStrCommaList) {
                    if(tempStrComma.length() > 0 && tempStrComma.length() < 3) {
                        if(month == null) {
                            month = Integer.valueOf(tempStrComma);
                        } else if(day == null) {
                            day = Integer.valueOf(tempStrComma);
                            break;
                        }
                    }
                }
            }
            
        } else {

            // 西暦で月が英語で記載されている場合その月を入れる
            String targetStrUpperCase = targetStr.toUpperCase();
            if(     targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_01)) {month =  1;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_02)) {month =  2;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_03)) {month =  3;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_04)) {month =  4;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_05)) {month =  5;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_06)) {month =  6;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_07)) {month =  7;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_08)) {month =  8;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_09)) {month =  9;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_10)) {month = 10;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_11)) {month = 11;}
            else if(targetStrUpperCase.contains(ENGLISH_MONTH_SHORT_12)) {month = 12;}

            List<String> seirekiStrList = targetStr.replaceAll('[^0-9]', ',').split(',');
            for(String seirekiStr :seirekiStrList) {
                // 4桁以上の数値が見つかれば、年として扱う
                if(seirekiStr.length() > 3) {
                    year = Integer.valueOf(seirekiStr);
                } else if(seirekiStr.length() > 0) {
                    // 月が英語で記載されていない場合、左から月、日と記載されている想定で調べる
                    if(month == null) {
                        month = Integer.valueOf(seirekiStr);
                    } else if(day == null) {
                        day = Integer.valueOf(seirekiStr);
                    }
                }
            }
        }

        if(year == null || month == null || day == null) {
            return null;
        }
        
        return Date.newInstance(year, month, day);
    }

    private static String convertZenkakuToHankaku(String targetStr) {

        // 空なら処理しない
        if(String.isBlank(targetStr)) {
            return '';
        }

        Map<String, String> henkanMap = new Map<String, String>();
        henkanMap.put( '！','!' );
        henkanMap.put( '＃','#' );
        henkanMap.put( '＄','$' );
        henkanMap.put( '％','%' );
        henkanMap.put( '＆','&' );
        henkanMap.put( '’','\'' );
        henkanMap.put( '＊','*' );
        henkanMap.put( '＋','+' );
        henkanMap.put( '，','' );
        henkanMap.put( '−','-' );
        henkanMap.put( '．','.' );
        henkanMap.put( '／','/' );
        henkanMap.put( '０','0' );
        henkanMap.put( '１','1' );
        henkanMap.put( '２','2' );
        henkanMap.put( '３','3' );
        henkanMap.put( '４','4' );
        henkanMap.put( '５','5' );
        henkanMap.put( '６','6' );
        henkanMap.put( '７','7' );
        henkanMap.put( '８','8' );
        henkanMap.put( '９','9' );
        henkanMap.put( '：',':' );
        henkanMap.put( '；',';' );
        henkanMap.put( '＜','<' );
        henkanMap.put( '＝','=' );
        henkanMap.put( '＞','>' );
        henkanMap.put( '？','?' );
        henkanMap.put( '＠','@' );
        henkanMap.put( 'Ａ','A' );
        henkanMap.put( 'Ｂ','B' );
        henkanMap.put( 'Ｃ','C' );
        henkanMap.put( 'Ｄ','D' );
        henkanMap.put( 'Ｅ','E' );
        henkanMap.put( 'Ｆ','F' );
        henkanMap.put( 'Ｇ','G' );
        henkanMap.put( 'Ｈ','H' );
        henkanMap.put( 'Ｉ','I' );
        henkanMap.put( 'Ｊ','J' );
        henkanMap.put( 'Ｋ','K' );
        henkanMap.put( 'Ｌ','L' );
        henkanMap.put( 'Ｍ','M' );
        henkanMap.put( 'Ｎ','N' );
        henkanMap.put( 'Ｏ','O' );
        henkanMap.put( 'Ｐ','P' );
        henkanMap.put( 'Ｑ','Q' );
        henkanMap.put( 'Ｒ','R' );
        henkanMap.put( 'Ｓ','S' );
        henkanMap.put( 'Ｔ','T' );
        henkanMap.put( 'Ｕ','U' );
        henkanMap.put( 'Ｖ','V' );
        henkanMap.put( 'Ｗ','W' );
        henkanMap.put( 'Ｘ','X' );
        henkanMap.put( 'Ｙ','Y' );
        henkanMap.put( 'Ｚ','Z' );
        henkanMap.put( '＾','^' );
        henkanMap.put( '＿','_' );
        henkanMap.put( '‘','`' );
        henkanMap.put( 'ａ','a' );
        henkanMap.put( 'ｂ','b' );
        henkanMap.put( 'ｃ','c' );
        henkanMap.put( 'ｄ','d' );
        henkanMap.put( 'ｅ','e' );
        henkanMap.put( 'ｆ','f' );
        henkanMap.put( 'ｇ','g' );
        henkanMap.put( 'ｈ','h' );
        henkanMap.put( 'ｉ','i' );
        henkanMap.put( 'ｊ','j' );
        henkanMap.put( 'ｋ','k' );
        henkanMap.put( 'ｌ','l' );
        henkanMap.put( 'ｍ','m' );
        henkanMap.put( 'ｎ','n' );
        henkanMap.put( 'ｏ','o' );
        henkanMap.put( 'ｐ','p' );
        henkanMap.put( 'ｑ','q' );
        henkanMap.put( 'ｒ','r' );
        henkanMap.put( 'ｓ','s' );
        henkanMap.put( 'ｔ','t' );
        henkanMap.put( 'ｕ','u' );
        henkanMap.put( 'ｖ','v' );
        henkanMap.put( 'ｗ','w' );
        henkanMap.put( 'ｘ','x' );
        henkanMap.put( 'ｙ','y' );
        henkanMap.put( 'ｚ','z' );
        henkanMap.put( '｛','{' );
        henkanMap.put( '｜','|' );
        henkanMap.put( '｝','}' );
        henkanMap.put( '〜','~' );
        henkanMap.put( '　',' ' );

        for(String key : henkanMap.keySet()) {
            if(targetStr.contains(key)) {
                String tempKey = key;
                targetStr = targetStr.replaceAll(tempKey, henkanMap.get(key));
            }
        }

        return targetStr;
    }
    
    private static String convertNumberToHankaku(String targetStr) {

        // 空なら処理しない
        if(String.isBlank(targetStr)) {
            return '';
        }

        // 全角数字を半角数字に変換
        Map<String, String> henkanMap = new Map<String, String>();
        henkanMap.put('０', '0');
        henkanMap.put('１', '1');
        henkanMap.put('２', '2');
        henkanMap.put('３', '3');
        henkanMap.put('４', '4');
        henkanMap.put('５', '5');
        henkanMap.put('６', '6');
        henkanMap.put('７', '7');
        henkanMap.put('８', '8');
        henkanMap.put('９', '9');

        for(String key : henkanMap.keySet()) {
            if(targetStr.contains(key)) {
                targetStr = targetStr.replaceAll(key, henkanMap.get(key));
            }
        }

        return targetStr;
    }

    private static Integer getWarekiYear(String targetStr, Integer gannenNum) {
        if(targetStr.contains(NENGO_STR_GANNEN)) {
            return gannenNum;
        } else if(targetStr.contains(NENGO_STR_NEN)) {
            String yearStr = targetStr.substringBefore(NENGO_STR_NEN).replaceAll('[^0-9]', '');

            if(String.isBlank(yearStr)) {
                return null;
            }
            // 西暦（4桁以上）が引っかかってきたら西暦で返す（西暦と和暦が併記されている場合があるため）
            if(yearStr.length() > 3) {
                return Integer.valueOf(yearStr);
            }

            return Integer.valueOf(yearStr) + gannenNum - 1;
        } else {
            return null;
        }
    }
}