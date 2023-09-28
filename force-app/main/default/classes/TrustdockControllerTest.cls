@isTest
private class TrustdockControllerTest {

    @isTest
    private static void initialization(){
        Test.startTest();
        TrustDockController tdc = new TrustDockController();
        Test.stopTest();

        Assert.isNotNull(tdc.lexCommunityOrigin);
        Assert.isNotNull(tdc.trustdockUploderCdn);
        Assert.isNotNull(tdc.trustdockApiPlanId);
    }
}