require 'broadcaster'
class ReminderReleaseWorker

  def initialize(opts = {})
    @reminder_id = opts['reminder_id']
  end

  def run
    reminder = Reminder.find(@reminder_id)
    release_reminder(reminder)
  end

  #
  # After a reminder is fired, if the user
  # does not take any action and the alert
  # remains 
  #
  def release_reminder(reminder)
    alert = reminder.alert
    merchant = alert.merchant
    member = merchant.member

    reminder.cleared = true
    reminder.job_id = nil
    reminder.job_type = nil
    reminder.save!
    
    # Un-assign the alert and ensure it's no
    # longer marked as being examined
    alert.user_id = nil
    alert.examined = false
    alert.being_examined = false
    alert.reminder_unactioned = true
    alert.save!

    message = {
      action: :released,
      resource_type: 'Alert',
      resource: alert
    }

    broadcaster = Broadcaster.new
    broadcaster.broadcast("/topics/merchants", message, { merchant_id: merchant.id.to_s })
    broadcaster.broadcast("/topics/members", message, { member_id: member.id.to_s })
  end

end