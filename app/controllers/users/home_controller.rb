class Users::HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :confirm_add_funds ]
  skip_before_action :authenticate_admin!, only: [ :index, :edit, :update, :add_funds, :confirm_add_funds ]
  before_action :set_locale

  def index
    @member = Member.find(current_user.credentials_id)

    @balance = CheckoutBalance.find_by_member_id( @member.id )
    @default = Participant.where( :paid => false, :member => @member ).joins( :activity ).where('activities.start_date < NOW()').sum( :price ) + Participant.where( :paid => false, :price => nil, :member => @member ).joins( :activity ).where('activities.start_date < NOW()').sum( 'activities.price ')

    @participants = (@member.activities.study_year( params['year'] ).distinct.joins(:participants).where(:participants => { :member => @member }) \
      + @member.activities.joins(:participants).where("participants.paid = FALSE AND participants.price > 0") ).uniq.sort_by(&:start_date).reverse!

    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)

    #@activities = Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today ).order(:start_date).limit(4)
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)

     if @member.educations.length < 1
       @member.educations.build( :id => '-1' )
     end
  end

  def update
    @member = Member.find(current_user.credentials_id)

    if @member.update(member_post_params)
      impressionist(@member, 'lid bewerkt')

      redirect_to users_home_path
      return
    end

    render 'edit'
    return
  end

  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_by_member_id!(member.id)

    if ideal_transaction_params[:amount].to_f <= 0.5
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
      :description => "Mongoose #{member.name}",
      :amount => (ideal_transaction_params[:amount].to_f + ENV['MONGOOSE_IDEAL_COSTS'].to_f),
      :issuer => ideal_transaction_params[:bank],
      :type => 'MONGOOSE',
      :member => member,
      :transaction_id => NIL,
      :transaction_type => 'CheckoutTransaction' )

    if ideal.save
      redirect_to ideal.url
      return
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to users_home_path
      return
    end
  end

  def confirm_add_funds
    ideal = IdealTransaction.find_by_uuid(params[:uuid])

    if ideal.status == 'SUCCESS' && ideal.type == 'MONGOOSE'

      if ideal.transaction_id.empty?
        transaction = CheckoutTransaction.new( :price => (ideal.amount - ENV['MONGOOSE_IDEAL_COSTS'].to_f), :checkout_balance => CheckoutBalance.find_by_member_id!(ideal.member) )
        transaction.save

        IdealTransaction.where(:uuid => params[:uuid]).update_all( :transaction_id => [ transaction.id ] )
      else
        flash[:notice] = I18n.t('processed', scope: 'activerecord.errors.models.ideal_transaction')
      end

      flash[:notice] = I18n.t('success', scope: 'activerecord.errors.models.ideal_transaction')
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
    end

    redirect_to users_home_url
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
                                   :birth_date)
  end

  def ideal_transaction_params
    params.require( :ideal_transaction ).permit( :bank, :amount )
  end

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end
