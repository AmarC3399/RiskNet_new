class EnrichmentResult < ApplicationRecord
  self.primary_keys = :authorisation_created_at, :id

  belongs_to :authorisation
end
