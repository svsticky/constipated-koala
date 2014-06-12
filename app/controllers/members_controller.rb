class MembersController < ApplicationController
  #skip_before_action :authenticate_admin!, only: [:new_public, :create]
  
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
  
  def new_public
  end
  
  def new
  end
  
  def create
		@member = Member.new(member_post_params)   
		
		if @member.save
			redirect_to @member
		else
			render 'new'
		end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])

    if @member.update(member_post_params)
      redirect_to @member
    else
      render 'edit'
    end
  end

  private
  def member_post_params
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
