# == Schema Information
#
# Table name: report_results
#
#  id             :integer          not null, primary key
#  result         :text
#  timestamps     :string(255)
#  finished       :boolean
#  start_date     :timestamp
#  end_date       :timestamp
#  executed_by    :string(255)
#  deleted        :boolean
#  executed_by_id :integer
#  report_id      :integer
#  created_at     :timestamp
#  updated_at     :timestamp
#

class ReportResult < ApplicationRecord
  schema_validations unless Rails.env.test?

  belongs_to :report
  belongs_to :executor, class_name: 'User', foreign_key: :executed_by_id

  default_scope { where(deleted: false).order(created_at: :desc) }

  before_save :init_defaults
  # Start an async resulting job as soon as the job record itself has been created.
  after_create :async_result

  def init_defaults
    saved_dates = []
    #
    # first split the date_range
    # remove white space
    # return a Range
    #
    dates = self.report.date_range.split('-').map(&:strip).inject { |s,e| Time.parse(s)..Time.parse(e) }

    if dates.is_a? Range
      saved_dates << dates.first.beginning_of_day#.to_s(:db)
      saved_dates << dates.last.end_of_day#.to_s(:db)
    else
      # else relative dates i.e. last month, 7 days ago, etc
      #
      # put parameters into a hash
      # to be used for "date_range"
      #
      keys = [:calc, :number, :now, :range]
      relatives = [dates.split(',').map(&:strip)]
      parameters = relatives.map{ |r| Hash[keys.zip(r)] }.first
      range = self.send("date_range", parameters)
      saved_dates << range.first
      saved_dates << range.last
    end

    self.finished = false
    self.start_date = saved_dates.first
    self.end_date = saved_dates.last
  end

  # Run blocking resulting in a background worker.
  def async_result
    klass = "report_#{self.report.report_type}_task".classify.constantize.new
    klass.background.run(id: self.id)
  end

  def get_csv(csv)
    json = JSON.parse(self.result, symbolize_names: true)
    headers = []

    json[:headers].each do |header|
      headers << header[:frontend_name]
    end
    csv << headers

    json[:results].each do |result|
      row = []
      json[:headers].each do |header|
        row << result[header[:value].to_sym]
      end
      csv << row
    end
    csv
  end

  private

    # use this method to calculate what the user
    # has selected from the relative date range
    #
    # options are and must be in this order:
    ## calc : string (day,week,month,year)
    ## number : integer (in the past i.e. last 3 months)
    ## now : boolean (does the end date need to be now?)
    ## range : boolean (Last 3 months : could mean the last 3 months in the past i.e. Jan-Mar )
    #
    def date_range(options = nil)
      range = Time.current.send("#{options[:calc].pluralize}_ago", options[:number].to_i)
      if options[:now].to_b.is_a? TrueClass
        range.send("beginning_of_#{options[:calc]}")..Time.zone.now
      elsif options[:range].to_b.is_a? TrueClass
        start_date = range
        end_date = range.send("#{options[:calc].pluralize}_since", (options[:number].to_i - 1))
        start_date.send("beginning_of_#{options[:calc]}")..end_date.send("end_of_#{options[:calc]}")
      else
        range.send("all_#{options[:calc]}")
      end
    end

end
