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

      get   'edit',         to: 'users/home#edit',   as: :users_edit
      patch 'edit',         to: 'users/home#update'

      post  'mongoose',     to: 'users/home#add_funds'
      get   'mongoose',     to: 'users/home#confirm_add_funds'
    end

    root 'admin/home#index'

    # No double controllers
    get     'admin/home',   to: redirect('/')
    get     'users/home',   to: redirect('/')

    # Devise routes
    devise_for :users, :path => '', :skip => [ :registrations ], :controllers => {
      sessions:       'users/sessions'
    }

    get     'sign_up',      to: 'users/registrations#new',  as: :new_registration
    post    'sign_up',      to: 'users/registrations#create'

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

      resources :settings, only: [:index, :create] do
        collection do
          get 'logs'

          patch 'profile',        to: 'settings#profile'

          post 'advertisement'
          delete 'advertisement', to: 'settings#destroy_advertisement'
        end
      end

      scope 'apps' do
        get 'ideal',              to: 'apps#ideal'
        get 'checkout',           to: 'apps#checkout'

        # json checkout urls
        patch  'cards',           to: 'checkout_products#activate_card'
        patch  'transactions',    to: 'checkout_products#change_funds'

        resources :checkout_products, only: [:index, :show, :create, :update], path: 'products'
      end
    end

    scope 'api' do
      use_doorkeeper do
        skip_controllers :token_info, :applications, :authorized_applications
      end

      scope module: 'api' do
        resources :members, only: [:index, :show] do
          resources :participants, only: :index
        end

        resources :groups, only: [:index, :show]

        resources :activities, only: [:index, :show] do
          resources :participants, only: [:index, :create, :destroy]
        end


        # NOTE legacy implementation for checkout without oauth
        scope 'checkout' do
          get 'card',           to: 'checkout#info'
          post 'card',          to: 'checkout#create'

          get 'products',       to: 'checkout#products'
          post 'transaction',   to: 'checkout#purchase'
        end

        get 'advertisements',   to: 'activities#advertisements'
      end
    end
  end

  get '/', to: redirect('/404')
end
