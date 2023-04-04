# == Schema Information
#
# Table name: installations
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  email       :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#

class Installation < ApplicationRecord
  include RequiredColumnHelper

  has_many :members
  has_many :users, as: :owner
  has_many :rules, as: :owner
  has_many :statistic_tables, as: :owner
  has_many :active_rules, -> { where(active: true) }, class_name: 'Rule', as: :owner # this just used only inside rule manager step module

  resourcify

  before_create :return_readonly
  before_destroy :return_readonly


  DISCOUNTED_COLUMNS = %w(created_at updated_at)

  REQUIRED_COLUMNS = %w(id name email)

  def return_readonly
    # raise ActiveRecord::ReadOnlyRecord
  end
end
