
#require 'user_hierarchy/ground_rule'

# Other authorizers should subclass this one
class ApplicationAuthorizer < Authorisation::Authorizer
  extend UserHierarchy::GroundRule::CurrentSession
  include UserHierarchy::GroundRule
  include UserHierarchy::GroundRule::Info

  # Any class method from Authority::Authorizer that isn't overridden
  # will call its authorizer's default method.
  #
  # @param [Symbol] adjective; example: `:creatable`
  # @param [Object] user - whatever represents the current user in your app
  # @return [Boolean]
  def self.default(adjective, user)
    # 'Whitelist' strategy for security: anything not explicitly allowed is
    # considered forbidden.
    false
  end
end
