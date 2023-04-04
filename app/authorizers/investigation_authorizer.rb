#
# Investigations require the same 
# permissions as an authorisation,
# except that they are created
# manually. This authorizer simply
# extends the authorisation 
# authorized and makes a few changes
#
class InvestigationAuthorizer < AuthorisationAuthorizer

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # authorisation. This is not 
  # allowed for any user
  #
  def self.creatable_by?(user, opts = {})
    auth = opts[:for]
    return false unless auth && auth.is_a?(Authorisation)

    auth.authorizer.readable_by?(user)
  end

end