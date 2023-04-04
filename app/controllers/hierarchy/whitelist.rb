# If you need to test this in console, type the command below.

class Hierarchy::Whitelist
  cattr_reader :instance

  protected
  def dictionary
    {
      :create_definitions      => %w(INSTALLATION_CAN_CREATE MEMBER_CAN_CREATE CLIENT_CAN_CREATE),
      :front_end_entities_type => %w(installation client merchant submerchant),
      :hierarchy_level         => %w(installation member client merchant),
      :installation_can_create => %w(member client merchant),
      :member_can_create       => %w(client merchant),
      :client_can_create       => %w(merchant),
      :admin                   => 'admin',
      :rule_manager            => 'rule_manager',
      :user                    => 'user',
      :installation            => 'installation',
      :member                  => 'member',
      :client                  => 'client',
      :merchant                => 'merchant'
    }
  end

  public
  def initialize
    dictionary.each { |name, block| create_method(name) { block } }
  end

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  @@instance = Hierarchy::Whitelist.new

  def convert_to_backend(entity)
    case entity.downcase
      when 'client'
        'member'
      when 'merchant'
        'client'
      when 'submerchant'
        'merchant'
      else
        raise 'User Hierarchy Not Found'
    end
  end

  private_class_method :new
end
