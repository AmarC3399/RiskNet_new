class Site < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
