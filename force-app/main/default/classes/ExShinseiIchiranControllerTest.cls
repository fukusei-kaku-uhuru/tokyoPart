@isTest
private class ExShinseiIchiranControllerTest {

    @TestSetup
    private static void setUp(){
        String uniqueKey = ExTestUtil.getUniqueKey();

        String generalName = ExTestUtil.GENERAL_PREFIX + uniqueKey;
        String dvName = ExTestUtil.DV_PREFIX + uniqueKey;
        String satoyaName = ExTestUtil.SATOYA_PREFIX + uniqueKey;

        Account generalAcc = ExTestUtil.getPersonAccount(generalName);
        Account dvAcc = ExTestUtil.getPersonAccount(dvName);
        Account satoyaAcc = ExTestUtil.getPersonAccount(satoyaName);
        insert new List<Account>{generalAcc, dvAcc, satoyaAcc};

        User generalUser = ExTestUtil.getGeneralUser(generalName, generalAcc.Id);
        generalUser.TimeZoneSidKey = UserInfo.getTimeZone().toString();
        User dvUser = ExTestUtil.getDvUser(dvName, dvAcc.Id);
        dvUser.TimeZoneSidKey = UserInfo.getTimeZone().toString();
        User satoyaUser = ExTestUtil.getSatoyaUser(satoyaName, satoyaAcc.Id);
        satoyaUser.TimeZoneSidKey = UserInfo.getTimeZone().toString();
        insert new List<User>{generalUser, dvUser, satoyaUser};
    }

    /** getNinteiSeikyu 一般 */
    @isTest
    private static void getNinteiSeikyuForGeneral(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.GENERAL_QUERY_STRING LIMIT 1];

        NinteiSeikyu__c seikyu1;
        NinteiSeikyu__c seikyu2;
        TaishoJido__c jido1;
        TaishoJido__c jido2;

        ExShinseiIchiranController.ShinseiWrapper result;
        System.runAs(platformUser){
            Seikyusha__c seikyusha = ExTestUtil.getSeikyusha();
            insert seikyusha;

            seikyu1 = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu1.ShinsaStatus__c = '	未申請';
            seikyu2 = ExTestUtil.getNinteiSeikyu(seikyusha);
            seikyu2.ShinsaStatus__c = '	1次審査中';
            insert seikyu1;
            insert seikyu2;

            jido1 = new TaishoJido__c(
                NinteiSeikyu__c = seikyu2.Id,
                Shimei__c = '対象児童1氏名'
            );
            jido2 = new TaishoJido__c(
                NinteiSeikyu__c = seikyu2.Id,
                Shimei__c = '対象児童2氏名',
                ShoninKekka__c = '保留'
            );
            insert new List<TaishoJido__c>{jido1, jido2};

            Test.startTest();
            result = ExShinseiIchiranController.getNinteiSeikyu();
            Test.stopTest();
        }

        List<NinteiSeikyu__c> seikyus = [
            SELECT
                NinteiSeikyuStatus__c,
                NinteiSeikyuUketsukeBangou__c,
                CreatedDate
            FROM
                NinteiSeikyu__c
            WHERE
                Id IN :new Set<Id>{seikyu1.Id, seikyu2.Id}
            ORDER BY
                Name DESC
        ];
        List<TaishoJido__c> jidos = [
            SELECT
                ShoninKekka_Community__c
            FROM
                TaishoJido__c
            WHERE
                Id IN :new Set<Id>{jido1.Id, jido2.Id}
            ORDER BY
                Name ASC
        ];

        Assert.areEqual(2, result.shinseiList.size());

