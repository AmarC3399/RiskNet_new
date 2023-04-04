# == Schema Information
#
# Table name: list_items
#
#  id            :integer          not null, primary key
#  frontend_name :string(255)
#  value         :string(255)
#  description   :string(255)
#  list_type     :string(255)
#  data_list_id  :integer
#  created_at    :timestamp        not null
#  updated_at    :timestamp        not null
#  visible       :boolean          default(FALSE)
#

class ListItem < ApplicationRecord
	
  belongs_to :data_list
	
  validates_presence_of :frontend_name, :data_list_id, :value
  validates :frontend_name, :value, length: { minimum: 13 }, if: :card_number?
	
  before_create :set_list_type
  before_create :pci_compliant, if: :card_number?
		# before_update :pci_compliant, if: :card_number?
		
		default_scope -> { where(visible: true).order(frontend_name: :asc) }
		
		@@list_Item_not_visible = ListItem.unscoped.where(visible: false)
		
		def self.not_visible
			@@list_Item_not_visible
		end
		
		def set_list_type
			self.list_type = self.data_list.name
		end
		
		def serializable_hash(options={})
			# the id should match the statistic calculation id in order for Rule Engine to
			# make the match when receiving the data
			# original will allow you to access the original json object as provided by rails
			if options && options[:original]
				super
			else
				super(only: [:id,:value,:data_list_id])
			end
		end
		
		#Export to CSV(list items)
		def self.to_csv
			require 'csv'
			attributes = %w{frontend_name value}
			CSV.generate(headers: true) do |csv|
				all.each do |item|
					csv << attributes.map{ |attr| item.send(attr) }
				end
			end
		end
		
    def self.validate_csv(csv_array)
      results = {status: false, errors: []}
      if csv_array.count <= 0
        results[:errors] << I18n.t('models.list_item.import.file_is_empty')
        return results
      end
      if csv_array.count > RiskNet.list_max_size.to_i
        results[:errors] << I18n.t('models.list_item.import.list_max_size')
        return results
      end
      results[:status] = true
      return results
    end
    
    def self.validate_datatype(row, data_type)
      flag = false;
      case data_type
      when "integer"
        then
        flag =  valid_integer?(row[1])
      when "decimal"
        then
        flag = valid_float?(row[1])
      when "datetime"
        then
        flag = valid_datetime?(row[1])
      when "string"
        flag = true
      else
        flag = false
      end
      return flag
    end
    
    def self.validate_csv_row(row, index)
      results = {status: false, errors: []}
      if row.empty? || row[0].nil? || row[1].nil?
        results[:errors] << I18n.t('models.list_item.import.empty_values_at_line', line_number: index+1)
        return results
      end
      if row.count >= 3
        results[:errors] << I18n.t('models.list_item.import.extra_values_at_line', line_number: index+1)
        return results
      end
      results[:status] = true
      return results
    end
    
    def self.build_sql_query(item, data_list)
      return "('#{item.frontend_name}','#{item.value}','#{data_list.name}','#{data_list.id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,'1')"
    end
    
		#Import from CSV(list items)
		def self.import_csv(file , data_list_id, user)
      require 'csv' unless defined?(CSV)
			data_list = DataList.find(data_list_id)
      results = {status: false, errors: []}

      unless user.can_update?(data_list)
       results[:errors] << I18n.t('models.list_item.import.list_update_not_permitted') 
       return results
      end 
      
      values = []
			if data_list
        csv_array = CSV.read(file.path)
        results = validate_csv(csv_array)
        return results unless results[:status]
				csv_array.each_with_index do |row,index|
          results = validate_csv_row(row, index)
          return results unless results[:status]
					if validate_datatype(row, data_list.data_type)
            item = new({frontend_name: row[0], value: row[1], data_list_id: data_list_id })
            item.send(:pci_compliant) if item.send(:card_number?)
						values <<  build_sql_query(item, data_list)
					else
						results[:errors] << I18n.t('models.list_item.import.datatype_does_not_match', line_number: index+1)
            results[:status] = false
            return results
					end					
				end
        transaction do
          data_list.list_items.delete_all
          values.each_slice(1000) do |value|
            sql_query = "INSERT INTO list_items (frontend_name, value, list_type, data_list_id, created_at, updated_at, visible) VALUES "
            sql_query += value.join(',')
            sql_query += ";"
            ActiveRecord::Base.connection.execute(sql_query)
          end
        end
        results[:status] = true
				return results
			end
		end
		
		
		private
		
		def self.valid_integer?(value)
			/\A[-+]?\d+\z/ === value
    end
		
		def self.valid_float?(value)
			!!Float(value) rescue false
		end
		
		def self.valid_datetime?(value)
			!!DateTime.parse(value).is_a?(DateTime) rescue false
		end

    def card_number?
     field = self.data_list.field_lists.first

     case field.nil?
       when false
        return true if (field.model_type == 'Authorisation') && (field.name == 'card_number')
      when true
        return false
     end

     false
    end
		
		def pci_compliant
			card_number = CardNumber.new(self.frontend_name)
			self.frontend_name = card_number.masked_card_number
			self.value = card_number.hashed_value
		end
		
	end
