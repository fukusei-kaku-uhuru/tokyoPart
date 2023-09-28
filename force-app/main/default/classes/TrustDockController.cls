public with sharing class TrustDockController {

    public String lexCommunityOrigin{get;set;}
    public String trustdockUploderCdn{get;set;}
    public String trustdockApiPlanId{get;set;}

    public TrustDockController() {
        Trustdock__mdt mdt = Trustdock__mdt.getAll().values().get(0);

        this.lexCommunityOrigin = Site.getBaseSecureUrl().replace(Site.getPathPrefix(), '');
        this.trustdockUploderCdn = mdt.HelperJsCdn__c;
        this.trustdockApiPlanId = mdt.PlanId__c;
    }
}