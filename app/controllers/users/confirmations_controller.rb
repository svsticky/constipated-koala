#:nodoc:
class Users::ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_admin!, only: :show

  # This method is used to confirm account on creation as well as confirmation on updating email
  def show
    # change email for member first using unconfirmed_email, then super, super ends the function
    user = User.find_by_confirmation_token params['confirmation_token']
    unless user.nil? || user.uncofirmed_email.nil? || user.admin?
      user.credentials.update_column(:email, user.unconfirmed_email)
      user.credentials.update_fuzzy_query!
    end

    super
  end
end
