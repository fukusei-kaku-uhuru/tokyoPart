public without sharing class CommonConvertString {

    private static final string STARTDAYTAISYOU = '19120730';        // 大正始期日
    private static final string STARTDAYSHOUWA = '19261225';         // 昭和始期日
    private static final string STARTDAYHEISEI = '19890108';         // 平成始期日
    private static final string STARTDAYREIWA = '20190501';          // 令和始期日

    private static final Map<String, String> CONVERTMAP= new Map<String, String>{
        '０' => '0'
        , '１' => '1'
        , '２' => '2'
        , '３' => '3'
        , '４' => '4'
        , '５' => '5'
        , '６' => '6'
        , '７' => '7'
        , '８' => '8'
        , '９' => '9'
        , 'Ａ' => 'A'
        , 'Ｂ' => 'B'
        , 'Ｃ' => 'C'
        , 'Ｄ' => 'D'
        , 'Ｅ' => 'E'
        , 'Ｆ' => 'F'
        , 'Ｇ' => 'G'
        , 'Ｈ' => 'H'
        , 'Ｉ' => 'I'
        , 'Ｊ' => 'J'
        , 'Ｋ' => 'K'
        , 'Ｌ' => 'L'
        , 'Ｍ' => 'M'
        , 'Ｎ' => 'N'
        , 'Ｏ' => 'O'
        , 'Ｐ' => 'P'
        , 'Ｑ' => 'Q'
        , 'Ｒ' => 'R'
        , 'Ｓ' => 'S'
        , 'Ｔ' => 'T'
        , 'Ｕ' => 'U'
        , 'Ｖ' => 'V'
        , 'Ｗ' => 'W'
        , 'Ｘ' => 'X'
        , 'Ｙ' => 'Y'
        , 'Ｚ' => 'Z'
        , 'ア' => 'ｱ'
        , 'イ' => 'ｲ'
        , 'ウ' => 'ｳ'
        , 'エ' => 'ｴ'
        , 'オ' => 'ｵ'
        , 'カ' => 'ｶ'
        , 'キ' => 'ｷ'
        , 'ク' => 'ｸ'
        , 'ケ' => 'ｹ'
        , 'コ' => 'ｺ'
        , 'サ' => 'ｻ'
        , 'シ' => 'ｼ'
        , 'ス' => 'ｽ'
        , 'セ' => 'ｾ'
        , 'ソ' => 'ｿ'
        , 'タ' => 'ﾀ'
        , 'チ' => 'ﾁ'
        , 'ツ' => 'ﾂ'
        , 'テ' => 'ﾃ'
        , 'ト' => 'ﾄ'
        , 'ナ' => 'ﾅ'
        , '二' => '二'
        , 'ヌ' => 'ﾇ'
        , 'ネ' => 'ﾈ'
        , 'ノ' => 'ﾉ'
        , 'ハ' => 'ﾊ'
        , 'ヒ' => 'ﾋ'
        , 'フ' => 'ﾌ'
        , 'ヘ' => 'ﾍ'
        , 'ホ' => 'ﾎ'
        , 'マ' => 'ﾏ'
        , 'ミ' => 'ﾐ'
        , 'ム' => 'ﾑ'
        , 'メ' => 'ﾒ'
        , 'モ' => 'ﾓ'
        , 'ヤ' => 'ﾔ'
        , 'ユ' => 'ﾕ'
        , 'ヨ' => 'ﾖ'
        , 'ラ' => 'ﾗ'
        , 'リ' => 'ﾘ'
        , 'ル' => 'ﾙ'
        , 'レ' => 'ﾚ'
        , 'ロ' => 'ﾛ'
        , 'ワ' => 'ﾜ'
        , 'ン' => 'ﾝ'
        , 'ァ' => 'ｱ'
        , 'ィ' => 'ｲ'
        , 'ゥ' => 'ｳ'
        , 'ェ' => 'ｴ'
        , 'ォ' => 'ｵ'
        , 'ッ' => 'ﾂ'
        , 'ャ' => 'ﾔ'
        , 'ュ' => 'ﾕ'
        , 'ョ' => 'ﾖ'
        , 'ガ' => 'ｶﾞ'
        , 'ギ' => 'ｷﾞ'
        , 'グ' => 'ｸﾞ'
        , 'ゲ' => 'ｹﾞ'
        , 'ゴ' => 'ｺﾞ'
        , 'ザ' => 'ｻﾞ'
        , 'ジ' => 'ｼﾞ'
        , 'ズ' => 'ｽﾞ'
        , 'ゼ' => 'ｾﾞ'
        , 'ゾ' => 'ｿﾞ'
        , 'ダ' => 'ﾀﾞ'
        , 'ヂ' => 'ﾁﾞ'
        , 'ヅ' => 'ﾂﾞ'
        , 'デ' => 'ﾃﾞ'
        , 'ド' => 'ﾄﾞ'
        , 'バ' => 'ﾊﾞ'
        , 'ビ' => 'ﾋﾞ'
        , 'ブ' => 'ﾌﾞ'
        , 'ベ' => 'ﾍﾞ'
        , 'ボ' => 'ﾎﾞ'
        , 'パ' => 'ﾊﾟ'
        , 'ピ' => 'ﾋﾟ'
        , 'プ' => 'ﾌﾟ'
        , 'ぺ' => 'ﾍﾟ'
        , 'ポ' => 'ﾎﾟ'
        , '（' => '('
        , '）' => ')'
        , '－' => '-'
        , '．' => '.'
    };
    
    public static String convert(String orgStr){
        String destStr = '';
        
        if (String.isEmpty(orgStr)) {
            return destStr;
        }
        String[] stringCharacters = orgStr.split('');
        for(String str : stringCharacters){
            // 変換対象文字列
            if (CONVERTMAP.containsKey(str)) {
                destStr += CONVERTMAP.get(str);
            } else {
                destStr += str;
            }
        }

        return destStr;
    }

    /**
     * 日付変換（西暦和暦変換 GGYY年MM月DD日）
     * @param  dt  日付
     */
    public static String convertSeireki2WarekiYMD(Date dt){
        String retWarekiDt = '';
        String oriDt = '';
        String nengou = '';
        Integer base = 0;
        Integer intYear = 0;

        // NULLの場合、空白を返却する
        if (dt == null) {
            return retWarekiDt;
        }

        oriDt = Datetime.newInstance(dt.year(), dt.month(), dt.day()).format('yyyyMMdd');
        // oriDt = dt.format('yyyyMMdd');

        intYear = dt.year();
        // 
        if(oriDt.compareTo(STARTDAYTAISYOU) < 0) {
            return retWarekiDt;
        }
        else if(oriDt.compareTo(STARTDAYTAISYOU) >= 0 && oriDt.compareTo(STARTDAYSHOUWA) < 0) {
            retWarekiDt = '大正';
            base = 1912;
        }
        else if(oriDt.compareTo(STARTDAYSHOUWA) >= 0 && oriDt.compareTo(STARTDAYHEISEI) < 0) {
            retWarekiDt = '昭和';
            base = 1926;
        }
        else if(oriDt.compareTo(STARTDAYHEISEI) >= 0 && oriDt.compareTo(STARTDAYREIWA) < 0)  {
            retWarekiDt = '平成';
            base = 1989;
        } else {
            retWarekiDt = '令和';
            base = 2019;
        }
        intYear = intYear - base + 1;
        if (intYear == 1) {
            retWarekiDt = retWarekiDt + '元年';
        } else {
            retWarekiDt = retWarekiDt + String.valueOf(intYear) + '年';
        }

        // GGYY年MM月DD日
        retWarekiDt = retWarekiDt + String.valueOf(dt.month()) + '月' + String.valueOf(dt.day()) + '日';

        return retWarekiDt;
    }

    /**
     * 日付変換（西暦和暦変換 GGYY年MM月）
     * @param  dt  日付
     */
    public static String convertSeireki2WarekiYM(Date dt){

        // 形式：GGYY年MM月DD日　取得
        String retWarekiDt = convertSeireki2WarekiYMD(dt);

        Integer idx = retWarekiDt.indexOf('月');

        // 形式：GGYY年MM月　返却
        return retWarekiDt.left(idx + 1);

    }
}