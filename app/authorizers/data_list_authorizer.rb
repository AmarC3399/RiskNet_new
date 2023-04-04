class DataListAuthorizer < ApplicationAuthorizer

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # data list. This is not 
  # allowed for any user
  #
  def self.creatable_by?
    user = self.session_user
    
    return true if user.has_role?(:god, :any)
    return true if user.has_any_role?({ name: :admin, resource: :any })
    return true if user.has_any_role?({ name: :rule_manager, resource: :any }) 
    # DataListAuthorizer.readable_by?(user)

    false
  end

  def creatable_by?(user)
     
     return true if user.has_role?(:god, :any)
     return true if user.has_any_role?({ name: :admin, resource: :any })
     return true if user.has_any_role?({ name: :rule_manager, resource: :any }) && is_operation_list?(resource)

     false
  end


  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if any
  # user can delete a data list. 
  # This is forbidden by all users.
  #
  def self.deletable_by?
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
  # can update any data list.
  #
  # Only admin and rule managers 
  # are able to update data lists.
  # Further checks are performed 
  # on an instance level
  #
  def self.updatable_by?
    user = self.session_user
    DataListAuthorizer.creatable_by?
  end

  #
  # Instance level test to see if a
  # user can update the specific 
  # data list.
  #
  # Only admins and rule 
  # managers of a member may update
  # a rule, and only if that rule
  # belongs to the same member as
  # them, or a merchant of that same
  # member. No other rules can be
  # updated
  #
  def updatable_by?(user)
    owner = resource.owner
    return true  if user.has_role?(:god, :any)
    return false if is_config_list?(resource)

    roles = [{ name: :admin, resource: owner }]
    roles << { name: :rule_manager, resource: owner } if is_operation_list?(resource)



    # The list owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
    if owner.is_a?(Merchant)

      roles << { name: :admin, resource: owner.client }
      roles << { name: :rule_manager, resource: owner.client } if is_operation_list?(resource)

      roles << { name: :admin, resource: owner.member }
      roles << { name: :rule_manager, resource: owner.member } if is_operation_list?(resource)
      
    elsif owner.is_a?(Client)  
      roles << { name: :admin, resource: owner.member } 
      roles << { name: :rule_manager, resource: owner.member } if is_operation_list?(resource)
    end

    return true if user.has_any_role?(*roles)

    false
  end
  

  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY data list.
  #
  # Data lists are accessible by 
  # any admin or rule manager. Only
  # standard users cannot access them.
  #
  def self.readable_by?
    user = self.session_user
    return true if user.has_role?(:god, :any)
    
    user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any })
  end

  #
  # Instance level test to see if a
  # user can read the specific data list.
  #
  # Data lists are accessible by
  # any admin or rule manager. Only
  # standard users cannot acces them.
  #
  def readable_by?(user)
    return true if user.has_role?(:god, :any)
    return true if is_reporting_list?(resource)
    return true if is_config_list?(resource) && user.has_role?(:admin, :any)

    owner = resource.owner
    roles = [{ name: :admin, resource: owner }]
    roles << { name: :rule_manager, resource: owner } if is_operation_list?(resource)

    # The list owner is a client or merchant. We already have our
    # roles for that, so we now need to add the roles
    # for the client / member
    if owner.is_a?(Merchant)

      roles << { name: :admin, resource: owner.client }
      roles << { name: :rule_manager, resource: owner.client } if is_operation_list?(resource)

      roles << { name: :admin, resource: owner.member }
      roles << { name: :rule_manager, resource: owner.member } if is_operation_list?(resource)
      
    elsif owner.is_a?(Client)  
      roles << { name: :admin, resource: owner.member } 
      roles << { name: :rule_manager, resource: owner.member} if is_operation_list?(resource)
    end

    return true if user.has_any_role?(*roles)

    false
  end

  private 

  def is_reporting_list?(resource)
      return true if ['Rule Efficiency', 'Fraud Activity', 'Operational Merchant', 'Operational User'].include?(resource.name) 

      false
  end  

  def is_config_list?(resource)
      return true if ['Actions', 'Fraud Activity', 'Reminders', 'Rule Category'].include?(resource.name) 

      false
  end    

  def is_operation_list?(resource)
    # If a new list is being created - ensure rule managers can access 
    # only field_lists in the dropdown, and check here is not required
    return true if resource.field_lists.empty?

    resource.field_lists.first.model_type != 'CustomList' ? true : false
  end  

end