#:nodoc:
class Users::ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_admin!, :only => [:show, :create]

  # This method is used when a user wants to confirm their email
  def show
    @user = User.find_by(confirmation_token: params[:confirmation_token]) unless params['confirmation_token'].nil?

    # no confirmation token, redirect to login
    if @user.nil?
      flash[:alert] = I18n.t 'devise.confirmations.no_token'
      redirect_to :new_user_session
      return
    end

    render 'devise/confirmations/show'
  end

  # This method is called once the user submits the form rendered in show
  def create
    user = User.find_by(confirmation_token: confirmation_params[:confirmation_token]) unless confirmation_params[:confirmation_token].nil?

    # no confirmation token
    if user.nil?
      flash[:alert] = I18n.t 'devise.confirmations.no_token'
      redirect_to :new_user_session
      return
    end

    # require valid password to confirm email
    unless user.valid_password?(confirmation_params[:password])
      flash[:alert] = I18n.t 'devise.failure.invalid_password'
      redirect_to user_confirmation_path(:confirmation_token => confirmation_params[:confirmation_token])
      return
    end

    # send new email address to mailchimp
    # then update the email column for the member
    # finally, confirm the user with devise
    unless user.nil? || user.unconfirmed_email.nil? || user.admin?
      MailchimpUpdateAddressJob.perform_later user.email, user.unconfirmed_email
      user.credentials.update_column(:email, user.unconfirmed_email)
      user.credentials.update_fuzzy_query!
      user.confirm
      user.confirmation_token = nil
    end

    redirect_to :new_user_session, :notice => I18n.t('devise.confirmations.confirmed')
  end

  def confirmation_params
    params.require(:user).permit(:email, :password, :confirmation_token)
  end
end
