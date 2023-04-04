# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  title            :string(50)       default("")
#  comment_text     :string(255)
#  role             :string(255)      default("comments")
#  entered_by       :string(255)
#  last_updated_by  :string(255)
#  commentable_id   :integer
#  commentable_type :string(255)
#  alert_id         :integer
#  user_id          :integer
#  alert_created_at :timestamp        not null
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class Comment < ApplicationRecord

  schema_validations :except => [:id, :created_at, :updated_at] unless Rails.env.test?

  include ActsAsCommentable::Comment
  include Filter
  include UserHierarchy::GroundRule::Info

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  belongs_to :alert, foreign_key: [:alert_created_at, :alert_id]

  # before_validation :set_user_name
  before_validation :set_alert_id

  # validates_presence_of :comment_text

  default_scope -> { order(created_at: :desc) }

  private

  # def set_user_name
  #   puts "comment.rb ============ #{user.inspect} ===== "
  #   self.entered_by = user.name rescue 'username not set' # self.user.try(:name)
  # end

  def set_alert_id
    if alert_id_before_type_cast && alert_id_before_type_cast.kind_of?(String) && alert_id_before_type_cast.split('-').count > 1
      # We have a composite key definition
      new_id = CompositePrimaryKeys::CompositeKeys.parse(alert_id_before_type_cast)
      self.alert_id = new_id[1]
      self.alert_created_at = Time.at(Rational(new_id[0])).utc.strftime('%Y-%m-%d %H:%M:%S')
    end
  end

end
