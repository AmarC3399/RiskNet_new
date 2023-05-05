class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_filter :load_commentable, except: [:create]


  def index
    @comments = @commentable.comments.date_filter(params[:start_date], params[:end_date], :created_at)
    render json: { comments: @comments }
  end

  # def show
  #   @comment = Comment.find(params[:id])
  #   render json: @comment
  # end

  # POST /comments.json
  def create
    @alerts = Alert.where(id: alert_ids(params[:alerts][:ids]) )

    if comment_params[:comment_text].present?
      cleaned = comment_params
      attributes = []
      @alerts.each { |v| attributes << { alert_id: v.ids_hash['id'], alert_created_at: v.created_at, comment_text: cleaned[:comment_text], user_id: current_user.id, entered_by: current_user.name  } }

      if (@comment = Comment.create(attributes))
        # render json: @comment, status: :created
        render json: {message: I18n.t('batch.success.batch_update', actioned_count: @alerts.length, total_count: @alerts.length), alerts: @alerts}, status: :ok
      else
        render json: {errors: @comment.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {message: I18n.t('batch.success.batch_update', actioned_count: @alerts.length, total_count: @alerts.length), alerts: @alerts}, status: :ok
    end
  end

  private

  def alert_ids(alerts)
    alerts.collect { |a| a.to_s.split(CompositePrimaryKeys::ID_SEP).second }
  end

  # Use callbacks to share common setup or constraint between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:title, :comment_text, :user_id, :alert_id, :entered_by)
  end

  def load_commentable
    resource, id = request.path.split('/')[2, 3]
    if defined? resource.singularize.classify.constantize == 'constant'
      id = id.to_s.split('-')
      id = id[0] if id.length == 1
      if resource.singularize.classify.constantize.exists? id
        @commentable = resource.singularize.classify.constantize.find(id)
      end
    end
  end
end