class RuleAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:current_user, :scope)

    def resolve
      if current_user.has_role?(:user, :any)
        scope.none
      else
        case current_user.owner_type
          when 'Installation'
            scope
          when 'Member'
            scope.where("(rules.owner_type = 'Member' AND rules.owner_id = #{current_user.owner_id}) " \
                        "OR (rules.owner_type = 'Client' AND rules.owner_id IN (SELECT DISTINCT clients.id FROM clients WHERE member_id = #{current_user.owner_id})) " \
                        "OR (rules.owner_type = 'Merchant' AND rules.owner_id IN " \
                           "(SELECT DISTINCT merchants.id FROM merchants JOIN clients ON merchants.client_id = clients.id WHERE clients.member_id = #{current_user.owner_id}))")
          when 'Client'
            scope.where("(rules.owner_type = 'Client' AND rules.owner_id = #{current_user.owner_id}) "\
                        "OR (rules.owner_type = 'Merchant' AND rules.owner_id IN (SELECT DISTINCT merchants.id FROM merchants WHERE client_id = #{current_user.owner_id}))")
          when 'Merchant'
            scope.where("(rules.owner_type = 'Merchant' AND rules.owner_id = #{current_user.owner_id})")
        end
      end
    end

  end

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if the user
  # can create any rule. We have some
  # conditional logic here, so an option
  # hash is passed to specify the 
  # the resource that the rule is going
  # to belong to.
  #
  def self.creatable_by?(user=nil)

    # return true if user.has_role?(:god, :any)
    # return false unless opts[:for]
    #
    # owner = opts[:for]
    #
    # roles = [{ name: :rule_manager, resource: owner }]
    #
    # # The rule owner is a client or merchant. We already have our
    # # roles for that, so we now need to add the roles
    # # for the client / member
    # if owner.is_a?(Merchant)
    #
    #   # roles << { name: :rule_manager, resource: owner.client }
    #   # roles << { name: :rule_manager, resource: owner.member }
    #   roles << { name: :rule_manager, resource: :any }
    #
    # elsif owner.is_a?(Client)
    #   roles << { name: :rule_manager, resource: :any }
    # end
    #
    # user.has_any_role?(*roles)
    # #true # DEVELOPERS CANNOT WORK


    # puts "rule...."
    # puts self.session_user.inspect
    # return true if self.session_user.has_role?(:god, :any)
    # self.session_user.has_role?(:rule_manager, :any) # only rule_manager at any level can create rules.

    self.new(self.session_user).creatable_by?
  end

  def creatable_by?(user=nil)
    # RuleAuthorizer.creatable_by?(ur=nil, opts)
    user = self.session_user #TODO Weird logic. Shouldn't the user come as var?
    return true if user.has_role?(:god, :any)
    return true if user.has_role?(:rule_manager, :any)
  end  



  #############
  # UPDATABLE #
  #############

  #
  # Class wide test to see if the
  # user can update any rule. 
  # Only member rule managers and
  # admins are able to update rules.
  # Further checks are performed 
  # on an instance level
  #
  def self.updatable_by?(user)
    return true if user.has_role?(:god, :any)
    user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any })
  end

  #
  # Instance level test to see if
  # the user can update a specific
  # rule. Only admins and rule 
  # managers of a member may update
  # a rule, and only if that rule
  # belongs to the same member as
  # them, or a merchant of that same
  # member. No other rules can be
  # updated
  #
  
  def updatable_by?(user)
    return true if user.has_role?(:god, :any)
    owner = resource.owner

    roles = [{ name: :admin, resource: owner}, { name: :rule_manager, resource: owner }]

    # The rule owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
    if owner.is_a?(Merchant)

      %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner.client} }
      %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner.member} } 

    elsif owner.is_a?(Client) 
      %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner.member} }  
    end

    user.has_any_role?(*roles)
  end

  ############
  # READABLE #
  ############

  #
  # Class wide test to see if the user
  # can view any rule. Rules are only
  # available to everyone (for the
  # Alerts page). Further checks
  # will be performed at an instance
  # level
  #
  def self.readable_by?(user)
    return true if user.has_role?(:god, :any)
    user.has_any_role?({ name: :admin, resource: :any}, { name: :rule_manager, resource: :any })#, { name: :user, resource: :any })
    #true # DEVELOPERS CANNOT WORK
  end


  #
  # Instance level test to see if
  # the user can view a specific
  # rule. Only admins and rule
  # managers may view rules, and
  # only under certain situations:
  #
  # Member users can only view rules
  #   that belong to the same member,
  #   or that members merchants / clients
  #
  # Merchant users can only view rules
  #   that belong to the same merchant
  #
  #
  def readable_by?(user)
    return true if user.has_role?(:god, :any)

    owner = resource.owner

    roles = []
    %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner} }

    if owner.is_a?(Merchant)
     
    # The rule owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
      %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner.client} }
      %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner.member} }
  
    elsif owner.is_a?(Client)
      %w(admin rule_manager).each { |role| roles << {name: role.to_sym, resource: owner.member} }
    end

    user.has_any_role?(*roles)
    # true # DEVELOPERS CANNOT WORK
  end

  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if the user
  # can remove a rule. Rules are only
  # removable by member admins and rule
  # managers. Further checks will be
  # performed at an instance level
  #
  def self.deletable_by?(user)
    return true if user.has_role?(:god, :any)
    user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any })
    #true # DEVELOPERS CANNOT WORK
  end


  #
  # Instance level test to see if the
  # user can remove a specific rule.
  # Rules can only be removed by 
  # rule managers of a member, and
  # only for rules that belong to that
  # member, or the members merchants or clients.
  #

  def deletable_by?(user)
    return true if user.has_role?(:god, :any)

    owner = resource.owner
    return false unless owner

    
    roles = [{ name: :rule_manager, resource: owner }]
    
    # The rule owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
    if owner.is_a?(Merchant)

      roles << { name: :rule_manager, resource: owner.client }
      roles << { name: :rule_manager, resource: owner.member }
    elsif owner.is_a?(Client)
      roles << { name: :rule_manager, resource: owner.member }
    end
    
    user.has_any_role?(*roles)
  end


end
