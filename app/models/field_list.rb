# == Schema Information
#
# Table name: field_lists
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  data_type   :string(255)
#  model_type  :string(255)
#  visible     :boolean          default(TRUE)
#  created_at  :timestamp        not null
#  updated_at  :timestamp        not null
#

class FieldList < ApplicationRecord
  cattr_reader :field_list
  include IsSummarisable
  include LowLevelCache
  #include Authority::Abilities

  
  is_summarisable
  scope :ordered, -> { order(created_at: :desc) }
  scope :ordered_by_name, -> { order(name: :asc) }
  scope :ordered_by_model_type, -> { order(model_type: :asc) }
  scope :visible, -> { where(visible: true) }
  scope :ext_provider_fields, -> { where(is_ext_provider_field: true) }
  @@field_list = FieldList.where(visible: true).select(:id, :name, :description)

  #scope :available, -> { where(visible: true) }
  has_many :statistics
  has_many :field_list_mapping_owner
  has_many :enrichments

  after_commit  :create_cache

  has_and_belongs_to_many :data_lists, join_table: "link_field_data_lists"

  def self.lazy_load_auths
    @lazy_load_auths ||= FieldList.where(model_type: 'Authorisation')
  end

  def self.id_for(model = nil, col = nil, full_object=false)
    if full_object
      @@field_list.where(model_type: model, name: col).first if model and col
    else
      @@field_list.where(model_type: model, name: col).first.try(:id) if model and col
    end
  end

  def self.fields_for(model = nil)
    # the order we select info affects the test results..
    # if order changed, update the tests
    if model
      @@field_list.where(model_type: model).select(:id, :name, :description, :data_type) if model
    else
      where(nil)
    end
  end

  def self.with_data_type(data_type = nil)
    # the order we select info affects the test results..
    # if order changed, update the tests
    if data_type
      data_type = ["integer", "decimal"] if data_type == "intimal"
      where(data_type: data_type)
    else
      where(nil)
    end
  end


  def not_for_rules
      # TODO Potentially buggy place - is_ext_provider_field was false in every record I've checked
      # (self.name.include?('user_') && (self.is_ext_provider_field == false))
      self.name.include?('user_') && false
  end
  

  def serializable_hash(options = nil)
    # original will allow you to access the original json object as provided by rails
    # :incl_lists makes sure that the lists are not included unless specified and exist
    if options && options[:original]
      super
    elsif options && options[:user_field] 
      update_description(super(only: [:id, :name, :data_type, :description]), options[:user_field]) 
    elsif options && options[:incl_list] and !self.data_lists.blank?
      super(only: [:id, :name, :data_type, :description], include: :data_lists, for_jpos: options[:for_jpos])
    elsif options
      #if object exists
      super(only: [:id, :name, :data_type, :description], for_jpos: options[:for_jpos])
    else
      super(only: [:id, :name, :data_type, :description])
    end
  end



  def update_description(field_hash, user_field)
      field_hash['description'] = user_field if field_hash['name'].include?('user_')

      field_hash  
  end

  alias_method :cached_fields, :create_cache
  protected
  # Method that provides external provider fields, which are then cached
  def query
    self.class.where(is_ext_provider_field: true).all
              .map {|f| hash = Hash.new; hash[f.name] = f.ext_provider_field_name; hash;}.inject(:merge) 
  end
end