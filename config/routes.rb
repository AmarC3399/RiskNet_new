Rails.application.routes.draw do
  get 'users/index'
  get 'users/forwardable'
  get 'users/verify_user'
  get 'users/show'
  get 'users/create'
  get 'users/update'
  get 'users/block'
  get 'users/unblock'
  get 'users/update_password'
  get 'users/installations'
  get 'users/members'
  get 'users/clients'
  get 'users/merchants'
  get 'users/report_users'
  get 'alert_overrides/index'
  get 'alert_overrides/show'
  get 'alert_overrides/create'
  get 'alert_overrides/update'
  get 'alert_overrides/deactivate'
  get 'alert_overrides/send_args'
  get 'alert_overrides/this_param'
  get 'statistic_timeframes/index'
  get 'statistics_operations/index'
  get 'rule_schedules/show'
  get 'rule_schedules/create'
  get 'rule_schedules/edit'
  get 'rule_schedules/disable'
  get 'rule_schedules/resources'
  get 'statistics/index'
  get 'statistics/list'
  get 'statistics/show'
  get 'statistics/create'
  get 'statistics/disable'
  get 'rules/all'
  get 'rules/show'
  get 'rules/create'
  get 'rules/update'
  get 'rules/destroy'
  get 'rules/disable'
  get 'rules/activate'
  get 'rules/deactivate'
  get 'rules/live'
  get 'rules/authorisation_ids'
  get 'alerts/index'
  get 'alerts/batch_alerts'
  get 'alerts/show'
  get 'alerts/allocated_commnets'
  get 'alerts/update'
  get 'alerts/batch_update'
 # get 'login/index'

  

  devise_for :users

  root to: "home#index" 

  devise_scope :user do
  get '/sign-in' => "devise/sessions#new", :as => :login
  
end
  #get "/alerts", to: "alerts#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
