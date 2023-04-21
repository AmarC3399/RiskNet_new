# == Schema Information
#
# Table name: authorisations
#
#  id                           :integer          not null, primary key
#  derived_transaction_type     :string(255)
#  card_name                    :string(128)
#  card_type                    :string(50)
#  card_number                  :string(128)
#  card_issuer                  :string(128)
#  card_issuer_country          :string(50)
#  card_class                   :string(20)
#  expiration_date              :timestamp
#  auth_code                    :string(20)
#  cv2_check_result             :string(20)
#  address_numeric_check_result :string(20)
#  post_code_check_result       :string(20)
#  secure_3d_auth_check_result  :string(20)
#  address                      :string(255)
#  city                         :string(128)
#  post_code                    :string(50)
#  county                       :string(128)
#  country                      :string(50)
#  email                        :string(100)
#  phone_number                 :string(30)
#  customer_ip_address          :string(20)
#  authorisation_amount         :decimal(22, 2)
#  local_amount                 :decimal(22, 2)
#  auth_response                :string(20)
#  auth_status                  :string(20)
#  transaction_type             :string(50)
#  mcc                          :string(20)
#  ccy                          :string(10)
#  order_key                    :string(255)
#  order_description            :string(256)
#  message                      :string(255)
#  jpos_auth_key                :string(255)
#  jpos_merchant_key            :string(255)
#  auth_date                    :timestamp
#  card_id                      :integer
#  account_id                   :integer
#  member_id                    :integer
#  merchant_id                  :integer
#  created_at                   :timestamp        not null, primary key
#  updated_at                   :timestamp        not null
#  processing_host              :string(255)
#  client_id                    :integer
#  jpos_client_key              :string(255)
#  jpos_member_key              :string(255)
#
require 'yaml'
#require 'authorisation_search'

class Authorisation < ApplicationRecord
  paginates_per 10
  include Filter
  #include Authorisation::Abilities

  attr_accessor :member_name, :client_name, :merchant_name
  
  
 # self.primary_keys = :created_at, :id

  # may cause problems with tests ..keep that in mind when testing
  has_many :authorisation_extras, foreign_key: [:created_at, :authorisation_id]
  has_many :frauds, foreign_key: [:authorisation_created_at, :authorisation_id]
  has_many :agnostic_fields, through: :authorisation_extras
  has_many :enrichment_results, foreign_key: [:authorisation_created_at, :authorisation_id]

  belongs_to :card
  belongs_to :account
  belongs_to :member
  belongs_to :client
  belongs_to :merchant

  has_one :violation, foreign_key: [:authorisation_created_at, :authorisation_id] # Reason for changing to has_one is alert page expects authorisaiton to have only one violations.
                                                                                  # For one auth- it could have many violations. so all violation belonging to an auth will always
                                                                                  # have same reference auth_id. So its best we send one violation. Hence, has_one.
  has_one :investigation, foreign_key: [:authorisation_created_at, :authorisation_id]

  accepts_nested_attributes_for :authorisation_extras
  accepts_nested_attributes_for :frauds

  #acts_as_commentable primary_key: :id
  # rule_breaker:  checks rules against authorisations and create violations
  # include Feeder

  scope :active, -> { where(active: true) }

  scope :with_frauds, -> do
    self.joins('LEFT OUTER JOIN (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY authorisation_id, authorisation_created_at ORDER BY created_at DESC) AS rn FROM frauds
        ) AS frauds
        ON frauds.authorisation_id = authorisations.id AND  frauds.authorisation_created_at = authorisations.created_at AND frauds.rn=1')
  end

  scope :join_frauds, -> do
    self.joins('LEFT JOIN (SELECT f1.authorisation_id, f1.fraud_status, f1."created_at" FROM frauds AS f1 LEFT JOIN frauds as f2 ON f1.authorisation_id = f2.authorisation_id and f1.created_at < f2.created_at WHERE f2.authorisation_id IS NULL) as frauds ON (authorisations.id = frauds.authorisation_id)')
  end

  scope :join_violation, -> do
    self.joins('LEFT JOIN violations ON (authorisations.id = violations.authorisation_id AND authorisations.created_at = violations.authorisation_created_at)')
  end

  before_create :match_merchant_and_build_card
	after_save {Enrichment.process(Enrichment.cached_enrichments, self)}
	
