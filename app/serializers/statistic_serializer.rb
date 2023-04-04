class StatisticSerializer < ApplicationSerializer
  self.root = false

  attributes :id, :stat_code, :description, :created_at, :updated_at, :owner_id, :owner_type
  has_one :criterion
  has_one :owner
  has_many :statistic_timeframes

end
