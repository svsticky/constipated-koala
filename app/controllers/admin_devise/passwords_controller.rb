class AdminDevise::PasswordsController < Devise::PasswordsController

  private

  def after_resetting_password_path_for(resource)
    super
#    impressionist(resource, message:"Wachtwoord veranderd")
  end

end