#	start of geolocation
	def build_geolocation
		owner = self.get_auth_owner
		fields = self.get_mapped_fields(owner)
		long = nil
		lat = nil
		point = nil
		fields.each do |field|
			case field['name']
			when 'geolocation_longtitude'
				long = self[field['abstract']].to_f
			when 'geolocation_latitude'
				lat = self[field['abstract']].to_f
			when 'geolocation_point'
				point = field['abstract']
			end
		end
		if long && lat && long.between?(-180, 180) && lat.between?(-90, 90)
				self[point] = "POINT(#{long} #{lat})"
		end
	end
	
	def get_auth_owner #TODO !!! Huge performance issue !!!
		return { :id =>  Merchant.select(:id, :jpos_key).find_by_jpos_key(self.jpos_merchant_key).try(:id),  :type => 'Merchant'} unless self.jpos_merchant_key.empty?
		return { :id =>  Client.select(:id, :jpos_key).find_by_jpos_key(self.jpos_client_key).try(:id),  :type => 'Client'} unless self.jpos_client_key.empty?
		return { :id =>  Member.select(:id, :jpos_key).find_by_jpos_key(self.jpos_member_key).try(:id),  :type => 'Member'} unless self.jpos_member_key.empty?
	end
	
	def get_mapped_fields(owner)
		FieldListMappingOwner.new.cached_json.map{ |h| (h if h['owner_id']== owner[:id] && h['owner_type'] == owner[:type]) }.compact
	end
#end of geolocation

  def self.merchant_filtered(filter)
    member_filter = (member_id = filter[:member]) ? {merchants: {member_id: member_id}} : {}
    merchant_filter = (merchant_id = filter[:merchant]) ? {merchant_id: merchant_id} : {}
    joins(:merchant).where(merchant_filter).where(member_filter)
  end

  def self.display_only_fields
    path = File.expand_path("../../../config/auth_fields.yml", __FILE__)
    YAML.load_file(path)["auth_fields"][RiskNet.system_type].map {|k, v| {column: k.to_s, mapping: v}}.compact
  end

  def self.display_columns(frontend_columns = [])
    (Authorisation.display_only_fields | frontend_columns).map {|c| c[:column].to_sym}
  end

  def self.filter_by_frauds(filter = nil)
    if filter.present?
      if filter == "0"
        with_frauds.where({frauds: {fraud_status: [false, nil]}})
      else
        with_frauds.where({frauds: {fraud_status: true}})
      end
    else
      where(nil)
    end
  end

  # helper method to remove custom fields which are null
  def as_json(options={})
    super(options).reject { |k, v| k.include?('user_') && v.nil? }
  end

  def self.target_filtered(report_hash)
    target_id = Report.find(report_hash[:report_id]).target_id
    
    case Report.find(report_hash[:report_id]).target_type
      when 'Member'
       where(jpos_member_key: Member.find(target_id).jpos_key)
      when 'Client' 
       where(jpos_client_key: Client.find(target_id).jpos_key) 
      when 'Merchant'
       where(jpos_merchant_key: Merchant.find(target_id).jpos_key)  
      else
       all  
    end   
  end

  def self.arel_search(user, params, meta)
    AuthorisationSearch.new(user, params, meta).query
  end

  def method_missing(m, *args, &block)
    begin
      super
    rescue => e
      # Lets try the agnostic fields before calling super
      agnostic = AgnosticField.find_by(name_from_switch: m)
      if agnostic
        # Great, there is an agnostic field with this name. Let's see if we have a value for it though
        value = self.authorisation_extras.where(agnostic_field_id: agnostic.id).first
        if value
          return value.val_string || value.val_int || value.val_date || value.val_curr
        else
          return ""
        end
      else
        raise e
      end
    end

  end

  def latest_fraud
    self.frauds.last
  end

  def match_merchant_and_build_card 
    puts "\n\n---- 1. In Process of Saving record to DB #{Time.zone.now}"

    find_or_create_user(level)

    @card_no = CardNumber.new(self.card_number)
    self.card_number = @card_no.hashed_value

    self.card =  Card.create_with(mapped_card_params)
      .order(:created_at)
      .find_or_create_by(card_number: @card_no.hashed_value, merchant_id:self.merchant_id,expiration_date: self.expiration_date)

    self.account = Account.create_with(card: self.card,
                                       member_id:self.member_id,
                                       client_id:self.client_id,
                                       merchant_id:self.merchant_id)
                       .order(:created_at)
                       .find_or_create_by(card: self.card)

    # this is just for testing
    self.auth_date ||= Time.zone.now

    puts "---- 2. Enriching tables for an auth completed #{Time.zone.now}"
