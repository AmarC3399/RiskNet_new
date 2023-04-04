class MemberSerializer < ApplicationSerializer
  attributes :id, :name, :address1, :address2, :post_code, :country, :contact, :phone, :fax, :email, :county, :web_address,
             :internal_code, :mcc, :cnp_type, :open_date, :closed_date, :floor_limit, :currency_code, :business_segment,
             :business_type, :parent_flag, :type_of_goods_sold, :jpos_key, :type


  def type; 'memeber'; end

  def full_address
    if object.address1 && object.address2 && object.post_code && object.country
      "#{object.address1}, #{object.address2}, #{object.post_code}, #{object.country}"
    end
  end

  def address_breakdown
    {
        address1: object.address1,
        address2: object.address2,
        postcode: object.post_code,
        country: object.country
    }
  end

end