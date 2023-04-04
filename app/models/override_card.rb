class OverrideCard < ApplicationRecord

  attr_accessor :skip_after_create_callback

  has_many :alert_overrides # has_many :override_types, through: :alert_overrides
  has_many :types, through: :alert_overrides, source: :override_type

  validates :card_number, presence: true

  after_create :_update_card, :unless => :skip_after_create_callback

  scope :create_card, ->(number){ find_or_create_by( card_number: (_card(number).hashed_value rescue number) ) }


  def self.card_exists?(number)
    oc_exists = exists?( card_number: _card(number).hashed_value)
    ao_exists = self.joins(:alert_overrides)
                    .where(card_number: _card.hashed_value)
                    .where( " not alert_overrides.active = 0 ")
                    .where( " alert_overrides.end_time > ?   or alert_overrides.end_time is NULL ", Time.zone.now )
                    .exists?
    true if oc_exists && ao_exists
  end

  def self.check_hashed_card_exists?(auth_id)
    hashed_number = Authorisation.find_by_id( auth_id.split(CompositePrimaryKeys::ID_SEP) ).card_number.to_s.freeze

    self.joins(:alert_overrides)
        .where(card_number: hashed_number)
        .where( " not alert_overrides.active = 0 ")
        .where( " alert_overrides.end_time > ?   or alert_overrides.end_time is NULL ", Time.zone.now )
        .exists?
  end

  # called from alert_override controller
  def hashed_number(auth_id)
    a = Authorisation.find_by_id( auth_id.split(CompositePrimaryKeys::ID_SEP) ).card_number.to_s.freeze
    puts __method__
    puts a
    a
  end


  private

  def self._card(number=nil)
    return @card ||= number if !number.nil? && number.length > 20

    @card = nil unless number.nil?
    @card ||= CardNumber.new(number)
  end

  def _update_card

    hashed = self.class._card.as_json

    if hashed.is_a?(Hash) && hashed.fetch('number').length < 21
      _update_columns(hashed)
    else
      hashed = _find_card
      _update_columns(hashed)
    end

  end

  def _update_columns(hashed)
    puts __method__
    puts hashed.inspect
    self.update_columns( bin: hashed.fetch('bin'), last_four: hashed.fetch('last_four'), masked_card_number: (hashed.fetch('masked_card_number') rescue hashed.fetch('card_number') ) )
  end


  def _find_card
    puts __method__
    puts self.card_number

    Card.find_by_card_number( self.card_number ).as_json
  end
end