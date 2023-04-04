# == Schema Information
#
# Table name: statistic_timeframes
#
#  id               :integer          not null, primary key
#  timeframe_type   :string(255)
#  aggregate_level  :string(255)
#  turnover         :string(255)
#  aggregate_length :integer
#  statistic_id     :integer
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class StatisticTimeframe < ApplicationRecord

  schema_validations unless Rails.env.test?

  has_and_belongs_to_many :statistics, join_table: :join_statistics_timeframes
  has_many :statistic_indices
  has_many :statistic_tables

  include Authority::Abilities
  self.authorizer_name = 'StatisticsAuthorizer'

  def window_size
    aggregate_length.send(unit)
  end

  def window_offset (date, offset)
    date + offset.send(unit)
  end

  def unit
    meth = :days
    if aggregate_level.upcase == 'W'
      meth = :weeks
    elsif aggregate_level.upcase == 'M'
      meth = :months
    elsif aggregate_level.upcase == 'H'
      meth = :hours
    elsif aggregate_level.upcase == 'S'
      meth = :minutes
    end
    meth
  end
end
