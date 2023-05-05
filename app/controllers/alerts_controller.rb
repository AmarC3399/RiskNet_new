class AlertsController < ApplicationController
  before_action :find_alert, only: [:allocated_comments, :update, :show]

  SELECT_LIST = 'alerts.*, reminders.id as reminder_id, reminders.reason, reminders.reminder_time, reminders.alert_created_at, reminders.expired, reminders.cleared, reminders.cleared_on, reminders.job_id, reminders.alert_id'
  REMINDER_CUSTOM_JOIN = 'LEFT OUTER JOIN reminders ON reminders.alert_created_at = alerts.created_at AND reminders.alert_id = alerts.id'
  ACTIVE_REMINDER_CUSTOM_JOIN = "LEFT OUTER JOIN reminders ON reminders.alert_created_at = alerts.created_at AND reminders.alert_id = alerts.id AND reminders.expired = 'false'"

  def index
    @alerts = AlertAuthorizer::Scope.new(Alert.joins(REMINDER_CUSTOM_JOIN)).resolve
                .allocated_for_user(current_user&.id)
                .alert_list(params[:type], current_user&.id)
                .filtered_response(params[:filter2])
                .date_filter(params[:start_date], params[:end_date], :run_date, :alert)
                .search(params[:search], 'alerts.id', :customer_merchant_name)
                .filter_owner(params[:only_mine] ? params.merge(user: current_user) : params)
                .unexamined(params[:type])
                .order(:run_date)
                .limit(20)

    # If alerts list does not include the user's current alert, fetch it and add to the list
    unless @alerts.pluck(:being_examined).include? true
      current_alert = AlertAuthorizer::Scope.new(Alert.joins(REMINDER_CUSTOM_JOIN)).resolve
                .allocated_for_user(current_user&.id)
                .where(being_examined: true)
                .first

      @alerts << current_alert if current_alert
    end
    respond_to do |format|
      format.html
      format.json {render json: @alerts, action: :index, root: 'alerts'}
    end

    
  end

  def batch_alerts
    calc_limit = 20
    calc_offset = ([params[:page].to_i.abs, 1].max - 1) * calc_limit
    calc_order = Alert.process_order_params(params)

    @alerts = AlertAuthorizer::Scope.new(Alert.joins(ACTIVE_REMINDER_CUSTOM_JOIN)).resolve
                .alert_list(params[:type])
                .filtered_response(params[:filter2])
                .date_filter(params[:start_date], params[:end_date], :run_date, :alert)
                .filter_owner(params[:only_mine] ? params.merge(user: current_user) : params)
                .merchant_group_search(params[:search])
                .order(calc_order || :run_date)
                .limit(calc_limit)
                .offset(calc_offset || 0)

    total_items = @alerts.except(:limit, :offset).length

    render json: { alerts: @alerts.as_json(include:[{user: {only: :name}}]), meta: page_meta_info(total_items, calc_limit, params[:page])}.as_json, status: :ok
  end

  def show
    # authorize_action_for(@alert)
    render json: @alert, action: :show #, rules: { authorisation_ids: true }
  end

  def allocated_comments
    # authorize_action_for(@alert)
    @comments = @alert.allocated_comments.date_filter(params[:start_date], params[:end_date], :created_at)
    render json: {comments: @comments}
  end

  def update
    # authorize_action_for(@alert)
    # We use this for some internal logic
    @alert.updated_by = current_user
    params[:alert][:original_updated_at] = params[:original_updated_at] if !params[:original_updated_at].blank?
    activity_created = true

    if params[:activity].present?
      activity = Activity.create_activity(@alert, params[:activity], current_user)
      if activity[:errors]
        activity_error = I18n.t('activerecord.errors.models.alert.unable_to_create_activity'),
        activity_created = false
      end
    end

    if @alert.update(alert_params) && activity_created
      render json: @alert, action: :show, root: false
    else
      render json: {errors: (!activity_created ? activity_error : @alert.errors.full_messages)}, status: :unprocessable_entity
    end
  end

  def batch_update
    # Examines/forwards all alerts provided
    #
    # Check if being_examined is true as an alert can not be actioned if a user is
    # currently examining it
    #
    params = bulk_params
    ids = params['alerts']['ids'].map{|id| id.to_s.split(CompositePrimaryKeys::ID_SEP).drop(1) }
    user_id = params['user_id']
    params.delete('alerts')

    alerts = Alert.where(id: ids)
    alerts_being_examined = alerts.where(being_examined: true)
    alerts_been_examined = alerts.where(examined: true)

    alerts_updated = 0

    if !alerts_being_examined.empty? || !alerts_been_examined.empty?
      render json: {errors: I18n.t('batch.errors.batch_update', actioned_count: (alerts_being_examined.length + alerts_been_examined.length), total_count: ids.length), alerts: alerts_being_examined}, status: :unprocessable_entity
    elsif
      alerts_not_being_examined = alerts.where(being_examined: false)
        # Only update the subject on CHALLENGE alerts, otherwise leave as is
        if params[:subject]
          switch = Arel::Nodes::Case.new.when(Alert.arel_table[:response].eq(RiskNet.review),params[:subject]).else(Alert.arel_table[:subject])
          literal = Arel::SqlLiteral.new(switch.to_sql)
          params[:subject] = literal
        end

        alerts_not_being_examined.map do |a|
          a.allocated_on = Time.zone.now
          a.being_examined = false
          if user_id.nil?
            a.subject = params[:subject]
            a.examined = true
            a.examined_on = Time.zone.now
          else
            # Set updated_by to make sure enters correct if statement in clear_being_examined in alert.rb
            a.updated_by = current_user
            a.examined = false
          end
          a.user_id = user_id || current_user.id

          if a.save
            alerts_updated += 1
          end
        end

        if alerts_updated == alerts_not_being_examined.count
          # render json: {message: I18n.t('batch.success.batch_update', actioned_count: alerts.length, total_count: bulk_params['alerts']['ids'].length), alerts: alerts}, status: :ok
          render json: {}, status: 200
        else
          render json: {errors: alerts_not_being_examined.map{|a| a.errors}}, status: :unprocessable_entity
        end
    end
  end

  private

  # Use callbacks to share common setup or constraint between actions.
  def find_alert
    @alert = Alert.find(params[:id].to_s.split(CompositePrimaryKeys::ID_SEP))
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def alert_params
    params.require(:alert).permit(:alert_type, :subject, :state, :run_date, :priority, :allocated_on, :examined_on, :examined, :being_examined, :user_id, :original_updated_at, comments_attributes: [:comment_text, :alert_id, :entered_by])
  end

  def bulk_params
    # params.require(:alerts).permit(ids: [])
    params.permit(:examined, :user_id, :subject, :alerts => {ids: []})
  end

end