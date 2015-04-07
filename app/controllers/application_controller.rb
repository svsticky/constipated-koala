class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # Moved the authentication requirement to the application controller
  before_action :authenticate_user!
  before_action :authenticate_admin!
  
  protected
  def authenticate_admin!    
    if !current_user.nil? && !current_user.admin?
      render 'public/403', :status => 403, :layout => false
    end
  end

  def enable_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
end
