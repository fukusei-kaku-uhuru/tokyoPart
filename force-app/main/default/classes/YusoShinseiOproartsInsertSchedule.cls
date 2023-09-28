public without sharing class YusoShinseiOproartsInsertSchedule implements Schedulable{
    List<oproarts1__OproartsAction__c> oproartsList;
    String strJobName;

    public YusoShinseiOproartsInsertSchedule(List<oproarts1__OproartsAction__c> oproartsList,String jobName) {
        this.oproartsList = oproartsList;
        this.strJobName = jobName;
    }

    public void execute(SchedulableContext sc){
        insert oproartsList;
        Database.executebatch(new DeleteJobBatch(strJobName), 2000);
    }
}