class AlertoverridesController < ApplicationController
#  before_action :set_alert_override, only: [:show, :edit, :update, :destroy]
#   before_action :check_card, only: [:create]

#   def index
#     alert_overrides =  ao_query
#                       .attach_filter(params, current_user)
#                       .limit_and_offset(calc_limit, calc_offset)

#     total_items     =  ao_query
#                       .except(:select)
#                       .attach_filter(params, current_user)
#                       .count

#     render json: alert_overrides,
#            root: 'alert_overrides',
#            meta: page_meta_info(total_items, calc_limit, params[:page])
#   end


#   def show
#     return_response(  ao_query
#                      .search(params[:id], 'alert_overrides.id')
#                      .first )
#   end


#   def create
#     alert_override =  ao_klass.build_association(send_args)

#     if alert_override.save
#       EpochObserverService.update_epoch_for_table(alert_override.id, alert_override.class.name)
#       Rule.update_rule_engine_v2(type: "alert_override",added: alert_override.id,user: current_user)
#       return_response( ao_klass.select_card_and_type(alert_override), :created )
#     else
#       return_response( { errors: alert_override.errors.full_messages }, :unprocessable_entity )
#     end
#   end


#   def update
#     if @alert_override.update(this_param)
#       EpochObserverService.update_epoch_for_table(@alert_override.id, @alert_override.class.name)
#       Rule.update_rule_engine_v2(type: "alert_override", updated: @alert_override.id, user: current_user)
#       return_response( ao_query, 200 )
#     else
#       return_response( { errors: @alert_override.errors.full_messages }, :unprocessable_entity )
#     end
#   end

#   def deactivate
#     @alert_overrides = AlertOverride.where(id: bulk_params[:ids])
#     deleted_ids = @alert_overrides.active.date_range.map(&:id)

#     if @alert_overrides.each { |alert_override|
#         alert_override.update(active: false)
#         EpochObserverService.update_epoch_for_table(alert_override.id, alert_override.class.name)
#       }
#       Rule.update_rule_engine_v2(type: "alert_override", deleted: deleted_ids, user: current_user)
#       render json: {message: I18n.t('alert_override.index.notifications.success.deactivate', total_count: deleted_ids.length), alert_overrides: @alert_overrides.pluck(:id)}, status: :ok
#     else
#       render json: {errors: I18n.t('actioncontroller.errors.unable_to_action', action: 'deactivate', model: ao_klass)}, status: :unprocessable_entity
#     end
#   end  

#   def send_args
#     {
#       :card_number_           => override_card_params[:card_number],
#       :alert_override_params_ => alert_override_params,
#       :override_type_         => override_type_params[:type],
#       :current_user_          => current_user
#     }
#   end

#   def this_param
#     alert_override_params.merge(ao_klass.send(:_override_type, override_type_params[:type]))
#   end

#   private

#   def bulk_params
#     params.require(:alert_overrides).permit(ids: [])
#   end 

#   def set_alert_override
#     @alert_override = AlertOverride.find(params[:id])
#   end

#   def alert_override_params
#     params.require(:alert_override).permit( :comment,  :start_time,
#                                             :end_time, :owner_type,
#                                             :owner_id, :user_id)
#                                    .merge( updated_by: current_user.id )
#                                    .merge( reason_code: ListItem.find_by_description(override_type_params[:type]).value )
#                                    .merge( initiated_by: 'Manual' )
#   end

#   def override_card_params
#     params.require(:alert_override).permit(:card_number)
#   end

#   def override_type_params
#     params.require(:alert_override).permit(:type)
#   end

#   def ao_klass
#     AlertOverride
#   end

#   def override_card_klass
#     OverrideCard
#   end

#   def calc_limit
#     22
#   end

#   def calc_offset
#     ([params[:page].to_i.abs, 1].max - 1) * calc_limit
#   end

#   def check_card

#     auth_id = params[:alert_override][:auth_id]


#     if auth_id.nil?
#       card_number = params[:alert_override][:card_number]

#       return card_mismatch  unless card_number == params[:alert_override][:confirm_card_number]

#       return card_num_range unless card_number.length > 11 && card_number.length < 20

#       return card_match_found if override_card_klass.card_exists?(card_number)
#     else
#       # this check is mainly for the override coming from alert page.
#       # Since, hashed_card number is not coming through from alert page,
#       # it is imperative we get the card number from auth and check if it exists on aler_override.
#       # All the other validation after below IF statement is not prudent.
#       if override_card_klass.check_hashed_card_exists?(auth_id)
#         return card_match_found
#       else
#         encrypted = override_card_klass.new.hashed_number(auth_id)
#         params[:alert_override][:card_number] = encrypted
#       end
#     end

#   end

#   protected

#   def card_mismatch
#     return_response({ errors: 'Card numbers do not match.' }, :unprocessable_entity)
#   end

#   def card_num_range
#     return_response({ errors: 'Card number should be between 11 and 20 characters.' }, :unprocessable_entity)
#   end

#   def card_match_found
#     return_response({ errors: 'Card number exists already.' }, :unprocessable_entity)
#   end

#   def ao_query
#     ao_klass.cards.types.select_all
#   end
 end
