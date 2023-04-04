class ReportSerializer < ApplicationSerializer
  include ActionView::Helpers::TextHelper
  include ValidJsonHelper

  attributes :id, :report_type, :date_range, :date_range_humanised, :created_by, :last_execution, :deleted, :created_by_id, :created_at, :updated_at, :title, :report_grouping, :report_definition
  has_many :report_results


  def include_report_grouping?
    valid_json?(object.report_grouping)
  end

  def include_report_definition?
    valid_json?(object.report_grouping)
  end  

  # 
  # Convert the ralative date range 
  # into a human readable format
  # 
  def date_range_humanised
    # "day, 0" = Today
    # "day, 1" = Yesterday
    # "week,1" = Last week
    # "month,1" = Last Month
    # "month, 3, false, true" = Last 3 Months
    # "year, 0, true" = This year to Date
    str = ""
    date_range = object.date_range.split(',').map(&:strip)
    
    # check to make sure this is a relative date range
    if date_range.count >= 2
      if date_range.second.to_i > 0
        if date_range.first == "day" && date_range.second.to_i == 1
          str += "Yesterday"
        else
          str += "Last "
          if date_range.second.to_i > 1
            str += pluralize(date_range.second.to_i, "#{date_range.first}")
          else
            str += "#{date_range.first}"
          end
        end
      else
        if date_range.first == "day"
          str += "Today"
        else
          str += "This #{date_range.first}"
        end
      end

      if date_range.third.to_b.is_a? TrueClass
        str += " to date"
      end
    else
      # just return the date range as normal
      str = object.date_range
    end
    
    # return str
    str
  end

  def report_grouping
    results = Hash.new {|h,k| h[k]=[]}
    parsed_json = JSON.parse(object.report_grouping, symbolize_names: true)

    # 
    # Merchants
    if parsed_json[:merchant].present?
      parsed_json[:merchant].each do |field_id|
        item = Merchant.select(:id, :name).find(field_id)
        results[:merchant] << {id: item.id, name: item.name}
      end
    else
      results[:merchant] << {name: 'all'}
    end

    #
    # Members
    if parsed_json[:member].present?
      parsed_json[:member].each do |member_id|
        item = Member.select(:id, :name).find(member_id)
        results[:member] << {id: item.id, name: item.name}
      end
    end

    results
  end

  def report_definition
    results = Hash.new {|h,k| h[k]=[]}
    
    parsed_json = JSON.parse(object.report_definition, symbolize_names: true)

    parsed_json[:fields].each do |field_id|
      item = ListItem.find(field_id)
      results[:fields] << {id: item.id, frontend_name: item.frontend_name}
    end if parsed_json[:fields].present?

    # 
    # sorted_by
    if parsed_json[:sorted_by].present?
      results[:sorted_by] = []
      sorted_field_ids = parsed_json[:sorted_by]
      sorted_field_ids.each do |i|
        item = ListItem.find(i)
        results[:sorted_by] << {id: item.id, frontend_name: item.frontend_name}
      end
    end

    results
  end

end
