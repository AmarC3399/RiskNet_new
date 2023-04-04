class ServerEpoch < ApplicationRecord
  self.table_name = "server_epochs"
  has_many :table_epochs
  
  validates :server_id, presence: :true, uniqueness: true
end
