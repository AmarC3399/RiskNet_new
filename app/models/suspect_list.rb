# == Schema Information
#
# Table name: suspect_lists
#
#  id               :integer          not null, primary key
#  suspect_type     :string(255)
#  pan              :string(255)
#  expires_on       :timestamp
#  deleted          :boolean
#  suspectable_id   :integer
#  suspectable_type :string(255)
#  user_id          :integer
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class SuspectList < ApplicationRecord
  include Authority::Abilities
  
  belongs_to :suspectable, polymorphic: true
  belongs_to :user

  acts_as_commentable primary_key: :id
  accepts_nested_attributes_for :comments

end
