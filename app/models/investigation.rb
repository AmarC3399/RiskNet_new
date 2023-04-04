# == Schema Information
#
# Table name: investigations
#
#  id                       :integer          not null, primary key
#  state                    :string(255)
#  pan                      :string(255)
#  transaction_date         :timestamp
#  transaction_amount       :decimal(22, 2)
#  amount_local_ccy         :string(255)
#  normal_spending          :boolean
#  cardholder_contacted     :boolean
#  cardholder_possession    :boolean
#  goods_received           :boolean
#  chased                   :boolean
#  declaration_ordered      :boolean
#  voucher_present          :boolean
#  deleted                  :boolean
#  investigation_type       :string(255)
#  due_to                   :string(255)
#  alert_created_at         :timestamp        not null, primary key
#  authorisation_created_at :timestamp        not null
#  user_id                  :integer
#  authorisation_id         :integer
#  merchant_id              :integer
#  alert_id                 :integer
#  created_at               :timestamp        not null
#  updated_at               :timestamp        not null
#

class Investigation < ApplicationRecord
  include Filter
  include Authority::Abilities

  self.primary_keys = :alert_created_at, :id

  belongs_to :authorisation, foreign_key: [:authorisation_created_at, :authorisation_id]
  belongs_to :user
  belongs_to :alert, foreign_key: [:alert_created_at, :alert_id]

  acts_as_commentable primary_key: :id

  accepts_nested_attributes_for :comments
  before_save :update_all
  validates_presence_of :authorisation_id

  def update_all
    if authorisation
      self.pan = self.authorisation.card.card_number
      self.transaction_date = self.authorisation.auth_date
      self.transaction_amount = self.authorisation.authorisation_amount
      self.amount_local_ccy = self.authorisation.ccy
      self.alert_id = self.authorisation.violation.try(:alert_id)
      self.alert_created_at = self.authorisation.violation.try(:alert_created_at)
      self.merchant_id = self.authorisation.merchant_id
    end
  end

end
