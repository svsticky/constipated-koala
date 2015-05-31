class Users::PublicController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :create, :confirm]
  skip_before_action :authenticate_admin!, only: [:index, :create, :confirm]
  before_action :set_locale

  @@intro = {
    'lidmaatschap' => 10,
    'lasergamen' => 12,
    'bbq' => 6
  }

  def index
    @member = Member.new
    @member.educations.build( :id => '-1' )
    @member.educations.build( :id => '-2' )
    
    @membership = Activity.find( settings.intro_membership )
    @activities = Activity.find( settings.intro_activities )
  end

  def create
    @member = Member.new( public_post_params.except :participant_attributes )
    activities = Activity.find( public_post_params[ :participant_attributes ].select{ |id, participant| participant['participate'].nil? || participant['participate'].to_b == true }.map{ |id, participant| participant['id'].to_i } )
    total = 0

    if @member.save
      impressionist(@member, 'nieuwe lid')
      flash[:notice] = I18n.t(:success, scope: 'activerecord.errors.subscribe')

      if !@member.educations.empty? && @member.educations.any? { |education| Study.find( education.study_id ).masters }
        flash[:notice] = I18n.t(:success_without_payment, scope: 'activerecord.errors.subscribe')
        redirect_to public_path
        return
      end
      
      activities.each do |activity|
        participant = Participant.create( :member => @member, :activity => activity)
        total += participant.currency
      end

      if params[:method] == 'IDEAL'
        @transaction = IdealTransaction.new( 
          :description => "Introductie #{@member.name}",
          :amount => @total,
          :issuer => params[:bank],
          :type => 'INTRO',
          :member => @member, 
          :transaction_id => @activities.to_a, 
          :transaction_type => 'Activity' )

        if @transaction.save
          redirect_to @transaction.url
          return
        else
          flash[:notice] = I18n.t(:failed, scope: 'activerecord.errors.subscribe')
        end
      end

      redirect_to public_path
      return
    else
      if @member.educations.length < 1
        @member.educations.build( :id => '-1' )
      end

      if @member.educations.length < 2
        @member.educations.build( :id => '-2' )
      end
 
      @membership = Activity.find( settings.intro_membership )
      @activities = Activity.find( settings.intro_activities )

      render 'index'
    end
  end

  def confirm
    @transaction = IdealTransaction.find_by_uuid(params[:uuid])

    if @transaction.status == 'SUCCESS'

      @transaction.transaction_id.each do |activity|
        @participant = Participant.where("member_id = ? AND activity_id = ?", @transaction.member.id, activity)

        if @participant.size != 1
          flash[:notice] = I18n.t(:default, scope: 'activerecord.errors')
      	  redirect_to public_path
      	end

      	@participant.first.paid = true
      	@participant.first.save
      end

      flash[:notice] = I18n.t(:success, scope: 'activerecord.errors.subscribe')
    else
      flash[:notice] = I18n.t(:failed, scope: 'activerecord.errors.subscribe')
    end

    redirect_to public_path
  end

  private

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end


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

                                   :method,
                                   :bank,

                                   participant_attributes: [ :id, :participate ],
                                   educations_attributes: [ :id, :study_id, :_destroy ])
  end
end
