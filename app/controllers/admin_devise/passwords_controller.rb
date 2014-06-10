class AdminDevise::PasswordsController < Devise::PasswordsController

  private

  def after_resetting_password_path_for(resource)
    super
    imperssionist(resource, message:"Wachtwoord veranderd")
  end

end
