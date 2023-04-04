#
# Reminders require the same permissions
# as alerts apart from the creation of 
# them.
#
class ReminderAuthorizer < AlertAuthorizer
  include UserHierarchy::GroundRule::CurrentSession
  include UserHierarchy::GroundRule::Info

  #
  # Class level test to see if a 
  # user can create a new reminder.
  # A parent alert must be specified
  # otherwise it is forbidden
  #
  def self.creatable_by?(user=nil || self.session_user)
    return true if owner_is_installation?
    user.has_any_role?(*admin_and_operator)
  end

  def creatable_by?(u=nil)
    return true if owner_is_installation?
    user.has_any_role?(*admin_and_operator)
  end

  def readable_by?(user)
    # return false unless resource.alert

    # merchant = resource.alert.merchant

    # roles = [{ name: :admin, resource: user.owner }]
    # roles << { name: :user, resource: user.owner }
    #
    # roles << { name: :admin, resource: user.owner }
    # roles << { name: :user, resource: user.owner }

    return true if owner_is_installation?
    user.has_any_role?(*admin_and_operator)
  end

  def updatable_by?(u=nil)
    return true if owner_is_installation?
    user.has_any_role?(*admin_and_operator)
  end

end