Rails.application.routes.draw do
  use_doorkeeper_openid_connect

  constraints :subdomain => ['intro', 'intro.dev'] do
    scope module: 'public' do
      get  '/', to: 'home#index', as: 'public'
      post '/', to: 'home#create'
    end
  end

  constraints :subdomain => ['koala', 'koala.dev', 'leden', 'leden.dev', 'members', 'members.dev'] do
    authenticate :user, ->(u) { !u.admin? } do
      scope module: 'members' do
        root to: 'home#index', as: :users_root

        resource :member, as: 'current_member', only: [:show, :edit, :update] do
          get 'download', to: 'members#download'

          # update password from member options
          get     'password',     to: '/users/password_change#edit'
          patch   'password',     to: '/users/password_change#update'

          post    'mongoose',     to: 'members#add_funds'

          # revoke access to external authorized_applications
          delete 'authorized_applications/:id',   to: 'members#revoke', as: :authorized_applications
        end

        resources :activities, only: [:index, :show] do
          get 'participants', to: redirect('/activities/%{activity_id}')
          resource :participants, only: [:create, :update, :destroy]
        end
      end
    end

    root 'admin/home#index'

    # No double controllers
    get     'admin/home',   to: redirect('/')
    get     'members/home', to: redirect('/')

    # Devise routes
    devise_for :users, :path => '', :skip => [:registrations], :controllers => {
      confirmations: 'users/confirmations',
      sessions: 'users/sessions',
      passwords: 'users/passwords'
    }

    # create account using a member's email
    get     'sign_up',      to: 'users/registrations#new', as: :new_registration
    post    'sign_up',      to: 'users/registrations#create'

    # update account with password after receiving invite
    get     'activate',     to: 'users/registrations#edit', as: :new_member_confirmation
    post    'activate',     to: 'users/registrations#update', as: :new_member_confirm

    scope module: 'public' do
      get   'status(/:token)', to: 'status#edit'
      post  'status',          to: 'status#update'
      post  'status/destroy',  to: 'status#destroy'
    end

    scope module: 'admin' do
      resources :members do
        get   'payment_whatsapp'
        patch 'force_email_change'
        post  'email/:type', to: 'members#send_email', as: :mail

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

      scope 'payments' do
        get 'payments', to: 'payments#index'
        get 'whatsapp/:member_id', to: 'payments#whatsapp_redirect', as: 'payment_whatsapp_redirect'
        get 'transactions',       to: 'payments#update_transactions'
      end

      resources :groups, only: [:index, :create, :show, :update, :destroy] do
        resources :group_members, only: [:create, :update, :destroy], path: 'members'
      end

      resources :settings, only: [:index, :create] do
        collection do
          get 'logs'
          patch 'profile', to: 'settings#profile'

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
          patch :flip, action: :flip_active
          match :flip, action: :flip_active, via: [:patch]
        end
      end

      # sidekiq web interface
      authenticate :user, ->(u) { u.admin? } do
        require 'sidekiq/web'
        mount Sidekiq::Web => '/sidekiq'
      end
    end

    scope 'api' do
      use_doorkeeper do
        # skip_controllers :token_info, :applications, :authorized_applications
      end

      scope module: 'api' do
        resources :members, only: [:index, :show, :create] do
          resources :participants, only: :index
        end

        resources :groups, only: [:index, :show]

        resources :activities, only: [:index, :show] do
          resources :participants
          get 'poster'
          get 'thumbnail'
        end

        scope 'hook' do
          get 'mollie/:token',  to: 'webhook#mollie_redirect',    as: 'mollie_redirect'
          post 'mollie',        to: 'webhook#mollie_hook',        as: 'mollie_hook'

          get 'mailchimp/:token', to: 'webhook#mailchimp_confirm_callback', as: 'mailchimp_confirm'
          post 'mailchimp/:token', to: 'webhook#mailchimp', as: 'mailchimp'
        end

        # NOTE legacy implementation for checkout without oauth
        scope 'checkout' do
          get  'card',          to: 'checkout#info'
          post 'card',          to: 'checkout#create'
          get  'confirmation',  to: 'checkout#confirm'

          get  'products',      to: 'checkout#products'
          post 'transaction',   to: 'checkout#purchase'
        end

        get 'advertisements', to: 'activities#advertisements'
      end
    end
  end

  get '/', to: redirect('/404')
end
