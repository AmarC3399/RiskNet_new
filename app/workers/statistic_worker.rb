require 'query_builder'

module App
  module Workers
    class StatisticWorker

      # optional, only needed if you pass config options to the job
      def initialize(options = {})
        @options = options
        @timeout = false
      end

      def run
        # StatisticCalculation.all.each do |calc|
        #   criterion = calc.criterion
        #   if calc.statistic
        #     unless criterion.blank? || criterion.rule.blank?
        #       unless calc.statistic_timeframe.aggregate_level == 'H'
        #         if calc.statistic.grouped
        #           StatisticGroupResult.create_from_statistic_calculation(calc)
        #         else
        #           StatisticResult.create_from_statistic_calculation(calc)
        #         end
        #       end
        #     end
        #   end
        # end
        # if ENV['COVERING_INDEX_CREATE_SCHEDULED']
        #   #Drop unused indexes (if rule is deleted, or if statistic_calculation is gone)
        #   StatisticIndex.all.select { |i| i.statistic_calculations.blank? || (i.statistic_calculations.map {|c| c.rule.deleted}.exclude? (false)) }.each {|i| i.delete}
        #   #Rotate existing indexes
        #   (StatisticCalculation.all.map {|c| c.statistic_index }.uniq-[nil]).each { |i| i.replace_in_database if !i.deleted}
        #   #Create indexes if any are missing
        #   StatisticCalculation.all.select{ |c| (!c.statistic_index || c.statistic_index.deleted) &&  (!c.criterion.blank? && !c.rule.blank? && !c.rule.deleted) }.each { |c| StatisticIndex.create_from_statistic_calculation(c)}
        #   #Remove any redundant indexes
        #   StatisticIndex.contained.each {|i| i.drop_in_database(i.name)}
        # end
        StatisticTable.all.select { |i| i.statistic_calculations.blank? || (i.statistic_calculations.map {|c| c.rule.deleted}.exclude? (false)) }.each {|i| i.delete}
        StatisticCalculation.all.select{ |c| (!c.statistic_table || c.statistic_table.deleted) &&  (!c.criterion.blank? && !c.rule.blank? && !c.rule.deleted) }.each { |c| StatisticTable.create_from_statistic_calculation(c)}

      end

      def on_timeout
      end

    end
  end
end