class AlertOverride < ApplicationRecord
  include Filter

  belongs_to :override_card
  belongs_to :override_type
  belongs_to :user
  belongs_to :rule
  belongs_to :owner, polymorphic: true

  validates :start_time,       presence: true
  validates :owner,            presence: true
  # validates :user,             presence: true
  validates :override_type_id, presence: true

  alias_attribute :card, :override_card
  alias_attribute :type, :override_type

  scope :cards,      -> { joins(:override_card) }
  scope :types,      -> { joins(:override_type) }
  scope :rules,      -> { joins(:rule) }
  scope :select_all, -> { select('alert_overrides.*, override_cards.masked_card_number, override_types.name') }
  scope :for_jpos,   -> { select('alert_overrides.*, override_cards.card_number, override_types.name') }

  scope :create_,    ->(card_number){ _override_card_klass.create_card(card_number) }

  before_create :set_active

  # attr_accessor :jpos_key

  def set_active
    self.active = true
  end

  def self.active
    where( " #{self.table_name}.active = 1")
  end

  def self.inactive
    where( " #{self.table_name}.active = 0 ")
  end

  def self.date_range
    where(" #{self.table_name}.end_time > ? or #{self.table_name}.end_time is NULL ", Time.zone.now )
  end

  def self.select_card_and_type(ao)
    ao.card.as_json(except: [:card_number]).merge(ao.type.as_json)
  end

  def self.build_association(args)
    card_num, params, type, user = _assign(args)

     create_(card_num)
    .alert_overrides
    .build(  params
            .merge( _override_type(type) )
            .merge( _owner_(user) ) )
  end

  def self.attach_filter(params, user)

    date_filter(params[:start_date], params[:end_date], :created_at, self.table_name )
        .search(params[:type], :name)
        .search(params[:search], :masked_card_number, :rule_id)
        .filter_by_owner(params[:only_mine] ? params.merge(user: user) : params)
        ._state(params[:state])
        .order(created_at: :desc, id: :desc)
  end

  def self.limit_and_offset(calc_limit, calc_offset)
     limit(calc_limit)
    .offset(calc_offset || 0)
  end

  private

  def self._state(state)
    case state.to_s
    when '0'
      inactive
    when '1'
      active.date_range
    else
      where(nil)
    end
  end

  def self._assign(args)
    return args[:card_number_], args[:alert_override_params_], args[:override_type_], args[:current_user_]
  end

  def self._override_type(type)
    {override_type: _override_type_klass.find_by_name(type.downcase)}
  end

  def self._owner_(u)
    {user: u, owner: u.owner}
  end

  def self._override_card_klass
    OverrideCard
  end

  def self._override_type_klass
    OverrideType
  end

  protected

  def self._encrypted_card(number)
    CardNumber.new(number).hashed_value
  end

  def self._user_id(args)
    User.where( "name #{_like_or_ilike} ? ", "%#{args}%" ).first.id
  end


  def self._like_or_ilike
    @like_or_ilike ||= ActiveRecord::Base.connection.adapter_name=="PostgreSQL" ? 'ILIKE' : 'LIKE'
  end

end