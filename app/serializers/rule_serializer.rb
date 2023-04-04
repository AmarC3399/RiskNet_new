class RuleSerializer < ApplicationSerializer
  self.root = false
  
  attributes :id, :internal_code, :description, :active,  :rule_evaluation_type, :evaluation_type, :priority, :created_at, :updated_at, :outcome, :simulation, :violation_limit, :owner_id, :owner_type, :deleted, :criteria_attributes, :category_id, :category_name, :visible, :owner_name,
             :override_type, :add_to_list, :time_value, :time_period

  has_many :authorisations, embed: :ids, embed_key: :to_param
  has_many :criteria
  has_one :owner
  has_one :schedule, serializer: RuleScheduleSerializer
  # has_one :category

  def include_associations!
    include! :owner if @options[:owner]
    include! :criteria if @options[:criteria]
    include! :authorisations if @options[:rules].try(:[], :authorisation_ids)
    # include! :category
    include! :schedule
  end

  def criteria_attributes
    ActiveModel::ArraySerializer.new(object.criteria, each_serializer: CriteriaFormattedSerializer) if @options[:formatted].present?
  end
  
  def owner_name
    self.owner_type.constantize.find(self.owner_id).name
  rescue
    nil
  end 

end
