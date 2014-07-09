ConstipatedKoala::Application.routes.draw do
  # You can have the root of your site routed with "root"
  root 'home#index'
  get "home/index"

  devise_for :admins, controllers: {registrations: "admin_devise/registrations",
                                    unlocks: "admin_devise/unlocks",
                                    passwords: "admin_devise/passwords"}
  # Resource pages
  resources :members, :activities
   
  #public pages for member registration
  get 'public' => 'public#index'
  post 'public' => 'public#create'

 end
