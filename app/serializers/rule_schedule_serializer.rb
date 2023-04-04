class RuleScheduleSerializer < ActiveModel::Serializer
  attributes :id, :rule_id, :start_datetime, :end_datetime, :week_days
  
  def week_days
    object.week_days.pluck(:code, :name).to_a
  end
  
end
