module JoinByType
  extend ActiveSupport::Concern

  TYPES = [Member, Client, Merchant]

  included do
    belongs_to :owner, polymorphic: true
    scope :join_by_type, ->(type) { joins("LEFT OUTER JOIN #{type.table_name} ON #{type.table_name}.id = #{self.table_name}.owner_id AND #{self.table_name}.owner_type = '#{type.to_s}'") if TYPES.include?(type) }
  end

end