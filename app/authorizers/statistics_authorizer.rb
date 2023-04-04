class StatisticsAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:current_user, :scope)

    def resolve
      if current_user.has_role?(:user, :any)
        scope.none
      else
        case current_user.owner_type
        when 'Installation'
          scope
        when 'Member'
          scope.where("(statistic.owner_type = 'Member' AND statistic.owner_id = #{current_user.owner_id}) " \
                        "OR (statistic.owner_type = 'Client' AND statistic.owner_id IN (SELECT DISTINCT clients.id FROM clients WHERE member_id = #{current_user.owner_id})) " \
                        "OR (statistic.owner_type = 'Merchant' AND statistic.owner_id IN " \
                           "(SELECT DISTINCT merchants.id FROM merchants JOIN clients ON merchants.client_id = clients.id WHERE clients.member_id = #{current_user.owner_id}))")
        when 'Client'
          scope.where("(statistic.owner_type = 'Client' AND statistic.owner_id = #{current_user.owner_id}) "\
                        "OR (statistic.owner_type = 'Merchant' AND statistic.owner_id IN (SELECT DISTINCT merchants.id FROM merchants WHERE client_id = #{current_user.owner_id}))")
        when 'Merchant'
          scope.where("(statistic.owner_type = 'Merchant' AND statistic.owner_id = #{current_user.owner_id})")
        end
      end
    end

  end

  def self.creatable_by?(user)
    self.new(self.session_user).statistics_role(user)
  end

  def deletable_by?(user)
    statistics_role(user)
  end

  def self.deletable_by?(user)
    self.new(self.session_user).statistics_role(user)
  end

  def updatable_by?(user)
    statistics_role(user)
  end

  def self.updatable_by?(user)
    self.new(self.session_user).statistics_role(user)
  end

  def readable_by?(user)
    # statistics_role(user)
    true
  end

  def self.readable_by?(user)
    # statistics_role(user)
    true
  end


  # private

  def self.statistics_role(user)
    # return true if user.has_role?(:god, :any)
    # return true if user.has_role?(:rule_manager, :any)
    self.new(self.session_user).statistics_role(self.session_user)
  end

  def statistics_role(user=nil)
    return true if user.has_role?(:god, :any)
    return false unless owner_type_is_member?
    return true if user.has_role?(:rule_manager, :any)
  end

end