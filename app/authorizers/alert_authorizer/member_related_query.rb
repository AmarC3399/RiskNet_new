class AlertAuthorizer
  class MemberRelatedQuery
    attr_reader :scope, :user

    def initialize(v, u); @scope, @user = v, u; end

    def qry; 'alerts.*, reminders.id as reminder_id, reminders.reason, reminders.reminder_time, reminders.alert_created_at, reminders.expired, reminders.cleared, reminders.cleared_on, reminders.job_id, reminders.alert_id'; end

    def m_qry;   ', members.contact, members.country, members.name, members.open_date, members.post_code '; end

    def c_qry;   ', clients.contact, clients.country, clients.name, clients.open_date, clients.post_code '; end

    def mer_qry; ', merchants.contact, merchants.country, merchants.name, merchants.open_date, merchants.post_code '; end

    def member_qry; scope.joins(:member).select(qry + m_qry ).where(members: {id: user.owner_id}); end

    def client_qry; scope.joins(:client).select(qry + c_qry).where(clients: {member_id: user.owner_id}); end

    def merchant_qry; scope.joins(:merchant).select(qry + mer_qry).where(merchants: {member_id: user.owner_id}); end
  end
end
