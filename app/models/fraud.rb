# == Schema Information
#
# Table name: frauds
#
#  id                       :integer          not null, primary key
#  authorisation_created_at :timestamp
#  authorisation_id         :integer
#  fraud_status             :integer
#  created_at               :timestamp        not null, primary key
#  updated_at               :timestamp        not null
#

class Fraud < ApplicationRecord
  self.primary_keys = :created_at, :id
  belongs_to :authorisation, foreign_key: [:authorisation_created_at, :authorisation_id]

  validates_presence_of :authorisation_id,:fraud_status

  before_save :set_auth_created_at

  def set_auth_created_at
    self.authorisation_created_at ||= self.authorisation.created_at
  end

end
