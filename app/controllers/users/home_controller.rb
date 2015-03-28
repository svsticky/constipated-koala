class Users::HomeController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index, :edit, :update ]
  before_action :set_locale
  

  def index
    @member = Member.find(current_user.credentials_id)
    @activities = (@member.activities.joins(:participants).where(:participants => { :paid => false, :member => @member } ).distinct + @member.activities.order(start_date: :desc).limit(10)).uniq.sort_by(&:start_date).reverse
    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)
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
    
      redirect_to users_root_path
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
                                   :birth_date)
  end
  
  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end