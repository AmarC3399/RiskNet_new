class RulesController < ApplicationController
  authorize_actions_for Rule, actions: {all: :read,
    activate: :update,
    deactivate: :update,
    disable: :delete,
    live: :update,
    authorisation_ids: :read,
    show: :read,
    create: :create
  }
  before_action :set_rule, only: [:show, :update, :destroy, :authorisation_ids]
  
  def all
     calc_limit = 16
    calc_offset = ([params[:page].to_i.abs, 1].max - 1) * calc_limit
    calc_order = Rule.process_order_params(params)
    
    
    @rules = RuleAuthorizer::Scope.new(current_user, Rule).resolve.includes(:criteria, :owner)
                .boolean_filter(params[:type], :active)
                .date_filter(params[:start_date], params[:end_date], :created_at)
                .search(params[:search], "rules.internal_code", :priority, :description)
                .filter_by_owner(params[:only_mine] ? params.merge(user: current_user) : params)
                .order(calc_order.empty? ? "rules.updated_at DESC" : calc_order)
                .limit(calc_limit)
                .offset(calc_offset || 0)
    # puts @rules.to_sql
    total_items = @rules.except(:limit, :offset).count
    
    # render json: { rules: @rules.as_json(root: false), criteria: {original: true}, meta: { total: total_items, itemsPerPage: calc_limit, totalPages: (total_items / calc_limit), currentPage: params[:page].to_i}}.as_json
    render json: @rules, criteria: {original: true}, root: 'rules', meta: page_meta_info(total_items, calc_limit, params[:page])
    # render json: @rules, include: [{criteria: {original: true}}], root: false
  end

  def show
     authorize_action_for @rule
    if params[:formatted].present?
      render json: @rule, formatted: true, root: 'rule'
    else
      render json: @rule, criteria: {original: false}
    end
  end

  def create
    authorize_action_for Rule.new(rule_params)
    
    @rule = Rule.new(rule_params)
    owner = rule_owner(params[:rule][:owner_id], params[:rule][:owner_type])
    @rule.owner =  owner.nil? ? current_user.owner : owner.first

    if params["opts"].present? && (params["opts"]["action"] == "clone" || params["opts"]["action"] == "edit")
      if params["opts"]["action"] == "clone"
        parent_rule_count = Rule.where(parent_id: rule_params["parent_id"]).count

        if parent_rule_count > 0
          @rule.internal_code = "#{parent_rule_count}-#{@rule.internal_code}"[0..99]
        end
      end
      build_rule_criteria
    end
    
    # if current_user.can_create?(Rule, for: @rule.owner)
    @rule.outcome = "TEST_#{@rule.outcome}" if @rule.simulation?
    result = @rule.save
    CriteriaCard.set_callback(:create, :before, :hash_value)
    if result
      @rule.created_by(current_user)
      rule_manager_log.info('-----------------')
      rule_manager_log.info('Recieved rule:')
      rule_manager_log.info("#{@rule.attributes}")
      rule_to_add = Rule.where(id: @rule.id ).where(active: true).map(&:id)
      if params["opts"]["action"].present? && params["opts"]["action"] == "edit"
        rule_to_delete = Rule.where(id: params[:rule][:id]).where(active: true).map(&:id)
        rule_d = Rule.find(params[:rule][:id])
        rule_d.update(deleted: true, active: false, updated_by_id: current_user.id)
        rule_manager_log.info('----Rule deletion-----')
        rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{params[:rule][:id]}, 'Rule')")
        rule_manager_log.info("Rule attributes: #{rule_d.attributes}")
        EpochObserverService.update_epoch_for_table(params[:rule][:id], 'Rule')
        RuleSchedule.assign(params[:rule][:id], @rule.id)
      end
      activate_static_table_rules(@rule) if @rule.active
      unless params['opts']['action'] == 'new' && @rule.active == false
        rule_manager_log.info('----Rule creation-----')
        rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{@rule.id},  #{@rule.class.name})")
        rule_manager_log.info("Rule attributes: #{@rule.attributes}")
        EpochObserverService.update_epoch_for_table(@rule.id, @rule.class.name)
      end
      rule_manager_log.info('-----------------')
      Rule.update_rule_engine_v2(type: "rules",added: rule_to_add ,deleted: rule_to_delete, user: current_user ) if !rule_to_delete.try(:empty?) ||!rule_to_add.empty?
      render json: @rule, criteria: {original: true}, status: :created
    else
      render json: {errors: @rule.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    authorize_action_for @rule
    rule_to_delete = Rule.where(id: @rule.id).where(active: true).map(&:id)
    if @rule.update(rule_params)
      @rule.updated_by(current_user)
      rule_to_add = Rule.where(id: @rule.id ).where(active: true).map(&:id)
      rule_manager_log.info('-----------------')
      rule_manager_log.info('----Rule update-----')
      rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{@rule.id},  #{@rule.class.name})")
      rule_manager_log.info("Rule attributes: #{@rule.attributes}")
      rule_manager_log.info('-----------------')
      EpochObserverService.update_epoch_for_table(@rule.id, @rule.class.name)
      Rule.update_rule_engine_v2(type: "rules",added: rule_to_add,deleted: rule_to_delete, user: current_user ) if !rule_to_delete.empty? ||!rule_to_add.empty?
      render json: @rule, status: :ok
    else
      render json: {errors: @rule.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def disable
      @rules = Rule.where(id: bulk_params[:ids])
    rule_ids = @rules.reject { |rule| !current_user.can_delete?(rule) }.map(&:id)
    rule_to_delete = Rule.where(id: rule_ids).where(active: true).map(&:id)
    if Rule.where(id: rule_ids).each { |rule| 
      rule_manager_log.info('-----------------')
      rule_manager_log.info('----Rule to delete/disable-----')
      rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{rule.id}, #{rule.class.name})")
      EpochObserverService.update_epoch_for_table(rule.id, rule.class.name) if rule.active?
      rule.update(deleted: true, active: false) 
      rule.updated_by(current_user) #TODO Performace issue
      rule_manager_log.info("Rule attributes: #{rule.attributes}")
      rule_manager_log.info('-----------------')
      }
      Rule.update_rule_engine_v2(type: "rules",deleted: rule_to_delete, user: current_user ) unless rule_to_delete.empty?
      render json: {message: I18n.t('rules.index.notifications.success.disable', total_count: rule_ids.length), rules: Rule.where(id: bulk_params[:ids])}, status: :ok
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'delete', model: 'rules')}, status: :unprocessable_entity
    end
  end

  def activate
     @rules = Rule.where(id: bulk_params[:ids]).where(active: false)
    rule_ids = @rules.reject { |rule| !current_user.can_update?(rule) }.map(&:id)
    if Rule.where(id: rule_ids).each { |rule|
        rule.update(active: true)
        rule.updated_by(current_user) #TODO Performace issue
        EpochObserverService.update_epoch_for_table(rule.id, rule.class.name)
      # Ensure parent stat table is set to rules_active 
      activate_static_table_rules(rule)
      rule_manager_log.info('-----------------')
      rule_manager_log.info('----Rule activate-----')
      rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{rule.id},  #{rule.class.name})")
      rule_manager_log.info("Rule attributes: #{rule.attributes}")
      rule_manager_log.info('-----------------')
    }
      Rule.update_rule_engine_v2(type: "rules",added: rule_ids,user: current_user ) unless rule_ids.empty?
      render json: {message: I18n.t('rules.index.notifications.success.activate', total_count: rule_ids.length), rules: Rule.where(id: bulk_params[:ids])}, status: :ok #TODO Performance issue with rules responce

    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'activate', model: 'rules')}, status: :unprocessable_entity
    end
  end

  def deactivate

     @rules = Rule.where(id: bulk_params[:ids]).where(active: true)
    rule_ids = @rules.reject { |rule| !current_user.can_update?(rule) }.map(&:id)
    if Rule.where(id: rule_ids).each { |rule|
       rule.update(active: false)
       rule.updated_by(current_user)
       EpochObserverService.update_epoch_for_table(rule.id, rule.class.name)
       # Check if all rules relating to stat table are disabled, and mark them
       tables = rule.criteria.map {|c| [c.leftable,c.rightable].select {|able| able.is_a?(StatisticCalculation)} }.flatten.map {|c| c.statistic_table}.map {|t| t.containing_statistic_table||t}
      tables.each do |t|
        unless [t.contained_statistic_tables,t].flatten.map {|ct| ct.statistic_calculations.map {|sc| sc.rule.active}}.flatten.include?(true)
          t.populated = false
          t.rules_active = false
          t.save
        end
      end
      rule_manager_log.info('-----------------')
      rule_manager_log.info('----Rule deactivate-----')
      rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{rule.id},  #{rule.class.name})")
      rule_manager_log.info("Rule attributes: #{rule.attributes}")
      rule_manager_log.info('-----------------')
    }
      Rule.update_rule_engine_v2(type: "rules",deleted: rule_ids, user: current_user ) unless rule_ids.empty?
      render json: {message: I18n.t('rules.index.notifications.success.deactivate', total_count: rule_ids.length), rules: Rule.where(id: bulk_params[:ids])}, status: :ok
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'deactivate', model: 'rules')}, status: :unprocessable_entity
    end

  end

  def live
     @rules = Rule.where(id: bulk_params[:ids])
    allowed_rules = @rules.reject { |rule| !current_user.can_update?(rule) }
    rule_to_update = Rule.where(id: allowed_rules).where(active: true).map(&:id)
    if !allowed_rules.blank?
      allowed_rules.each do |rule|
        rule.update_columns(outcome: rule.outcome[5..-1], simulation: false) if rule.simulation
        rule.updated_by(current_user)
        rule_manager_log.info('-----------------')
        rule_manager_log.info('----Rule live-----')
        rule_manager_log.info("Called EpochObserverService.update_epoch_for_table(#{rule.id},  #{rule.class.name})")
        rule_manager_log.info("Rule attributes: #{rule.attributes}")
        rule_manager_log.info('-----------------')
        EpochObserverService.update_epoch_for_table(rule.id, rule.class.name)
      end
      Rule.update_rule_engine_v2(type: "rules",added: rule_to_update,deleted: rule_to_update, user: current_user )
      render json: {message: I18n.t('rules.index.notifications.success.live', total_count: allowed_rules.length), rules: allowed_rules}, status: :ok
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'change the state of', model: 'rules')}, status: :unprocessable_entity
    end
  end

  def authorisation_ids
    if params[:alert_id]
      render json: @rule.authorisations.where(violations: {alert_id: params[:alert_id]}).select(:id, :created_at).map(&:to_param)
    else
      render json: @rule.authorisations.select(:id, :created_at).map(&:to_param)
    end
  end
end
