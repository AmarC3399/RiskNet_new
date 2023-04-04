class CurrencyPair < ApplicationRecord
  validates :transaction_currency_code, :base_currency_code, :conversion_rate, presence: true
  validates :conversion_rate, numericality: { greater_than: 0 }
  validate :currency_iso_exists

  belongs_to :convertible, polymorphic: true 
  
  def currency_iso_exists
    errors.add(:transaction_currency_code, "doesn't exist => #{transaction_currency_code}") unless IsoCountryCodes.try(:find, transaction_currency_code)
    errors.add(:base_currency_code, "doesn't exist => #{base_currency_code}") unless IsoCountryCodes.try(:find, base_currency_code)
  end
end