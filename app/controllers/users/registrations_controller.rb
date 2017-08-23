class Users::RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :new_member_confirmation, :new_member_confirm]
  skip_before_action :authenticate_admin!, only: [:new, :create, :new_member_confirmation, :new_member_confirm]

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
    @user = User.find_by(confirmation_token: params[:confirmation_token])
    if not @user or @user.confirmed?
      redirect_to :new_user_session
      return
    end

    render 'devise/confirmations/with_password'
  end

  def new_member_confirm
    @user = User.find_by(confirmation_token: params[:user][:confirmation_token])
    byebug
    if not @user or @user.confirmed?
      redirect_to :new_user_session
      return
    end

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.save
      @user.confirm
      flash[:notice] = 'Geactiveerd, je kan je aanmelden enzo'
      redirect_to :new_user_session
    else
      render 'devise/confirmations/with_password'
    end
  end

  private
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
