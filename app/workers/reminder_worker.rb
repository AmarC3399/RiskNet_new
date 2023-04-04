require 'broadcaster'

class ReminderWorker
   #todo-an test the hotfix and also fix the bug here
  def initialize(opts = {})
    @reminder_id = opts['reminder_id']
  end

  def run
    reminder = Reminder.find(@reminder_id)
    broadcast_reminder(reminder)
  end


  def broadcast_reminder(reminder)
    alert = reminder.alert
    user_id = alert.user_id

    message = {
      action: :reminder,
      resource_type: 'Alert',
      resource: alert
    }

    if user_id
      broadcaster = Broadcaster.new
      broadcaster.broadcast("/topics/users", message, { user_id: user_id.to_s })
    end

    # Now we need to schedule another job, that will
    # ensure that if the alert is ignored, it will be
    # released back into the list of alerts that all
    # users can access
    reminder.job_id = SecureRandom.uuid
    reminder.job_type = 'release'
    reminder.expired = true
    reminder.save!
    # TorqueBox::ScheduledJob.at('ReminderReleaseWorker', at: Time.now + 2.minutes, name: reminder.job_id, config: { 'reminder_id' => reminder.id }) # TODO Add scheduler here
  end

end