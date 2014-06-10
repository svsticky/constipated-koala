class AdminDevise::RegistrationsController < Devise::RegistrationsController

  private

  def after_sign_up_path_for(resource)
    super
    impressionist(resource, message:"Nieuwe Admin gebruiker")
  end

end
