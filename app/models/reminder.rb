# == Schema Information
#
# Table name: reminders
#
#  id               :integer          not null, primary key
#  reason           :string(255)
#  reminder_time    :timestamp
#  alert_created_at :timestamp        not null, primary key
#  expired          :boolean          default(FALSE)
#  cleared          :boolean          default(FALSE)
#  cleared_on       :timestamp
#  job_id           :string(255)
#  job_type         :string(255)
#  alert_id         :integer
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class Reminder < ApplicationRecord

  schema_validations unless Rails.env.test?

  include Authority::Abilities
  include Journaled::Model

  self.primary_keys = :alert_created_at, :id
  
  belongs_to :alert, foreign_key: [:alert_created_at, :alert_id]
  acts_as_commentable primary_key: :id
  accepts_nested_attributes_for :comments

  before_save :set_cleared_on, :if => :cleared_changed?
  after_save :remove_job, if: :cleared_changed?

  scope :uncleared, -> { where(cleared: false) }

  validates_presence_of :alert_id
  # validates :alert_id, :uniqueness => {:if => :active?}
  validates_uniqueness_of :alert_id, scope: :cleared, unless: :cleared?
  # validate :already_exists, on: :create

  validates_inclusion_of :job_type, in: %w(reminder release), allow_nil: true

  has_journal


  def set_cleared_on
    self.cleared_on = Time.zone.now
  end

  def remove_job
    #TorqueBox::ScheduledJob.remove(self.job_id) unless self.job_id.blank? #TODO Add scheduler here
  end

  # def already_exists
  #   # we want only one reminder per alert so we check if existing reminder for alert exists
  #   unless Reminder.uncleared.where(alert_id: self.alert_id).empty?
  #     self.errors.add(:alert_id, 'already has a reminder allocated')
  #     false
  #   end
  # end


  def serializable_hash(*)
    out = super
    out[:id] = to_param
    out.merge!(original_id: ids_hash['id'])
    out
  end

end