        Assert.areEqual(seikyu2.Id, result.shinseiList[0].parentId);
        Assert.areEqual(seikyus[0].NinteiSeikyuUketsukeBangou__c, result.shinseiList[0].parentNo);
        Assert.areEqual(seikyus[0].NinteiSeikyuStatus__c, result.shinseiList[0].status);
        Assert.areEqual(seikyus[0].CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString()), result.shinseiList[0].createdDate);
        Assert.isTrue(result.shinseiList[0].isEditDisabled);
        Assert.areEqual(2, result.shinseiList[0].childList.size());
        Assert.areEqual(jido1.Id, result.shinseiList[0].childList[0].childId);
        Assert.areEqual('対象児童1氏名', result.shinseiList[0].childList[0].childName);
        Assert.areEqual(jidos[0].ShoninKekka_Community__c, result.shinseiList[0].childList[0].shoninKekka);
        Assert.areEqual(jido2.Id, result.shinseiList[0].childList[1].childId);
        Assert.areEqual('対象児童2氏名', result.shinseiList[0].childList[1].childName);
        Assert.areEqual(jidos[1].ShoninKekka_Community__c, result.shinseiList[0].childList[1].shoninKekka);

        Assert.areEqual(seikyu1.Id, result.shinseiList[1].parentId);
        Assert.areEqual(seikyus[1].NinteiSeikyuUketsukeBangou__c, result.shinseiList[1].parentNo);
        Assert.areEqual(seikyus[1].NinteiSeikyuStatus__c, result.shinseiList[1].status);
        Assert.areEqual(seikyus[1].CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString()), result.shinseiList[1].createdDate);
        Assert.isFalse(result.shinseiList[1].isEditDisabled);
        Assert.areEqual(1, result.shinseiList[1].childList.size());
        Assert.areEqual('', result.shinseiList[1].childList[0].childId);
        Assert.areEqual(ExShinseiIchiranController.EM_DASH, result.shinseiList[1].childList[0].childName);
        Assert.areEqual(ExShinseiIchiranController.EM_DASH, result.shinseiList[1].childList[0].shoninKekka);
    }

    /** getNinteiSeikyu DV */
    @isTest
    private static void getNinteiSeikyuForDv(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.DV_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu1;
        DV_NinteiSeikyu__c seikyu2;
        DV_TaishoJido__c jido1;
        DV_TaishoJido__c jido2;

        ExShinseiIchiranController.ShinseiWrapper result;
        System.runAs(platformUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaDv();
            insert seikyusha;

            seikyu1 = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu1.ShinsaStatus__c = '	未申請';
            seikyu2 = ExTestUtil.getNinteiSeikyuDv(seikyusha);
            seikyu2.ShinsaStatus__c = '	1次審査中';
            insert seikyu1;
            insert seikyu2;

            jido1 = new DV_TaishoJido__c(
                NinteiSeikyu__c = seikyu2.Id,
                Shimei__c = '対象児童1氏名',
                RecordTypeId = ExTestUtil.DV_JIDO_ID
            );
            jido2 = new DV_TaishoJido__c(
                NinteiSeikyu__c = seikyu2.Id,
                Shimei__c = '対象児童2氏名',
                ShoninKekka__c = '保留',
                RecordTypeId = ExTestUtil.DV_JIDO_ID
            );
            insert new List<DV_TaishoJido__c>{jido1, jido2};

            Test.startTest();
            result = ExShinseiIchiranController.getNinteiSeikyu();
            Test.stopTest();
        }

        List<DV_NinteiSeikyu__c> seikyus = [
            SELECT
                NinteiSeikyuStatus__c,
                NinteiSeikyuUketsukeBangou__c,
                CreatedDate
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id IN :new Set<Id>{seikyu1.Id, seikyu2.Id}
            ORDER BY
                Name DESC
        ];
        List<DV_TaishoJido__c> jidos = [
            SELECT
                ShoninKekka_Community__c
            FROM
                DV_TaishoJido__c
            WHERE
                Id IN :new Set<Id>{jido1.Id, jido2.Id}
            ORDER BY
                Name ASC
        ];

        Assert.areEqual(2, result.shinseiList.size());

        Assert.areEqual(seikyu2.Id, result.shinseiList[0].parentId);
        Assert.areEqual(seikyus[0].NinteiSeikyuUketsukeBangou__c, result.shinseiList[0].parentNo);
        Assert.areEqual(seikyus[0].NinteiSeikyuStatus__c, result.shinseiList[0].status);
        Assert.areEqual(seikyus[0].CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString()), result.shinseiList[0].createdDate);
        Assert.isTrue(result.shinseiList[0].isEditDisabled);
        Assert.areEqual(2, result.shinseiList[0].childList.size());
        Assert.areEqual(jido1.Id, result.shinseiList[0].childList[0].childId);
        Assert.areEqual('対象児童1氏名', result.shinseiList[0].childList[0].childName);
        Assert.areEqual(jidos[0].ShoninKekka_Community__c, result.shinseiList[0].childList[0].shoninKekka);
        Assert.areEqual(jido2.Id, result.shinseiList[0].childList[1].childId);
        Assert.areEqual('対象児童2氏名', result.shinseiList[0].childList[1].childName);
        Assert.areEqual(jidos[1].ShoninKekka_Community__c, result.shinseiList[0].childList[1].shoninKekka);

        Assert.areEqual(seikyu1.Id, result.shinseiList[1].parentId);
        Assert.areEqual(seikyus[1].NinteiSeikyuUketsukeBangou__c, result.shinseiList[1].parentNo);
        Assert.areEqual(seikyus[1].NinteiSeikyuStatus__c, result.shinseiList[1].status);
        Assert.areEqual(seikyus[1].CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString()), result.shinseiList[1].createdDate);
        Assert.isFalse(result.shinseiList[1].isEditDisabled);
        Assert.areEqual(1, result.shinseiList[1].childList.size());
        Assert.areEqual('', result.shinseiList[1].childList[0].childId);
        Assert.areEqual(ExShinseiIchiranController.EM_DASH, result.shinseiList[1].childList[0].childName);
        Assert.areEqual(ExShinseiIchiranController.EM_DASH, result.shinseiList[1].childList[0].shoninKekka);
    }

    /** getNinteiSeikyu 里親 */
    @isTest
    private static void getNinteiSeikyuForSatoya(){
        User platformUser = [SELECT Id FROM User WHERE UserName LIKE :ExTestUtil.SATOYA_QUERY_STRING LIMIT 1];

        DV_NinteiSeikyu__c seikyu1;
        DV_NinteiSeikyu__c seikyu2;
        DV_TaishoJido__c jido1;
        DV_TaishoJido__c jido2;

        ExShinseiIchiranController.ShinseiWrapper result;
        System.runAs(platformUser){
            DV_Seikyusha__c seikyusha = ExTestUtil.getSeikyushaSatoya();
            insert seikyusha;

            seikyu1 = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu1.ShinsaStatus__c = '	未申請';
            seikyu2 = ExTestUtil.getNinteiSeikyuSatoya(seikyusha);
            seikyu2.ShinsaStatus__c = '	1次審査中';
            insert seikyu1;
            insert seikyu2;

            jido1 = new DV_TaishoJido__c(
                NinteiSeikyu__c = seikyu2.Id,
                BunsyoKanriBangou__c = '0001',
                Shimei__c = '対象児童1氏名',
                RecordTypeId = ExTestUtil.SATOYA_JIDO_ID
            );
            jido2 = new DV_TaishoJido__c(
                NinteiSeikyu__c = seikyu2.Id,
                BunsyoKanriBangou__c = '0002',
                Shimei__c = '対象児童2氏名',
                ShoninKekka__c = '保留',
                RecordTypeId = ExTestUtil.SATOYA_JIDO_ID
            );
            insert new List<DV_TaishoJido__c>{jido1, jido2};

            Test.startTest();
            result = ExShinseiIchiranController.getNinteiSeikyu();
            Test.stopTest();
        }

        List<DV_NinteiSeikyu__c> seikyus = [
            SELECT
                NinteiSeikyuStatus__c,
                NinteiSeikyuUketsukeBangou__c,
                CreatedDate
            FROM
                DV_NinteiSeikyu__c
            WHERE
                Id IN :new Set<Id>{seikyu1.Id, seikyu2.Id}
            ORDER BY
                Name DESC
        ];
        List<DV_TaishoJido__c> jidos = [
            SELECT
                ShoninKekka_Community__c
            FROM
                DV_TaishoJido__c
            WHERE
                Id IN :new Set<Id>{jido1.Id, jido2.Id}
            ORDER BY
                Name ASC
        ];

        Assert.areEqual(2, result.shinseiList.size());

        Assert.areEqual(seikyu2.Id, result.shinseiList[0].parentId);
        Assert.areEqual(seikyus[0].NinteiSeikyuUketsukeBangou__c, result.shinseiList[0].parentNo);
        Assert.areEqual(seikyus[0].NinteiSeikyuStatus__c, result.shinseiList[0].status);
        Assert.areEqual(seikyus[0].CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString()), result.shinseiList[0].createdDate);
        Assert.isTrue(result.shinseiList[0].isEditDisabled);
        Assert.areEqual(2, result.shinseiList[0].childList.size());
        Assert.areEqual(jido1.Id, result.shinseiList[0].childList[0].childId);
        Assert.areEqual('対象児童1氏名', result.shinseiList[0].childList[0].childName);
        Assert.areEqual(jidos[0].ShoninKekka_Community__c, result.shinseiList[0].childList[0].shoninKekka);
        Assert.areEqual(jido2.Id, result.shinseiList[0].childList[1].childId);
        Assert.areEqual('対象児童2氏名', result.shinseiList[0].childList[1].childName);
        Assert.areEqual(jidos[1].ShoninKekka_Community__c, result.shinseiList[0].childList[1].shoninKekka);

        Assert.areEqual(seikyu1.Id, result.shinseiList[1].parentId);
        Assert.areEqual(seikyus[1].NinteiSeikyuUketsukeBangou__c, result.shinseiList[1].parentNo);
        Assert.areEqual(seikyus[1].NinteiSeikyuStatus__c, result.shinseiList[1].status);
        Assert.areEqual(seikyus[1].CreatedDate.format('yyyy年MM月dd日 HH時mm分', UserInfo.getTimeZone().toString()), result.shinseiList[1].createdDate);
        Assert.isFalse(result.shinseiList[1].isEditDisabled);
        Assert.areEqual(1, result.shinseiList[1].childList.size());
        Assert.areEqual('', result.shinseiList[1].childList[0].childId);
        Assert.areEqual(ExShinseiIchiranController.EM_DASH, result.shinseiList[1].childList[0].childName);
        Assert.areEqual(ExShinseiIchiranController.EM_DASH, result.shinseiList[1].childList[0].shoninKekka);
    }
}