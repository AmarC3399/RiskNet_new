class WeekDay < ApplicationRecord
  
  has_many :rule_schedule_week_days
  has_many :rule_schedules , :through => :rule_schedule_week_days

  WEEK_DAY_MAPPING = {
    'SUN' => 'Sunday',
    'MON' => 'Monday', 
    'TUE' => 'Tuesday', 
    'WED' => 'Wednesday', 
    'THU' => 'Thursday', 
    'FRI' => 'Friday', 
    'SAT' => 'Saturday'
  }
end
