# == Schema Information
#
# Table name: criteria_cards
#
#  id           :integer          not null, primary key
#  value        :string(255)
#  data_type    :string(255)      default("string")
#  masked_value :string(255)
#  bin          :string(255)
#  last4        :string(255)
#  card_length  :integer
#  created_at   :timestamp
#  updated_at   :timestamp
#

class CriteriaCard < ApplicationRecord
  #todo-an pending tests for the model and affected components
  include Authority::Abilities
  include IsSummarisable

  is_summarisable
  has_one :criterion, as: :rightable

  validates_presence_of :value

  self.authorizer_name = 'StatisticsAuthorizer'

  before_create :hash_value
  def hash_value
    cn = CardNumber.new(self.value)
    self.value = cn.hashed_value
    self.bin = cn.bin
    self.last4 = cn.last_four
    self.card_length = cn.card_length
    self.masked_value = cn.masked_card_number
  end

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
