class ActivitySerializer < ApplicationSerializer
  attributes :id, :action_type, :created_at, :entered_by
  
  has_many :comments do
    object.comments.first
  end
end
