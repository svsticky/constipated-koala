class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_admin!, only: [:create, :destroy]
end
