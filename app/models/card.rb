# == Schema Information
#
# Table name: cards
#
#  id              :integer          not null, primary key
#  name_on_card    :string(255)
#  card_number     :string(255)
#  last_four       :string(255)
#  card_type       :string(255)
#  card_class      :string(255)
#  expiration_date :timestamp
#  valid_year      :timestamp
#  valid_month     :timestamp
#  status          :string(255)
#  issuer          :string(255)
#  issuer_country  :string(255)
#  bin             :string(255)
#  customer_id     :integer
#  member_id       :integer
#  merchant_id     :integer
#  created_at      :timestamp        not null
#  updated_at      :timestamp        not null
#  client_id       :integer
#

class Card < ApplicationRecord
  include Filter

  has_many :accounts
  has_many :authorisations
  has_one :suspect_list, as: :suspectable, dependent: :destroy
  has_many :violations, as: :violatable
  belongs_to :customer
  belongs_to :member
  belongs_to :merchant

  acts_as_commentable primary_key: :id

  before_create :add_customer_from_card
  before_create :hash_card_number ,if: Proc.new { |c| c.card_number_before_type_cast.size < 20 }

  def self.from_customer(customer_id = nil)
    #add check: existing records in the DB only..otherwise it fails
    if customer_id
      Customer.find(customer_id).cards
    else
      where(nil)
    end
  end

  def add_customer_from_card
    # puts " #{Time.zone.now.to_i}:inside#{__method__}"
    self.customer = Customer.select(:id).create_with(full_name: self.name_on_card,member_id:self.member_id,client_id:self.client_id,merchant_id:self.merchant_id).find_or_create_by(full_name: self.name_on_card,merchant_id:self.merchant_id)
  end

  def card_number
    # puts " #{Time.zone.now.to_i}:inside#{__method__} from the Card Model"
    "#{bin}******#{last_four}"
  end

  private

  def hash_card_number
    # puts " #{Time.zone.now.to_i}:inside#{__method__}"
    cn = CardNumber.new(self[:card_number])
    self.card_number = cn.hashed_value
    self.bin = cn.bin
    self.last_four = cn.last_four
  end

end
