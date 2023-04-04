class ClientSerializer < ActiveModel::Serializer
  attributes :id, :name, :address1, :address2, :post_code, :country, :contact, :phone, :fax, :email, :county, :web_address,
             :internal_code, :mcc, :cnp_type, :open_date, :closed_date, :floor_limit, :currency_code, :business_segment,
             :business_type, :parent_flag, :type_of_goods_sold, :jpos_key, :type

  # attributes :id, :name #, :belongs_to_a_member

  # :belongs_to_a_member, :has_many_merchants
  # attributes :has_many_merchants

  def type; 'client'; end

  def belongs_to_a_member
    Member.find_by_id(object.member_id).try(:name)
  end

  def has_many_merchants
    # Client.select("merchants.*").joins(:merchants)
  end
end
