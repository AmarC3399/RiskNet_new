class AuthorisationAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:current_user, :scope)

    def resolve
      # NOTE: Rule manager can now see authorisation. Plus R.M. can also view alerts and associated analysis i.e. auth, vio.
      
      # if current_user.has_role?(:rule_manager, :any)
      #   # Nope
      #   scope.none
      # else
        # Yup, but different ones per user type
        # if current_user.owner_type == 'Member'
        #   scope.joins(:merchant).where("merchants.member_id = ?", current_user.owner.id)
        # elsif current_user.owner_type == 'Merchant'
        #   scope.where(merchant_id: current_user.owner_id)
        # else
        #   scope
        # end

        case current_user.owner_type
          when 'Installation'
            scope
          when 'Member'
            scope.joins(:member).where('authorisations.member_id = ?', current_user.owner.id)
          when 'Client'
            scope.joins(:client).where('authorisations.client_id = ?', current_user.owner.id)
          when 'Merchant'
            scope.joins(:merchant).where('authorisations.merchant_id = ?', current_user.owner_id)
        end
      # end
    end

    def where_clause
      resolve.where_values.reduce(:and)
    end
  end

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # authorisation. This is not
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
  # user can delete an authorisation.
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
  # can update any authorisation.
  #
  # Authorisations cannot be updated
  #
  def self.updatable_by?(user)
    return true if owner_is_installation?
    user.has_any_role?({ name: :admin, resource: :any })
  end

  #
  # Instance level test to see if a
  # user can update the specific
  # authorisation.
  #
  # Authorisations cannot be updated
  #
  def updatable_by?(user)
    AuthorisationAuthorizer.updatable_by?(user)
  end


  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY authorisation.
  #
  # Authorisations are only accessible by
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
  # A single authorisation is only
  # visible to users and admins. A
  # merchant user can only see
  # authorisations for that merchant.
  # A member user can see authorisations
  # for any of their members
  #
  def readable_by?(user)
    return true if owner_is_installation?
    return false unless user.has_any_role?({ name: :admin, resource: :any }, { name: :rule_manager, resource: :any }, { name: :user, resource: :any })

    # merchant = Merchant.includes(:member).find(resource.merchant_id)
    # roles = [{ name: :admin, resource: merchant }]
    # roles << { name: :user, resource: merchant }
    #
    # roles << { name: :admin, resource: merchant.member }
    # roles << { name: :user, resource: merchant.member }
    #
    # user.has_any_role?(*roles)
    true
  end

end
