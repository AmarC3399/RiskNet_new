# == Schema Information
#
# Table name: authorisation_extras
#
#  id                :integer          not null, primary key
#  val_string        :string(255)
#  val_int           :integer
#  val_date          :timestamp
#  val_curr          :decimal(22, 4)
#  agnostic_field_id :integer
#  authorisation_id  :integer
#  created_at        :timestamp        not null, primary key
#  updated_at        :timestamp        not null
#

class AuthorisationExtra < ApplicationRecord

  self.primary_keys = :created_at, :id
  
  belongs_to :authorisation, foreign_key: [:created_at, :authorisation_id]
  belongs_to :agnostic_field
  before_save :set_data_types
  
  attr_accessor :field_from_switch


  def set_data_types
    self.agnostic_field_id = AgnosticField.where(name_from_switch: field_from_switch).try(:first).try(:id)

    if agnostic_field_id
      case self.agnostic_field.data_type
        when "integer"
          self.val_int = val_string.to_i
        when "decimal"
          temp_decimal = self.val_string.to_f.to_d
          self.val_curr = temp_decimal
        when "date"
          begin
            self.val_date = val_string.to_time
          rescue
            self.val_date = nil
          end
      end
      #begin
      #  self.val_date = val_string.to_time
      #rescue
      #  self.val_date = nil
      #end
    else
      false
    end
  end

end
