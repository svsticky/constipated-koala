ConstipatedKoala::Application.routes.draw do
  constraints :subdomain => 'intro' do
    get  '/', to: 'public#index', as: 'public'
    post '/', to: 'public#create'

    get 'confirm', to: 'public#confirm'
  end

  constraints :subdomain => 'koala' do
    # You can have the root of your site routed with "root"
    root 'home#index'

    # No double controllers
    get 'home', to: redirect('/')

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
    get    'participants/list', to: 'participants#list'
    get    'participants',      to: 'participants#find'
    post   'participants',      to: 'participants#create'
    patch  'participants',      to: 'participants#update'
    delete 'participants',      to: 'participants#destroy'
    
    # mail JSON calls
    post   'mail',              to: 'mail#mail'
    
    # checkout urls
    get    'checkout',          to: 'checkout#index'
    get    'checkout/card',     to: 'checkout#information_for_card'
    post   'checkout',          to: 'checkout#subtract_funds'
    patch  'checkout',          to: 'checkout#change_funds'
    post   'checkout/card',     to: 'checkout#add_card_to_member'
  end

  get '/', to: redirect('/404')
end
