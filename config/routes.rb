Rails.application.routes.draw  do 

   unless Rails.env.production?
    post 'db/savepoint', to: 'db#savepoint'
    post 'db/rollback', to: 'db#rollback'
  end

  devise_for :user
    root to: "home#index" 

    devise_scope :user do
      get '/sign-in' => "devise/sessions#new", :as => :login
      delete "sign_out", to: "sessions#destroy"
    end

    resources :users

  get "/users", to: "users#forwardable"
  get "/users", to: "users#verify_user"
  get "/users", to: "users#block"
  get "/users", to: "users#unblock"
  get "/users", to: "users#update_password"
  get "/users", to: "users#installations"
  get "/users", to: "users#members"
  get "/users", to: "users#clients"
  get "/users", to: "users#merchants"
  get "/users", to: "users#report_users"
  get "/users", to: "users#new"

  get "/about", to: "about#index"  

  get "/activities", to: "activities#index"
  get "/activities", to: "activities#create"

  resources :alertoverrides
  
  get "/alertoverrides", to: "alertoverrides#deactivate"
  get "/alertoverrides", to: "alertoverrides#send_args"
  get "/alertoverrides", to: "alertoverrides#this_param"

   get "/alerts", to: "alerts#index"
   get "/alerts", to: "alerts#batch_alerts"
   get "/alerts", to: "alerts#show"
   get "/alerts", to: "alerts#allocated_comments"
   get "/alerts", to: "alerts#update"
   get "/alerts", to: "alerts#batch_update"

resources :authorisations do 
   get '/page/:page', action: :index, on: :collection
 end
   get "/authorisations", to: "authorisations#index"
   get "/authorisations", to: "authorisations#all"
   get "/authorisations", to: "authorisations#mark"
   get "/authorisations", to: "authorisations#unmark"
   get "/authorisations", to: "authorisations#unused_fields"
   get "/authorisations", to: "authorisations#used_fields"

   get "/batch", to: "batch#index"

   resources :journals, only: [:index]
    resources :violations, only: [:index]
       resources :comments, only: [:index, :create]
      resources :activities, only: [:index, :create]
      resources :investigations, only: [:create, :index]
        
        resources :reminders, except: [:destroy, :edit, :new], constraints: { id: /\d+(\.\d+)?-\d+/ }, shallow: true do #, shallow_path: 'api' do
        resources :comments, only: [:index]
      end
   resources :customers



    resources :criteria, only: [:create, :destroy]  do
      collection do
        post 'description', to: 'criteria#description'
      end
    end
    resources :customers do
      
      collection do
        get "/members", to: "customers#members"
        # get 'clients' => "customers#clients"
        get "/merchants", to: "customers#merchants"
        
        get "client_with_many_merchants", to: "customers#client_with_many_merchants"
      end
      
    end
     resources :fields_lists, only: [:show]
    # resources :list_management, only: [:index, :show, :create, :update] do
    #   collection do
    #     get :dropdown_list
    #     get :get_list
    #     get :get_default_list
    #   end
    #   member do
    #     get :export
    #     post :import
    #     get :disable
    #   end
    # end
   
   #get "/fields_lists", to: "fields_lists#show"

   resources :lists
  
  get "/lists", to: "list_management#import"
  get "/lists", to: "list_management#export"
  get "/lists", to: "list_management#disable"
  get "/lists", to: "list_management#dropdown_list"

  resources :members
  resources :merchants
  resources :clients 


  resources :rules
  get "/rules", to: "rules#all"
  get "/rules", to: "rules#disable"
  get "/rules", to: "rules#activate"
  get "/rules", to: "rules#deactivate"
  get "/rules", to: "rules#live"
  get "/rules", to: "rules#authorisation_ids"

  
  get "/rule_schedules", to: "rule_schedules#show"
  get "/rule_schedules", to: "rule_schedules#create"
  get "/rule_schedules", to: "rule_schedules#edit"
  get "/rule_schedules", to: "rule_schedules#disable"
  get "/rule_schedules", to: "rule_schedules#resources"

 
  get "/reports", to: "reports#disable"
  get "/reports", to: "reports#results"
  get "/reports", to: "reports#execute"
  get "/reports", to: "reports#disable_result"
  get "/reports", to: "reports#results"
  get "/reports", to: "reports#result_downloads"
  get "/reports", to: "reports#result_download"

  
  get "/statistics", to: "statistics#index"
  get "/statistics", to: "statistics#list"
  get "/statistics", to: "statistics#show"
  get "/statistics", to: "statistics#create"
  get "/statistics", to: "statistics#disable"

  get "/statistic_timeframes", to: "statistic_timeframes#index"  

  get "/statistics_operations", to: "statistics_operations#index"
 
  get "/settings", to: "settings#index"

  get "/suspect_lists", to: "suspect_lists#create"


  get "reset_password", to: "reset_password#index"

   
end
