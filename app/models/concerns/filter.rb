require 'active_support/concern'

module Filter
  
  def self.included(base)
    base.extend ClassMethods
    @@included_class = base
  end

  module ClassMethods
    def date_filter(start_date = nil, end_date = nil, date_field = nil, model = nil)
      clean_field = date_field.to_s.include?("#{self.table_name}.") ? date_field.to_s.gsub("#{self.table_name}.",'') : date_field.to_s
      if column_names.include? clean_field
        if start_date.present? && end_date.present?
          if model.nil?
            where("#{date_field}" => start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
          else
            where("#{model.to_s.pluralize}.#{date_field }" => start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
          end
        elsif start_date.present?
          if model.nil?
            where("#{date_field} >= ?", start_date.to_date.beginning_of_day)
          else
            where("#{model.to_s.pluralize}.#{date_field} >= ?", start_date.to_date.beginning_of_day)
          end
        elsif end_date.present?
          if model.nil?
            where("#{date_field} <= ?", end_date.to_date.end_of_day)
          else
            where("#{model.to_s.pluralize}.#{date_field} <= ?", end_date.to_date.end_of_day)
          end
        else
          where(nil)
        end
      else
        where(nil)
      end
    end

    def filter(filter_criteria = nil, db_field = nil, model = nil)
      clean_field = db_field.to_s.include?("#{self.table_name}.") ? db_field.to_s.gsub("#{self.table_name}.",'') : db_field.to_s
      if column_names.include? clean_field
        if filter_criteria.present? && db_field.present?
          if ActiveRecord::Base.connection.adapter_name=="PostgreSQL"
            if model.nil?
              where("#{db_field} ILIKE ?", "%#{filter_criteria}%")
            else
              where("#{model.to_s.pluralize}.#{db_field} ILIKE ?", "%#{filter_criteria}%")
            end
          else
            if model.nil?
              where("#{db_field} LIKE ?", "%#{filter_criteria}%")
            else
              where("#{model.to_s.pluralize}.#{db_field} LIKE ?", "%#{filter_criteria}%")
            end
          end
        else
          where(nil)
        end
      else
        where(nil)
      end
    end

    def filter_by_owner(owner_params = {})
      #
      # filter by owner
      # loop through each of the owner types and
      # save the model and param in a hash
      # then remove the nils by using compact which
      # will then only return a single key value hash
      # example: {"Member" => 10}
      #
      filter_criteria = {}

      %w(Installation Member Client Merchant).each { |owner|
        filter_criteria[owner] = owner_params["#{owner.downcase.to_sym}"]
        filter_criteria[owner] = nil unless filter_criteria[owner].present?
      }
      filter_criteria = filter_criteria.compact.to_a.last


      if filter_criteria.present?
        where(owner_type: filter_criteria.first, owner_id: filter_criteria.last)
      elsif owner_params[:user]
        where(owner_type: owner_params[:user].owner_type, owner_id: owner_params[:user].owner_id)
      elsif owner_params[:user].nil?
        where(nil)
      end
    end

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
        valid_fields = []
        fields.each do |field|
          # TODO-AN we need to make sure that the columns exist
          # if column_names.include?(field.to_s) || column_names.include?(field.to_s[(self.name.downcase.pluralize.length + 1)..-1])
          valid_fields << field
          # end
        end
        query = ""
        if ActiveRecord::Base.connection.adapter_name=="PostgreSQL"
          query = valid_fields.map { |f| "CAST(#{f} as VARCHAR(MAX)) ILIKE ? " }.join(' OR ') unless valid_fields.empty?
        else
          query = valid_fields.map { |f| "CAST(#{f} as VARCHAR(MAX)) LIKE ? " }.join(' OR ') unless valid_fields.empty?
        end
        searches = Array.new(valid_fields.count, "%#{search}%")
        where(query, *searches)
      else
        where(nil)
      end
    end

    def process_order_params(params=nil)
      if params
        order_table = params.select { |key, value| /^order\d+$/.match(key.to_s) }.values
        final_order_tbl = []
        order_table.each do |ord_field|
          case ord_field[-4..-1]
            when "_ASC" then
              if column_names.include? ord_field[0..-5]
                if ord_field[0..1] == 'id'
                  final_order_tbl << ("#{self.table_name}"+'.'+"#{ord_field[0..-5].to_s}")
                else
                  final_order_tbl << "#{ord_field[0..-5]} ASC"
                end
              end
            when "DESC" then
              if column_names.include? ord_field[0..-6]
                if ord_field[0..1] == 'id'
                  final_order_tbl << ("#{self.table_name}"+'.'+"#{ord_field[0..-6].to_s}"+' DESC')
                else
                  final_order_tbl << "#{ord_field[0..-6]} DESC"
                end
              end
          end
        end
        final_order_tbl.join(",")
      end
    end

    def report_type(current_user)
      if current_user.as_json[:role] == :user
        where(report_type: 'operational_merchant')
      else
        where(nil)
      end
    end

    def filter_by_hierarchy(sym, id)
      if !id.nil?
        where("#{sym}.id =?", id)
      else
        where(nil)
      end
    end

    # Search we have in place gets confused with ambiguity column references,
    # database raises "column reference "name" is ambiguous"
    def search_customer(reference, search=nil, *fields)
      if search
        valid_fields = []
        fields.each do |field|
          # TODO-AN we need to make sure that the columns exist
          # if column_names.include?(field.to_s) || column_names.include?(field.to_s[(self.name.downcase.pluralize.length + 1)..-1])
          valid_fields << field
          # end
        end
        query = ""
        if ActiveRecord::Base.connection.adapter_name=="PostgreSQL"
          query = valid_fields.map { |f| "CAST(#{reference}.#{f} as VARCHAR) ILIKE ? " }.join(' OR ') unless valid_fields.empty?
        else
          query = valid_fields.map { |f| "CAST(#{reference}.#{f} as VARCHAR) LIKE ? " }.join(' OR ') unless valid_fields.empty?
        end
        searches = Array.new(valid_fields.count, "%#{search}%")
        where(query, *searches)
      else
        where(nil)
      end
    end
  end
end