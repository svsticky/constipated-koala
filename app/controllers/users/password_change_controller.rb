# Controller used to change a user's password
class Users::PasswordChangeController < ApplicationController
  skip_before_action :authenticate_admin!

  layout 'members'

  def edit
    @user = current_user

    render 'user/password/edit'
  end

  def update
    @user = current_user
    # Require current_password when changing the password and check if a
    # new password was entered manually because Devise doesn't think it's
    # necessary

    if @user.update_with_password(user_params) && !params[:user][:password].empty?
      bypass_sign_in @user, scope: :user
      redirect_to root_path
    else
      render 'user/password/edit'
    end
  end

  def user_params
    params.require(:user).permit(:current_password,
                                 :password,
                                 :password_confirmation)
  end
end