#		build geolocation add the map the point to the auth field
		self.build_geolocation
		
  end

  def [](key)
    if key == :card_number
      card[:card_number]
    else
      super
    end
  end


  def serializable_hash(opts = nil)
    opts ||= {}
    out = super
    if opts[:rpc]
      out['id'] = ids_hash['id']
    else
      out['id'] = to_param if id[0]
    end

    out
  end

  private

  def quote_col(col)
    self.class.connection.quote_column_name(col)
  end
  alias_method :q, :quote_col

  def escape(value)
    self.class.sanitize(value)
  end

  def exec(sql)
    self.class.connection.execute(sql)
  end

  def level
    case 
    when self.jpos_merchant_key && self.jpos_client_key && self.jpos_member_key
      'merchant'
    when self.jpos_client_key && self.jpos_member_key
      'client'
    when self.jpos_member_key
      'member'
    else
      puts '------ERROR: wrong set jpos keys-------'
    end
  end
  
  def find_or_create_user(user_type)
    open_date = Time.zone.now
    closed_date = Time.zone.now
    internal_code = SecureRandom.uuid
    name = self.send("#{user_type}_name") || "Unregistered #{user_type.capitalize}"

    case user_type
    when 'merchant'
      if _merchant.present? && _merchant.client_jpos_key != self.jpos_client_key
        self.errors.add(:client, message: "Received jpos_client_key: '#{self.jpos_client_key}' with no existing associated hierarchy")
        throw(:abort_save)
      end
      find_or_create_user('client')
      self.merchant = _merchant || Merchant.create(name: name, jpos_key: self.jpos_merchant_key, member_id: self.member.id, client_id: self.client.id, internal_code: internal_code, open_date: open_date, closed_date: closed_date)
    when 'client'
      find_or_create_user('member')
      self.client_id = _client || Client.create(name: name, jpos_key: self.jpos_client_key, member_id: self.member.id, internal_code: internal_code, open_date: open_date, closed_date: closed_date).id
    when 'member'
      self.member_id = _member || Member.create(name: name, jpos_key: self.jpos_member_key, installation_id: Installation.first.id, internal_code: internal_code, open_date: open_date, closed_date: closed_date).id
    end
  end

  # check if level exists or not?
  # def _member; Member.select(:id, :jpos_key).find_by_jpos_key(self.jpos_member_key); end
  def _member; Member.cache[self.jpos_member_key.freeze] || Member.select(:id, :jpos_key).find_by_jpos_key(self.jpos_member_key).try(:id); end
  # def _client; Client.select(:id, :jpos_key).find_by_jpos_key(self.jpos_client_key); end
  def _client; Client.cache[self.jpos_client_key.freeze] || Client.select(:id, :jpos_key).find_by_jpos_key(self.jpos_client_key).try(:id); end

  def _merchant; Merchant.select(:id, :jpos_key, 'clients.jpos_key as client_jpos_key').joins(:client).find_by_jpos_key(self.jpos_merchant_key); end


  def self._authorisation
    @authorisation ||= Authorisation
  end

  def self._auth_column_names
    @auth_column_names ||= Authorisation.column_names
  end

  def mapped_card_params
    base_params = {
      card_number: self.card_number,
      bin: @card_no.bin,
      last_four: @card_no.last_four,
      member_id:self.member_id,
      client_id:self.client_id,
      merchant_id:self.merchant_id,
      expiration_date:self.expiration_date
    }

    case RiskNet.system_type
    when 'issuer_system'
      base_params
    when 'gateway'
      base_params.merge!(
        name_on_card: self.card_name,
        card_class: self.card_class,
        card_type: self.card_type,
        issuer: self.card_issuer,
        issuer_country: self.card_issuer_country
      )
    else
      base_params
    end
  end
end
