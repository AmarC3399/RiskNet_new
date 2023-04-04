class AlertAuthorizer
  class ClientRelatedQuery
    attr_reader :scope, :user

    def initialize(v, u); @scope, @user = v, u; end

    def qry; 'alerts.*, reminders.id as reminder_id, reminders.reason, reminders.reminder_time, reminders.alert_created_at, reminders.expired, reminders.cleared, reminders.cleared_on, reminders.job_id, reminders.alert_id'; end

    def c_qry;   ', clients.contact, clients.country, clients.name, clients.open_date, clients.post_code '; end

    def mer_qry; ', merchants.contact, merchants.country, merchants.name, merchants.open_date, merchants.post_code '; end

    def client_qry
      scope.joins(:client).select(qry + c_qry).where(alerts: {alert_owner_id: user.owner_id, alert_owner_type: user.owner_type})
    end

    def merchant_qry
      scope.joins(:merchant).joins(' INNER JOIN clients on clients.id = merchants.client_id').select(qry + mer_qry).where(clients: {id: user.owner_id})
    end
  end
end
