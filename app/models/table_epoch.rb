class TableEpoch < ApplicationRecord
  self.table_name = "table_epochs"
  belongs_to :server_epoch
  self.primary_keys = [:created_at, :id]

  validates :object_id, :object_type, presence: :true
end
