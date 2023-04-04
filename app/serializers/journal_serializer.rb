class JournalSerializer < ApplicationSerializer
  attributes :alert_created_at, :alert_id, :category, :created_at, :event_date, :event_type, :id, :info_1, :info_2, :info_3, :info_4, :updated_at, :entered_by

  def entered_by
    object.user ? object.user.name : ''
  end
end