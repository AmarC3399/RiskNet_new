# == Schema Information
#
# Table name: activities
#
#  id               :integer          not null, primary key
#  action_type      :string(255)
#  entered_by       :string(255)
#  alert_created_at :timestamp        primary key
#  user_id          :integer
#  alert_id         :integer
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class Activity < ApplicationRecord
  include Journaled::Model
  include Filter
  include Authority::Abilities

  self.primary_keys = :alert_created_at, :id

  belongs_to :user
  belongs_to :alert, foreign_key: [:alert_created_at, :alert_id]
  acts_as_commentable primary_key: :id

  before_create :set_user_name
  accepts_nested_attributes_for :comments
  validates_associated :comments

  has_journal type: 'Action'

  def set_user_name
    self.entered_by = self.user.try(:name)
  end

  def self.create_activity(alert, params, user)
    result = {}
    to_create = []
    cleaned_params = params
    alert_id = alert.ids_hash['id']
    user_id = cleaned_params[:user_id] || user.id
    
    cleaned_params[:actions].each do |action|
      if ListItem.unscoped.exists?(action.to_i)
        action_type = ListItem.unscoped.select(:id,:frontend_name).find(action.to_i)
      elsif ListItem.unscoped.exists?(value: action.to_s)
        action_type = ListItem.unscoped.select(:id,:value,:frontend_name).find_by(value:action.to_s)
      end
      create_obj=nil


      if action_type
        create_obj = {
          action_type: action_type.frontend_name,
          alert_id: alert_id,
          user_id: user_id,
          alert_created_at: alert.created_at.to_s
        }
        create_obj[:comments_attributes] = [{
            comment_text: cleaned_params[:comment_text],
            user_id: user_id,
            alert_id: alert_id,
            alert_created_at: alert.created_at.to_s
          }]
      end
      to_create << create_obj
    end

    to_create.compact!

    if cleaned_params[:actions].count == to_create.count
      self.transaction do
        begin
          result = {activities: self.create!(to_create)}
        rescue ActiveRecord::RecordInvalid => e
          result = {errors: e.message}
          raise ActiveRecord::Rollback
        end
      end
    else
      result = {errors: 'No activity saved. Items are not valid'}
    end

    return result
  end

end
