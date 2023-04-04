class StatisticIndex < ApplicationRecord

  has_many :statistic_calculations
  belongs_to :statistic_timeframe
  has_many :used_statistic_indices
  belongs_to :containing_statistic_index, :class_name => 'StatisticIndex', :foreign_key => 'containing_statistic_index_id'
  has_many :contained_statistic_indices, :class_name => 'StatisticIndex', :foreign_key => 'containing_statistic_index_id'
  has_many :statistics, through: :statistic_calculations

  scope :active, -> { where(deleted: false).joins(:statistics) }
  scope :containing, -> { where(deleted: false).where(containing: nil) }
  scope :contained, -> { where(deleted: false).where.not(containing_statistic_index_id: nil) }


  before_create do
    self.name = self.class.unique_name
  end

  # Class methods
  def self.create_from_statistic_calculation(calculation)
    unless calculation.criterion.blank? || calculation.rule.blank? || calculation.rule.blank? || calculation.statistic.blank?
      fl = FieldList.lazy_load_auths.where(name: "#{calculation.owner.class.name.downcase}_id").first
      builder = QueryBuilder::StatQueryBuilder.builder_for_calculation(calculation,
                                                                       calculation.statistic,
                                                                       calculation.statistic_timeframe,
                                                                       calculation.statistic.statistics_operation,
                                                                       calculation.statistic.field_list,
                                                                       calculation.rule.owner,
                                                                       fl,
                                                                       calculation.statistic.criterion)
      index_details = builder.covering_index
      si = self
      .find_or_create_by(
         column_ddl: index_details[:column_ddl],
         where_ddl: index_details[:where_ddl],
         date_ddl: index_details[:date_ddl],
         statistic_timeframe_id: index_details[:statistic_timeframe_id],
         from_period: index_details[:from_period]
       )
      calculation.statistic_index = si
      calculation.save
      detect_overlaps
      si.reload
      if si.db_details == nil  # If it is missing we'll need to put it in the database again
        si.create_in_database
        si.update_attributes({deleted: false})
      end

      si
    end
  end

  def self.unique_name
    "index_authorisations_f_#{DateTime.current.strftime('%Q')}"
  end

  def self.detect_overlaps
    indexes = {}
    StatisticIndex.active.each {|i| indexes[i] =
        {start_date: i.statistic_timeframe.window_offset(Time.zone.now,0-i.from_period),
         group_field: i.statistic_calculations.first.statistic.grouping_factor.name,
         field_list: i.statistic_calculations.first.statistic.field_list.name}
    }

    # Find indexes with the same criteria and overlapping dates
    groups = indexes.group_by {|k,v| [k.where_ddl,k.column_ddl,v[:group_field]]}

    groups.each do |g|
      sorted = g[1].sort_by { |i| i[1][:start_date] }
      sorted[0][0].containing_statistic_index = nil
      sorted[0][0].save
      sorted.drop(1).each { |i| i[0].containing_statistic_index = sorted[0][0]; i[0].save }
    end
    # Find indexes using id which can be satisfied by other indexes
    indexes.select {|k,v| v[:field_list] == 'id' }.each do |k,v|
      csi = indexes.select {|kk,vv| k.where_ddl == kk.where_ddl && v[:group_field] == vv[:group_field] && !kk.containing_statistic_index && vv[:field_list] != 'id' }.min_by { |kk,vv| vv[:start_date]}.to_a[0]
      k.containing_statistic_index = csi if csi
      k.save
    end
  end

  # Instance methods
  def delete
    #Check if we are removing a containing index
    self.class.detect_overlaps
    #Create missing ones
    StatisticCalculation.all.select{ |c| (!c.statistic_index || c.statistic_index.deleted) &&  (!c.criterion.blank? && !c.rule.blank? && !c.rule.deleted) }.each { |c| StatisticIndex.create_from_statistic_calculation(c)}
    #Now delete
    self.update_attributes(deleted: true)
    self.class.detect_overlaps if self.contained_statistic_indices
    drop_in_database(self.name)
  end

  def detect_overlaps_and_create_in_db
    self.class.detect_overlaps
    self.create_in_database
  end

  def create_in_database
    if self.containing_statistic_index == nil
      ddl =
          "CREATE INDEX #{quote_col(name)} " \
          "ON authorisations #{column_ddl} "\
          "WHERE #{([where_ddl,"#{date_ddl} > '#{statistic_timeframe.window_offset(Time.zone.now,0-from_period).to_s(:db)}'"]-[nil]).join(' AND ')} "\
          "#{ENV['COVERING_INDEX_OPTIONS']} "
      Rails.logger.info "Created new covering index #{self.name}"
      Rails.logger.info ddl
      Authorisation.connection.execute(ddl)
      ddl
    else
      self.containing_statistic_index
    end
  end

  def drop_in_database(drop_name)
    unless db_details.blank?
      ddl =
          "DROP INDEX #{quote_col(drop_name)} ON authorisations"
      Authorisation.connection.execute(ddl)
      Rails.logger.info "Dropped covering index #{drop_name}"
      Rails.logger.info ddl
      ddl
    end
  rescue Exception => error
    Rails.logger.info error.message
    Rails.logger.info "Ignoring error when dropping an index"
    ddl
  end

  def replace_in_database
    if self.containing_statistic_index == nil
      previous_name = name
      self.name = self.class.unique_name
      ddlc = create_in_database
      ddld = drop_in_database(previous_name)
      UsedStatisticIndex.create_with(name: previous_name, statistic_index_id: self.id).create
      self.save
      [ddlc,ddld]
    else
      self.containing_statistic_index
    end
  end

  def db_details
    DatabaseFunctions.index_list(model: Authorisation).select {|i| i["name"] == self.name}.first
  end

  def quote_col(name)
    ActiveRecord::Base.connection.quote_column_name(name)
  end

end
