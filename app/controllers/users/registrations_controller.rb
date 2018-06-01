#:nodoc:
class Users::RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :new_member_confirmation, :new_member_confirm]
  skip_before_action :authenticate_admin!, only: [:new, :create, :new_member_confirmation, :new_member_confirm]
  before_action :get_user_from_token, only: [:new_member_confirmation, :new_member_confirm]

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

  def new_member_confirmation
    render 'devise/confirmations/with_password'
  end

  def new_member_confirm
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.save
      @user.confirm
      flash[:notice] = I18n.t :confirmed, scope: 'devise.confirmations'
      redirect_to :new_user_session
    else
      render 'devise/confirmations/with_password'
    end
  end

  # Ensure the confirmation_token is valid, retrieve user if it is, else redirect with error.
  def get_user_from_token # rubocop:disable AccessorMethodName
    token = params[:confirmation_token]
    if !token && params[:user]
      token = params[:user][:confirmation_token] # Or doesn't work if :user == nil
    end

    unless token
      flash[:alert] = I18n.t 'devise.passwords.no_token'
      redirect_to :new_user_session
      return
    end

    @user = User.find_by(confirmation_token: token)
    if !@user
      flash[:alert] = I18n.t 'devise.failure.invalid_token'
      redirect_to :new_user_session
    elsif @user.confirmed?
      flash[:notice] = "#{ @user.email } #{ I18n.t 'errors.messages.already_confirmed' }"
      redirect_to :new_user_session
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
