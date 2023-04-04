class AlertOverrideSerializer < ApplicationSerializer
  attributes :id, :start_time, :end_time, :owner_id, :owner_type, :comment, :card_number, :type, :owner,
             :initiated_by, :rule_id, :rule_name, :temp_id, :state

  # , :card_number, :name, :user

  def type
    object.override_type.name
  end

  def owner
    (object.user_id.nil? || User.find(object.user_id).try(:owner).is_a?(Installation)) ? '-' : User.find(object.user_id).name
  end

  def card_number
    object.override_card.masked_card_number
  end

  def rule_id
    object.rule_id.nil? ? '-' : object.rule_id
  end

  def rule_name
    Rule.unscoped.find_by_id(object.rule_id).internal_code rescue '-'
  end

  def start_time
    object.start_time.localtime rescue object.start_time
  end

  def end_time
    object.end_time.localtime rescue object.end_time
  end

  #TODO is this necessary? Confusion from merging
  def state
    (object.active.nil? || object.active == false) ? false : true
  end
end