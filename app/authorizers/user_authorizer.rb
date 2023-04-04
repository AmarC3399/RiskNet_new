class UserAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:current_user, :scope)

    def resolve(report_users=false)
      if !report_users && !current_user.has_any_role?({ name: :admin, resource: :any }, { name: :god, resource: :any })
        scope.none
      else
        case current_user.owner_type
          # All owned levels down, or owner level up.
          when 'Installation'
            scope.all
          when 'Member'
            scope.where("(users.owner_type = 'Member' AND users.owner_id = #{current_user.owner_id} " \
                        "OR (users.owner_type = 'Client' AND users.owner_id IN (SELECT DISTINCT clients.id FROM clients WHERE member_id = #{current_user.owner_id})) " \
                        "OR (users.owner_type = 'Merchant' AND users.owner_id IN " \
                          "(SELECT DISTINCT merchants.id FROM merchants JOIN clients ON merchants.client_id = clients.id WHERE clients.member_id = #{current_user.owner_id})))")
          when 'Client'
            scope.where("(users.owner_type = 'Client' AND users.owner_id = #{current_user.owner_id}) " \
                        "OR (users.owner_type = 'Merchant' AND users.owner_id IN (SELECT DISTINCT merchants.id FROM merchants WHERE client_id = #{current_user.owner_id}))")
          when 'Merchant'
            scope.where("(users.owner_type = 'Merchant' AND users.owner_id = #{current_user.owner_id}) ")
        end


      end
    end

  end

  class ForwardingScope < Struct.new(:current_user, :scope)

    def resolve
      # merchant = Merchant.where(id: merchant_id).first
      return scope.none unless current_user.has_any_role?({ name: :god, resource: Installation.first}, { name: :admin, resource: :any }, { name: :user, resource: :any })

      # roles = current_user.has_role?(:admin, :any) ? [:admin, :user] : [:user]
      case current_user.owner_type
        when 'Installation'
          scope.where("owner_type='Installation' and users.id != #{current_user.id}")
        when 'Member'
          patronage_query(Member.find_by_id(current_user.owner_id).installation)
        when 'Client'
          patronage_query(Client.find_by_id(current_user.owner_id).member)
        when 'Merchant'
          patronage_query(Merchant.find_by_id(current_user.owner_id).client)
        else
          scope.none
      end
    end

    def patronage_query(entity)
      roles = [:admin, :user]

      scope.where('(users.owner_id = ? and users.owner_type = ?) OR (users.owner_id = ? and users.owner_type = ?)', current_user.owner_id, current_user.owner_type, entity.id, entity.class.name)
           .where('users.id != ?', current_user.id)
           .where('users.enabled = ?', true)
           .joins(:roles)
               .where('(roles.name in (?) and roles.resource_type = ?) OR (roles.name = ? and roles.resource_type = ?)', roles, current_user.owner_type, 'admin', entity.class.name)
    end

  end

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if the user
  # is allowed to create any user. Only
  # administrators are able to create
  # users, but only for the member or
  # merchant they are a user of.
  #
  def self.creatable_by?(user, opts = {})
    # We must have the parent resource supplied
    return true if user.has_role?(:god, :any)

    return false unless opts[:for]



    # Now the user must have admin rights for that resource
    owner = opts[:for]

    roles = [{ name: :admin, resource: owner }]

    # The rule owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
    if owner.is_a?(Merchant)

      roles << { name: :admin, resource: owner.client }
      roles << { name: :admin, resource: owner.member }
      
    elsif owner.is_a?(Client)  
      roles << { name: :admin, resource: owner.member } 
    end

    user.has_any_role?(*roles)
    #true # DEVELOPERS CANNOT WORK
  end

  def creatable_by?(user, opts = {})
    UserAuthorizer.creatable_by?(user, opts)
  end   

  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if the user
  # is allowed to delete any user. Only
  # administrators have this privilege.
  # Further checks will be performed
  # at the instance level
  #
  def self.deletable_by?(user)
    user.has_role?(:admin, :any)
    #true # DEVELOPERS CANNOT WORK
  end

  #
  # Instance level check to see if the
  # user is able to delete the specified
  # user. Only administrators are able
  # to delete users in their own member
  # or merchant.
  #
  def deletable_by?(user)
    # This method could be removed in future
    return true if user.has_role?(:god, :any)
    return false unless user.has_role?(:admin, :any)

    owner = resource.owner
    return false unless owner

    # Must be an admin or rule manager of the rule owner
    # regardless of that rule owner type
    roles = [{ name: :admin, resource: owner }]

    if owner.is_a?(Merchant)
      # The rule owner is a merchant. We already have our
      # roles for that, so we now need to add the roles
      # for the member
      roles << { name: :admin, resource: owner.member }
    end

    user.has_any_role?(*roles)
   # true # DEVELOPERS CANNOT WORK
  end


  #############
  # UPDATABLE #
  #############


  #
  # Class wide test to see if the user
  # is able to update any other user.
  # Only administrators have this
  # privilege. Further checks will be
  # performed at an instance level
  #
  def self.updatable_by?(user)
    return true if user.has_role?(:god, :any)
    user.has_role?(:admin, :any)
    #true # DEVELOPERS CANNOT WORK
  end

  #
  # Instance level test to see if the
  # users has permission to update the
  # specified user. Only administrators
  # are able to update users in their
  # own member or merchant
  #
  def updatable_by?(user)
    return true if user.has_role?(:god, :any)
    return false unless user.has_role?(:admin, :any)

    owner = resource.owner
    return false unless owner

    # Must be an admin or rule manager of the rule owner
    # regardless of that rule owner type
    roles = [{ name: :admin, resource: owner }]

    if owner.is_a?(Merchant)
      # The rule owner is a client or merchant. We already have our
      # roles for that, so we now need to add the roles
      # for the client / member
      roles << { name: :admin, resource: owner.client }
      roles << { name: :admin, resource: owner.member }
    elsif owner.is_a?(Client) 
      roles << { name: :admin, resource: owner.member } 
    end

    user.has_any_role?(*roles)
    #true # DEVELOPERS CANNOT WORK
  end



  ############
  # READABLE #
  ############


  #
  # Class wide test to see if the user
  # is able to view others users. All
  # users except for rule managers are
  # able to do this. Further checks
  # will be performed at an instance
  # level
  #
  def self.readable_by?(user)
    return true if user.has_role?(:god, :any)
    return false unless user.has_role?(:admin, :any)


    owner = user.owner
    return false unless owner

    # Must be an admin
    roles = [{ name: :admin, resource: owner }]

    if owner.is_a?(Merchant)
      # The rule owner is a client or merchant. We already have our
      # roles for that, so we now need to add the roles
      # for the member
      roles << { name: :admin, resource: owner.client }
      roles << { name: :admin, resource: owner.member }
    elsif owner.is_a?(Client) 
      roles << { name: :admin, resource: owner.member }
    end

    user.has_any_role?(*roles)
    #true # DEVELOPERS CANNOT WORK
  end

  #
  # Instance level check to see if the
  # user is able to view the specified
  # user. Standard users and admins
  # are able to view other users.
  # Merchant users are unable to view
  # member users, but member users are
  # able to view merchant users, but only
  # merchants that belong to that member
  #
  def readable_by?(user)
    UserAuthorizer.readable_by?(user)
    #true # DEVELOPERS CANNOT WORK
  end

  def self.filterable_by?(user)
    owner = user.owner

    return true if user.has_role?(:god, :any)

    roles = []
    %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: owner} }

    if owner.is_a?(Merchant)
     
    # The rule owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
      %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: owner.client} }
      %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: owner.member} }
  
    elsif owner.is_a?(Client)
      %w(admin rule_manager user).each { |role| roles << {name: role.to_sym, resource: owner.member} }
    end

    user.has_any_role?(*roles)
  end  

  

  def filterable_by?(user)
    UserAuthorizer.filterable_by?(user)
  end

  def self.skippable_by?(user)
    true
  end

  # def skippable_by?
  #   true
  # end
end
