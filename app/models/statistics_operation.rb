# == Schema Information
#
# Table name: statistics_operations
#
#  id          :integer          not null, primary key
#  op_type     :string(255)
#  op_code     :string(255)
#  operator    :string(255)
#  op_datatype :string(255)
#  size        :integer
#  calc_type   :string(255)
#  created_at  :timestamp        not null
#  updated_at  :timestamp        not null
#

class StatisticsOperation < ApplicationRecord

  schema_validations unless Rails.env.test?

  has_many :statistics

  include Authority::Abilities
  self.authorizer_name = 'StatisticsAuthorizer'

end
