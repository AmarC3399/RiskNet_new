class StatisticsController < ApplicationController
  authorize_actions_for Statistic, actions: { list: :read, disable: :update }
  before_action :set_statistic, only: [:show, :edit, :update, :destroy]
  before_action :set_statistic_timeframes, only: [:create]

  def index
    calc_limit = 10
    calc_offset = ([params[:page].to_i.abs, 1].max - 1) * calc_limit

    @statistics = StatisticsAuthorizer::Scope.new(current_user, Statistic).resolve
                      &.includes(:statistic_timeframes,:grouping_factor)
                      &.date_filter(params[:start_date], params[:end_date], :created_at)
                      &.search(params[:search], :description, :stat_code, :category)
                      &.filter(params[:type], :category)
                      &.filter_by_owner(params[:only_mine] ? params.merge(user: current_user) : params)
                      &.order(created_at: :desc)
                      &.limit(calc_limit)&.offset(calc_offset || 0)

    total_items = @statistics&.except(:limit, :offset)&.count

    respond_to do |format|
      format.html
      format.json { render json: { statistics: @statistics.as_json(include: [:statistic_timeframes,:grouping_factor, :criterion] ,original:true), meta: page_meta_info(total_items, calc_limit, params[:page])}.as_json, status: :ok}
    end
  end

  def list
    @statistics = StatisticsAuthorizer::Scope.new(current_user, Statistic).resolve
                      .includes(:statistic_timeframes)
                      .filter_by_owner(params)
                      .order(created_at: :desc)
                      .load
    @categories = @statistics.group_by(&:category)
    @categorised = @categories.sort.map { |k, v| {text: k.humanize, children: v} }

    render json: { statistics: @categorised }
  end

  def show
    authorize_action_for @statistic
    render json: @statistic
  end

  def create
    @statistic = Statistic.new( statistic_params )
    @statistic.created_by = current_user.name
    owner = stat_owner(params[:statistic][:owner_id], params[:statistic][:owner_type])
    @statistic.owner =  owner.nil? ? current_user.owner : owner.first

    if @statistic.save
      render json: @statistic.as_json(include: [:statistic_timeframes,:grouping_factor] ,original:true), status: :created
    else
      render json: {errors: @statistic.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def disable
    #todo-an testing pending
    # Disable/delete all statistics provided
    @statistics = Statistic.where(id: bulk_params[:ids])
    statistic_ids = @statistics.reject { |statistic| !current_user.can_update?(statistic)}.map(&:id)

    @statistics.each { |statistic| statistic.statistic_calculations.each {
        |calculation|
      rule = calculation.criterion_left.try(:rule)
      rule = calculation.criterion_right.try(:rule) unless rule
      if rule
        render json: {errors: I18n.t('actioncontroller.errors.statistic_in_use', stat_code: calculation.statistic.stat_code, rule_code: rule.internal_code)}, status: :unprocessable_entity and return
      end
    }
    }

    if Statistic.where(id: statistic_ids).each { |stats| stats.update(deleted: true, stat_code: "#{stats.stat_code}_#{Time.zone.now}_deleted") }
      render json: {message: I18n.t('statistics.index.notifications.success.delete', total_count: statistic_ids.length), statistics: Statistic.unscoped.where(id: statistic_ids)}, status: :ok
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'delete', model: 'statistic')}, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraint between actions.
  def set_statistic
    # THIS IS BROKEN! The MSSql JDBC driver produces invalid
    # sql for a find for the statistics table so we have to
    # use this horrible work around
    @statistic = Statistic.where(id: params[:id]).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statistic_params
    params
      .require(:statistic)
      .permit(:stat_code,
              :stat_type,
              :statistic_id,
              :statistics_operation_id,
              :grouping_factor_id,
              :field_list_id,
              :user_id,
              statistic_timeframe_ids: [],
              criterion_attributes: [
                :constraint,
                leftable_attributes: [ :id, :type ],
                rightable_attributes: [ :id, :type, :right_operator, :right_operator_value, { parameter: [ :value, :data_type] }  ]
              ]
    ).merge('statistic_timeframe_ids' => @stats_timeframe.new_timeframes)
  end

  def set_statistic_timeframes
    @stats_timeframe = Statistic.new
  end

  # Get the actual owner from the stat params hash
  def stat_owner(owner_id, owner_type)

    case owner_type
    when "member"
      owner_id.map { |id| Member.find id }
    when "client"
      owner_id.map { |id| Client.find id }
    when "merchant"
      owner_id.map { |id| Merchant.find id }
    end
  end

  # def bulk_params
  #   params.require(:statistics).permit(ids: [])
  # end

end
