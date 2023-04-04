# == Schema Information
#
# Table name: violations
#
#  id                       :integer          not null, primary key
#  internal_code            :string(255)
#  rule_priority            :integer
#  alert_created_at         :timestamp        not null, primary key
#  authorisation_created_at :timestamp        not null
#  alert_id                 :integer
#  rule_id                  :integer
#  account_id               :integer
#  authorisation_id         :integer
#  customer_id              :integer
#  violatable_id            :integer
#  violatable_type          :string(255)
#  merchant_id              :integer
#  created_at               :timestamp        not null
#  updated_at               :timestamp        not null
#  card_id                  :integer
#

class Violation < ApplicationRecord
  include Filter
  include Journaled::Model
  include Authority::Abilities

  self.primary_keys = :alert_created_at, :id

  belongs_to :alert, foreign_key: [:alert_created_at, :alert_id]
  belongs_to :rule, -> { select(:id,:outcome,:priority,:internal_code,:description,:level) }
  belongs_to :account
  belongs_to :authorisation, foreign_key: [:authorisation_created_at, :authorisation_id]
  belongs_to :customer
  belongs_to :violatable, polymorphic: true
  belongs_to :merchant

  before_create :assign_to_alert
  after_create :update_alert

  has_journal type: 'Rule', message: 'Alert priority was updated', on: :create

  private

  def assign_to_alert
    # check if violation exist for give authorisation id. if violation exist then it means we already have an alert
    # for given auth so creating another auth is forbade.
    violation = Violation.find_by_authorisation_id(self.authorisation['id'])
    auth = self.authorisation

    if auth.jpos_merchant_key
      owner_id, owner_type = Merchant.find_by_jpos_key(auth.jpos_merchant_key).try(:id), 'Merchant'
    elsif auth.jpos_client_key
      owner_id, owner_type = Client.find_by_jpos_key(auth.jpos_client_key).try(:id), 'Client'
    elsif auth.jpos_member_key
      owner_id, owner_type = Member.find_by_jpos_key(auth.jpos_member_key).try(:id), 'Member'
    end

    if violation.nil?
      current_time = Time.zone.now
      self.alert = Alert.create(response: self.internal_code,
        alert_owner_id: owner_id,
        alert_owner_type: owner_type,
        alert_type: 'Auth',
        subject: self.internal_code,
        priority: self.rule_priority,
        run_date: DateTime.current,
        examined: false,
        merchant_id: self.merchant_id,
        created_at: current_time,
        card_id: self.authorisation['card_id'])
    else
      self.alert = Alert.find_by_id(violation.alert_id)
      alert.priority = self.rule_priority
      alert.alert_owner_id   = owner_id
      alert.alert_owner_type = owner_type
      alert.save
    end
  end

  # After our violation has been created,
  # we need to update the assigned alert
  # (whether it is new or not doesn't matter).
  # This will ensure that the alerts priority
  # is updated to reflect the new violation
  def update_alert
    alert.priority = alert.rules.collect(&:priority).sum #TODO Performance issue
    alert.save
  end
end
