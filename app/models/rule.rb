# == Schema Information
#
# Table name: rules
#
#  id                            :integer          not null, primary key
#  member                        :string(255)
#  level                         :string(255)
#  rule_type                     :string(255)
#  internal_code                 :string(100)
#  description                   :text
#  priority_calculation          :string(255)
#  priority_totalling            :string(255)
#  rule_evaluation_type          :string(255)
#  evaluation_type               :string(255)
#  priority                      :integer
#  enhanced_priority_calculation :boolean
#  outcome                       :string(255)
#  violation_limit               :integer          default(500)
#  active                        :boolean          default(TRUE)
#  simulation                    :boolean          default(FALSE)
#  deleted                       :boolean          default(FALSE)
#  owner_id                      :integer
#  owner_type                    :string(255)
#  created_at                    :timestamp        not null
#  updated_at                    :timestamp        not null
#  parent_id                     :integer
#  category_id                   :integer
#  visible                       :boolean          default(FALSE)
#

class Rule < ApplicationRecord

  # schema_validations unless Rails.env.test?

  include Broadcastable
  include Filter
  include Authority::Abilities
  include JoinByType

  has_many :criteria, class_name: "Criterion", dependent: :destroy, inverse_of: :rule
  has_many :violations
  has_many :authorisations, through: :violations
  has_one :category, class_name: 'ListItem', primary_key: 'category_id', foreign_key: 'id'
  has_one :schedule, class_name: 'RuleSchedule', foreign_key: 'rule_id', :dependent => :destroy

  # belongs_to :member
  # belongs_to :client
  # belongs_to :merchant


  accepts_nested_attributes_for :criteria
  accepts_nested_attributes_for :schedule
  default_scope { where(deleted: false).where.not(owner: nil)}
  scope :active, -> { where(active: true) }
  scope :with_authorisations, -> do
    joins('LEFT OUTER JOIN violations ON violations.rule_id = rules.id')
      .joins('LEFT OUTER JOIN authorisations ON violations.authorisation_id = authorisations.id AND violations.authorisation_created_at = authorisations.created_at')
  end

  
  def self.update_rule_engine_v2(arg={})
    require 'messenger/rule_manager'
    #make use of a executor which is better than Thread.new and faster
    executor = Executors.newSingleThreadExecutor
    # based on Oracle documentation, it waits for the action to finish and then shuts down..
    # just making sure we don't hold open threads and memory is free
    executor.submit do
      begin
        rm = RuleManager.new
        rm.update_rule_engine_v2(arg)
      rescue StandardError => ex
        puts "\n\n\n---- Failed to update the rule processer (see me at line:68 models/rule.rb) ------- \n\n\n"
        puts "\n Detailed message:\n #{ex.message} \n"
        if arg[:user]
          message, header = {}, {}
          message[:action] = arg[:action].capitalize
          message[:resource_type] = arg[:type].capitalize
          message[:resource] = arg
          header["#{arg[:user].owner_type.downcase}_id".to_sym] = arg[:user].owner_id.to_s
          broadcaster = Broadcaster.new
          broadcaster.broadcast("/topics/#{arg[:user].owner_type.downcase.pluralize}", message, header).inspect
        end
      end
    end
    executor.shutdown
  end
  
  #scope :deleted, -> { where(deleted: true) }

  def self.merchant_filtered(filter)
    member_filter = (member_id = filter[:member]) ? {owner_id: member_id, owner_type: 'Member'} : {}
    merchant_filter = (merchant_id = filter[:merchant]) ? {owner_id: merchant_id, owner_type: 'Merchant'} : {}
    where(member_filter).where(merchant_filter)
  end

  def self.target_filtered(report_hash)
    target_id = Report.find(report_hash[:report_id]).target_id
    
    case Report.find(report_hash[:report_id]).target_type
      when 'Member'
       where(owner_type: 'Member',  owner_id: target_id)
      when 'Client' 
       where(owner_type: 'Client',  owner_id: target_id) 
      when 'Merchant'
       where(owner_type: 'Merchant', owner_id: target_id)  
      else
       all  
    end   
  end



  #THIS WAS SUPPOSED TO BE FIXED BUT THE CHANGE WAS LOST/OVERWRITTEN
  #before_save :set_description
  #def set_description
  #  cnt = self.criteria.count
  #  self.description = "#{self.evaluation_type.singularize.humanize} rule for #{self.level.downcase} with #{cnt} #{'criterion'.pluralize(cnt)}"
  #end
  after_create :calculate_statistic_values
  after_save :set_description

  %w(created_by updated_by).each { |method_name| define_method(method_name) { |user| self.update_attribute("#{method_name}_id".to_sym, user.id) } }
  
  def set_description
    cnt = self.criteria.count
    self.update_column :description, "#{self.criteria.collect { |z| z.description }.to_sentence}"
  end

  def criteria_included
    criteria.as_json(include:
                 [
                   {leftable: {excl_list: true, extended_stats: true, for_jpos: true}},
                   {rightable: {incl_statistic: true, extended_stats: true, for_jpos: true}}])
  end

  def self.is_global?
    rules.each do |acr|
      case acr["level"]
        when "Card"
          acr["subject_type_id"] = 1
          acr["subject_name"] = "GLOBAL"
          acr["subject_id"] = nil
        when "Merchant"
          acr["subject_type_id"] = 1
          acr["subject_name"] = "MERCHANT"
          acr["subject_id"] = acr["owner_id"]
        else
          acr["subject_type_id"] = nil
          acr["subject_name"] = "GLOBAL"
          acr["subject_id"] = nil
      end
    end
    rules.each { |rl| rl.delete("level") }
    rules.each { |rl| rl["criteria_included"].each { |cr| cr["rightable_type"]="CriteriaParameter" if cr["rightable_type"]=="CriteriaCard" } }
    rules.each { |rl| rl["criteria_included"].each { |cr| cr["rightable"][:unique_id]["data_type"]="CriteriaParameter" if cr["rightable"][:unique_id]["data_type"]=="CriteriaCard" } }
  end


  def self.build_complete_json
    all_active_rules = Rule.includes(:criteria).active.as_json(methods: :criteria_included)
    #delete the authorisation_ids from the json
    all_active_rules.each { |rl| rl.delete(:authorisation_ids) }
    ##TODO-AN hardcoding subject types
    #related with rule_init rake tasks in rpc_jobs.rake file
    #1  = Merchant
    #2  = Card
    all_active_rules.each do |acr|
      case acr["level"]
        when "Card"
          acr["subject_type_id"] = 1
          acr["subject_name"] = "GLOBAL"
          acr["subject_id"] = nil
        when "Merchant"
          acr["subject_type_id"] = 1
          acr["subject_name"] = "MERCHANT"
          acr["subject_id"] = acr["owner_id"]
        else
          acr["subject_type_id"] = nil
          acr["subject_name"] = "GLOBAL"
          acr["subject_id"] = nil
      end
    end
    all_active_rules.each { |rl| rl.delete("level") }
    all_active_rules.each { |rl| rl["criteria_included"].each { |cr| cr["rightable_type"]="CriteriaParameter" if cr["rightable_type"]=="CriteriaCard" } }
    all_active_rules.each { |rl| rl["criteria_included"].each { |cr| cr["rightable"][:unique_id]["data_type"]="CriteriaParameter" if cr["rightable"][:unique_id]["data_type"]=="CriteriaCard" } }
  end
  # def authorisation_ids(exclude=nil)
  #   #todo-an we need to filter this by alert because in the future, we will receive all auths that broke that rule..
  #   # and it will generate a huge array!
  #   @authorisation_ids ||= Violation.select(:authorisation_id).where(rule_id: self.id).map{|z| z.authorisation_id}
  # end
  #todo-an this will be improved when we will add more types
  #def rule_types
  #
  #end
  #Available types can be:
  # ['AUTHORISATION', 'STATISTIC_ON_AUTHORISATION', 'STATISTIC_ON_TRANSACTION','TRANSACTION']
  #also rule_evaluation type can be:
  # ['SEQUENCE', 'STANDARD', 'MOVINGWINDOW', 'SINGLE']

  def serializable_hash(options = nil)
    options ||= {}
    ids = false

    if Array(options[:extra]).include?(:authorisation_ids)
      ids = true
    end

    if ids
      super.merge(authorisation_ids: self.authorisations.map(&:to_param))
    else
      super
    end

  end


  def calculate_statistic_values
    criteria.each do |c|
      if c.leftable_type == 'StatisticCalculation' && c.leftable.statistic
        calculate_statistic(c.leftable)
      end

      if c.rightable_type == 'StatisticCalculation' && c.rightable.statistic
        calculate_statistic(c.rightable)
      end
    end
  end

  def calculate_statistic(xable)
    # unless xable.statistic_timeframe.aggregate_level == "H"
    #   if xable.statistic.grouped
    #     StatisticGroupResult.create_from_statistic_calculation(xable)
    #   else
    #     StatisticResult.create_from_statistic_calculation(xable)
    #   end
    # end
    # StatisticIndex.create_from_statistic_calculation(xable) if ENV['COVERING_INDEX_CREATE_IMMEDIATE']
    StatisticTable.create_from_statistic_calculation(xable)
  end

  def category_name
    ListItem.where(id: self.category_id).pluck(:frontend_name).first
  end


end

# ActiveRecord::Base.establish_connection
