class ClientAuthorizer < ApplicationAuthorizer
  
  class Scope < Struct.new(:params, :scope)
    include UserHierarchy::GroundRule::CurrentSession
    include UserHierarchy::GroundRule::Info

    # Only installation, member, client have visibility to resources.
    def resources
      scope.none unless ClientAuthorizer.new(user).readable_by?

      case user.owner_type
        when 'Member'
          if !params[:client].nil?
            attach_filters(scope.includes(:merchants).where(clients: {member_id: user.owner_id, id: params[:client]}).first.merchants, 'merchants')
          else
            attach_filters(scope.where(clients: { member_id: user.owner_id }), 'clients')
          end
      end
    end

    def attach_filters(_scope, reference )
       _scope.search_customer(reference, params[:search], :name, :internal_code, :address1)
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
    # return false unless owner_type_is_member? || owner_type_is_client?
    return false unless user.has_any_role?(*admin_rule_and_operator)
    true
  end
end