# == Schema Information
#
# Table name: statistic_calculations
#
#  id                     :integer          not null, primary key
#  calc_type              :string(255)
#  from_period            :integer
#  to_period              :integer
#  description            :string(255)
#  grouping_operator      :string(255)
#  calculate_on_the_fly   :boolean          default(FALSE)
#  date_only              :boolean          default(FALSE)
#  statistic_id           :integer
#  statistic_timeframe_id :integer
#  created_at             :timestamp        not null
#  updated_at             :timestamp        not null
#

class StatisticCalculation < ApplicationRecord

  schema_validations unless Rails.env.test?

  include Authority::Abilities
  include IsSummarisable

  is_summarisable

  self.authorizer_name = 'StatisticsAuthorizer'

  belongs_to :statistic
  belongs_to :statistic_timeframe

  has_one :criterion_left, as: :leftable, class_name: 'Criterion'
  has_one :criterion_right, as: :rightable, class_name: 'Criterion'

  has_many :statistic_results

  belongs_to :statistic_index
  belongs_to :statistic_table

  before_create :set_remaining_fields

  validates_presence_of :statistic

  def set_remaining_fields
    timeframe_description = ""
    period_desc = ""

    self.from_period ||=  statistic_timeframe.aggregate_length if self.statistic_timeframe
    self.calculate_on_the_fly = false
    self.to_period ||= 0
    self.from_period ||= 0

    period_desc = ''
    period_desc = ''
    period_desc << " #{from_period} #{get_time_type} ago" if self.from_period > 0
    period_desc << " (ignoring last #{to_period}) " if self.to_period > 0

    self.description = self.statistic.description + period_desc

    if statistic.grouped
      self.grouping_operator = statistic.statistics_operation.operator
    end
  end

  def serializable_hash(options={})
    # :extended_stats is used in the rule engine in order to deliver the statistic when
    # the calculate_on_the_fly is true
    #because all results  are stored in predefined datatype.. it should be a decimal
    if self.calculate_on_the_fly? and options and options[:extended_stats]
      #adding :extended_stats to statistic in order to get the full statistic object
      super(include: [{statistic: {extended_stats: true,for_jpos: options[:for_jpos]}},:statistic_timeframe,],for_jpos: options[:for_jpos]).merge(data_type:"decimal")
    elsif options and options[:extended_stats]
      super(for_jpos: options[:for_jpos]).merge(data_type:"decimal")
    elsif options
      super(for_jpos: options[:for_jpos]).merge(data_type:"decimal")
    else
      super.merge(data_type:"decimal")
    end
  end

  def calculate
    raise 'Grouped statistics not supported by this method' if self.statistic.grouped
    interval = get_time_type(true)
    span = self.statistic_timeframe.aggregate_length
    if self.statistic.statistics_operation.operator.upcase == 'COUNT DISTINCT'
      raise 'COUNT DISTINCT not supported by persisted stats'
    end
    oper = case self.statistic.statistics_operation.operator.upcase
                  when 'COUNT'
                    :count
                  when 'SUM'
                    :sum
                  when 'MAX'
                    :maximum
                  when 'MIN'
                    :minimum
                  when 'AVG'
                    :average
                end
    if self.calculate_on_the_fly
      scope = #{self.statistic.stat_type}
      #TODO: Check if Time.zone.now is correctly used
      scope.where(auth_date => span.send(interval).ago..Time.zone.now)
        .send(oper, :authorization_amount)
    elsif self.statistic.grouped
      scope = StatisticGroupResult
      scope.where(:statistic_calculation_id => self.id)
        .where(:from_date => span.send(interval).ago..Time.zone.now)
        .send(oper, :value)
    else
      scope = StatisticResult.where(:statistic_calculation_id => self.id)
      scope.pluck(:value)
    end
  end

  def criterion
    (criterion_left || criterion_right)
  end

  def rule
    Rule.unscoped.where(id: criterion.rule_id).first
  end

  def owner
    rule.owner
  end

  def get_time_type (is_it_symbol=false)
    interval = case self.statistic_timeframe.aggregate_level.upcase
                 when 'H'
                   :hours
                 when 'D'
                   :days
                 when 'W'
                   :weeks
                 when 'M'
                   :months
                 when 'S'
                   :minutes
               end
    is_it_symbol ? interval : interval.to_s
  end

  def from_period_in_seconds
    from_period.send(self.statistic_timeframe.unit).to_i
  end

  def queryable_statistic_table
    st = self.statistic_table
    if !st.containing_statistic_table && st.populated
      then st
    elsif st.populated_containing_statistic_table
      then st.populated_containing_statistic_table
    else nil
    end
  end

end

#d90 = StatisticTimeframe.create timeframe_type: "90DAY",aggregate_level: "D",turnover: "N",aggregate_length: 90
#dd = StatisticTimeframe.create timeframe_type: "DAILY",aggregate_level: "D",turnover: "N",aggregate_length: 1
#mt = StatisticTimeframe.create timeframe_type: "MONTHLYTURNOVER",aggregate_level: "M",turnover: "Y",aggregate_length: 1
#stddev = StatisticTimeframe.create timeframe_type: "STANDARDDEVIATION",aggregate_level: "S",turnover: "N",aggregate_length: 1
#zval = StatisticTimeframe.create timeframe_type: "ZVALUE",aggregate_level: "Z",turnover: "N",aggregate_length: 1
