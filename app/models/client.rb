# == Schema Information
#
# Table name: clients
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  internal_code      :string(255)
#  jpos_key           :string(255)
#  member_id          :integer
#  created_at         :timestamp
#  updated_at         :timestamp
#  address1           :string(255)
#  address2           :string(255)
#  post_code          :string(20)
#  telephone          :string(255)
#  country            :string(128)
#  address            :string(255)
#  mcc                :string(4)
#  contact            :string(100)
#  phone              :string(30)
#  fax                :string(255)
#  email              :string(100)
#  company_id         :string(20)
#  vat_number         :string(20)
#  company_reg        :string(4)
#  owing_bank         :string(255)
#  bank_acc_no        :string(20)
#  bank_sort_code     :string(10)
#  sales_exec_code    :string(255)
#  cnp_type           :boolean
#  open_date          :timestamp
#  closed_date        :timestamp
#  floor_limit        :integer
#  data_collection    :integer
#  control_id         :integer
#  control_area       :string(255)
#  currency_code      :string(255)
#  state              :string(4)
#  business_segment   :string(255)
#  business_type      :string(255)
#  county             :string(128)
#  web_address        :string(255)
#  mrm_category       :integer
#  billing_point      :boolean
#  settlement_point   :boolean
#  parent_flag        :boolean
#  group_no           :string(4)
#  trade_assoc        :string(255)
#  settle_method      :string(255)
#  sett_sort_code     :integer
#  sett_account       :integer
#  clearing_name      :string(255)
#  clearing_city      :string(255)
#  contactless        :string(255)
#  defer_sett_amt     :string(4)
#  cur_bal_amt        :integer
#  business_cat       :string(255)
#  type_of_goods_sold :string(4)
#  comm_card_no       :integer
#  comm_card_limit    :integer
#  ret_reward_prog    :string(255)
#

class Client < ApplicationRecord

  include Filter
  include Authority::Abilities
  include RequiredColumnHelper
  include MemCaching
  is_cachable

  schema_validations unless Rails.env.test?
  validates :jpos_key, presence: true, jpos_unique: true
  validates :internal_code, uniqueness: true
  validates_format_of :email,:with => Devise.email_regexp, allow_blank: true
  validates_date :open_date
  validates_date :closed_date
  validates :member_id, presence: true, unless: :skip_owner_presence_validation 
  
  has_many :merchants
  has_many :customers
  has_many :cards
  has_many :accounts
  has_many :users, as: :owner
  has_many :rules, as: :owner
  has_many :statistic_tables, as: :owner
  has_many :active_rules, -> { where(active: true) }, class_name: 'Rule', as: :owner # this just used only inside rule manager step module

  has_many :field_list_mapping_owner, as: :owner
  has_many :alerts, as: :alert_owner
  has_many :data_lists, as: :owner
  has_many :enrichments, as: :owner
  has_many :currency_pairs, as: :currency_pair_ownerable
  has_many :sites, as: :owner

  belongs_to :member

  has_one :suspect_list, as: :suspectable, dependent: :destroy

  resourcify

  DISCOUNTED_COLUMNS = %w(id created_at updated_at member_id address)

  REQUIRED_COLUMNS = %w( name internal_code address1 address2 post_code country mcc contact phone fax email
                            cnp_type open_date closed_date floor_limit currency_code business_segment business_type
                            county web_address parent_flag type_of_goods_sold jpos_key
                          )

  attr_accessor :type, :skip_owner_presence_validation

  self.authorizer_name = 'ClientAuthorizer'

  # Get method below. If you fancy you could just do => self.type = 'client'
  # def type
  #   'client'
  # end
  #
  # def attributes
  #   super.merge(:'type' => self.type)
  # end

  def authority_check?(entity_type)
    self.class.creatable_by?(entity_type)
  end

end
