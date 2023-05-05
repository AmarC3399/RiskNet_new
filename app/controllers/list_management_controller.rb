class ListManagementController < ApplicationController

  before_filter :find_list, only: [:show, :update, :export, :import]


  # authorize_actions_for DataList, actions: {
  #     dropdown_list: :read,
  #     get_list: :read,
  #     index: :read
  # }

  def index
    name = nil
    calc_limit = 25
    calc_offset = ([params[:page].to_i.abs, 1].max - 1) * calc_limit

    if params[:name].present?
      name = params[:name].parameterize.underscore.downcase
    end

    @datalists = DataList.list_for(params[:model_type], name)
                     .filter_by_owner(params[:only_mine] ? params.merge(user: current_user) : params)
                     .search(params[:search] || '')
                     .order(:name)
                     .select {|list| current_user.can_read?(list)}

    total_items = @datalists.count

    @datalists = paginated_list(@datalists, calc_limit, calc_offset)

    render json: @datalists, root: 'data_lists', meta: page_meta_info(total_items, calc_limit, params[:page])
  end

  def show
    unless current_user.can_read?(@list)
      render json: {errors: I18n.t(:violation, scope: 'user_hierarchy_errors')}, status: :unprocessable_entity
    else
      calc_limit = 100
      calc_offset = ([params[:page].to_i.abs, 1].max - 1) * calc_limit
      list_items = @list.list_items
      total_items = list_items.count
      list_items = paginated_list(list_items, calc_limit, calc_offset)
      render json: list_items, meta: page_meta_info(total_items, calc_limit, params[:page]), root: 'list_items'
    end
  end

  #Export CSV list items
  def export
    respond_to do |format|
      format.html {send_data @list.list_items.to_csv, filename: "#{@list.name}.csv"}
      format.csv {send_data @list.list_items.to_csv, filename: "#{@list.name}.csv"}
    end
  end

  #Import CSV list items
  def import
    if params[:file]
      results = ListItem.import_csv(params[:file], params[:id], current_user)
      if results[:status]
        calc_limit = 15
        calc_offset = 0
        list_items = @list.list_items
        total_items = list_items.count
        list_items = paginated_list(list_items, calc_limit, calc_offset)
        Rule.update_rule_engine_v2(type: "datalists", added: params[:id], user: current_user)
        render json: list_items, meta: page_meta_info(total_items, calc_limit, params[:page]), root: 'list_items', status: :ok
      else
        render json: {errors: results[:errors]}, status: :unprocessable_entity
      end
    else
      render json: {errors: [I18n.t('models.list_item.import.no_file')]}, status: :unprocessable_entity
    end
  end

  def create
    if params[:data_list][:type] == "CustomList"
      field_list = FieldList.where(model_type: params[:data_list][:type], name: params[:data_list][:table].parameterize.underscore).first
    else
      field_list = FieldList.where(model_type: params[:data_list][:table], name: params[:data_list][:field]).first
    end

    if field_list.present?

      data_list = DataList.new(list_params)
      data_list.user_id = current_user.id

      owner = list_owner(params[:data_list][:owner_id], params[:data_list][:owner_type])
      data_list.owner = owner.nil? ? current_user.owner : owner.first

      if current_user.can_create?(data_list)
        if data_list.save
          field_list.data_lists << data_list
          render json: data_list, meta: {message: I18n.t('listmanagement.success.create.data_list', description: data_list.description)}, root: 'data_list', status: :ok
        else
          render json: {errors: data_list.errors.full_messages}, status: :unprocessable_entity
        end
      else
        render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'create', model: 'data list')}, status: :unprocessable_entity
      end
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'create', model: 'data list')}, status: :unprocessable_entity
    end
  end

  def update
    if current_user.can_update?(@list)
      if @list.update(list_params)
        Rule.update_rule_engine_v2(type: "datalists", added: @list.id, user: current_user)
        render json: @list.list_items, meta: {message: I18n.t('listmanagement.success.create.list_items')}, :root => 'list_items', status: :ok
      else
        render json: {errors: @list.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'update', model: 'data list')}, status: :unprocessable_entity
    end
  end

  def disable
    # Disable/delete all lists provided
    @datalist = DataList.where(id: params[:id]).first

    if current_user.can_update?(@datalist)
      if @datalist.belongs_to_rules.length > 0
        # error if the data list belongs to active rules
        render json: {errors: I18n.t('actioncontroller.errors.unable_to_action_has_rules', action: 'disable', model: 'data list')}, status: :unprocessable_entity
      else
        if @datalist.update(deleted: true)
          render json: {message: I18n.t('list_management.index.notifications.success.delete'), datalist: @datalist}, status: :ok
        else
          # error if something went wrong with updating the deleted attribute to true
          render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'disable', model: 'data list')}, status: :unprocessable_entity
        end
      end
    else
      # error if user doesn't have permission to update this data list
      render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'disable', model: 'data list')}, status: :unprocessable_entity
    end
  end

  def dropdown_list
    if params[:table].present?
      fieldlist = FieldList.visible.ordered_by_name.where(:model_type => (params[:table].present? ? params[:table] : params[:type])).select(:id, :description, :name, :data_type)
      fieldlist_options = fieldlist #.map{|f| f.map{ |f| f.humanize}}
    else
      fieldlist = FieldList.visible.ordered_by_model_type.uniq.pluck(:model_type)
      fieldlist_options = fieldlist.map {|field| field.underscore.humanize}
    end

    render json: fieldlist_options
  end

  def get_list
    # This will need to change if/when we have multple data lists per custom field list
    data_list = FieldList.id_for(params[:model_type], params[:name], true).data_lists.first
    render json: order_list(data_list.list_items), root: 'list_items'
  end

  def get_default_list
    default_list = DataList.return_list(params[:list_type])
    render json: default_list, root: 'list_items'
  end

  private

  def find_list
    @list = DataList.find(params[:id])
  end

  # Ordering list items for generating reports
  def order_list(list_items)
    if ['Rule Efficiency', 'Operational User'].include?(list_items.first.list_type)

      case list_items.first.list_type
      when 'Rule Efficiency'
        ordered_list = list_items.select {|list| ['Rule ID', 'Rule Description'].include?(list.frontend_name)}
        list_items = ordered_list.reverse | list_items

      when 'Operational User'
        ordered_list = list_items.select {|list| ['User'].include?(list.frontend_name)}
        list_items = ordered_list | list_items
      end

    else
      list_items
    end
  end

  def list_params
    params.require(:data_list).permit(:id, :name, :data_type, :description, :created_at,
                                      list_items_attributes: [:id, :frontend_name, :value, :list_type, :description, :_destroy])
  end

  def paginated_list(list, limit, offset)
    list[offset..(offset + limit - 1)]
  end

  # get the actual owner from list params hash
  def list_owner(owner_id, owner_type)

    case owner_type
    when "member"
      owner_id.map {|id| Member.find id}
    when "client"
      owner_id.map {|id| Client.find id}
    when "merchant"
      owner_id.map {|id| Merchant.find id}
    end
  end

end
