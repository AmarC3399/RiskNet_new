# == Schema Information
#
# Table name: criteria_summaries
#
#  id         :integer          not null, primary key
#  data_id    :integer
#  data_type  :string(255)
#  created_at :timestamp        not null
#  updated_at :timestamp        not null
#

class CriteriaSummary < ApplicationRecord

  belongs_to :data, polymorphic: true
  belongs_to :fieldlist_data, :foreign_key => :data_id, :class_name => "FieldList"
  validates_presence_of :data_id, :data_type
  validates_uniqueness_of :data_id, scope: :data_type

  #returns the id for the DATA model you requested
  def self.for_data(type=nil, id=nil)
    CriteriaSummary.where(data_type: type, data_id: id).select(:id).first if type and id
  end
end
