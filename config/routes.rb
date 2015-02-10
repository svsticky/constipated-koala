ConstipatedKoala::Application.routes.draw do
  
  constraints :subdomain => 'intro' do
    scope module: 'users' do
      get  '/', to: 'public#index', as: 'public'
      post '/', to: 'public#create'
  
      get 'confirm', to: 'public#confirm'
    end
  end

  constraints :subdomain => 'koala' do
    
    authenticated :user, ->(u) { !u.admin? } do
      root to: 'users/home#index', as: :user_root
    end
    
    root 'admins/home#index'

    # No double controllers
    get 'admins/home', to: redirect('/')
    get 'users/home',  to: redirect('/')

    # Devise routes
    devise_for :users, :skip => [ :registrations ], :path => '', controllers:
    {
      registrations:  'users/registrations',
      sessions:       'users/sessions',
      passwords:      'users/passwords',
      confirmations:  'users/confirmations'
    }

    # override route for user profile
    devise_scope :user do
      get   'registration/cancel',  to: 'users/registrations#cancel',   as: :cancel_registration
      
#      get   'sign_up',              to: 'users/registrations#new',      as: :new_registration      
#      post  'sign_up',              to: 'users/registrations#create',   as: :registration

      get   'settings/profile',     to: 'users/registrations#edit',     as: :edit_registration
      put   'settings/profile',     to: 'users/registrations#update'
      patch 'settings/profile',     to: 'users/registrations#update'
    end

    scope module: 'admins' do
      # Resource pages
      resources :members, :activities
  
      # Participants routes for JSON calls
      get    'participants/list', to: 'participants#list'
      get    'participants',      to: 'participants#find'
      post   'participants',      to: 'participants#create'
      patch  'participants',      to: 'participants#update'
      delete 'participants',      to: 'participants#destroy'
      post   'participants/mail', to: 'participants#mail'  
      
      # search for member using dropdown
      get    'search',                to: 'members#find'
  
      # checkout urls
      get    'checkout',              to: 'checkout#index'
      
      patch  'checkout/card',         to: 'checkout#activate_card'
      patch  'checkout/transaction',  to: 'checkout#change_funds'  
      
      # api routes, own authentication
      get    'checkout/card',         to: 'checkout#information_for_card'
      post   'checkout/card',         to: 'checkout#add_card_to_member'
      post   'checkout/transaction',  to: 'checkout#subtract_funds'
    end
  end

  get '/', to: redirect('/404')
end
