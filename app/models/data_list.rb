# == Schema Information
#
# Table name: data_lists
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  data_type   :string(255)
#  description :string(255)
#  created_at  :timestamp        not null
#  updated_at  :timestamp        not null
#  deleted     :boolean          default(FALSE)
#  user_id     :integer
#  read_only   :boolean
#  owner_id    :integer
#  owner_type  :string(255)
#

class DataList < ApplicationRecord
  include Filter
  include IsSummarisable
  include Authority::Abilities

  is_summarisable
  resourcify

  self.authorizer_name = 'DataListAuthorizer'

  has_many :list_items, dependent: :destroy
  accepts_nested_attributes_for :list_items, allow_destroy: true
  has_and_belongs_to_many :field_lists, join_table: "link_field_data_lists"
  belongs_to :user
  belongs_to :owner, polymorphic: true

  validates_presence_of :data_type

  validates :name, uniqueness: { case_sensitive: false, allow_blank: false }

  default_scope { where(deleted: false) }

  scope :search, ->(name) { where('lower(data_lists.name) LIKE ?', "%#{name.downcase}%") }


  def self.get_country_list
    keys = [:name, :alpha3]
    objects = IsoCountryCodes.for_select(:alpha3)
    objects.map { |r| Hash[keys.zip(r)] }
  end

  def self.get_currency_list
    ccys = Money::Currency.all.as_json
    keepers = ["iso_code", "name", "symbol"]
    ccys.map { |j| j.keep_if{ |k, v| keepers.include? k}}
    ccys.uniq {|k| k["name"]}.sort_by {|k| k["name"]}
  end

  def self.read_mccs
    mccs = JSON.parse(File.read(Rails.root+'vendor/external_feeds/mcc_codes.json'))
    keepers = ["mcc", "edited_description"]
    mccs.map { |j| j.keep_if{ |k, v| keepers.include? k}}
    mccs.sort_by {|k| k["edited_description"]}
  end

  @@country_list = get_country_list
  @@currency_list = get_currency_list
  @@mccs_list = read_mccs

  # @@data_list = DataList.joins(:field_lists).where('field_lists.visible = ?', true)

  def self.return_list(list = nil)
    if list == 'country'
      @@country_list
    elsif list == 'ccy'
      @@currency_list
    elsif list == 'mcc'
      @@mccs_list
    end
  end

  def belongs_to_rules
    Criterion.joins(:rule)
        .select('rules.id, rules.internal_code')
        .where(rightable_type: 'DataList', rightable_id: self.id)
        .where('rules.deleted = ?', false)
  end

  def self.list_for(model_type = nil, name = nil)
    scope = self.joins(:field_lists).where('field_lists.visible = ?', true)

    if model_type == "Field"
      scope = scope.where('field_lists.model_type != ?', 'CustomList')
      model_type = nil
    end

    if model_type && name
      scope = scope.where('field_lists.model_type = ? and field_lists.name = ?', model_type, name)
    elsif model_type
      scope = scope.where('field_lists.model_type = ?', model_type)
    else
      scope
    end
  end

  def serializable_hash(options = nil)
    # original will allow you to access the original json object as provided by rails
    if options && options[:original]
      super
      #overriding default in order to return the custom result that RuleEngine requires
    elsif options && options[:include]
      #passing for_jpos either it exists or not.. it doesn't break since options object exists
      super(only: [:id, :name], include: options[:include], for_jpos: options[:for_jpos])
    elsif options
      #if object exists
      super(only: [:id, :name], for_jpos: options[:for_jpos])
    else
      super(only: [:id, :name])
    end
  end
end
