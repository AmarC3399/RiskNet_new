class StatisticTable < ApplicationRecord

  has_many :statistic_calculations
  belongs_to :statistic_timeframe
  belongs_to :containing_statistic_table, :class_name => 'StatisticTable', :foreign_key => 'containing_statistic_table_id'
  has_many :contained_statistic_tables, :class_name => 'StatisticTable', :foreign_key => 'containing_statistic_table_id'
  belongs_to :populated_containing_statistic_table, :class_name => 'StatisticTable', :foreign_key => 'populated_containing_statistic_table_id'
  has_many :populated_contained_statistic_tables, :class_name => 'StatisticTable', :foreign_key => 'populated_containing_statistic_table_id'
  has_many :statistics, through: :statistic_calculations
  belongs_to :owner, polymorphic: true

  scope :active, -> { where(deleted: false).joins(:statistics).uniq }
  scope :containing, -> { where(deleted: false).where(containing_statistic_table_id: nil) }
  scope :contained, -> { where(deleted: false).where.not(containing_statistic_table_id: nil) }

  attr_accessor :queryable_name
  attr_accessor :queryable_created
  attr_accessor :queryable_ddl
  attr_accessor :writeable_name

  before_create do
    self.name = self.class.unique_name
  end

  # Class methods
  def self.create_from_statistic_calculation(calculation)
    unless calculation.criterion.blank? || calculation.rule.blank? || calculation.rule.blank? || calculation.statistic.blank?
      fl = FieldList.lazy_load_auths.find_by(name: "#{calculation.rule.owner.class.name.downcase}_id")
      builder = QueryBuilder::StatQueryBuilder.builder_for_calculation(calculation,
                                                                       calculation.statistic,
                                                                       calculation.statistic_timeframe,
                                                                       calculation.statistic.statistics_operation,
                                                                       calculation.statistic.field_list,
                                                                       calculation.rule.owner,
                                                                       fl,
                                                                       calculation.statistic.criterion
                                                                       )
      table_details = builder.statistic_table_hash
      st = self
      .find_or_create_by(
          table_ddl: table_details[:table_ddl],
          index_ddl: table_details[:index_ddl],
          where_dml: table_details[:where_dml],
          sql_column_list: table_details[:sql_column_list],
          statistic_timeframe_id: table_details[:statistic_timeframe_id],
          from_period: table_details[:from_period],
          from_period_seconds: table_details[:from_period_seconds],
          owner: calculation.owner
      )
      calculation.statistic_table = st
      calculation.save
      # detect_overlaps unless eval(ENV['DETECT_ST_OVERLAPS_IN_DB'])

    end
  end

  def self.unique_name
    "st_#{DateTime.current.strftime('%Q')}"
  end

  def self.detect_overlaps
    # Overlaps where fields are identical and time periods are longer
    groups = StatisticTable.active.group_by {|t| [t.where_dml,t.index_ddl]}
    groups.each do |g|
      sorted = g[1].sort_by {|t| t.from_period_seconds}.reverse
      sorted[0].containing_statistic_table = nil
      sorted[0].save
      sorted.drop(1).each {|t| t.containing_statistic_table = sorted[0]; t.save}
    end
    # Overlaps where one table may contain extra fields and time periods are equal or longer
    StatisticTable.active.where(containing_statistic_table_id: nil).each do |st|
      contained = st.contained_statistic_tables
      new_container = StatisticTable.active
                          .where(containing_statistic_table_id: nil, where_dml: st.where_dml)
                          .where("from_period_seconds >= #{st.from_period_seconds}")
                          .where.not(id: st.id)
                          .select do |t|
        astat = st.statistic_calculations.first.statistic
        bstat = t.statistic_calculations.first.statistic
        bstat.grouping_factor == astat.grouping_factor &&
            bstat.field_list == astat.field_list &&
            bstat.criterion &&
            bstat.criterion.leftable.is_a?(FieldList)
            astat.criterion == nil
      end.first
      if new_container
        st.containing_statistic_table = new_container; st.save
        contained.each {|c| c.containing_statistic_table = new_container; c.save}
      end
    end

    # Overlaps where calculation is a count (id) and can be satisfied by a table with extra fields
    id_field = FieldList.find_by(model_type: 'Authorisation', name: 'id')
    StatisticTable.active.where(containing_statistic_table_id: nil)
      .select {|t| t.statistic_calculations.first.statistic.field_list == id_field}
      .each do |st|
      contained = st.contained_statistic_tables
      new_container = StatisticTable.active
                          .where(containing_statistic_table_id: nil, where_dml: st.where_dml)
                          .where("from_period_seconds >= #{st.from_period_seconds}")
                          .where.not(id: st.id)
                          .select do |t|
        t.statistic_calculations.first.statistic.grouping_factor == st.statistic_calculations.first.statistic.grouping_factor
      end.first
      if new_container
        st.containing_statistic_table = new_container; st.save
        contained.each {|c| c.containing_statistic_table = new_container; c.save}
      end
    end
  end

  # Instance methods
  def queryable_statistic_table
    if self.populated_containing_statistic_table then
      populated_containing_statistic_table
    elsif self.populated then
      self
    else
        nil
    end

  end

  def delete
    self.transaction do
      self.update_attributes(deleted: true)
      # self.class.detect_overlaps unless eval(ENV['DETECT_ST_OVERLAPS_IN_DB'])
    end
  end

  def create_in_database
    # We will run this DB side to account for replication
  end

  def drop_in_database
    # We will run this DB side to account for replication
  end

  def db_details
    DatabaseFunctions.table_list(table: self.name)
  end

  def quote_col(name)
    ActiveRecord::Base.connection.quote_column_name(name)
  end

end
