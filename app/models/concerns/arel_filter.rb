require 'active_support/concern'

module ArelFilter


    def date_filter(start_date = nil, end_date = nil, date_field)
      if column_names.include? date_field.to_s
        if start_date || end_date
          where(table[date_field].gteq(DateTime.parse(start_date))) if start_date
          where(table[date_field].lteq(DateTime.parse(end_date))) if end_date
        end
      end
    end

    def filter(filter_criteria = nil, db_field)
      if column_names.include? db_field.to_s
        if filter_criteria.present? && db_field.present?
          where(table[db_field].eq(filter_criteria))
        end
      end
    end

    # TODO: Make this work
    def match_filter(filter_criteria = nil, db_field)
      if filter_criteria.present? && db_field.present?
        split_criteria = filter_criteria.upcase.split(",")
        if column_names.include? db_field.to_s
          where(db_field.to_sym => split_criteria)
        else
          where(nil)
        end
      else
        where(nil)
      end
    end

    # TODO: Make this work
    def boolean_filter(filter_criteria = nil, db_field)
      if column_names.include? db_field.to_s
        if filter_criteria.present? && db_field.present?
          if filter_criteria == true || filter_criteria =~ (/(true|t|yes|y|1)$/i) || filter_criteria=="1"
            bool_result =true
          elsif filter_criteria == false || filter_criteria.blank? || filter_criteria =~ (/(false|f|no|n|0)$/i) || filter_criteria=="0"
            bool_result = false
          end
          where(:"#{db_field}" => bool_result)
        else
          where(nil)
        end
      else
        where(nil)
      end
    end

    def search(search=nil, *fields)
      if search
        exact_fields = []
        inexact_fields = []
        fields.each do |field|

          if FieldList.where(model_type: model).with_data_type(["integer", "decimal", "datetime"]).where(name: field.to_s).first
            exact_fields << field if is_numeric?(search)
          else
            if FieldList.where(model_type: model).where(name: field.to_s).first
              inexact_fields << field
            end
          end

        end

        conditions = []
        exact_fields.each { |c| conditions << table[c].eq(search) }
        inexact_fields.each { |c| conditions << table[c].matches("%#{search}%") }
        if conditions.length > 0
          search_any = conditions.inject { |conditions, condition| conditions.or(condition).expr }
          where(table.grouping(search_any))
        else
          where(nil)
        end
      end
    end

    # TODO: Make this work
    def process_order_params(params=nil)
      if params
        order_table = params.select { |key, value| /^order\d+$/.match(key.to_s) }.values
        final_order_tbl = []
        order_table.each do |ord_field|
          case ord_field[-4..-1]
            when "_ASC" then
              final_order_tbl << "#{ord_field[0..-5]} ASC" if column_names.include? ord_field[0..-5]
            when "DESC" then
              final_order_tbl << "#{ord_field[0..-6]} DESC" if column_names.include? ord_field[0..-6]
          end
        end
        final_order_tbl.join(",")
      end
    end

    def column_names
      self.froms[0].name.classify.constantize.column_names
    end

    def table
      self.froms[0]
    end

    def model
      table.name.classify.constantize
    end

    def is_numeric?(value)
      true if Float(value) rescue false
    end
  end
