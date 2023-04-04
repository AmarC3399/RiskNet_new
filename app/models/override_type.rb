class OverrideType < ApplicationRecord
  has_many :alert_overrides # has_many :override_cards, through: :alert_overrides
  has_many :cards, through: :alert_overrides, source: :override_card

  validates :name, presence: true
end
