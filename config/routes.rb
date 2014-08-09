ConstipatedKoala::Application.routes.draw do
  constraints :subdomain => 'koala' do
    # You can have the root of your site routed with "root"
    root 'home#index'
   
    # Home controller
    get 'home' => 'home#index'
  
    # Devise routes
    devise_for :admins, controllers: 
    {
      registrations: "admin_devise/registrations",
      unlocks: "admin_devise/unlocks",
      passwords: "admin_devise/passwords"
    }
    
    # Resource pages
    resources :members, :activities
  
    # Participants routes for JSON calls
    get 'participants/list' => 'participants#list'
    get 'participants' => 'participants#find'
    post 'participants' => 'participants#create'
    patch 'participants' => 'participants#update'
    delete 'participants' => 'participants#destroy'
  end

  constraints :subdomain => 'abc' do
    match '/', to: 'public#index', via: :get, as: 'public'
    match '/', to: 'public#create', via: :post

    # Public pages for member registration
#    get 'public' => 'public#index'
#    post 'public' => 'public#create'
  end
end
