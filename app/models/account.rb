# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  account_status  :string(255)
#  open_date       :timestamp
#  close_date      :timestamp
#  credit_limit    :decimal(22, 2)
#  balance         :decimal(22, 2)
#  available_funds :decimal(22, 2)
#  card_id         :integer
#  member_id       :integer
#  merchant_id     :integer
#  created_at      :timestamp        not null
#  updated_at      :timestamp        not null
#  client_id       :integer
#

class Account < ApplicationRecord
  has_many :authorisations
  belongs_to :member
  belongs_to :merchant
  belongs_to :card
end
