Salesforce Schedule Manager
===========================

<a href="https://githubsfdeploy.herokuapp.com?owner=vitaliaventel&repo=ScheduleManager">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Benefits
--------
1) You don't need to create new schedulable class every time when you want to schedule a new batch.
2) You don't need to duplicate start and stop logic.
3) You can define your own methods in ScheduleManager class and use it in the future.

Documentation
-------------
void stop() - Stop all scheduled jobs based on job name

void scheduleDailyAt(Integer) - Schedule daily at specific hour

void scheduleDailyAt(Integer, String) - Schedule daily at specific hour and on specific day

void scheduleEveryNMinutes(Integer) - Schedule daily every minute

void scheduleWithCron(String) - Schedule based on cron expression

Examples
--------
For example we have a batch class
```java
global class BatchExample implements Database.Batchable<SObject> {

    global final String query;
    
    global BatchExample() {
        query = '<YOUR_QUERY_GOES_HERE>';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        <YOUR_LOGIC_GOES_HERE>
    }

    global void finish(Database.BatchableContext BC) {

    }

}
```

Everything that you need it just implements Executable interface and define logic for execute() method
```java
global class BatchExample implements Database.Batchable<SObject>, Executable {

    global final String query;
    
    global BatchExample() {
        query = '<YOUR_QUERY_GOES_HERE>';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        <YOUR_LOGIC_GOES_HERE>
    }
    
    global void execute() {
         Database.executeBatch(this);
    }

    global void finish(Database.BatchableContext BC) {

    }

}
```

To schedule BatchExample class you just need to
```java
   new ScheduleManager('BatchExample job', new AccountContactNullValuesBatch()).scheduleDailyAt(12); 
```
