class PublicController < ApplicationController
  skip_before_action :authenticate_admin!, only: [:index, :create]
  layout nil
  
  def index
    @member = Member.new
    @member.educations.build( :id => '-1' )
  end

  def create
    @member = Member.new(public_post_params)
    logger.debug(params[:activities])
    
    if @member.save
      flash[:notice] = 'Je hebt je ingeschreven!'   
      redirect_to public_path
    else
      if @member.educations.length < 1
        @member.educations.build( :id => '-1' )
      end
    
      render 'index', :anchor => 'form'
    end
  end
  
  # Create a iDeal payment and redirect to the bank
  def payment
    #check if hash is correct
  
  end
  
  # Confirm the payment has been done, the redirect url 
  def confirm
    
  end
  
  private
  def public_post_params
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
                                   educations_attributes: [ :id, :name_id, :start_date, :end_date, :_destroy ])
  end
end
