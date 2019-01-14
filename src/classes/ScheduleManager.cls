/**
 * @AUTHOR       : Vitalii Leshchenko
 * @DESCRIPTION  : 
 * @HISTORY      : 26.12.2018 - Created.(VLeshchenko)
**/

public class ScheduleManager implements Schedulable {

    private String jobName;
    private String CRON_EXP;
    private Executable executable;
    private static final Integer MINUTES_MAX = 60;


    public ScheduleManager() {

    }

    public ScheduleManager(Executable executable) {
        this.executable = executable;
        this.jobName = executable.getJobName();
    }

    public ScheduleManager(String jobName, String CRON_EXP) {
        this.jobName = jobName;
        this.CRON_EXP = CRON_EXP;
    }

    public void execute(SchedulableContext SC) {
        executable.execute();
    }

    /**
     * Method to stop all scheduled jobs based on job name
     */
    public void stop() {
        List<CronJobDetail> jobs = [SELECT Id FROM CronJobDetail WHERE Name LIKE :jobName + '%'];

        if (!jobs.isEmpty()) {
            for (CronJobDetail job : jobs) {
                Id jobId = [SELECT Id from CronTrigger WHERE CronJobDetailId = :job.Id][0].Id;
                System.abortJob(jobId);
            }
        }
    }

    /**
     * Method to schedule daily at specific hour
     *
     * @param hour 0-23
     */
    public void scheduleDailyAt(Integer hour) {
        if (hour > 23 || hour < 0) throw new InvalidCRONException('Invalid hours value');
        CRON_EXP = '0 0 {0} * * ?';
        System.schedule(jobName, String.format(CRON_EXP, new List<String>{
                String.valueOf(hour)
        }), this);
    }

    /**
     * Method to schedule daily at specific hour and on specific day
     *
     * @param hour 0-23
     * @param days 1–7 or the following:1–7 or the following: SUN,MON,TUE,WED,THU,FRI,SAT
     */
    public void scheduleDailyAt(Integer hour, String days) {
        if (hour > 23 || hour < 0) throw new InvalidCRONException('Invalid hours value');
        CRON_EXP = '0 30 {0} ? * {1}';
        System.schedule(jobName, String.format(CRON_EXP, new List<String>{
                String.valueOf(hour), days
        }), this);
    }

    /**
     * Method to schedule daily every minute
     *
     * @param minutes 0-59
     */
    public void scheduleEveryNMinutes(Integer minutes) {
        if (minutes > 59 || minutes < 0) throw new InvalidCRONException('Invalid minutes value');
        CRON_EXP = '0 {0} * * * ?';
        Integer counter = Integer.valueOf(Math.roundToLong((Double) MINUTES_MAX / (Double) minutes));
        Integer tempMinutes = 0;
        for (Integer i = 0; i < counter; counter--) {
            System.schedule(jobName + ' ' + counter, String.format(CRON_EXP, new List<String>{
                    String.valueOf(tempMinutes)
            }), this);
            tempMinutes += minutes;
        }
    }

    /**
     * Standard method to schedule based on cron expression
     *
     * @param cronExpression
     */
    public void scheduleWithCron(String cronExpression) {
        System.schedule(jobName, cronExpression, this);
    }
    
     /**
     * Method to schedule weekly at specific day
     *
     * @param dayNumber 1-7 the number before the # specifies weekday (SUN-SAT)
     * @param timesPerMonth 1-5 the number after the # specifies the day of the month
     */
    public void scheduleWeekly(Integer dayNumber, Integer timesPerMonth, Integer shift){
        if (dayNumber > 7 || dayNumber < 1) throw new InvalidCRONException('Invalid day number');
        if (timesPerMonth > 5 || timesPerMonth < 0) throw new InvalidCRONException('Invalid times number');
        String CRON_EXP = '0 0 23 ? * {0}#{1}';
        Integer dayOfMonth = 1;
        for(Integer i = 1; i <= timesPerMonth; i++){
            System.schedule(jobName + ' ' + counter, String.format(CRON_EXP, new List<String>{
                    String.valueOf(dayNumber), String.valueOf(dayOfMonth)
            }), this);
            dayOfMonth += shift;
        }
        return this;
    }

    private class InvalidCRONException extends Exception {
    }
}
