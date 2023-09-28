public without sharing class SfDVFurikomiUtil {
    
    public static final String SHINSA_KEKKA_STR_OK         = 'OK';

    public static final String YOKINSHUMOKU_FUTSU = '1';
    public static final String YOKINSHUMOKU_TOZA = '2';
    public static final String YOKINSHUMOKU_CHOCHIKU = '4';

    public static final String YUCHOYOKINSHUMOKU_SOGO = '1';
    public static final String YUCHOYOKINSHUMOKU_TSUJO = '2';
    public static final String YUCHOYOKINSHUMOKU_TSUJOCHOCHIKU = '3';
    public static final String YUCHOYOKINSHUMOKU_FURIKAE = '4';

    public static void createFurikomi(Map<Id, DV_Seikyusha__c> newSeikyushaMap, Map<Id, DV_Seikyusha__c> oldSeikyushaMap){
        System.debug('請求者trigger 振込レコードを作成');

        List<Id> skIdList = new List<Id>();
        List<DV_TaishoJido__c> tjListUpdate = new List<DV_TaishoJido__c>();
        // 振込レコードList作成(更新用)
        List<Furikomi__c> furikomiList = new List<Furikomi__c>();
        // 振込レコードMap作成(KEYが対象児童のID)
        Map<id,Furikomi__c> furikomiMap = new Map<id,Furikomi__c>();

        for (DV_Seikyusha__c skObj : newSeikyushaMap.values()){
            DV_Seikyusha__c skOldObj = oldSeikyushaMap.get(skObj.Id);

             // 請求者の審査結果(最終)が「OK」以外から「OK」に変更された場合
             if(SHINSA_KEKKA_STR_OK == skObj.ShinsaKekkaSaishu__c
                && SHINSA_KEKKA_STR_OK != skOldObj.ShinsaKekkaSaishu__c)
            {
                skIdList.add(skObj.Id);
            }
        }

        if(skIdList.size() == 0){
            //処理対象が 0件 の場合は終了
            return;
        }

        // 対象児童のうち審査結果（最終）が「OK」のものを取得
        List<DV_TaishoJido__c> tjList = [SELECT Id,
            FurikomiId__c,

            KyufuGaku__c,

            SK_YuchoKigo__c,
            SK_YuchoBango__c,
            SK_YuuchoKouzaMeigi__c,
            SK_Yucho_Shumoku01__c,
            SK_Yucho_Shumoku02__c,
            SK_Yucho_Shumoku03__c,
            SK_Yucho_Shumoku04__c,           
            SK_KinyuKikanCode__c,
            SK_ShitenCode__c,
            SK_KouzaBango__c,
            SK_KouzaMeigi__c,
            SK_Shumoku01__c,      
            SK_Shumoku02__c,     
            SK_Shumoku03__c,    

            YuchoKigo__c,
            YuchoBango__c,
            YuchoKouzaMeigi__c,
            TJ_Yucho_Shumoku01__c,
            TJ_Yucho_Shumoku02__c,
            TJ_Yucho_Shumoku03__c,
            TJ_Yucho_Shumoku04__c,
            KinyuKikanCode__c,
            ShitenCode__c,
            KouzaBangou__c,
            KouzaMeigi__c,
            TJ_Shumoku01__c,
            TJ_Shumoku02__c,
            TJ_Shumoku03__c

            FROM DV_TaishoJido__c
            WHERE NinteiSeikyu__r.Seikyusya__c IN :skIdList
            AND ShinsaKekkaSaishu__c = 'OK'];

        // 振込データ生成
        for(DV_TaishoJido__c tjObj : tjList){
            Furikomi__c fkObj = new Furikomi__c();
            if(tjObj.FurikomiId__c != null){
                fkObj.Id = tjObj.FurikomiId__c;
            }else{
                furikomiMap.put(tjObj.id,fkObj);
            }
            FurikomiSet(fkObj,tjObj);
            furikomiList.add(fkObj);
        }

        // 作成する振込レコードがある場合
        if (furikomiList.size() > 0) {
            upsert furikomiList;
        }
        if (furikomiMap.size() > 0) {
            for (Id recordId : furikomiMap.keySet()) {
                Furikomi__c furikomiObj = furikomiMap.get(recordId);
                DV_TaishoJido__c taishoJidoObj = new DV_TaishoJido__c();
                taishoJidoObj.Id = recordId;
                taishoJidoObj.FurikomiId__c = furikomiObj.id;
                tjListUpdate.add(taishoJidoObj);
            }
        }
        // 更新する対象児童レコードがある場合
        if(tjListUpdate.size() > 0){
            update tjListUpdate;
        }
    }

    public static void createFurikomi(Map<Id, DV_TaishoJido__c> newTaishoJidoMap, Map<Id, DV_TaishoJido__c> oldTaishoJidoMap){
        System.debug('対象児童trigger 振込レコードを作成');
        // 振込レコードList作成(更新用)
        List<Furikomi__c> furikomiList = new List<Furikomi__c>();
        // 振込レコードMap作成(KEYが対象児童のID)
        Map<id,Furikomi__c> furikomiMap = new Map<id,Furikomi__c>();
        Furikomi__c fkObj;
        // 認定請求レコードMap ( 認定請求.Id => 請求者.審査結果（最終）)
        Map<Id, String> ninteiSeikyuMap = new Map<Id, String>();

        List<DV_TaishoJido__c> taishoJidoList = new List<DV_TaishoJido__c>();


        Set<Id> ninteiSeikyuIdSet = new Set<Id>();
        for (DV_TaishoJido__c tjObj : newTaishoJidoMap.values()) {
            ninteiSeikyuIdSet.add(tjObj.NinteiSeikyu__c);
        }

        List<DV_NinteiSeikyu__c> nsList = [SELECT Id, Seikyusya__r.ShinsaKekkaSaishu__c FROM DV_NinteiSeikyu__c WHERE Id IN :ninteiSeikyuIdSet];
        for(DV_NinteiSeikyu__c ns : nsList){
            ninteiSeikyuMap.put(ns.Id, ns.Seikyusya__r.ShinsaKekkaSaishu__c);
        }

        for (DV_TaishoJido__c tjObj : newTaishoJidoMap.values()) {

            DV_TaishoJido__c tjOldObj = oldTaishoJidoMap.get(tjObj.Id);
            String skShinsaKekksaSaishu = ninteiSeikyuMap.get(tjObj.NinteiSeikyu__c);

             // 対象児童の審査結果(最終)が「OK」以外から「OK」に変更された場合
             // かつ 請求者の審査結果（最終）が「OK」の場合
            if (SHINSA_KEKKA_STR_OK == String.valueOf(tjObj.ShinsaKekkaSaishu__c)
                && SHINSA_KEKKA_STR_OK != String.valueOf(tjOldObj.ShinsaKekkaSaishu__c)
                && SHINSA_KEKKA_STR_OK == skShinsaKekksaSaishu){

                fkObj = new Furikomi__c();
                if(tjObj.FurikomiId__c != null){
                    fkObj.Id = tjObj.FurikomiId__c;
                }else{
                    furikomiMap.put(tjObj.id,fkObj);
                }
                FurikomiSet(fkObj,tjObj);
                furikomiList.add(fkObj);
            }
        }

        // 作成する振込レコードがある場合
        if (furikomiList.size() > 0) {
            upsert furikomiList;
        }
        if (furikomiMap.size() > 0) {
            for (Id recordId : furikomiMap.keySet()) {
                Furikomi__c furikomiObj = furikomiMap.get(recordId);
                System.debug(furikomiObj.id);
                DV_TaishoJido__c taishoJidoObj = newTaishoJidoMap.get(recordId);
                taishoJidoObj.FurikomiId__c = furikomiObj.id;
            }
        }
    }

    @testVisible
    private static String getYokinShumoku(Boolean chk01, Boolean chk02, Boolean chk03){
        if(chk01){
            //普通
            return YOKINSHUMOKU_FUTSU;
        }
        if(chk02){
            //当座
            return YOKINSHUMOKU_TOZA;
        }
        if(chk03){
            //貯蓄
            return YOKINSHUMOKU_CHOCHIKU;
        }

        return null;
    }

    @testVisible
    private static String getYuchoYokinShumoku(Boolean chk01, Boolean chk02, Boolean chk03, Boolean chk04){
        if(chk01){
            //総合
            return YUCHOYOKINSHUMOKU_SOGO;
        }
        if(chk02){
            //通常
            return YUCHOYOKINSHUMOKU_TSUJO;
        }
        if(chk03){
            //通常貯蓄
            return YUCHOYOKINSHUMOKU_TSUJOCHOCHIKU;
        }
        if(chk04){
            //振替
            return YUCHOYOKINSHUMOKU_FURIKAE;
        }

        return null;
    }

    @testVisible
    private static void FurikomiSet(Furikomi__c furikomiobj,DV_TaishoJido__c taiShoJidoObj){
        if (!String.isBlank(taiShoJidoObj.KinyuKikanCode__c)){
            // 対象児童の金融機関コードが設定されている場合

            // 被仕向銀行番号
            furikomiobj.GinkoBango__c = taiShoJidoObj.KinyuKikanCode__c;
            // 被仕向支店番号
            furikomiobj.ShitenBango__c = taiShoJidoObj.ShitenCode__c;
            // 預金種目
            furikomiobj.YokinShumoku__c = getYokinShumoku(taiShoJidoObj.TJ_Shumoku01__c, taiShoJidoObj.TJ_Shumoku02__c, taiShoJidoObj.TJ_Shumoku03__c);
            // 口座番号
            furikomiobj.KozaBango__c = taiShoJidoObj.KouzaBangou__c;
            // 受取人名
            furikomiobj.UketorininMei__c = taiShoJidoObj.KouzaMeigi__c;

        } else if(!String.isBlank(taiShoJidoObj.YuchoKigo__c)) {
            // 対象児童のゆうちょ記号が設定されている場合
    
            // ゆうちょ記号
            furikomiobj.YuchoKigo__c = taiShoJidoObj.YuchoKigo__c;
            // ゆうちょ番号
            furikomiobj.YuchoBango__c = taiShoJidoObj.YuchoBango__c;
            // ゆうちょ分類
            furikomiobj.YuchoYokinShumoku__c = getYuchoYokinShumoku(taiShoJidoObj.TJ_Yucho_Shumoku01__c, taiShoJidoObj.TJ_Yucho_Shumoku02__c, taiShoJidoObj.TJ_Yucho_Shumoku03__c, taiShoJidoObj.TJ_Yucho_Shumoku04__c);
            // ゆうちょ口座名義
            furikomiobj.UketorininMei__c = taiShoJidoObj.YuchoKouzaMeigi__c;

        } else if(!String.isBlank(taiShoJidoObj.SK_KinyuKikanCode__c)) {
            // 請求者の金融機関コードが設定されている場合

            // 被仕向銀行番号
            furikomiobj.GinkoBango__c = taiShoJidoObj.SK_KinyuKikanCode__c;
            // 被仕向支店番号
            furikomiobj.ShitenBango__c = taiShoJidoObj.SK_ShitenCode__c;
            // 預金種目
            furikomiobj.YokinShumoku__c = getYokinShumoku(taiShoJidoObj.SK_Shumoku01__c, taiShoJidoObj.SK_Shumoku02__c, taiShoJidoObj.SK_Shumoku03__c);
            // 口座番号
            furikomiobj.KozaBango__c = taiShoJidoObj.SK_KouzaBango__c;
            // 受取人名
            furikomiobj.UketorininMei__c = taiShoJidoObj.SK_KouzaMeigi__c;

        } else if(!String.isBlank(taiShoJidoObj.SK_YuchoKigo__c)) {
            // 請求者のゆうちょ記号が設定されている場合

            // ゆうちょ記号
            furikomiobj.YuchoKigo__c = taiShoJidoObj.SK_YuchoKigo__c;
            // ゆうちょ番号
            furikomiobj.YuchoBango__c = taiShoJidoObj.SK_YuchoBango__c;
            // ゆうちょ分類
            furikomiobj.YuchoYokinShumoku__c = getYuchoYokinShumoku(taiShoJidoObj.SK_Yucho_Shumoku01__c, taiShoJidoObj.SK_Yucho_Shumoku02__c, taiShoJidoObj.SK_Yucho_Shumoku03__c, taiShoJidoObj.SK_Yucho_Shumoku04__c);
            // ゆうちょ口座名義
            furikomiobj.UketorininMei__c = taiShoJidoObj.SK_YuuchoKouzaMeigi__c;
        }
        // 振込ステータス
        furikomiobj.FurikomiStatus__c = '口座照会待ち';
        // 振込金額
        furikomiobj.FurikomiKingaku__c = taiShoJidoObj.KyufuGaku__c;
    }
}