class ActivitiesController < ApplicationController
    include NestedResourceFor

  nested_resource_for :alert
  authorize_actions_for Activity, except: :create

  def index
     calc_limit = 15
    calc_offset = ([params[:page].to_i.abs, 1].max - 1) * calc_limit

    @activities = @alert.activities.date_filter(params[:start_date], params[:end_date], :allocated_on ).order(created_at: :desc).limit(calc_limit).offset(calc_offset || 0)

    total_items = @activities.except(:limit, :offset).count

    render json: { activities: @activities.as_json, meta: page_meta_info(total_items, calc_limit, params[:page])}.as_json
    # render json: @activities, root: 'activities'
  end

  def create
     if current_user.can_create?(Activity, for: @alert)
      create_result = Activity.create_activity(@alert, activity_params, current_user)
      if create_result[:errors]
        render json: {errors: create_result[:errors]}, status: :unprocessable_entity
      else
        render json: create_result[:activities], each_serializer: ActivitySerializer, status: :created
      end
    else
      render json: {errors: I18n.t('actioncontroller.errors.not_authorised')}, status: :forbidden
    end
  end

  
  private

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit({actions: []}, :alert_id, :comment_text, :user_id)
  end
end
