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

    # Find routes for JSON calls
    get    'members/find',      to: 'members#find'
    get    'committees/find',   to: 'committees#find'

    post   'activities/setOrganiser', to: 'activities#setOrganiser'

    # Participants routes for JSON calls
    get    'participants/list', to: 'participants#list'
    post   'participants',      to: 'participants#create'
    patch  'participants',      to: 'participants#update'
    delete 'participants',      to: 'participants#destroy'

    # CommitteeMembers JSON calls
    post   'committeeMembers', to: 'committees#createMember'
    patch  'committeeMembers', to: 'committees#updateMember'
    delete 'committeeMembers', to: 'committees#destroyMember'

    #mail JSON calls
    post   'mail',              to: 'mail#mail'

    # Resource pages
    resources :members, :activities, :committees
  end

  get '/', to: redirect('/404')
end
