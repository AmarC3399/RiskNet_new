class RuleSchedulesController < ApplicationController
   before_action :set_rule_schedule, only: [:show, :edit, :update, :destroy]

  def show
     render json: @rule_schedule.with_includes, status: :ok
  end

  def create
   schedules, errors = [], []
    week_days = RuleSchedule.get_week_days_ids(params[:week_days])
    params[:rule_ids].each {|rule_id|
      schedules << RuleSchedule.new({
                                        rule_id: rule_id,
                                        start_datetime: params[:start_datetime],
                                        end_datetime: params[:end_datetime],
                                        week_days: week_days,
                                        owner: current_user
                                    })
    }
    schedules.each {|schedule|
      if !schedule.valid?
        errors << schedule.errors.full_messages
      end
    }
    unless errors.empty?
      render json: {errors: errors.flatten.uniq}, status: :unprocessable_entity
    else
      schedules.each {|schedule|
        RuleSchedule.find_by(rule_id: schedule.rule_id).try(:update, {deleted_at: Time.now, owner: current_user})
        schedule.save
      }
      rule_manager_log = Logger.new("#{Rails.root}/log/rule_manager.log")
      rule_to_update = Rule.where(id: params[:rule_ids]).where(active: true)
      rule_to_update.each do |rule|
        rule_manager_log.info('-----------------')
        rule_manager_log.info('----Rule schedules update-----')
        rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{rule.id}, 'Rule')")
        rule_manager_log.info("Rule attributes: #{rule.attributes}")
        rule_manager_log.info('-----------------')
        EpochObserverService.update_epoch_for_table(rule.id, 'Rule')
      end
      Rule.update_rule_engine_v2(type: "rules", added: rule_to_update, deleted: rule_to_update, user: current_user) unless rule_to_update.empty?
      render json: {message: I18n.t('rules.index.notifications.success.schedule', total_count: schedules.length), schedules: schedules}, status: :created
    end
  end

  def edit
      render json: {
        rule_schedule: @rule_schedule.with_includes,
        resources: RuleSchedule.get_resources
    }
  end

  def disable
     schedules = []

    params['rules']['ids'].each {|rule_id|
      schedules << RuleSchedule.find_by_rule_id(rule_id)
    }

    if !schedules.empty?
      schedules.each {|schedule|
        if !schedule.nil?
          if schedule.update(deleted_at: Time.now)
            EpochObserverService.update_epoch_for_table(schedule.rule_id, 'Rule')
            Rule.update_rule_engine_v2(type: "rules", added: schedule.rule_id, deleted: schedule.rule_id, user: current_user)
          else
            render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'delete', model: 'rule_schedule')}, status: :unprocessable_entity
          end
        end
      }
      render json: {message: I18n.t('rules.index.notifications.success.unschedule', total_count: schedules.length), schedules: schedules}, status: :ok
    end
  end

  def resources
     render json: RuleSchedule.get_resources
  end

  private

  def set_rule_schedule
    @rule_schedule = RuleSchedule.find(params[:id])
  rescue => e
    render json: {errors: ['Could not find Rule Schedule']}
  end
end
