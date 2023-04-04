class ViolationSerializer < ApplicationSerializer
  attributes :id, :internal_code, :rule_priority

  has_one :rule
end