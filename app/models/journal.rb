# == Schema Information
#
# Table name: journals
#
#  id               :integer          not null, primary key
#  event_type       :string(255)
#  info_1           :string(255)
#  info_2           :string(255)
#  info_3           :string(255)
#  info_4           :string(255)
#  event_date       :timestamp
#  alert_created_at :timestamp        primary key
#  category         :string(255)
#  alert_id         :integer
#  user_id          :integer
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class Journal < ApplicationRecord
  include Filter
  include Authority::Abilities

  self.primary_keys = :alert_created_at, :id

  belongs_to :alert, foreign_key: [:alert_created_at, :alert_id]
  belongs_to :user

end
