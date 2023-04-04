class CardSerializer < ApplicationSerializer
  attributes :id, :name_on_card, :card_number, :expiration_date, :card_type, :card_class, :issuer, :issuer_country
end