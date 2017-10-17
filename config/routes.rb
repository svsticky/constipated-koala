Rails.application.routes.draw do
  constraints :subdomain => ['intro', 'intro.dev'] do
    get  '/', to: 'public#index', as: 'public'
    post '/', to: 'public#create'
  end

  constraints :subdomain => ['koala', 'koala.dev', 'leden', 'leden.dev', 'members', 'members.dev'] do
    authenticate :user, ->(u) { !u.admin? } do
      scope module: 'members' do
        root to: 'home#index', as: :users_root

        get   'edit',                           to: 'home#edit',   as: :users_edit
        patch 'edit',                           to: 'home#update'
        delete 'authorized_applications/:id',   to: 'home#revoke', as: :authorized_applications

        post  'mongoose',                       to: 'home#add_funds'

        get 'enrollments',                      to: redirect('/activities')
        get 'enrollments/:id',                  to: redirect('/activities/%{id}')

        resources :activities, only: [:index, :show] do
          resource :participants, only: [:create, :update, :destroy]
        end
      end
    end

    root 'admin/home#index'

    # No double controllers
    get     'admin/home',   to: redirect('/')
    get     'members/home',   to: redirect('/')

    # Devise routes
    devise_for :users, :path => '', :skip => [ :registrations ], :controllers => {
      sessions:       'users/sessions'
    }

    get     'sign_up',      to: 'users/registrations#new',  as: :new_registration
    post    'sign_up',      to: 'users/registrations#create'
    get     'activate',     to: 'users/registrations#new_member_confirmation', as: :new_member_confirmation
    post    'activate',     to: 'users/registrations#new_member_confirm', as: :new_member_confirm

    scope module: 'admin' do
      resources :members do
        get 'payment_whatsapp'
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

      resources :payments, only: [:index], path: 'payments'

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

        resources :checkout_products, only: [:index, :show, :create, :update], path: 'products' do
          get :flip, action: :flip_active
          match :flip, action: :flip_active, via: [:patch, :put]
        end

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
          resources :participants, only: [:index, :create] do
            collection do
              delete '',        to: 'participants#destroy'
            end
          end
        end

        scope 'hook' do
          get 'mollie/:token',  to: 'webhook#mollie_redirect',    as: 'mollie_redirect'
          post 'mollie',        to: 'webhook#mollie_hook',        as: 'mollie_hook'
        end

        # NOTE legacy implementation for checkout without oauth
        scope 'checkout' do
          get 'card',           to: 'checkout#info'
          post 'card',          to: 'checkout#create'
          get 'confirmation',   to: 'checkout#confirm'

          get 'products',       to: 'checkout#products'
          post 'transaction',   to: 'checkout#purchase'
        end

        get 'advertisements',   to: 'activities#advertisements'
      end
    end
  end

  get '/', to: redirect('/404')
end
