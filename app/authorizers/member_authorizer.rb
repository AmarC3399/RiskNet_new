class MemberAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:params, :scope)
    include UserHierarchy::GroundRule::Info

    SELECT = [:id, :name, :address1, :address2, :post_code, :country, :contact, :phone, :fax, :email, :county, :web_address,
              :internal_code, :mcc, :cnp_type, :open_date, :closed_date, :floor_limit, :currency_code, :business_segment,
              :business_type, :parent_flag, :type_of_goods_sold, :jpos_key]

    def resources
      scope.none unless MemberAuthorizer.new(user).readable_by?

      case user.owner_type
        when 'Installation'
          if !params[:member].nil? && !params[:client].nil?
            attach_filters(Client.includes(:merchants).where(clients: {member_id: params[:member], id: params[:client]}).first.merchants, 'merchants')
          elsif !params[:member].nil?
            attach_filters(scope.includes(:clients).where(members: {id: params[:member]}).first.clients, 'clients')
          else
            attach_filters(scope, 'members')
          end
      end
    end

    def attach_filters(_scope, search_on )
      _scope.search_customer(search_on, params[:search], :name, :internal_code, :address1)
    end

  end

  #############
  # CREATABLE #
  #############
  def self.creatable_by?(u=nil)
    self.new(self.session_user).creatable_by?
  end

  def creatable_by?(u=nil)
    return true if owner_is_installation?
    return false if owner_type_is_merchant?
    user.has_any_role?(admin)
  end

  #############
  # UPDATABLE #
  #############
  def self.updatable_by?(u=nil)
    self.new(self.session_user).creatable_by?
  end

  def updatable_by?(u=nil)
    creatable_by?
  end

  #############
  # READABLE #
  #############
  def self.readable_by?(u=nil)
    self.new(self.session_user).readable_by?
  end


  def readable_by?(u=nil)
    return true if owner_is_installation?
    return false if owner_type_is_merchant?
    return false unless user.has_any_role?(*admin_rule_and_operator)
    true
  end
end