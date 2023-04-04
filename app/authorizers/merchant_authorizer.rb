class MerchantAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:params, :scope)
    include UserHierarchy::GroundRule::Info

    def resolve
      case user.owner_type
        when 'Client'
          attach_filters(scope.joins(' inner join clients on clients.id = merchants.client_id and clients.member_id = merchants.member_id '), 'merchants')#.where(clients: { id: user.owner_id, member_id: 1 })
      end
    end

    def attach_filters(_scope, reference )
      _scope.search_customer(reference, params[:search], :name, :internal_code, :address1)
            .where(clients: { id: user.owner_id, member_id: user.owner.member_id })
    end

  end


  #
  # Class wide checks to see if
  # a user can create, delete,
  # or update ANY merchant. By
  # default, this is not possible,
  # so they all simply return false
  #
  def self.creatable_by?(user)
    return true if owner_is_installation?
    user.has_role?(:admin, :any) && user.owner_type != 'Merchant'
  end

  def creatable_by?(u=nil)
    return true if owner_is_installation?
    user.has_any_role?(admin)
  end

  def self.deletable_by?(user)
    false
  end

  def self.updatable_by?(user)
    return true if owner_is_installation?
    user.has_role?(:admin, :any) && user.owner_type != 'Merchant'
  end

  def updatable_by?(user)
    return true if owner_is_installation?
    if user.owner_type == 'Installation'
      true
    elsif user.owner_type == 'Member' && user.has_role?(:admin, resource.member)
      true
    elsif user.owner_type == 'Client' && user.has_role?(:admin, resource.client)
      true
    end    
  end



  ############
  # READABLE #
  ############


  #
  # Instance level test to see if a
  # user can read the specific merchant.
  #
  # A single merchant is only visible 
  # to users who are administrators for
  # a member. Thos administrators must
  # also belong to the same member that
  # the merchant does
  #  
  def readable_by?(user)
    return true if owner_is_installation?
    merchant = resource

    roles = [{name: :admin, resource: merchant.member.installation}]

    %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: merchant.member} }
    %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: merchant.client} }
    %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: merchant} }

    user.has_any_role?(*roles)
  end

  #
  # Class wide test to see if a user
  # can read ANY merchant. This doesn't
  # grant a user to view an individual
  # merchant.
  #
  # Merchants are only accessible by 
  # member administrators.
  #


  #
  # Viewing merchants is allowed for anyone.
  # Further restrictions will be applied later
  #
  def self.readable_by?(user)
    # user.has_any_role?({ name: :admin, resource: :any}, { name: :rule_manager, resource: :any }) && user.owner_type == 'Member'
    true
  end

end