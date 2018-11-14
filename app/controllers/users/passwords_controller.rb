# This controller is overridden to re-send the account confirmation e-mail if a password reset is requested while the
# account has not yet been confirmed.
class Users::PasswordsController < Devise::PasswordsController
  def create
    @user = User.find_by email: resource_params[:email]

    if @user && !@user.confirmed?
      @user.resend_confirmation! :confirmation_instructions

      flash[:notice] = I18n.t 'devise.passwords.account_not_confirmed_resent'
      redirect_to :new_user_session
      return
    end

    super
  end
end
