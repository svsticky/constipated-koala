class MembersController < ApplicationController
  #skip_before_action :authenticate_admin!, only: [:public_new, :create]
  
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
  
  def new
  	@member = Member.new
    @member.educations.build
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
    
         
     if @member.educations.length < 1
       @member.educations.build( :id => '0' )
     end
    
     if @member.educations.length < 2
       @member.educations.build( :id => '-1' )
     end
     
  end

  def update
    @member = Member.includes(:educations).find(params[:id])

    if @member.update(member_post_params)
      redirect_to @member
    else
      render 'edit'
    end
  end

  private
  def member_post_params
    params.require(:member).permit(:first_name,
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
                                   :comments,
                                   educations_attributes: [ :id, :name_id, :start_date, :end_date, :_destroy ])
                                   
#                                    :educations_attributes => { :id => NIL, :name_id => '', :start_date => Date.new, :end_date => '', :_destroy => false })
  end
end
