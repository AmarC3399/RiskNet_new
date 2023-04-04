class RuleScheduleWeekDay < ApplicationRecord
  belongs_to :rule_schedule
  belongs_to :week_day
end
