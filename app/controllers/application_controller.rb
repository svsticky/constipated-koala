class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Moved the authentication requirement to the application controller
  before_action :authenticate_user!
  before_action :authenticate_admin!

  protected
  def authenticate_user!
    if user_signed_in?
      super
    else
      if request.get?
        store_location_for(:user, request.url)
      end
      redirect_to new_user_session_path
    end
  end

  def authenticate_admin!
    if !current_user.nil? && !current_user.admin?
      head :forbidden
      return
    end
  end
end
