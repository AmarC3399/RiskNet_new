Rails.application.routes.draw  do 

  devise_for :user
    root to: "home#index" 

    devise_scope :user do
      get '/sign-in' => "devise/sessions#new", :as => :login
      delete "sign_out", to: "sessions#destroy"
    end

  get "/users", to: "users#index"
  get "/users", to: "users#forwardable"
  get "/users", to: "users#verify_user"
  get "/users", to: "users#show"
  get "/users", to: "users#create"
  get "/users", to: "users#update"
  get "/users", to: "users#block"
  get "/users", to: "users#unblock"
  get "/users", to: "users#update_password"
  get "/users", to: "users#installations"
  get "/users", to: "users#members"
  get "/users", to: "users#clients"
  get "/users", to: "users#merchants"
  get "/users", to: "users#report_users"

  get "/alert_overrides", to: "alert_overrides#index"
  get "/alert_overrides", to: "alert_overrides#show"
  get "/alert_overrides", to: "alert_overrides#create"
  get "/alert_overrides", to: "alert_overrides#update"
  get "/alert_overrides", to: "alert_overrides#deactivate"
  get "/alert_overrides", to: "alert_overrides#send_args"
  get "/alert_overrides", to: "alert_overrides#this_param"

   get "/alerts", to: "alerts#index"
   get "/alerts", to: "alerts#batch_alerts"
   get "/alerts", to: "alerts#show"
   get "/alerts", to: "alerts#allocated_comments"
   get "/alerts", to: "alerts#update"
   get "/alerts", to: "alerts#batch_update"

   get "/authorisations", to: "authorisations#index"
   get "/authorisations", to: "authorisations#all"
   get "/authorisations", to: "authorisations#mark"
   get "/authorisations", to: "authorisations#unmark"
   get "/authorisations", to: "authorisations#unused_fields"
   get "/authorisations", to: "authorisations#used_fields"

   get "/batch", to: "batch#index"

   get "/customers", to: "customers#index"
  
  get "/statistic_timeframes", to: "statistic_timeframes#index"  

  get "/statistics_operations", to: "statistics_operations#index"
 
  get "/rule_schedules", to: "rule_schedules#show"
  get "/rule_schedules", to: "rule_schedules#create"
  get "/rule_schedules", to: "rule_schedules#edit"
  get "/rule_schedules", to: "rule_schedules#disable"
  get "/rule_schedules", to: "rule_schedules#resources"
  
  get "/statistics", to: "statistics#index"
  get "/statistics", to: "statistics#list"
  get "/statistics", to: "statistics#show"
  get "/statistics", to: "statistics#create"
  get "/statistics", to: "statistics#disable"

  get "/list_management", to: "list_management#index"
  get "/list_management", to: "list_management#show"
  get "/list_management", to: "list_management#update"
  get "/list_management", to: "list_management#import"
  get "/list_management", to: "list_management#export"
  get "/list_management", to: "list_management#disable"
  get "/list_management", to: "list_management#dropdown_list"

      
 get "/rules", to: "rules#all"
 get "/rules", to: "rules#show"
 get "/rules", to: "rules#create"
 get "/rules", to: "rules#update"
 get "/rules", to: "rules#disable"
 get "/rules", to: "rules#activate"
 get "/rules", to: "rules#deactivate"
 get "/rules", to: "rules#live"
 get "/rules", to: "rules#authorisation_ids"



get "/about", to: "about#index"  

get "/settings", to: "settings#index"

 get "reset_password", to: "reset_password#index"

  
  
end
