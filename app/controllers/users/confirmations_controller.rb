#:nodoc:
class Users::ConfirmationsController < Devise::ConfirmationsController
  # This method is used to confirm account on creation as well as confirmation on updating email
  def show
    # change email for member first using unconfirmed_email, then super, super ends the function
    user = User.find_by_confirmation_token params['confirmation_token']
    user.credentials.update_column(:email, user.unconfirmed_email) unless user.nil? || user.unconfirmed_email.nil? || user.admin?
    user.credentials.update_fuzzy_query!

    super
  end

  # show page for first confirmation setting a new password for new enrollments
  def edit
    @user = User.find_by(confirmation_token: params[:confirmation_token])

    if @user.confirmed?
      flash[:notice] = "#{ @user.email } #{ I18n.t 'errors.messages.already_confirmed' }"
      redirect_to :new_user_session
    end

    render 'devise/confirmations/edit'
  end

  # update newly chosen password
  def update
    @user = User.find_by(confirmation_token: params[:confirmation_token])
    @user.update(sign_up_params)

    if @user.save
      @user.confirm # confirm account

      flash[:notice] = I18n.t :confirmed, scope: 'devise.confirmations'
      redirect_to :new_user_session
    else
      render 'devise/confirmations/edit'
    end
  end

  private

  def authenticate
    return if sign_up_params[:confirmation_token]

    flash[:alert] = I18n.t 'devise.passwords.no_token'
    redirect_to :new_user_session
    return
  end

  def sign_up_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
