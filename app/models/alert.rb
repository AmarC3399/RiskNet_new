# == Schema Information
#
# Table name: alerts
#
#  id                     :integer          not null, primary key
#  alert_type             :string(255)
#  subject                :string(255)
#  response               :string(255)
#  priority               :integer
#  customer_merchant_name :string(255)
#  run_date               :timestamp
#  examined_on            :timestamp
#  allocated_on           :timestamp
#  examined               :boolean          default(FALSE)
#  being_examined         :boolean          default(FALSE), not null
#  reminder_unactioned    :boolean          default(FALSE), not null
#  alert_owner_id         :integer
#  alert_owner_type       :string(255)
#  user_id                :integer
#  merchant_id            :integer
#  created_at             :timestamp        not null, primary key
#  updated_at             :timestamp        not null
#  card_id                :integer
#

class Alert < ApplicationRecord
  include Broadcastable
  include ActionView::Helpers::TextHelper
  include Filter
  include Authority::Abilities

  self.primary_keys = :created_at, :id

  acts_as_commentable primary_key: :id

  belongs_to :user
  belongs_to :alert_owner, polymorphic: true
  # belongs_to :merchant
  # has_one :client, primary_key: 'client_id', foreign_key: 'id', through: :merchant
  # has_one :member, through: :client

  belongs_to :merchant, -> { where("alert_owner_type = ?", 'Merchant') }, class_name: 'Merchant', foreign_key: 'alert_owner_id'
  belongs_to :client,   -> { where("alert_owner_type = ?", 'Client') },   class_name: 'Client',   foreign_key: 'alert_owner_id'
  belongs_to :member,   -> { where("alert_owner_type = ?", 'Member') },   class_name: 'Member',   foreign_key: 'alert_owner_id'
  belongs_to :card

  has_many :violations, foreign_key: [:alert_created_at, :alert_id]
  has_many :journals, foreign_key: [:alert_created_at, :alert_id]
  # we want to present distinct cases and not duplicated ones
  has_many :authorisations, -> { uniq }, through: :violations
  has_many :rules, -> { uniq },  through: :violations
  has_many :customers, -> { uniq }, through: :violations
  has_many :investigations, foreign_key: [:alert_created_at, :alert_id]
  has_many :activities, foreign_key: [:alert_created_at, :alert_id], dependent: :destroy
  has_many :allocated_comments, :class_name => 'Comment', foreign_key: [:alert_created_at, :alert_id]

  #toso-an if you eager load reminders, the 'where' clause is treated as part of the join section!!!
  has_one :reminder, -> { where(cleared: false) }, foreign_key: [:alert_created_at, :alert_id], dependent: :destroy
  has_one :all_reminder, :class_name => 'Reminder', foreign_key: [:alert_created_at, :alert_id], dependent: :destroy

  accepts_nested_attributes_for :reminder

  before_save :clear_being_examined, only: :update# , :if => :user_id_changed?
  before_save :set_alert_info
  after_create :broadcast_alert

  accepts_nested_attributes_for :comments
  validates_associated :comments

  validate :handle_conflict, only: :update
  validate :assigned_once, only: :update, :if => :user_id_changed?
  validate :no_pending_alert, only: :update, :unless => :examined_changed?
  validate :not_examined, only: :update, unless: :examined_changed?


  after_update :broadcast_update, :clear_job unless Rails.env.test?


  attr_writer :original_updated_at
  attr_writer :updated_by

 # around_update :broadcast_alert_update


  # scope :unexamined, -> { where(examined: false) }
  scope :unallocated, -> { where(user_id: nil) }
  # scope :with_merchant_and_reminder, -> { joins(:merchant).with_reminder }
  scope :with_reminder, -> { joins('LEFT OUTER JOIN reminders ON reminders.alert_id = alerts.id and reminders.alert_created_at = alerts.created_at')}

  # broadcastable channels: [{ type: :merchant, merchant: ->{ merchant.id } }, { type: :member, member: ->{ merchant.client_id } }, { type: :member, member: ->{ merchant.client.member.id } }]


  #
  #
  # CLASS METHODS
  #
  #

  # If no type is given do not send alerts that have been examined
  def self.unexamined(type=nil)
    if type.nil?
      where(examined: false)
    else
      where(nil)
    end
  end

  # MCC should come from the associated Authorisation
  def as_json(options={})
    if !self.authorisations[0].nil? # check if the alert has auth first 
      super(options).merge({mcc: self.authorisations[0].mcc})
    else
      super(options)
    end
  end

  #
  # Retrieve all alerts assigned to the
  # specified user. If the user is not
  # provided, this will simply return
  # a where scope with no condition. i.e
  # where(nil).
  #
  def self.merchant_filtered(filter)
    member_filter = (member_id = filter[:member]) ? {merchants: {member_id: member_id}} : {}
    merchant_filter = (merchant_id = filter[:merchant]) ? {merchant_id: merchant_id} : {}
    joins(:merchant).where(member_filter).where(merchant_filter)
  end


  def self.with_merchant_and_reminder(report_hash)
    target_type = ReportResult.find(report_hash[:id]).report.target_type
    joins(target_type.downcase.to_sym).with_reminder
  end

  def self.target_filtered(report_hash)
    target_id = Report.find(report_hash[:report_id]).target_id

    case Report.find(report_hash[:report_id]).target_type
      when 'Member'
       where(alert_owner_type: 'Member',  alert_owner_id: target_id)
      when 'Client'
       where(alert_owner_type: 'Client',  alert_owner_id: target_id)
      when 'Merchant'
       where(alert_owner_type: 'Merchant',  alert_owner_id: target_id)
      else
       all
    end
  end


  def broadcast_alert
    action = self.id_changed? ? :create : :update
    self.class.broadcastable(channels: [{ type: :merchant, merchant: self.alert_owner.id  }, { type: :member, member: self.alert_owner.member.id }, { type: :client, client: self.alert_owner.client.id  }], message: self, only: action)
  end


  def self.allocated_for_user(usr_id = nil)
    if usr_id
      if User.exists? usr_id
        where(user_id: [usr_id, nil])
      else
        where(nil)
      end
    else
      where(nil)
    end
  end

  # puts "1. Alert_list ---- #{list['type']} ----- #{list} ------ #{split_filter.is_a?(Array)}"
  def self.alert_list(list=nil, user_id=nil)
    return where(nil) if list.nil?

    split_filter = list.split(',')

    case split_filter
      when ['allocated'] # Do not return already examined alerts
        where("#{self.allocated(user_id)} AND NOT #{self.examined}")
      when ['examined']
        where(self.examined)
      when ['reminder'] # Do not return already examined alerts
        where("#{self.reminder} AND NOT #{self.examined}")
      when %w(allocated examined)
        where("#{self.allocated(user_id)} OR #{self.examined}")
      when %w(allocated reminder) # Do not return already examined alerts
        where("#{self.allocated(user_id)} AND NOT #{self.examined} OR #{self.reminder}")
      when %w(examined reminder)
        where("#{self.examined} OR #{self.reminder}")
      when %w(allocated examined reminder)
        where("#{self.allocated(user_id)} OR #{self.examined} OR #{self.reminder}")
      else
        where(nil)
    end
  end

  def self.filter_owner(params = nil)

    # TODO: Refactor it.
    return where(nil) if params[:installation].nil? && params[:member].nil? && params[:client].nil? && params[:merchant].nil? && params[:only_mine].nil?

    alert_types = []

    if params[:member]
      member_type, member_id = 'Member', params[:member]
    end

    if params[:client]
      client_type, client_id = 'Client', params[:client]
    end

    if params[:merchant]
      merchant_type, merchant_id = 'Merchant', params[:merchant]
    end




    # If merchant param is present, merchant level has been selected so use merchant_type & merchant_id
    if params[:merchant]
      where("alert_owner_type = ? and alert_owner_id = ?", merchant_type, merchant_id )

    # If client param is present but the merchant is not, client level has been selected so use client_type and client_id
    elsif params[:client] && !params[:merchant]
      # Get all of the merchants belonging to the client (children)
      Client.find(client_id).merchants.map do |merchant|
        alert_types << "(alert_owner_type = '#{merchant.class.name}' and alert_owner_id = #{merchant.id})"
      end
      # Add the parent as an owner too (parent)
      alert_types << "(alert_owner_type = '#{client_type}' and alert_owner_id = #{client_id})"
      where(alert_types.join(' OR '))

    # If member param is present but the client and merchant are not, member level has been selected so use member_type and member_id
    elsif params[:member] && !params[:client] && !params[:merchant]
      # Get all of the clients belonging to the member (children)
      Member.find(member_id).clients.map do |client|
        alert_types << "(alert_owner_type = '#{client.class.name}' and alert_owner_id = #{client.id})"
        # Get all of the merchants belonging to each client (grand children)
        Client.find(client.id).merchants.map do |merchant|
          alert_types << "(alert_owner_type = '#{merchant.class.name}' and alert_owner_id = #{merchant.id})"
        end
      end
      # Add the parent as an owner too (parent)
      alert_types << "(alert_owner_type = '#{member_type}' and alert_owner_id = #{member_id})"
      where(alert_types.join(' OR '))

    # If only_mine param is present, user only wants to see alerts at their level
    elsif params[:only_mine]
      alert_types << "(alert_owner_type = '#{params[:user].owner_type}' and alert_owner_id = #{params[:user].owner_id})"
      where(alert_types.join(' OR '))
    end
  end

  def self.filtered_response(filter = nil)
    filter ||= 'approve,review,decline,test_approve,test_review,test_decline'
    split_filter = filter.upcase.split(',')

    where(subject: split_filter)
  end

  def self.filtered_by_merchant(filter=nil)
    if filter.present?
      where(merchant: filter)
    else
      where(nil)
    end
  end

  def self.in_merchants(merchants=nil)
    if merchants.present?
      where(merchant: merchants)
    else
      where(nil)
    end
  end

  def self.merchant_group_search(filter)
    if filter.present?
       # This assumes all authorisations come in at merchant (submerchant FE) level
       joins(:merchant).joins(:user).search(filter, 'merchants.name', 'merchants.post_code', 'merchants.country',
                          'merchants.id','merchants.mcc','merchants.open_date', 'merchants.contact',
                          'alerts.customer_merchant_name', 'alerts.priority','alerts.id','alerts.run_date',
                          'alerts.alert_type','alerts.response','alerts.examined_on', 'alerts.allocated_on', 'users.name')
    else
      where(nil)
    end
  end

  #
  #
  # INSTANCE METHODS
  #
  #

  def broadcast_update

    user = self.user_id_changed? && !self.user_id.nil? ? true : false
    examine = self.examined_changed? && self.examined ? true : false

    # just to be sure that both wont happen together
    examine = false if user

    message = Hash.new
    header = Hash.new

    examine ?  message[:action] = :examined : message[:action] = :assigned
    message[:resource_type] = 'Alert'
    message[:resource] = self

    header["#{self.alert_owner_type.downcase}_id".to_sym] = self.alert_owner_id.to_s

    broadcaster = Broadcaster.new
    broadcaster.broadcast("/topics/#{self.alert_owner_type.downcase.pluralize}", message, header)

    case self.alert_owner_type
      when 'Client'
        broadcaster.broadcast("/topics/members", message, { member_id: Client.find(self.alert_owner_id).member.id.to_s })
      when 'Merchant'
        broadcaster.broadcast("/topics/members", message, { member_id: Merchant.find(self.alert_owner_id).member.id.to_s })
        broadcaster.broadcast("/topics/clients", message, { client_id: Merchant.find(self.alert_owner_id).client.id.to_s })
    end
  end


  def clear_being_examined
    # If this alert is being forwarded, then
    # we need to clear the 'being examined'
    # flag. If the user ID has changed, and
    # the user updating it is not the same
    # as the user_id, then it is being forwarded
    #
    # being_examined is NOT set to true on forwarding
    if self.user.present?
      if (@updated_by && @updated_by.id != self.user_id) #|| !@updated_by
        # It's been assigned, and not by the logged in
        # user, so it's being forwarded
        # puts "inside user diff"
        # Add a journal manually

        Journal.create(
          event_type: 'Alert',
          info_1: "Forwarded Alert to #{self.user.try(:name)}",
          info_2: self.comments.last.try(:comment_text),
          event_date: self.updated_at,
          alert_id: self.ids_hash['id'],
          user_id: @updated_by.id,
          alert_created_at: self.created_at
        )
        self.being_examined = false
        true
      else
        self.being_examined ||= true
      end
    end
  end

  def set_alert_info
    self.examined_on  = Time.zone.now  if examined_changed?
    self.allocated_on = Time.zone.now if  user_id_changed?
    self.being_examined = false if examined_changed? && examined
    self.response = self.response.upcase if response_changed?
    #TODO-AN need to fix that and properly manipulate either customer or merchant info
    # 06.12.2013 just for merchant until a proper solution is implemented
    # merchant = self.violations.try(:first).try(:merchant_id)
    # if alert_owner_type == 'Merchant'
    #   self.customer_merchant_name = alert_owner.internal_code
    # else
    #   self.customer_merchant_name = alert_owner.name_on_card   #TODO This needs be looked at as alert_owner no longer represent card
    # end
    if %w(installation member client merchant).include?(alert_owner_type.downcase)
      self.customer_merchant_name = correct_merchant_name
    else                                                                             # WARNING: Alert will always and must belong to an entity Level.
      self.customer_merchant_name = Card.find_by_id(self.card_id).try(:name_on_card) # So, the 'else' statement can be removed but keeping it alive to
    end                                                                              # support old logic (although defunct) where level was either merchant or card.
  end

  def correct_merchant_name
    owner = self.alert_owner
    if owner.is_a?(Installation)
      owner.name.nil? ? name = 'UNTITLED INSTALLATION' : name = owner.name
    end
    if owner.is_a?(Member)
      owner.name.nil? ? name = 'UNTITLED MEMBER' : name = owner.name
    end
    if owner.is_a?(Client) # internal_code
      owner.name.nil? ? name = 'UNTITLED CLIENT' : name = owner.name
    end
    if owner.is_a?(Merchant) # internal_code
      owner.name.nil? ? name = 'UNTITLED MERCHANT' : name = owner.name
    end

    name
  end


  # if we decide to link with more than 1 model linked with accounts,
  # we need to convert this to has_many :through
  def account
    violations.first.account
  end

  def original_updated_at
    @original_updated_at ? ActiveRecord::ConnectionAdapters::Column.string_to_time(@original_updated_at) : updated_at
  end

  def handle_conflict
    #If we want to use this across multiple models
    #then extract this to module
    if @conflict || updated_at.to_f > original_updated_at.to_f
      @conflict = true
      @original_updated_at = nil
      #If two updates are made at the same time a validation error
      #is displayed and the fields with
      errors.add :base, :no_conflict
      changes.each do |attribute, values|
        errors.add attribute, :was, :value => values.first
      end
    end
  end

  def uncleared_reminder
    Reminder.where(alert_id: self.id, cleared: false)
  end

  def serializable_hash(*)
    out = super
    # out.delete 'alert_owner_id'
    # out.delete 'alert_owner_type'
    out.merge!(alert_owner_url: alert_owner_type.downcase.pluralize) if alert_owner_type
    # out.merge!(merchant_id: alert_owner_id) if alert_owner_type == 'Merchant'
    # out.merge!(customer_id: alert_owner_id) if alert_owner_type == 'Customer'
    out[:id] = to_param if id[0]
    out.merge!(original_id: ids_hash['id'])
    out.merge({mcc: self.authorisations[0].mcc}) if self.authorisations[0]
    out
  end

  # Check no allocated alerts assigned to user before assigning new alert
  def no_pending_alert
    if @updated_by && @updated_by.id == self.user_id

      my_alerts = @updated_by.alerts.where(examined: false)
      my_alerts_with_reminders = my_alerts.includes(:all_reminder).where.not(reminders: {id: nil})
      alert_has_reminder = my_alerts_with_reminders.find_by id: self.ids_hash['id']

      if !alert_has_reminder
        my_allocated_alerts = my_alerts.where(being_examined:true).includes(:all_reminder).where(reminders: {id: nil}).order(:run_date)
        alert_is_allocated = my_allocated_alerts.find_by id: self.ids_hash['id']

        if !alert_is_allocated
          if my_allocated_alerts.count > 0
            errors.add(:base, I18n.t('activerecord.errors.models.alert.no_pending.one_assigned', id: my_allocated_alerts.first.id[1]))
          end
        end
      end
    end
  end

  #
  # When a user selects an alert, they assign it to themselves. They can only
  # assign themselves a single alert, but they can have alerts forwarded to them.
  # This method enforces this
  #
  def assigned_once
    # Don't let the user_id change if it already has one. If the user ID is not
    # empty and is a different ID to the new one, don't allow it
    unless user_id_was.blank?
      if @updated_by &&  @updated_by.id != user_id_was
        errors.add :base, :assigned
      end
    end
  end

  #
  # If an alert has a reminder set that has already expired, then we need
  # to cancel the alert release job when the alert is updated, as it means
  # the user has taken action on the reminder
  #
  def clear_job
    if reminder && !reminder.cleared? && reminder.job_type == 'release'
      # TorqueBox::ScheduledJob.remove(reminder.job_id) #TODO Add scheduler
      reminder.cleared = true
      reminder.job_id = nil
      reminder.job_type = nil
      reminder.save
    end
  end


  #
  # If a user attempts to update an alert that has already been marked as examined,
  # it should fail. Once examined, an alert cannot be modified
  #
  def not_examined
    if examined?
      errors.add :base, :examined
    end
  end

  private

  def self.allocated(user_id)
    # If user id exists, this originated from the main alerts screen and only alerts
    # allocated to the logged in user should be returned
    if user_id
      "alerts.user_id =  #{user_id}"
    # If user id does not exist, this originated from the batch alerts screen and
    # all allocated alerts to any user should be returned
    else
      "alerts.user_id is not null"
    end
  end

  def self.examined
    if ActiveRecord::Base.connection.adapter_name=="PostgreSQL"
      "alerts.examined = true"
    else
      "alerts.examined = 1"
    end
  end

  def self.reminder
    if ActiveRecord::Base.connection.adapter_name=="PostgreSQL"
      # alert_id refers to reminder.alert_id and cleared refers to reminder.cleared
      "alert_id is not null AND cleared = false"
    else
      "alert_id is not null AND cleared = 0"
    end
  end
end