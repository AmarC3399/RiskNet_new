# Couldn't use ArelRecord because
# ArgumentError: A copy of ArelRecord::Setup has been removed from the module tree but is still active!
module ArelKlass
  extend ActiveSupport::Autoload
  autoload :Setup
  autoload :TableRelation # might not be needed to be autoloaded as some part of it has been inherited in Setup::ArelTable

  # Use of this method is quite simple.
  #     arel.new(User) => will initialise your User.
  def arel
    Setup::ArelTable.new(self.class)
  end
end