#:nodoc:
class Users::ConfirmationsController < Devise::ConfirmationsController
  # This method is used to confirm account on creation as well as confirmation on updating email
  def show
    # change email for member first using unconfirmed_email, super ends the function
    user = User.find_by_confirmation_token params['confirmation_token']
    user.credentials.update_column(:email, user.unconfirmed_email) unless user.nil? || user.unconfirmed_email.nil? || user.admin?
    user.credentials.update_fuzzy_query!

    super
  end
end
