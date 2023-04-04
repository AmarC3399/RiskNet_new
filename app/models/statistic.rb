# == Schema Information
#
# Table name: statistic
#
#  id                      :integer          not null, primary key
#  stat_code               :string(100)
#  stat_type               :string(255)
#  created_by              :string(255)
#  updated_by              :string(255)
#  deleted                 :boolean
#  mandatory               :boolean
#  calculation_order       :integer
#  category                :string(255)
#  description             :string(255)
#  average                 :boolean          default(FALSE)
#  is_distinct             :boolean          default(FALSE)
#  grouped                 :boolean          default(FALSE)
#  statistics_operation_id :integer
#  field_list_id           :integer
#  grouping_factor_id      :integer
#  created_at              :timestamp        not null
#  updated_at              :timestamp        not null
#  owner_id                :integer
#  owner_type              :string(255)
#

class Statistic < ApplicationRecord

  schema_validations unless Rails.env.test?

  include Authority::Abilities
  include Filter

  # because 'statistics' which is the default name is a reserved for in MSSQL
  self.table_name = 'statistic'
  self.authorizer_name = 'StatisticsAuthorizer'

  default_scope { where(deleted: false) }
  belongs_to :statistics_operation
  belongs_to :field_list
  # the grouping factor is another linkage to the fieldlist table... it indicates the fields to be used as a grouping by field
  belongs_to :grouping_factor, class_name: "FieldList", foreign_key: "grouping_factor_id"
  belongs_to :owner, polymorphic: true

  has_many :statistic_calculations
  has_many :statistic_indices, through: :statistic_calculations
  has_many :statistic_tables, through: :statistic_calculations
  has_and_belongs_to_many :statistic_timeframes, :join_table => "join_statistics_timeframes"
#  has_many :criteria, as: :leftable
 # has_many :criteria, as: :rightable
  has_many :statistic_group_results

  has_one :criterion, inverse_of: :statistic, dependent: :destroy
  accepts_nested_attributes_for :criterion

  after_create :set_description
  validates_presence_of :statistics_operation
  before_create :set_booleans_and_grouping

  def set_booleans_and_grouping
    self.average = true if (self.statistics_operation.operator == "AVG" || self.statistics_operation.operator == "AVERAGE")
    
    # Mark as grouped if we have a grouping factor
    if self.grouping_factor.present?
      self.grouped = true
    else
      # We don't have a grouping factor so we won't mark as grouped,
      # however the stupid rule engine still needs a grouping factor
      # so we'll set that. This method cannot be run twice however,
      # as it will then think it's grouped. You've been warned!
      self.grouped = false
      self.grouping_factor_id = FieldList.id_for("Authorisation","id")
    end

    self.category =  self.statistics_operation.operator
  end


  def serializable_hash(options = nil)
    # original will allow you to access the original json object as provided by rails
    # :extended_stats is used in the rule engine in order to deliver the full version of statistics
    if options && options[:original]
      super
    elsif options && options[:extended_stats]
      super(include: [:statistics_operation,{criterion: {include:[
              {leftable: {excl_list: true, extended_stats: true, for_jpos:true}},
              { rightable: {incl_statistic: true, extended_stats: true, for_jpos:true}}]}}, {grouping_factor:{for_jpos: options[:for_jpos]}}, {field_list:{for_jpos: options[:for_jpos]}}])
        .merge(period_field_id: FieldList.id_for("Authorisation","auth_date"),period_field: FieldList.id_for("Authorisation","auth_date",true).as_json(for_jpos: options[:for_jpos]))
    else
      super(only: [:id,:stat_code,:description]).merge(timeframes: self.statistic_timeframes.pluck(:id))
    end
  end

  def set_description
    if self.statistics_operation
      desc = 'The '
      case self.statistics_operation.op_code
        when "COUNT"
          desc << "total number of #{self.stat_type.humanize.pluralize.downcase}"
        when "SUM"
          desc << "total sum of values of each #{self.field_list.description.pluralize}"
        when "COUNT DISTINCT"
          desc << "number of distinct values for #{self.field_list.description.pluralize}"
        when "GROUP COUNT"
          desc << "count of the number of #{self.field_list.description.pluralize}"
        when "GROUP SUM"
          desc << "sum of the values of #{self.field_list.description.pluralize}"
        when "MAXIMUM"
          desc << "maximum value of all #{self.field_list.description.pluralize}"
        when "MINIMUM"
          desc << "minimum value of all #{self.field_list.description.pluralize}"
        when "AVERAGE"
          desc << "average value of all #{self.field_list.description.pluralize}"
      end

      desc << " where #{criterion.description}" if criterion
      desc << ", grouped by #{grouping_factor.description.upcase.humanize}" if grouped

      self.update_column(:description, desc)
    end
  end

  def self.build_statistics_json
    Statistic.includes(:statistics_operation, :statistic_timeframes, :statistic_calculations, :criterion, :grouping_factor, :field_list).as_json(original:true, include: [:statistics_operation,:statistic_timeframes,:statistic_calculations,:criterion, :grouping_factor, :field_list])
  end

  # As we have better implementation of timeframe for 12H, 24H, 30DAY and 90DAY.
  # We will no longer support the above timeframes for future stats but will still support it for existing stats.
  def new_timeframes
    @new_timeframes  ||= StatisticTimeframe.where(timeframe_type: %w(HOURLY DAILY WEEKLY MINUTES)).pluck(:id)
  end

end
