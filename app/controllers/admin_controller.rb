class AdminController < UserController
  before_action :authenticate_admin!

  protected
  def authenticate_admin!
    if !current_user.nil? && !current_user.admin?
      head :forbidden
      return
    end
  end
end