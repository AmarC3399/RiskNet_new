class ViolationAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:current_user, :scope, :params)

    # include ApplicationController.helpers.system_type_helper
    include SystemTypeHelper

    def resolve
      # NOTE: Rule manager can now see authorisation. Plus R.M. can also view alerts and associated analysis i.e. auth, vio.

      # if current_user.has_role?(:rule_manager, :any)
      #   scope.none
      # else
        scope.where('alert_id = ?', params[:alert_id].to_i)
      # end
    end

    def parent(_objects, entities)
      system_objects = _objects.where("violatable_type IN (?)", entities).as_json#.as_json(methods: :system_rule)
      non_system_objects = _objects.where("violatable_type IN (?)", owner_rule(entities)).as_json#.as_json(methods: :system_rule)

      system_objects.map! do |r|
        r['internal_code'] = 'SYSTEM VIOLATION'
        r['description'] = 'SYSTEM VIOLATION'
        r
      end

      [system_objects, non_system_objects].flatten
    end
  end


  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # violation. This is forbidden by
  # all users, as violations are 
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
  # can update ANY violation. This doesn't
  # grant the user to update an 
  # individual violation.
  #
  # Violations are not updatable
  #
  def self.updatable_by?(user)
    false
  end

  #
  # Instance level test to see if a
  # user can update the specific violation.
  #
  # Violations are not updatable
  #
  def updatable_by?(user)
    false
  end


  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY violation. This doesn't
  # grant a user to view an individual
  # violation.
  #
  # Violations have the same permissions
  # as alerts. This will simply call the
  # alert authorizer. If however the user
  # is trying to access violations for a
  # merchant, we must check if they have
  # different permissions.
  #
  def self.readable_by?(user, opts = {})
    return true if owner_is_installation?
    parent = opts[:for]
    if parent
      if parent.is_a?(Card)
        AlertAuthorizer.readable_by?(user)
      elsif parent.is_a?(Merchant)
        roles = [{ name: :admin, resource: parent.member }]
        roles << { name: :user, resource: parent.member }

        user.has_any_role?(*roles)
      else
        false
      end
    else
      AlertAuthorizer.readable_by?(user)
    end
  end

  #
  # Instance level test to see if a
  # user can read the specific violation.
  #
  # Violations have the same permissions
  # as alerts. This will simply call the
  # alert authorizer
  #
  def readable_by?(user)
    return true if owner_is_installation?
    alert = resource.alert
    return false unless alert

    alert.authorizer.readable_by?(user)
  end

end