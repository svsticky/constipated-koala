class Members::HomeController < MembersController
  skip_before_action :authenticate_user!, only: [ :confirm_add_funds ]

  def index
    @member = Member.find(current_user.credentials_id)

    # information of the middlebar
    @balance = CheckoutBalance.find_by_member_id( current_user.credentials_id )
    @debt = Participant
      .where( paid: false, member: @member, reservist: false )
      .joins( :activity )
      .where('activities.start_date < NOW()')
      .sum( :price ) \
     + Participant # The plus makes it work for all activities where the member does NOT have a modified price.
      .where( paid: false, price: nil, member: @member, reservist: false )
      .joins( :activity )
      .where('activities.start_date < NOW()')
      .sum( 'activities.price ')

    # @participants =
    #   (
    #    @member.activities
    #      .study_year( params['year'] )
    #      .distinct
    #      .joins(:participants)
    #      .where(:participants => { :member => @member }) \
    #    +
    #     @member.activities
    #       .joins(:participants)
    #       .where("participants.paid = FALSE AND participants.price > 0")
    #    ).uniq
    #      .sort_by(&:start_date)
    #      .reverse!

    @participants =
       @member.activities
         .study_year( params['year'] )
         .distinct
         .joins(:participants)
         .where(:participants => { member: @member, reservist: false })
         .order('start_date DESC')

    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @applications = Doorkeeper::Application.authorized_for(current_user)

     if @member.educations.length < 1
       @member.educations.build( :id => '-1' )
     end
  end

  def revoke
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user
    redirect_to :users_edit
  end

  def update
    @member = Member.find(current_user.credentials_id)

    if @member.update(member_post_params)
      impressionist(@member, 'lid bewerkt')

      redirect_to users_home_path
      return
    end

    # @applications = Doorkeeper::Application.authorized_for(current_user)
    render 'edit'
    return
  end

  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_or_create_by!(member: member)

    if ideal_transaction_params[:amount].to_f <= Settings.mongoose_ideal_costs
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to users_home_url
      return
    end

    if balance.nil?
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to users_home_path
      return
    end

    ideal = IdealTransaction.new(
      :description => 'Mongoose-tegoed',
      :amount => (ideal_transaction_params[:amount].to_f + Settings.mongoose_ideal_costs),
      :issuer => ideal_transaction_params[:bank],
      :member => member,

      :transaction_id => NIL,
      :transaction_type => 'CheckoutTransaction',

      :redirect_uri => users_root_url)

    if ideal.save
      redirect_to ideal.mollie_uri
      return
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to users_home_path
      return
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
                                   :gender)
  end

  def ideal_transaction_params
    params.require( :ideal_transaction ).permit( :bank, :amount )
  end
end
