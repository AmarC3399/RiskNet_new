# == Schema Information
#
# Table name: agnostic_fields
#
#  id               :integer          not null, primary key
#  name_from_switch :string(255)
#  name             :string(255)
#  description      :string(255)
#  data_type        :string(255)      default("string")
#  created_at       :timestamp        not null
#  updated_at       :timestamp        not null
#

class AgnosticField < ApplicationRecord

  has_many :authorisation_extras
  has_many :authorisations, through: :authorisation_extras

  # avoid using validation because everytime it makes 2 db requests, one per db field
  validates_uniqueness_of :name, :name_from_switch
  validates_inclusion_of :data_type, in: %w( string date integer decimal )

  def self.mass_create(fields={})
    #following quide here https://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
    fields.each_key do |new_field|
      a = AgnosticField.new name_from_switch: new_field, name: new_field, description: ""
      a.save
    end if fields

    #wrapped in transaction per field , pure sql without any integrity check
    #self.transaction do
    #  fields.each do  |new_field|
    #      self.connection.execute "INSERT INTO agnostic_fields (name_from_switch, name) VALUES ('#{new_field}','#{new_field}')"
    #  end
    #end if fields

    # one mass insert
    # TODO-AN WIP
    #self.connection.execute "INSERT INTO agnostic_fields (name_from_switch, name) VALUES #{fields.join(", ")}"
  end

  # CHECK: there is no uniqueness constraint in this class, check if this is necessary
  # def save
  #   super
  #     #rescuing the DB error for indexes and  adding a message to the errors method in objects
  # rescue ActiveRecord::RecordNotUnique
  #   errors.add(:base, "Field already exists")
  #   # to maintain the existing save functionality and keep compatibility
  #   false
  # end
end
