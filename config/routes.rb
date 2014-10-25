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
    resources :members, :activities, :committees

    # Participants routes for JSON calls
    get    'participants/list', to: 'participants#list'
    get    'participants',      to: 'participants#find'
    post   'participants',      to: 'participants#create'
    patch  'participants',      to: 'participants#update'
    delete 'participants',      to: 'participants#destroy'

    # CommitteeMembers JSON calls
    get    'committeeMembers', to: 'committee_members#find'
    post   'committeeMembers', to: 'committee_members#create'
    patch  'committeeMembers', to: 'committee_members#update'
    delete 'committeeMembers', to: 'committee_members#destroy'
    
    #mail JSON calls
    post   'mail',              to: 'mail#mail'
  end

  get '/', to: redirect('/404')
end
