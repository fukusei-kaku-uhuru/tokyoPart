@isTest
public with sharing class ExContentVersionTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        ShinseiShoruiTeigi__c sst1 = new ShinseiShoruiTeigi__c(
            Name = 'update1'
            ,OCR_Syoruisyubetu__c = '種別1'
        );
        ShinseiShoruiTeigi__c sst2 = new ShinseiShoruiTeigi__c(
            Name = 'update2'
            ,OCR_Syoruisyubetu__c = '種別2'
        );
        insert new List<ShinseiShoruiTeigi__c>{sst1, sst2};

        ContentVersion cv1 = new ContentVersion(
            Title = 'sampleFile1',
            VersionData = EncodingUtil.base64Decode('base64encodedData'),
            PathOnClient = 'pathonclient',
            ShinseiShoruiTeigiId__c = sst1.Id
            // ShinseiShoruiTeigiName__c = 'default1'
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'sampleFile2',
            VersionData = EncodingUtil.base64Decode('base64encodedData'),
            PathOnClient = 'pathonclient',
            ShinseiShoruiTeigiId__c = sst2.Id
            // ShinseiShoruiTeigiName__c = 'default2'
        );
        insert new List<ContentVersion>{cv1, cv2};
    }

    @isTest
    static void updateShinseiShoruiTeigiName(){
        List<ContentVersion> cvList = [SELECT Id, ShinseiShoruiTeigiId__c FROM ContentVersion];

        Test.startTest();

        ExContentVersionTriggerHandler.updateShinseiShoruiTeigiData(cvList);

        Test.stopTest();

        Assert.areEqual('update1', cvList.get(0).ShinseiShoruiTeigiName__c);
        Assert.areEqual('種別1', cvList.get(0).OCR_Syoruisyubetu__c);
        Assert.areEqual('update2', cvList.get(1).ShinseiShoruiTeigiName__c);
        Assert.areEqual('種別2', cvList.get(1).OCR_Syoruisyubetu__c);
    }

    @isTest
    static void updateShinseiShoruiTeigiName_sstIdIsNull(){
        List<ContentVersion> cvList = [SELECT Id, ShinseiShoruiTeigiId__c FROM ContentVersion];

        cvList.get(1).ShinseiShoruiTeigiId__c = null;

        Test.startTest();

        ExContentVersionTriggerHandler.updateShinseiShoruiTeigiData(cvList);

        Test.stopTest();

        Assert.areEqual('update1', cvList.get(0).ShinseiShoruiTeigiName__c);
        Assert.areEqual(null, cvList.get(1).ShinseiShoruiTeigiName__c);
        Assert.areEqual(null, cvList.get(1).OCR_Syoruisyubetu__c);
    }

}