class JposUniqueValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    
    if attribute == :jpos_key
      if is_update?(record)
        if !is_jpos_old?(record, value)
          record.errors.add(attribute, "can not be changed")          
        end
      else
        if find_jpos_in_all_entities(value)
          record.errors.add(attribute, "already taken!")
        end
      end
    else
      puts "\n Man are you validating the wrong attribute with the wrong validator, please delete jpos_unique: true \n"
    end

  end
  
  def find_jpos_in_all_entities(jpos_key)
    return true if Member.where(jpos_key: jpos_key).first
    return true if Client.where(jpos_key: jpos_key).first
    return true if Merchant.where(jpos_key: jpos_key).first
    false
  end
  
  def is_jpos_old?(record=nil, value=nil)
    if record && value
      klass = Object.const_get record.class.name # get the class calling this validator
      old_record = klass.where(jpos_key: value).first #get the record from database
      if old_record
        return true if old_record.jpos_key == value # compare the old and the new values if they are the same
      else
        return false
      end
    end
    return false
  end
  
  def is_update?(record=nil)
    if record && record.id
      return true
    end
    return false
  end
  
end
