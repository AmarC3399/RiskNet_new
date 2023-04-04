# == Schema Information
#
# Table name: criteria_parameters
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  data_type  :string(255)
#  created_at :timestamp        not null
#  updated_at :timestamp        not null
#

class CriteriaParameter < ApplicationRecord
  include Authority::Abilities
  include IsSummarisable

  is_summarisable
  has_one :criterion, as: :rightable

  validates_presence_of :value, :data_type

  self.authorizer_name = 'StatisticsAuthorizer'


  def serializable_hash(options = nil)
    # json optimization.. only used columns
    # original will allow you to access the original json object as provided by rails
    if options && options[:original]
      super
    elsif options && options[:only]
      super(only: options[:only], for_jpos: options[:for_jpos])
    elsif options
      #if object exists
      super(only: [:id, :value, :data_type], for_jpos: options[:for_jpos])
    else
      super(only: [:id, :value, :data_type])
    end
  end
end
