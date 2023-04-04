class CriteriaFormattedSerializer < ApplicationSerializer

  attributes :constraint, :include_empty, :description, :leftable_attributes, :rightable_attributes

  def leftable_attributes    
    left = object.leftable
    Hash.new.tap do |h|
      h[:type] = object.leftable_type
      if object.leftable_type == "FieldList"
        h[:id] = left.id
        h[:calculation] = {
          :calc_type => 'AUTHORISATION'
        }
      else
        h[:calculation] = {
          :statistic_id => left.statistic_id,
          :statistic_timeframe_id => left.statistic_timeframe_id,
          :calc_type => left.calc_type,
          :from_period => left.from_period,
          :to_period => left.to_period
        }        
      end          
    end
  end

  def rightable_attributes
    right = object.rightable
    Hash.new.tap do |h|
      h[:type] = object.rightable_type
      h[:right_operator_value] = object.right_operator_value
      h[:right_operator] = object.right_operator
      if object.rightable_type == "CriteriaParameter"
        h[:parameter] = {
          :value => right.value,
          :data_type => right.data_type
        }
      end
      if object.rightable_type == "StatisticCalculation"
        h[:calculation] = {
          :statistic_id => right.statistic_id,
          :statistic_timeframe_id => right.statistic_timeframe_id,
          :calc_type => 'AUTHORISATION'
        }
      else
        h[:id] = right.id
        h[:calculation] = {
          :calc_type => 'AUTHORISATION'
        }       
      end
    end    
  end

end