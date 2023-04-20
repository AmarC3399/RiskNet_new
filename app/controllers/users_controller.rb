class UsersController < ApplicationController

  #  skip_before_action :authenticate_user!, only: :update_password

  # before_filter :load_user, only: [:show, :update]
  # authorize_actions_for User, except: [:create, :update_password], actions: {all: :read,
  #                                                                            verify_user: :read,
  #                                                                            block: :update,
  #                                                                            unblock: :update,
  #                                                                            update: :update,
  #                                                                            create: :create,
  #                                                                            forwardable: :skip,
  #                                                                            installations: :read,
  #                                                                            members: :filter,
  #                                                                            clients: :filter,
  #                                                                            merchants: :filter,
  #                                                                            report_users: :skip}

  def index
  end
    
  def new

  end
  
  def forwardable
     @users = UserAuthorizer::ForwardingScope.new(current_user, User).resolve
    render json: {users: @users}, status: :ok
  end

  def verify_user
    render json: {user: current_user}, status: :ok
  end

  def show
     authorize_action_for @user
    render json: @user, status: :ok
  end

  def create
     @user = User.new(user_details)
    owner =  user_owner(params[:user][:owner_id], params[:user][:owner_type])
    @user.owner =  owner.nil? ? current_user.owner : owner.first

    # so that the user will change his password the next time he/she logs in
    @user.password_changed_at=Time.zone.now-92.days
    if current_user.can_create?(User, for: @user.owner)
      if @user.save
        @user.add_role user_details[:role], @user.owner
        render json: @user, status: :created
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {}, status: :forbidden
    end
  end

  def update
    authorize_action_for @user
    params = user_details
    if @user.update(params)
      if @user.roles.present?
        @user.roles.delete_all
      end
      @user.add_role user_details[:role], @user.owner
      render json: {user: @user}, status: :ok
    else
      render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def block
     @users = User.where(id: bulk_params[:ids])
    user_ids = @users.reject { |user| !current_user.can_update?(user) || user.id == current_user.id }

    if User.where(id: user_ids).update_all(enabled: false, locked_at: DateTime.current)
      render json: {message: I18n.t('users.index.notifications.success.disable', total_count: user_ids.length), users: User.where(id: bulk_params[:ids]).reject { |user| !current_user.can_read?(user)}}, status: :ok
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'disable', model: 'users')}, status: :unprocessable_entity
    end
  end

  def unblock
    @users = User.where(id: bulk_params[:ids])
    user_ids = @users.reject { |user| !current_user.can_update?(user) || user.id == current_user.id }

    if User.where(id: user_ids).update_all(enabled: true, locked_at: nil, failed_attempts: 0)
      render json: {message: I18n.t('users.index.notifications.success.enable', total_count: user_ids.length), users: User.where(id: bulk_params[:ids]).reject { |user| !current_user.can_read?(user)}}, status: :ok
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'enable', model: 'users')}, status: :unprocessable_entity
    end
  end

  def update_password
      user_params = password_update_params

    user = User.find_for_database_authentication(email: user_params[:email])

    if !user
      render json: {errors: I18n.t("devise.failure.not_found_in_database")}
    else
      if user.update_with_password(user_params)
        sign_in(user, :bypass => true)
        render json: {message: I18n.t('reset.password_updated')}, status: :ok
      else
        render json: {errors: user.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

  def installations
     authorize_action_for current_user

    if current_user.owner_type == 'Installation'
      render json: current_user.owner, status: :ok
    else
      render json: [I18n.t('users.validation_error.not_found', action: 'installations')], status: :unprocessable_entity, root: :errors
    end
  end

  def members
    authorize_action_for current_user

    owners = User.get_users_owners(current_user, 'member', 'installation_id', params[:installation_id], ['Member'], ['Installation'])

    if owners[:result].nil?
      render json: {errors: [owners[:errors]]}, status: :unprocessable_entity, root: :errors
    else
      render json: { members: custom_serializer(owners[:result], MemberSerializer) }, status: :ok
    end
  end

  def clients
     authorize_action_for current_user

    owners = User.get_users_owners(current_user, 'client', 'member_id', params[:member_id], ['Client', 'Member'], ['Installation'])

    if owners[:result].nil?
      render json: {errors: [owners[:errors]]}, status: :unprocessable_entity, root: :errors
    else
      render json: { clients: custom_serializer(owners[:result], ClientSerializer) }, status: :ok
    end
  end

  def merchants
     authorize_action_for current_user

    owners = User.get_users_owners(current_user, 'merchant', 'client_id', params[:client_id], ['Client', 'Merchant'], ['Installation', 'Member'])

    if owners[:result].nil?
      render json: {errors: [owners[:errors]]}, status: :unprocessable_entity, root: :errors
    else
      render json: { merchants: custom_serializer(owners[:result], MerchantSerializer) }, status: :ok
    end
  end

  def report_users
    @users= UserAuthorizer::Scope.new(current_user, User).resolve(true)
    render json: {users: @users.as_json(include: {owner: {only: :name}})}, status: :ok
  end

 

end
