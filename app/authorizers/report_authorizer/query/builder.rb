####################################
# Query Builder for USER HIERARCHY #
####################################

class ReportAuthorizer
  module Query
    class Builder
      SELECT_USER  = 'select u.* from users u
                       inner join users_roles ur on ur.user_id = u.id
                       inner join roles r on r.id = ur.role_id '
      WHERE        = ' WHERE '
      INNER_JOIN   = ' inner join '

      BRACKET_OPEN  = ' ('
      BRACKET_CLOSE = ') '
      BRACKET_CLOSE_OR = ') OR'

      WITH_ROLES    = ' and r.name in'


      ADMIN = 'admin'
      RULE_MANAGER = 'rule_manager'
      USER  = 'user'


      class << self
        include UserHierarchy::GroundRule::CurrentSession
        include UserHierarchy::GroundRule::Info

        def client_qry
          "u.owner_id in (select c.id from members m
                            inner join clients c on c.member_id = m.id
                            where m.id = #{self.session_user.owner.member_id rescue self.session_user.owner_id}
                          ) and
            u.owner_type = 'Client'"
        end

        def merchant_qry
          "u.owner_id in (select mer.id  from merchants mer
                           where mer.client_id in (select c.id from members m
                                                    inner join clients c on c.member_id = m.id
                                                    where m.id = #{self.session_user.owner.member_id rescue self.session_user.owner_id}
                                                  )
                         ) and
           u.owner_type = 'Merchant' "
        end

        def merchant_qry_for_client
          "u.owner_id in (select mer.id from merchants mer
                           inner join clients c on c.id = mer.client_id
                           inner join members m on m.id = mer.member_id
                           where mer.member_id = #{self.session_user.owner.member_id} and
                                 mer.client_id = #{self.session_user.owner_id}
                         ) and
           u.owner_type = 'Merchant' "
        end

        def user_owner_id;  " and u.owner_id = #{user.owner_id}"; end

        def member
          if user.has_role? :admin, user.owner
            "(u.owner_id = #{user.owner_id} and u.owner_type = 'Member') OR "
          elsif user.has_role? :rule_manager, user.owner
            "(u.owner_id = #{user.owner_id} and u.owner_type = 'Member' and (r.name = 'rule_manager' or r.name = 'user') ) OR "
          elsif user.has_role? :user, user.owner
            "(u.owner_id = #{user.owner_id} and u.owner_type = 'Member' and r.name = 'user') OR "
          end
        end

        def client
          if (user.has_any_role?(*admin_rule_and_operator) && owner_type_is_member?) || (user.has_any_role?(admin) && owner_type_is_client?)

            if owner_type_is_member?
              BRACKET_OPEN + client_qry + WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}', '#{ADMIN}'" + BRACKET_CLOSE + BRACKET_CLOSE_OR
            else
              BRACKET_OPEN + client_qry + user_owner_id + WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}', '#{ADMIN}'" + BRACKET_CLOSE + BRACKET_CLOSE_OR
            end

          elsif user.has_any_role?(rule_manager) && owner_type_is_client?
            BRACKET_OPEN + client_qry + user_owner_id + WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}'" + BRACKET_CLOSE + BRACKET_CLOSE_OR
          elsif user.has_any_role?(operator) && owner_type_is_client?
            BRACKET_OPEN + client_qry + user_owner_id + WITH_ROLES + BRACKET_OPEN + "'#{USER}'" + BRACKET_CLOSE + BRACKET_CLOSE_OR
          end
        end

        def merchant
          if (user.has_any_role?(*admin_rule_and_operator) && owner_type_is_member?)  || (user.has_any_role?(*admin_rule_and_operator) && owner_type_is_client?) || (user.has_any_role?(admin) && owner_type_is_merchant?) # if user.has_any_role?(*admin_and_rule) && (owner_type_is_member? || owner_type_is_client? || owner_type_is_merchant?)

            if owner_type_is_member?
              BRACKET_OPEN + merchant_qry +  WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}', '#{ADMIN}'" + BRACKET_CLOSE + BRACKET_CLOSE
            elsif owner_type_is_client?
              BRACKET_OPEN + merchant_qry_for_client +  WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}', '#{ADMIN}'" + BRACKET_CLOSE + BRACKET_CLOSE
            else
              BRACKET_OPEN + merchant_qry + user_owner_id +  WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}', '#{ADMIN}'" + BRACKET_CLOSE + BRACKET_CLOSE
            end

          elsif user.has_any_role?(rule_manager) && owner_type_is_merchant?
            BRACKET_OPEN + merchant_qry + user_owner_id +  WITH_ROLES + BRACKET_OPEN + "'#{USER}', '#{RULE_MANAGER}' " + BRACKET_CLOSE + BRACKET_CLOSE
          elsif user.has_any_role?(operator) && owner_type_is_merchant?
            BRACKET_OPEN + merchant_qry + user_owner_id +  WITH_ROLES + BRACKET_OPEN + "'#{USER}'" + BRACKET_CLOSE + BRACKET_CLOSE
          end
        end
      end
    end
  end
end