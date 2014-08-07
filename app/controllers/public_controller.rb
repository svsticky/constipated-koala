class PublicController < ApplicationController
  skip_before_action :authenticate_admin!, only: [:index, :create]
  layout nil
  
  @@intro = {
    'lidmaatschap' => 1,
    'lasergamen' => 2,
    'bbq' => 3,
  }
  
  def index
    @member = Member.new
    @member.educations.build( :id => '-1' )
  end

  def create
    @member = Member.new(public_post_params)
    
    if @member.save
      flash[:notice] = 'Je hebt je ingeschreven!'
      
      @lidmaatschap = Participant.new( :member => @member, :activity => Activity.find(@@intro['lidmaatschap']))
      if !@lidmaatschap.save
        
      end
      
      if params[:activities].include? 'bbq'
        @bbq = Participant.new( :member => @member, :activity => Activity.find(@@intro['bbq']))
        if !@bbq.save
        
        end
      end
            
      if params[:activities].include? 'lasergamen'
        @lasergamen = Participant.new( :member => @member, :activity => Activity.find(@@intro['lasergamen']))
        if !@lasergamen.save
        
        end
      end
      
      #betaingen aanmaken indien iDeal
      if params[:method] == 'IDEAL'
        logger.debug(params[:bank])
      end
      
      redirect_to public_path
    else
      if @member.educations.length < 1
        @member.educations.build( :id => '-1' )
      end
    
      render 'index'
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
