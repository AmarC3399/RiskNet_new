class AlertSerializer < ApplicationSerializer
  self.root = false

  attributes :id, :alert_type, :subject, :response, :run_date, :priority, :examined_on, :created_at, :updated_at,
             :allocated_on, :examined, :customer_merchant_name, :user_id, :being_examined, :merchant_id,
             :reminder_unactioned, :reminder, :original_id, :alert_owner_id, :alert_owner_url, :merchant, :rules

  # has_one :merchant
  # has_one :reminder
  # has_many :rules
  has_one :card


  def merchant; find_merchant(object.alert_owner_type, object.alert_owner_id); end

  # merchant is a loosely used term here. It could actually either be member, client or merchant.
  def find_merchant(model, id)
    model.constantize.find(id) if object.alert_owner_type == model
  end


  # TODO: Moved them to single responsibility class. START
  def rules
     _rules = object.rules.rewhere(owner_id: nil, owner_type: nil)

     return proxy_rules(_rules) unless  _rules.blank? # proxy_rules

    _rules = object.rules.rewhere(deleted: [true,false])

    return _rules if current_user.owner.is_a?(Installation)

    return _member(_rules) if current_user.owner.is_a?(Member)

    return _client(_rules) if current_user.owner.is_a?(Client)

    _merchant(_rules) if current_user.owner.is_a?(Merchant)
  end

  def _installation(_rules)
    _rules
  end

  def _member(_rules)
    parent_rules(_rules, INSTALLATION_IS_SR)
  end

  def _client(_rules)
    parent_rules(_rules, INSTALLATION_MEMBER_ARE_SR)
  end

  def _merchant(_rules)
    parent_rules(_rules, INSTALLATION_MEMBER_CLIENT_ARE_SR)
  end

  def parent_rules(_rules, entities)
    system_rules     = _rules.where("owner_type IN (?)", entities).as_json#.as_json(methods: :system_rule)
    non_system_rules = _rules.where("owner_type IN (?)", owner_rule(entities)).as_json#.as_json(methods: :system_rule)

    system_rules.map! do |r|
      if !r['visible']
        r['internal_code'] = 'SYSTEM RULES'
        r['description'] = 'SYSTEM RULES'
      end
      r
    end

    [system_rules, non_system_rules].flatten
  end

  def owner_rule(entities)
    hierarchy_level = %w(Installation Member Client Merchant)
    hierarchy_level - entities
  end

  def proxy_rules(_rules)
    card_number = object.card.card_number

    scope = AlertOverride.cards.where("override_cards.masked_card_number = ? ", card_number).first.owner_type

    _rules.each do |r|
      r[:priority] = 100
      r[:owner_type] = scope
    end
    _rules
  end

  # TODO: Moved them to single responsibility class. END

  # ############################ #
  # START : Polymorphic associations #
  # ############################ #
  def alert_owner?(model)
    object.alert_owner.class.name == model
  end
  #
  # dynamically creating associations
  # Add to the array when / if other associations are needed
  #
  # ['Card'].each do |model|
  #   downcased = model.downcase
  #
  #   has_one downcased.underscore.to_sym
  #
  #   define_method downcased do
  #     object.alert_owner if alert_owner?(model)
  #   end
  #
  #   define_method "include_#{downcased}?" do
  #     alert_owner?(model)
  #   end
  # end
  # ######################### #
  # END Polymorphic associations #
  # ######################### #


  private

    # ######################### #
    # ATTRIBUTES CUSTOMISATIONS #
    # ######################### #

    def id
      object.to_param
    end

    def original_id
      object.ids_hash['id']
    end

    def alert_owner_url
      object.alert_owner_type.downcase.pluralize
    end

    # def violations
    #   object.violations.each do |v|
    #     v.delete() if v.rule.blank?
    #   end
    # end

    def reminder
      if @options[:action] == :index
        if object.try(:reminder_id)
          { id: object.reminder_id,
            reason: ListItem.find_by_id(object.reason).frontend_name,
            reminder_time: object.reminder_time,
            expired: object.expired,
            cleared: object.cleared
          }
        end
      else
        object.reminder
      end
    end

                   INSTALLATION_IS_SR = %w(Installation) # Applicable to Member
           INSTALLATION_MEMBER_ARE_SR = %w(Installation Member) # Applicable to Client
    INSTALLATION_MEMBER_CLIENT_ARE_SR = %w(Installation Member Client) # Applicable to Merchant
end
