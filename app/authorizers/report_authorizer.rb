class ReportAuthorizer < ApplicationAuthorizer

  class Scope < Struct.new(:params)
    include UserHierarchy::GroundRule::CurrentSession
    include UserHierarchy::GroundRule::Info
    def resources
      if owner_is_installation?
        Report.search(params[:search], :title)
        .date_filter(params[:start_date], params[:end_date], :created_at, :report)
        .filter(params[:type], :report_type, :report)
        .report_type(self.session_user)
        .order(last_execution: params[:order].present? ? params[:order].downcase.to_sym : 'desc'.to_sym)
      else  
       Report.joins(build_query + ' u on u.id = reports.created_by_id')
        .search(params[:search], :title)
        .date_filter(params[:start_date], params[:end_date], :created_at, :report)
        .filter(params[:type], :report_type, :report)
        .report_type(self.session_user)
        .order(last_execution: params[:order].present? ? params[:order].downcase.to_sym : 'desc'.to_sym)
      end  

    end

    def build_query
      case self.session_user.owner_type
        when 'Member'
          Query::Builder::INNER_JOIN + '(' + Query::Builder::SELECT_USER + Query::Builder::WHERE + Query::Builder.member + Query::Builder.client + Query::Builder.merchant + ')'
        when 'Client'
          Query::Builder::INNER_JOIN + '(' + Query::Builder::SELECT_USER + Query::Builder::WHERE + Query::Builder.client + Query::Builder.merchant + ')'
        when 'Merchant'
          Query::Builder::INNER_JOIN + '(' + Query::Builder::SELECT_USER + Query::Builder::WHERE + Query::Builder.merchant + ')'
      end
    end
  end


  ####################################
  # Query Builder for USER HIERARCHY #
  ####################################
  # class Query
  #   class Builder
  #
  #
  #   end
  # end

  #############
  # CREATABLE #
  #############
  def self.creatable_by?(user=nil); check; end

  def creatable_by?(user = nil || self.session_user)
    return true if owner_is_installation?
    
    if user.has_any_role?(operator)
      return false unless %w(operational_merchant).include? resource.report_type
      return true
    end

    user.has_any_role?(*admin_and_rule) if owner_type_is_member? || owner_type_is_client? || owner_type_is_merchant?
  end

  #############
  # UPDATABLE #
  #############
  def self.updatable_by?(user=nil); check; end

  def updatable_by?(user = nil || self.session_user)
    if user.has_any_role?(operator)
      return false unless %w(operational_merchant).include? resource.report_type
      return true
    end

    user.has_any_role?(*admin_and_rule) if owner_type_is_member? || owner_type_is_client? || owner_type_is_merchant?
  end

  ############
  # READABLE #
  ############
  def self.readable_by?(user=nil); check; end

  def readable_by?(user = nil || self.session_user) # raise "Resource: #{resource.inspect} \n---\n   #{self.session_user.inspect}" # self.class.is_admin?
    # if user.has_role? :user, user.owner
    #   return false unless %w(operation_merchant).include? resource.report_type # return false if %w(fraud_activity rule_efficiency operational_user).include? resource.report_type
    # end
    true
  end


  ##############
  # DELETEABLE #
  ##############



  ################
  # COMMON SETUP #
  ################

  def self.check(user = nil || self.session_user)
    # return false if self.is_merchant?
    return true if owner_is_installation?
    return false unless self.is_admin? or self.is_rule_manager? or self.is_user? # puts caller[0]    # puts caller[0][/`.*'/][1..-2]

    return true
  end

end



# allow operator to create "operation_merchant" report type only
# return false unless %w(operation_merchant).include? resource.report_type if user.has_role? :user, user.owner
#
# roles = [{name: :user, resource: user.owner}]
# if user.owner.is_a?(Member) || user.owner.is_a?(Client)
#   roles = [{name: :admin, resource: user.owner}, {name: :rule_manager, resource: user.owner}]
# end
#
# user.has_any_role?(*roles)






# bracket_open  = ' ('
# bracket_close = ') '
#
# admin_str         = 'admin'
# rule_manager_str  = 'rule_manager'
# user_str          = 'user'
#
# merchant_qry  = "u.owner_id in (select mer.id  from merchants mer
#                                  where mer.client_id in (select c.id from members m
#                                                           inner join clients c on c.member_id = m.id
#                                                           where m.id = #{self.session_user.owner.member_id rescue self.session_user.owner_id}
#                                                         )
#                                ) and
#                  u.owner_type = 'Merchant' and
#                  u.owner_id = #{user.owner_id} "

# merchant_qry  = "u.owner_id in (select mer.id  from merchants mer where mer.client_id in (select c.id from members m inner join clients c on c.member_id = m.id where m.id = #{self.session_user.owner.member_id rescue self.session_user.owner_id})) and u.owner_type = 'Merchant' and u.owner_id = #{user.owner_id} "

# with_roles = ' and r.name in'