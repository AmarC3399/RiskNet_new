class AuthorisationSerializer < ApplicationSerializer
  attributes :id, :latest_fraud, :violation

  def attributes
    data = super
    frontend_columns = scope.present? ? scope.fetch(:column_names, []) : []

    #TODO Potential performance issue (every time on serialization it read file, need to research how it affects on performance. but with file no need to restart servers when new fields added)
    Authorisation.display_columns(frontend_columns).each do |field|
      data[field] = case field
                      when :marked_fraud_date
                        object.latest_fraud.nil? ? '-' : object.latest_fraud.updated_at
                      when :response
                        object.latest_fraud.nil? ? '-' : object.latest_fraud.fraud_status
                      when :alert_id
                        object.violation.nil? ? '-' : object.violation.alert_id
                      else
                        object.public_send(field)
                    end
    end
    data
  end

  def id
    "#{object.id.to_a.first}-#{object.id.last}"
  end
end