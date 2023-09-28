public class DeleteJobBatch implements Database.Batchable<sObject>, Database.Stateful{
    String strJobName;
    public DeleteJobBatch(String jobNm) {
        this.strJobName = jobNm;
    }

    /**
     * 処理対象を取得する
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start DeleteJobBatch ');

        String query;
        query = 'Select id, name, userroleid from user where isactive = true limit 1';

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<SObject> scopes) {
        System.debug('execute DeleteJobBatch ');
        System.debug('JobId: ' + bc.getJobId());
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('finish TestJobBatch ');
        System.debug('JobId: ' + bc.getJobId());
        List<CronTrigger> ctLst = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger WHERE CronJobDetail.Name = :strJobName AND State = 'DELETED'];
        
        System.debug(ctLst);
        for(CronTrigger ct : ctLst){
            System.abortJob(ct.Id);
        }

    }

}