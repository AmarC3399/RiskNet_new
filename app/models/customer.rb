# == Schema Information
#
# Table name: customers
#
#  id                :integer          not null, primary key
#  first_name        :string(255)
#  last_name         :string(255)
#  full_name         :string(255)
#  address1          :string(255)
#  address2          :string(255)
#  post_code         :string(255)
#  telephone         :string(255)
#  country           :string(255)
#  member_id         :integer
#  merchant_id       :integer
#  created_at        :timestamp        not null
#  updated_at        :timestamp        not null
#  client_id         :integer
#  customerable_id   :integer
#  customerable_type :string(255)
#

class Customer < ApplicationRecord

  has_many :cards
	has_many :alerts, as: :alert_owner

  belongs_to :member
  belongs_to :client
	belongs_to :merchant

  acts_as_commentable primary_key: :id

  # CONTACT  = %w(name address1 address2 post_code country contact phone fax email county web_address)
  #
  # BUSINESS = %w(internal_code mcc cnp_type open_date closed_date floor_limit currency_code business_segment
  #               business_type parent_flag type_of_goods_sold jpos_key )

  # attr_accessor :customer

  def build_json(customers)

    # TODO: Build hash dynamically. Might not pursue it as this has one to many loops causing performance issue.
    # TODO: 23+20 = 43 loops, which can be avoided by just doing 20 loops.
    # contact, business = default_hash, default_hash
    # pretty_hash = []
    #
    # customers.as_json.collect do |customer|
    #   self.customer = customer
    #   CONTACT.each {|c| contact[c]}
    #   BUSINESS.each {|b| business[b]}
    #   pretty_hash << { contact: contact, business: business }
    # end

    # pretty_hash

    pretty_hash = []

    customers.each do |customer|
      contact = {
                  name: customer.name,
                  address1: customer.address1,
                  address2: customer.address2,
                  post_code: customer.post_code,
                  country: customer.country,
                  contact: customer.contact,
                  phone: customer.phone,
                  fax: customer.fax,
                  email: customer.email,
                  county: customer.county,
                  web_address: customer.web_address
      }

      business = {
                  internal_code: customer.internal_code,
                  mcc: customer.mcc,
                  cnp_type: customer.cnp_type,
                  open_date: customer.open_date,
                  closed_date: customer.closed_date,
                  floor_limit: customer.floor_limit,
                  currency_code: customer.currency_code,
                  business_segment: customer.business_segment,
                  business_type: customer.business_type,
                  parent_flag: customer.parent_flag,
                  type_of_goods_sold: customer.type_of_goods_sold,
                  jpos_key: customer.jpos_key
      }

      if customer.try(:member_id) && customer.try(:client_id)
        type = 'merchant'
      elsif customer.try(:member_id)
        type = 'client'
      elsif customer.try(:installation_id)
        type = 'member'
      end

      pretty_hash << { id: customer.id, contact: contact, business: business, type: type}
    end

    pretty_hash
  end

  def default_hash
    Hash.new { |hash, key| hash[key] = self.customer[key]}
  end
end
