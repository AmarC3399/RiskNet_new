class FieldListAuthorizer < ApplicationAuthorizer

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # field list. This is not 
  # allowed for any user
  #
  def self.creatable_by?(user)
    false
  end


  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if any
  # user can delete a field list. 
  # This is forbidden by all users.
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
  # can update any field list.
  #
  # Field lists cannot be updated
  #
  def self.updatable_by?(user)
    false
  end

  #
  # Instance level test to see if a
  # user can update the specific 
  # field list.
  #
  # Field lists cannot be updated
  #
  def updatable_by?(user)
    false
  end


  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY field list.
  #
  # Field lists are accessible by 
  # any admin or rule manager. Only
  # standard users cannot acces them.
  #
  def self.readable_by?(user)
    return true if user.has_role?(:god, :any)
    user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any })
  end

  #
  # Instance level test to see if a
  # user can read the specific field list.
  #
  # Field lists are accessible by
  # any admin or rule manager. Only
  # standard users cannot acces them.
  #
  def readable_by?(user)
    FieldListAuthorizer.readable_by?(user)
  end

end