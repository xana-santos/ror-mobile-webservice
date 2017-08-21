PfloRewrite::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "pages#home"

  controller :documentation do
    get "documentation" => :show
  end

  resources :sessions, controller: :client_sessions, only: :show do
    post "confirm"
    post "reject"
  end

  resources :purchases, only: :show do
    post "confirm"
    post "reject"
  end

  resources :clients, only: [] do
    get "terms"
    post "terms/accept" => :accept_terms
  end

  controller :pages do
    get "terms/:terms" => :terms, as: :terms
  end

  controller :password_reset do
    get   '/reset/:reset_token' => :edit, as: 'reset_password'
    patch '/reset/:reset_token' => :update, as: 'change_password'
  end

  namespace :v1 do

    controller :trainers do

      post "trainer" => :create
      get "trainer" => :show
      put "trainer" => :update
      delete "trainer" => :destroy

      get "trainer/list" => :index

      post "trainer/restore" => :restore
      post "trainer/authenticate" => :authenticate

      post "trainer/activate" => :activate
      post "trainer/deactivate" => :deactivate

      post "trainer/forgot_password" => :forgot

    end

    controller :stripe do
      post "stripe/events" => :events
    end

    controller :gyms do

    post "gym" => :create
    get "gym" => :show
    put "gym" => :update

    delete "gym" => :destroy
    get "gym/list" => :index
    post "gym/restore" => :restore

    end

    controller :gym_locations do

      post "gym_location" => :create
      get "gym_location" => :show
      put "gym_location" => :update
      delete "gym_location" => :destroy

      get "gym_location/list" => :index

      post "gym_location/restore" => :restore

    end

    controller :addresses do

      post "address" => :create
      get "address" => :show
      put "address" => :update
      delete "address" => :destroy

      get "address/list" => :index

      post "address/restore" => :restore

    end

    controller :images do

      post "image" => :create
      get "image" => :show
      put "image" => :update
      delete "image" => :destroy

      get "image/list" => :index

      post "image/restore" => :restore

    end

    controller :clients do

      post "client" => :create
      get "client" => :show
      put "client" => :update
      delete "client" => :destroy

      get "client/list" => :index

      post "client/restore" => :restore

      post "client/authenticate" => :authenticate

      post "client/activate" => :activate
      post "client/deactivate" => :deactivate

    end

    controller :trainers do

      post "trainer" => :create
      get "trainer" => :show
      put "trainer" => :update
      delete "trainer" => :destroy

      get "trainer/list" => :index

      post "trainer/restore" => :restore
      post "trainer/authenticate" => :authenticate

      post "trainer/activate" => :activate
      post "trainer/deactivate" => :deactivate

    end

    controller :sessions do
      get "session/list" => :index
      get "session" => :show

      post "session" => :create
      put "session" => :update


      post "session/mark_attendance" => :attendance
      post "session/resend_confirmation" => :resend

      delete "session/cancel" => :cancel

    end

    controller :consultations do

      post "consultation" => :create
      get "consultation" => :show
      put "consultation" => :update
      delete "consultation" => :destroy

      get "consultation/list" => :index
      post "consultation/restore" => :restore

    end

    controller :comments do

      post "comment" => :create
      get "comment" => :show
      put "comment" => :update
      delete "comment" => :destroy

      get "comment/list" => :index
      post "comment/restore" => :restore

    end

    controller :users do
      post "user/authenticate" => :authenticate
    end

    controller :appointments do

      post "appointment" => :create
      get "appointment" => :show
      put "appointment" => :update
      delete "appointment" => :destroy

      get "appointment/list" => :index
      post "appointment/restore" => :restore

    end

    controller :products do

      post "product" => :create
      get "product" => :show
      put "product" => :update
      delete "product" => :destroy

      get "product/list" => :index
      post "product/restore" => :restore

    end

    controller :invoices do
      get "invoice" => :show
      get "invoice/list" => :index
      get "invoice/retry" => :retry
      get "invoice/send_csv" => :csv
    end

    controller :invoice_items do
      get "invoice_item" => :show
      get "invoice_item/list" => :index
    end

    controller :product_categories do

      post "product_category" => :create
      get "product_category" => :show
      put "product_category" => :update
      delete "product_category" => :destroy

      get "product_category/list" => :index
      post "product_category/restore" => :restore

    end

    controller :purchases do

      post "purchase" => :create
      get "purchase" => :show

      delete "purchase" => :destroy

      delete "purchase/cancel" => :cancel

      get "purchase/list" => :index

      post "purchase/resend_confirmation" => :resend

      post "purchase/restore" => :restore
      post "purchase/confirm" => :confirm

    end

  end

  match "*path", :to => "api#routing_error", :via => :all, :constraints => {:format => [:html, :json, :js]}

end
