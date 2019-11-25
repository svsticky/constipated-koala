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
    if @user.update_with_password(user_params) # current_password required to change password
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
