#:nodoc:
class Users::RegistrationsController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate, only: :edit

  layout 'doorkeeper'

  def new
    @user = User.new
    render 'devise/registrations/new'
  end

  def create
    if User.find_by_email sign_up_params[:email]
      User.send_reset_password_instructions(sign_up_params.slice(:email))
      flash[:alert] = I18n.t :signed_up_but_unconfirmed, scope: 'devise.registrations'

      redirect_to :new_user_session
      return
    end

    @user = User.new sign_up_params
    @user.credentials = Member.find_by_email sign_up_params[:email]

    flash[:alert] = nil

    if @user.credentials.nil?
      flash[:alert] = I18n.t :not_found_in_database, scope: 'devise.registrations'
      render 'devise/registrations/new'
      return
    end

    if @user.save
      flash[:notice] = I18n.t :signed_up_but_unconfirmed, scope: 'devise.registrations'
      redirect_to :new_user_session
    else
      render 'devise/registrations/new'
    end
  end

  # show page for first confirmation setting a new password for new enrollments
  def edit
    @user = User.find_by(confirmation_token: params[:confirmation_token])

    if @user.nil?
      flash[:alert] = I18n.t 'devise.passwords.no_token'
      redirect_to :new_user_session
      return
    end

    if @user.confirmed?
      flash[:notice] = "#{ @user.email } #{ I18n.t 'errors.messages.already_confirmed' }"
      redirect_to :new_user_session
      return
    end

    render 'devise/confirmations/edit'
  end

  # update newly chosen password
  def update
    @user = User.find_by!(confirmation_token: sign_up_params[:confirmation_token])
    @user.update(sign_up_params.except(:email, :confirmation_token))

    if @user.save
      @user.confirm # confirm account

      flash[:notice] = I18n.t :confirmed, scope: 'devise.confirmations'
      redirect_to :new_user_session
      return
    end

    render 'devise/confirmations/edit'
  end

  private

  def authenticate
    return if params[:confirmation_token].present?

    flash[:alert] = I18n.t 'devise.passwords.no_token'
    redirect_to :new_user_session
    return
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :confirmation_token)
  end
end
