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

    root 'admin/home#index'

    # No double controllers
    get 'admin/home',  to: redirect('/')
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
      get   'registration/cancel',    to: 'users/registrations#cancel',   as: :cancel_registration

      get   'sign_up',                to: 'users/registrations#new',      as: :new_registration
      post  'sign_up',                to: 'users/registrations#create',   as: :registration

      get   'settings/profile',       to: 'users/registrations#edit',     as: :edit_registration
      put   'settings/profile',       to: 'users/registrations#update'
      patch 'settings/profile',       to: 'users/registrations#update'
    end

    scope module: 'admin' do
      resources :members do
        collection do
          get 'search'
        end
      end

      resources :activities do
        resources :participants, only: [:create, :update, :destroy] do
          collection do
            post 'mail'
          end
        end
      end

      resources :groups, only: [:index, :create, :show, :update] do
        resources :group_members, only: [:create, :update, :destroy], path: 'members'
      end

      resources :settings, only: [:index, :create, :update] do
        collection do
          get 'logs'

          post 'advertisement'
          delete 'advertisement', :to => 'settings#destroy_advertisement'
        end
      end

      scope 'apps' do
        get 'ideal',              :to => 'apps#ideal'
        get 'checkout',           :to => 'apps#checkout'

        # json checkout urls
        patch  'cards',           :to => 'checkout_products#activate_card'
        patch  'transactions',    :to => 'checkout_products#change_funds'

        resources :checkout_products, only: [:index, :show, :create, :update], path: 'products'
      end
    end

    scope 'api' do
      use_doorkeeper do
        skip_controllers :token_info, :applications, :authorized_applications
      end


      # api routes, without authentication                        NOTE obsolete
      get    'api/activities',        to: 'api#activities'
      get    'api/advertisements',    to: 'api#advertisements'

      # api routes, own authentication                            NOTE obsolete
      get    'api/checkout/card',         to: 'checkout#information_for_card'
      get    'api/checkout/products',     to: 'checkout#products_list'

      post   'api/checkout/card',         to: 'checkout#add_card_to_member'
      post   'api/checkout/transaction',  to: 'checkout#subtract_funds'



      scope module: 'api' do
        resources :members, only: [:index, :show] do
          resources :participants, only: :index
        end

        resources :groups, only: [:index, :show]

        resources :activities, only: [:index, :show] do
          resources :participants, only: [:index, :create, :destroy]
        end

        # get    'checkout/transactions', to: 'checkout#index'
        # post   'checkout/transactions', to: 'checkout#transaction'
        #
        # get    'checkout/products',     to: 'checkout#products'
        # post   'checkout/ideal',        to: 'checkout#ideal'
        #
        # get    'checkout/info',         to: 'checkout#info'
        # get    'checkout/card/:uuid',   to: 'checkout#show'
        # put    'checkout/card/:uuid',   to: 'checkout#update'
        # post   'checkout/card',         to: 'checkout#create'
        # patch  'checkout/card/:uuid',   to: 'checkout#update'
        # delete 'checkout/card/:uuid',   to: 'checkout#destroy'
        #
        # get    'advertisements',    to: 'activities#advertisements'
      end
    end
  end

  get '/', to: redirect('/404')
end
