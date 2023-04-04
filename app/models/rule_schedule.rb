# == Schema Information
#
# Table name: rule_schedules
#
#  id                      :integer          not null, primary key
#  rule_id                 :references
#  start_datetime          :datetime
#  end_datetime            :datetime
#  created_at              :timestamp        not null
#  updated_at              :timestamp        not null
#


class RuleSchedule < ApplicationRecord
  belongs_to :rule 
  
  has_many :rule_schedule_week_days , :dependent => :destroy
  has_many :week_days , :through => :rule_schedule_week_days
  belongs_to :owner, polymorphic: true

  validates_presence_of :rule_id
#  validates_uniqueness_of :rule_id
  validates_presence_of :start_datetime
  validate :check_datetime
  validate :check_rule

  default_scope { where(deleted_at: nil) }
  
  #  custom validation method, *to do move them to validation class
  def check_datetime
    errors.add('Start Date', "does not look formatted correctly ") unless DateTime.parse(start_datetime.to_s).is_a?(DateTime)
    if end_datetime.present? && start_datetime >= end_datetime 
      errors.add('Wrong Dates', ", End Date must be after Start Date")
    end
  rescue
    errors.add('Dates', "do not look formatted correctly")
  end
  
  def check_rule
    if rule_id
      rule = Rule.find(rule_id)
      if rule
        true
      else
        errors.add(:rule_id, "Could not be found ")
      end
    end
  rescue
    errors.add(:rule_id, "Could not be found ")
  end
  
  #  get all relations for the schedule model
  def with_includes
    self.as_json(
      :except => [:created_at, :updated_at] ,
      :include => { 
        :week_days => {:except => [:created_at , :updated_at]}, 
      }
    )
  end

  def self.schedule_json_for_rule_new(schedule)
    result = {}
    if schedule
      result = {
          :rule_key => schedule['rule_id'],
          :start_datetime => schedule['start_datetime'],
          :end_datetime => schedule['end_datetime'],
          :recurring_weekdays => schedule['week_days'].map { |wd| wd['code'] }
      }
    end
    result
  end
  
  def self.schedule_json_for_rule(id=nil)
    result = {}
    if id
      schedule = find_by(rule_id: id)
      if schedule
        result = {
          :rule_key => schedule.rule_id,
          :start_datetime => schedule.start_datetime.iso8601,
          :end_datetime => schedule.end_datetime.try(:iso8601),
          :recurring_weekdays => schedule.week_days.pluck(:code).to_a
        }
      end
    end
    return result
  end
  
  # get the week days for the schedule
  def self.get_week_days_ids(days_names)
    unless days_names.empty?
      results = []
      if days_names.include?'All'
        results =  WeekDay.all.to_a
      else
        days_names.each do |day|
          day = WeekDay.where("name LIKE ?", "%"+day+"%").try(:first)
          if day
            results << day
          end
        end
      end
    end
    results
  end
  
  # This method used when editing a rule to switch the schedule
  def self.assign(o, n)
    s = find_by(rule_id: o)
    if s && s.rule_id != n
      s.update(rule_id: n)
    end
  end
  
  #  build the json object for the rule
  def self.schedule_json_for_rules
    schedules = get_active_schedules
    results = Array.new
    schedules.each do |schedule|
      results << {:id => schedule.id,
        :rule_key => schedule.rule_id,
        :start_datetime => schedule.start_datetime.iso8601,
        :end_datetime => schedule.end_datetime.try(:iso8601),
        :recurring_weekdays => schedule.week_days.pluck(:code).to_a
      }
    end
    return results
  end
  
  def self.get_active_schedules
    where(rule: Rule.active, deleted_at: null)
  end
  
  #get resources tables for the schedule model
  def self.get_resources
    {
      'days' => WeekDay.all.as_json(:except => [:created_at , :updated_at]),
    }
  end
  
  def self.create_schedule_for_rule(schedule_params, rule_id,parent_id = nil, action = "new")
    results = {:messages => [],:schedule => nil}
    if action == "clone"
      results[:messages] << "No schedule for clone action"
      return results
    end
    if parent_id
      schedule = self.where(rule_id: parent_id )
      schedule.update(deleted_at: Time.now) if schedule.first
      results[:messages] << "rule had a schedule and was deleted!"
    end
    if schedule_params && rule_id
      schedule_params[:rule_id] = rule_id
      results[:schedule] = RuleSchedule.creator(schedule_params)
    end
    return results
  end
  
  def build_week_days(week_days)
    if week_days.present? && !week_days.empty?
      if week_days.include?'All'
        WeekDay.all.each do |day|
            self.rule_schedule_week_days.create(week_day_id: day.id)
        end
      else
        week_days.each do |day|
          if day = WeekDay.where("name LIKE ?", "%"+day+"%").first
            self.rule_schedule_week_days.create(week_day_id: day.id)
          end
        end
        
      end
    end
  end  
  
  
  def self.creator(params)
    results = []
    if params[:rule_id].kind_of?(Array)
      params[:rule_id].each do |rule_id|
        results << RuleSchedule.build_one_schedule(RuleSchedule.build_schedule_params(params, rule_id), params[:week_days])
      end
    else
      results << RuleSchedule.build_one_schedule(RuleSchedule.build_schedule_params(params), params[:week_days])
    end
    return results
  end
  
  def self.build_one_schedule(params, week_days)
    RuleSchedule.delete_schedule(params[:rule_id])
    schedule = RuleSchedule.new(params)
    if schedule.save
      schedule.build_week_days(week_days)
    end
    return {:schedule => schedule.with_includes, :errors => schedule.errors.full_messages}
  end
  
  def self.build_schedule_params(params, rule_id = nil)
    {
      :rule_id => rule_id || params[:rule_id],
      :start_datetime => params[:start_datetime],
      :end_datetime => params[:end_datetime]
    }
    
  end
  
  def self.delete_schedule(rule_id)
    schedule = RuleSchedule.where(rule_id: rule_id )
    schedule.update(deleted_at: Time.now) if schedule.first
  end

end
