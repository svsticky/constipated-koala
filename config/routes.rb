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
      root to: 'users/home#index', as: :users_root

      get    'edit',   to: 'users/home#edit',   as: :users_edit
      patch  'edit',   to: 'users/home#update'

      post   'mongoose',        to: 'users/home#add_funds'
      get    'mongoose',        to: 'users/home#confirm_add_funds'
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

      get   'sign_up',              to: 'users/registrations#new',      as: :new_registration
      post  'sign_up',              to: 'users/registrations#create',   as: :registration

      get   'settings/profile',     to: 'users/registrations#edit',     as: :edit_registration
      put   'settings/profile',     to: 'users/registrations#update'
      patch 'settings/profile',     to: 'users/registrations#update'
    end

    scope module: 'admins' do
      # Resource pages
      resources :members, :activities

      # search for member using dropdown
      get    'search',            to: 'members#find'

      get    'groups',            to: 'groups#index'
      post   'groups',            to: 'groups#create'
      get    'groups/:id',        to: 'groups#index',       as: :group
      patch  'groups/:id',        to: 'groups#update'

      post   'groups/:id/members',    to: 'groups#create_member'
      patch  'groups/:id/member',     to: 'groups#update_member'
      delete 'groups/:id/member',     to: 'groups#destroy_member'

      # Participants routes for JSON calls
      get    'participants/list', to: 'participants#list'
      get    'participants',      to: 'participants#find'
      post   'participants',      to: 'participants#create'
      patch  'participants',      to: 'participants#update'
      delete 'participants',      to: 'participants#destroy'
      post   'participants/mail', to: 'participants#mail'

      # setting pages
      get    'settings',                  to: 'settings#index'
      post   'settings/advertisement',    to: 'settings#advertisement'
      delete 'settings/advertisement',    to: 'settings#destroy_advertisement'
      get    'settings/mailings',         to: 'settings#mailings'
      post   'settings/mailings',         to: 'settings#mail'

      get    'apps/ideal',                 to: 'apps#ideal'
      get    'apps/checkout',              to: 'apps#checkout'
      get    'apps/products',              to: 'apps#products'
      get    'apps/products/:id',          to: 'apps#products',             as: :apps_product
      patch  'apps/products/:id',          to: 'apps#update_product'
      post   'apps/products',              to: 'apps#create_product'

      # json checkout urls
      patch  'checkout/card',         to: 'checkout#activate_card'
      patch  'checkout/transaction',  to: 'checkout#change_funds'

      # api routes, without authentication
      get    'api/activities',        to: 'api#radio'

#       # v1
#       get    'checkout/card',         to: 'checkout#information_for_card'
#       post   'checkout/card',         to: 'checkout#add_card_to_member'
#       post   'checkout/transaction',  to: 'checkout#subtract_funds'

      # v2 api routes, own authentication
      get    'api/checkout/card',         to: 'checkout#information_for_card'
      get    'api/checkout/products',     to: 'checkout#products_list'

      post   'api/checkout/card',         to: 'checkout#add_card_to_member'
      post   'api/checkout/transaction',  to: 'checkout#subtract_funds'
    end
  end

  get '/', to: redirect('/404')
end
