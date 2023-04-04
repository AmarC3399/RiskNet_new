class ActivityAuthorizer < ApplicationAuthorizer

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # activity. Users and admins are
  # allowed to do this, but only
  # for alerts they are able to
  # see
  #
  def self.creatable_by?(user, opts = {})
    return true if owner_is_installation?
    alert = opts[:for]
    puts "HELLO #{alert.inspect}"
    return false unless alert && alert.is_a?(Alert)
    
    # Anyone who can read this alert can add an activity for it
    alert.authorizer.readable_by?(user)
  end


  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if any
  # user can delete an activity. This
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
  # Activities cannot be updated
  #
  def self.updatable_by?(user)
    false
  end

  #
  # Instance level test to see if a
  # user can update the specific 
  # activity.
  #
  # Activities cannot be updated
  #
  def updatable_by?(user)
    false
  end


  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY activity. This doesn't
  # grant a user to view an individual
  # activity.
  #
  # Activities are only accessible by 
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
    # This is the same as an alert
    alert = resource.alert
    return false unless alert
    
    alert.authorizer.readable_by?(user)
  end


end