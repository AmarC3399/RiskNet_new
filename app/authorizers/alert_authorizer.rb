class AlertAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:scope)
    include UserHierarchy::GroundRule::CurrentSession
    include UserHierarchy::GroundRule::Info
  
    def resolve
      case user.owner_type
      when 'Installation'
          i = InstallationRelatedQuery.new(scope, user)
          installation(i)
        when 'Member'
          m = MemberRelatedQuery.new(scope, user)
          member(m)
        when 'Client'
          c = ClientRelatedQuery.new(scope, user)
          client(c)
        when 'Merchant'
          m = MerchantRelatedQuery.new(scope, user)
          merchant(m)
        else
          scope.none
      end
    end


    def installation(i)
     i.member_qry.union(i.client_qry).union(i.merchant_qry)
    end

    def member(m)
      m.member_qry.union(m.client_qry).union(m.merchant_qry) if user.has_any_role?(*admin_rule_and_operator) #TODO investigate .union for performance reasons
    end

    def client(c)
      c.client_qry.union(c.merchant_qry) if user.has_any_role?(*admin_rule_and_operator) #TODO investigate .union for performance reasons
    end

    def merchant(m)
      m.merchant_qry if user.has_any_role?(*admin_rule_and_operator)
    end
  end

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # alert. This is forbidden by
  # all users, as alerts are 
  # automatically created
  #
  def self.creatable_by?(user)
    false
  end


  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if any
  # user can delete an alert. This
  # is forbidden by all users.
  #
  def self.deletable_by?(user)
    false
  end
   
  def deletable_by?(user)
    false
  end

  #############
  # UPDATABLE #
  #############

  #
  # Class wide test to see if a user
  # can update ANY alert. This doesn't
  # grant the user to update an 
  # individual alert.
  #
  # Alerts are only updatable by 
  # standard users, and by admins.
  # They are not updatable by rule
  # managers
  #
  def self.updatable_by?(user)
    AlertAuthorizer.readable_by?(user)
  end

  #
  # Instance level test to see if a
  # user can update the specific alert.
  #
  # A single alert is only updatable
  # to users who either belong to the
  # same merchant that the alert belongs
  # to, or to the PSP that the merchant
  # belongs to. They must also not be a
  # rule manager
  #
  def updatable_by?(user)
    readable_by?(user)
  end


  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY alert. This doesn't
  # grant a user to view an individual
  # alert.
  #
  # Alerts are only accessible by 
  # standard users, and by admins.
  # They are not accessible to rule
  # managers
  #
  def self.readable_by?(user)
    return true if owner_is_installation?
    user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any }, { name: :user, resource: :any })
  end

  #
  # Instance level test to see if a
  # user can read the specific alert.
  #
  # A single alert is only visible 
  # to users who either belong to the
  # same merchant that the alert belongs
  # to, or to the PSP that the merchant
  # belongs to. They must also not be
  # a rule manager
  #
  def readable_by?(user)
    return true if owner_is_installation?
    return false unless user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any }, { name: :user, resource: :any })

    # NOTE: The below code only takes into account of merchant. Alerts can be read by everyone. TODO: check properly as this is being referenced by Journal,
    # merchant = Merchant.includes(:member).find(resource.merchant_id)

    # roles = [{ name: :admin, resource: merchant }]
    # roles << { name: :user, resource: merchant }
    #
    # roles << { name: :admin, resource: merchant.member }
    # roles << { name: :user, resource: merchant.member }

    # user.has_any_role?(*roles)
    true
  end

end