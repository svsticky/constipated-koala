class MembersController < ApplicationController
  before_action :authenticate_admin!
  def index
    if params[:search]
      @members = Member.search(params[:search])
    else
      @members = Member.all
    end
  end

  def show
    @member = Member.find(params[:id])
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])

    if @member.update(admin_post_params)
      redirect_to @member
    else
      render 'edit'
    end
  end

  private
  def admin_post_params
    params[:member].permit(:first_name,
                                   :infix,
                                   :last_name,
                                   :address,
                                   :house_number,
                                   :postal_code,
                                   :city,
                                   :phone_number,
                                   :email,
                                   :gender,
                                   :student_id,
                                   :birth_date,
                                   :join_date,
                                   :comments)
  end
end
