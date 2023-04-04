class SuspectListAuthorizer < ApplicationAuthorizer
  



  #############
  # CREATABLE #
  #############


  #
  # Class wide test to see if the user
  # can create a new suspect list. This
  # is only available to users and admins,
  # but they must have permissions to
  # update the parent resource which must
  # also be provided
  #
  def self.creatable_by?(user, opts = {})
    return false unless opts[:for]
    return false unless user.has_any_role?({ name: :admin, resource: :any }, { name: :user, resource: :any })

    owner = nil
    parent = opts[:for]
    return true if parent.is_a?(Card)
    
    # It is a suspect list for a merchant. 
    # Only member users can do this
    merchant = parent

    roles = [{ name: :admin, resource: merchant.member }, { name: :user, resource: merchant.member }]

    user.has_any_role?(*roles)
  end


  #############
  # UPDATABLE #
  #############


  def self.updatable_by?(user)
    false
  end

  def updatable_by(user)
    false
  end


  #############
  # DELETABLE #
  #############

  def self.deletable_by?(user)
    false
  end

  def deletable_by?(user)
    false
  end


  ############
  # READABLE #
  ############

  def self.readable_by?(user)
    false
  end

  def readable_by?(user)
    false
  end

end