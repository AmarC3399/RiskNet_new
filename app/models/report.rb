# == Schema Information
#
# Table name: reports
#
#  id                :integer          not null, primary key
#  report_type       :string(255)
#  date_range        :string(255)      not null
#  report_grouping   :string(4000)
#  report_definition :string(4000)
#  created_by        :string(255)
#  last_execution    :timestamp
#  deleted           :boolean
#  created_by_id     :integer
#  created_at        :timestamp
#  updated_at        :timestamp
#  title             :string(255)      not null
#  target_id         :integer
#  target_type       :string(255)
#

class Report < ApplicationRecord
  include Filter
  include ValidJsonHelper
  include Authority::Abilities
  
  schema_validations unless Rails.env.test?
  
  has_many :report_results, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id

  resourcify

  validate :report_definition_validator
  validates_inclusion_of :report_type, in: %w(fraud_activity rule_efficiency operational_user operational_member operational_merchant active_override override_by_operator overridden_transactions)

  default_scope { where(deleted: false) }

  before_save :save_member_merchants

  self.authorizer_name = 'ReportAuthorizer'

  def save_member_merchants
    # parsed_json = JSON.parse(self.report_grouping, symbolize_names: true)
    #
    # parsed_json.delete(:merchant) if parsed_json[:merchant].present? && parsed_json[:merchant].reject(&:blank?).blank?
    # parsed_json.delete(:member) if parsed_json[:member].blank? || parsed_json[:member].reject(&:blank?).blank?
    # self.report_grouping = parsed_json.to_json

    self.report_grouping = '{}' unless self.report_grouping 
  end

  # 
  # Check to make sure at least 
  # one field has been  selected
  # 
  def report_definition_validator
    unless valid_json?(self.report_definition)
      errors.add(:report_elements, I18n.t('.reports.errors.report_elements'))
      return
    end

    parsed_json = JSON.parse(self.report_definition, symbolize_names: true)
    if parsed_json[:fields].blank?
      errors.add(:report_elements, I18n.t('.reports.errors.report_elements'))
      return
    end
  end

  # cattr_accessor :entity
  #
  # def self.get_created_by_id(current_user)
  #   self.entity = current_user.owner_type.downcase
  #   case self.entity
  #   when 'installation'
  #   when 'member'
  #     member_id(current_user).flatten +  client_ids(current_user).flatten + merchant_ids(current_user).flatten
  #   when 'client'
  #     client_ids(current_user).flatten + merchant_ids(current_user).flatten
  #   when 'merchant'
  #     merchant_ids(current_user).flatten
  #   else
  #     raise t(:can_not_find_entity) # I doubt this scenario will ever turn up in real world.
  #   end
  # end
  #
  # def self.member_id(current_user)
  #   current_user.owner.users.map(&:id)
  # end
  #
  # def self.client_ids(current_user)
  #   if self.entity == 'member'
  #     current_user.owner.clients.map { |m| m.users.map(&:id) }
  #   elsif self.entity == 'client'
  #     current_user.owner.users.map(&:id)
  #   end
  # end
  #
  # def self.merchant_ids(current_user)
  #   if self.entity == 'member'
  #     current_user.owner.clients.map { |c| c.merchants.map { |m| m.users.map(&:id) } }
  #   elsif self.entity == 'client'
  #     current_user.owner.merchants.map { |m| m.users.map(&:id) }
  #   elsif self.entity == 'merchant'
  #     current_user.owner.users.map(&:id)
  #   end
  # end
end
