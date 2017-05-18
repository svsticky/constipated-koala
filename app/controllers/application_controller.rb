class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: :true

  # Moved the authentication requirement to the application controller
  before_action :authenticate_user!
  before_action :authenticate_admin!

  protected
  def authenticate_admin!
    if !current_user.nil? && !current_user.admin?
      head :forbidden
      return
    end
  end
end
