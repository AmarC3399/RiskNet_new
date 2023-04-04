class DataListSerializer < ApplicationSerializer
  
  attributes :id, :name, :data_type, :description, :created_at, :user, :table, :field, :current_rules, :read_only, :owner_type

  def user 
  	object.user.name
  end

  def owner_type
    object.owner_type
  end  

  def table
  	object.field_lists.first.model_type
  end

   def field
  	object.field_lists.first.description
  end

  def current_rules
    object.belongs_to_rules
  end

end