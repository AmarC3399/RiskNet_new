class FieldListMappingOwner < ApplicationRecord
  include Filter
  include LowLevelCache

  belongs_to :owner, polymorphic: true
  belongs_to :field_list

  after_save -> { create_cache(true) }
  

	def self.update_field_mappings(params, method_symbol, user)
      if params[:field_type_mappings].present?
        case method_symbol
          when :put 
           params[:field_type_mappings].each { |f| FieldListMappingOwner.find(f['id']).update(name: f['mapping']) }
          when :post
           params[:field_type_mappings].each do |f|
             field = FieldList.find_or_create_by(name: f['column'], model_type: 'Authorisation', data_type: self.translated_data_type(Authorisation.new.column_for_attribute(f['column']).type))
              begin
                FieldListMappingOwner.find_or_create_by(name: f['mapping'], field_list_id: field.id, owner_type: user.owner_type, owner_id: user.owner_id)
              rescue ActiveRecord::RecordNotUnique
                false
              end   
           end
          end    
      end   
  end

	def self.translated_data_type(type)
    case type
      when :decimal
        'integer'
      when :datetime
        'datetime'
      when :string
        'string'
    else
        puts "Exception: unknown type: #{type}"
        raise "Exception: unknown type: #{type}"
    end
  end

  def self.fetch_field_mappings(owner_params, current_user, for_alerts = nil)
      ext_provider_fields = []
      ext_provider_fields = FieldList.ext_provider_fields.map {|field| {column: field.name, mapping: field.description, id: field.id} } if for_alerts

      Authorisation.display_only_fields + ext_provider_fields + self.user_fields(owner_params, current_user)
  end

  def self.user_fields(owner_params, current_user)
      self.filter_by_owner(owner_params.merge(user: current_user)).map {|field| {column: field.field_list.name, mapping: field.name, id: field.id} }
  end    

  def query
      self.class.joins(:field_list).select(SELECT_LIST).as_json.map{|h| h.delete('id'); h}
  end


  alias_method :cached_json, :create_cache

	TABLE_NAME_ONE  = 'field_lists'
	TABLE_NAME_TWO  = 'field_list_mapping_owners'
	SELECT_LIST     = "#{TABLE_NAME_ONE}.name as abstract, #{TABLE_NAME_TWO}.name, #{TABLE_NAME_TWO}.owner_id, #{TABLE_NAME_TWO}.owner_type"
end