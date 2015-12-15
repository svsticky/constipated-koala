class Users::PublicController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :create, :confirm]
  skip_before_action :authenticate_admin!, only: [:index, :create, :confirm]
  before_action :set_locale

  def index
    @member = Member.new
    @member.educations.build( :id => '-1' )
    @member.educations.build( :id => '-2' )

    @membership = Activity.find( ENV['INTRO_MEMBERSHIP'].to_a )

    @activities = Activity.find( ENV['INTRO_ACTIVITIES'].to_a )
    @participate = @activities.map{ |activity| activity.id }
  end

  def create
    @member = Member.new( public_post_params.except :participant_attributes )
    @member.require_student_id = true

    activities = Activity.find( public_post_params[ :participant_attributes ].select{ |id, participant| participant['participate'].nil? || participant['participate'].to_b == true }.map{ |id, participant| participant['id'].to_i } )
    total = 0

    # if bank is empty report and test model for additional errors
    flash[:error] = NIL
    flash[:error] = I18n.t(:no_bank_provided, scope: 'activerecord.errors.subscribe') if params[:bank].blank? && params[:method] == 'IDEAL' && @member.educations.none? { |education| Study.find( education.study_id ).masters }
    @member.valid? unless flash[:error].nil?

    if flash[:error].nil? && @member.save
      impressionist @member
      flash[:notice] = I18n.t(:success_without_payment, scope: 'activerecord.errors.subscribe')

      # if a masters student no payment required, also no access to activities for bachelors
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
          :amount => total,
          :issuer => params[:bank],
          :type => 'INTRO',
          :member => @member,
          :transaction_id => activities.map{ |activity| activity.id },
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
      #@participants = public_post_params[ :participant_attributes ]

      #number the already filled in educations to bypass an 500 error
      @member.educations.each_with_index{ |education, index| education.id = ((index+1)*-1) }

      # create empty study field if not present
      if @member.educations.length < 1
        @member.educations.build( :id => '-1' )
      end

      if @member.educations.length < 2
        @member.educations.build( :id => '-2' )
      end

      @membership = Activity.find( ENV['INTRO_MEMBERSHIP'].to_a )

      @activities = Activity.find( ENV['INTRO_ACTIVITIES'].to_a )
      @participate = public_post_params[ :participant_attributes ].map{ |key, value| key.to_i if value['participate'] == '1' }.compact

      @method = params[:method]
      @bank = params[:bank]

      render 'index'
    end
  end

  def confirm
    @transaction = IdealTransaction.find_by_uuid(params[:uuid])

    if @transaction.status == 'SUCCESS' && @transaction.type == 'INTRO'

      @transaction.transaction_id.each do |activity|
        @participant = Participant.where("member_id = ? AND activity_id = ?", @transaction.member.id, activity)
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
