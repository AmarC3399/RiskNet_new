# == Schema Information
#
# Table name: statistic_group_results
#
#  id           :integer          not null, primary key
#  key          :string(255)      not null
#  value        :float            not null
#  statistic_id :integer
#  from_date    :timestamp
#  to_date      :timestamp
#  created_at   :timestamp
#  updated_at   :timestamp
#

class StatisticGroupResult < ApplicationRecord
  belongs_to :statistic

  def self.create_from_statistic_calculation(calculation)

    # Now we need to find out the timeframes for this statistic
    timeframe = calculation.statistic_timeframe
    fd = StatisticGroupResult.arel_table[:from_date]
    # Find existing calculated days for statistic
    exist_dates = calculation.statistic.statistic_group_results
      .where(fd.gteq(from_date(timeframe, calculation).beginning_of_day))
      .group(:from_date)
      .pluck(:from_date)
    # Map those to start/end times for each day
    exist_days = exist_dates.map { |d| [d.beginning_of_day, d.end_of_day] }
    # Work out the days we should have, then subtract the existing days.
    stat_days = (from_date(timeframe, calculation).to_date..end_date(timeframe, calculation).to_date)
      .map{ |d| [d.beginning_of_day, d.end_of_day] }
    stat_days = stat_days - exist_days

    unless stat_days.length == 0

      # For each day in the array, build and execute an INSERT INTO...SELECT directly against the db
      stat_days.each do |stat_day|
        fl = FieldList.lazy_load_auths.where(name: "#{calculation.rule.owner.class.name.downcase}_id").first
        builder = QueryBuilder::StatQueryBuilder.builder_for_calculation(calculation,
                                                                         calculation.statistic,
                                                                         calculation.statistic_timeframe,
                                                                         calculation.statistic.statistics_operation,
                                                                         calculation.statistic.field_list,
                                                                         calculation.rule.owner,
                                                                         fl,
                                                                         calculation.statistic.criterion,
                                                                         stat_day: stat_day, exclude_timeframe: true, insert_to: self.table_name)
        insert_sql = builder.insert_sql

        ActiveRecord::Base.connection.execute(insert_sql)
      end

    end

  end

  def self.retrieve_statistic_for_calculation(calculation, key)
    operator = calculation.statistic.statistics_operation.operator
    # If we have previously done a COUNT into the summary table, we now need to SUM those values, not COUNT
    operator = 'SUM' if operator == 'COUNT'
    selector = "#{operator}(value) as statistic"

    timeframe = calculation.statistic_timeframe

    # Get start and end for the query
    from = from_date(timeframe, calculation)
      to = end_date(timeframe, calculation)

    #  Query SGR table ONLY for this calculation's statistic ID
    scope_sql = StatisticGroupResult.select(selector)
      .where(statistic_id: calculation.statistic.id)
      .where("from_date >= ?", from)
      .where("to_date <= ?", to)
      .where(key: key)
      .to_sql


    puts "==== constructed sql from #{self}"
    puts scope_sql
    result = ActiveRecord::Base.connection.execute(scope_sql)

    # If we get a nil result, send a zero
    result ? result[0]['statistic'] : 0.0
  end


  private

  #
  # Determine the from date for this
  # calculation. This may not be used
  # if we already have a calculation
  # later than this, but that will be
  # determined later.
  #
  # @param timeframe The timeframe to determine the from date
  # @param calculation The statistic calculation this is for
  #
  def self.from_date(timeframe, calculation)
    if timeframe.timeframe_type == 'DAILY' && calculation.from_period > 0
      Time.zone.now.beginning_of_day - calculation.from_period.days
    else
      unit = timeframe.aggregate_level
      quant = timeframe.aggregate_length
      meth = :days

      if unit.upcase == 'W'
        meth = :weeks
      elsif unit.upcase == 'M'
        meth = :months
      elsif unit.upcase == 'S'
        meth = :minutes
      end

      Time.zone.now.beginning_of_day - quant.send(meth)
    end
  end

  #
  # Determin the end date for this
  # calculation.
  #
  # @param timeframe The timeframe to determine the end date
  # @param calculation The statistic calculation this is for
  #
  def self.end_date(timeframe, calculation)
    if timeframe.timeframe_type == 'DAILY' && calculation.from_period > 0
      Time.zone.now.beginning_of_day - calculation.to_period.days
    else
      (Time.zone.now - 1.day).end_of_day
    end
  end

end
