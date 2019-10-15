#:nodoc:
class Admin::MembersController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :create, :update ]

  def index
    @limit = params[:limit] ? params[:limit].to_i : 50

    if params[:search]
      @members = Member.search(params[:search].clone)
                       .paginate(page: param[:page], per_page: params[:limit] ||= 50)

      @search = params[:search]

      redirect_to @members.first if @members.size == 1 && params[:page] ||= 1

    else
      @members =
        Member
        .includes(:educations)
        .where(:id => (
          Education.select(:member_id)
                   .where('status = 0')
                   .map(&:member_id) +
        Tag.select(:member_id)
           .where(:name => Tag.active_by_tag)
           .map(&:member_id)
        ))
        .select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id)
        .order(:last_name, :first_name)
        .paginate(page: params[:page], per_page: params[:limit] ||= 50)

    end
  end

  # As defined above this is an json call only
  def search
    @members = Member.select(:id, :first_name, :infix, :last_name, :student_id).search(params[:search])
  end

  def show
    @member = Member.find(params[:id])

    # Show all activities from the given year + unpaid past activities. And make a list of years starting from the member's join_date until the last activity
    current_year_activities = @member.activities.study_year(params['year']).order(start_date: :desc).joins(:participants).distinct.where("participants.reservist = ?", false)
    unpaid_old_activities = @member.unpaid_activities.order(start_date: :desc).where('start_date < ?', Date.to_date(Date.today.study_year))
    @activities = (current_year_activities + unpaid_old_activities).uniq

    @years = (@member.join_date.study_year..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

    # Pagination for checkout transactions
    @limit = params[:limit] ? params[:limit].to_i : 10

    @transactions = CheckoutTransaction
                    .where(:checkout_balance => CheckoutBalance
                    .find_by_member_id(params[:id]))
                    .order(created_at: :desc)
                    .paginate(page: params[:page], per_page: params[:limit] ||= 10)
  end

  def new
    @member = Member.new

    # Construct a education so that there is always one visible to fill in
    @member.educations.build(:id => '-1')
  end

  def create
    @member = Member.new(member_post_params)

    if @member.save

      @member.tags_names = params[:member][:tags_names]

      # impressionist is the logging system
      impressionist(@member, 'nieuwe lid')
      redirect_to @member
    else

      # If the member hasn't filled in a study, again show an empty field
      @member.educations.build(:id => '-1') if @member.educations.empty?

      render 'new'
    end
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(params[:id])
    @member.educations.build(:id => '-1') if @member.educations.empty?
  end

  def update
    @member = Member.find(params[:id])

    if @member.update(member_post_params)
      impressionist @member
      redirect_to @member
    else
      render 'edit'
    end
  end

  def force_email_change
    @member = Member.find(params[:member_id])

    Mailings::Devise.forced_confirm_email(@member, current_user).deliver_later
    @member.user.force_confirm_email!

    redirect_to @member
  end

  # Send appropriate email to user for account access, either password reset, user creation, or activation mail.
  def send_email
    @member = Member.find(params[:member_id])

    case params[:type]
    when 'create_user'
      user = User.create_on_member_enrollment! @member
      user.resend_confirmation! :activation_instructions
      flash[:success] = I18n.t 'admin.member_account_status.email_sent'

    when 'resend_confirmation'
      @member.user.resend_confirmation! :confirmation_instructions
      flash[:success] = I18n.t 'admin.member_account_status.email_sent'

    when 'password_reset'
      @member.user.send_reset_password_instructions
      flash[:success] = I18n.t 'admin.member_account_status.email_sent'

    when 'consent'
      Mailings::Status.consent([@member].pluck(:id, :first_name, :infix, :last_name, :email)).deliver_later
      flash[:success] = I18n.t 'admin.member_account_status.consent_sent'

    end

    redirect_to member_path @member
  end

  def destroy
    @member = Member.includes(:checkout_balance).find(params[:id])

    impressionist @member
    flash[:notice] = []

    if @member.destroy
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.info', :name => @member.name)
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.checkout_emptied', :balance => view_context.number_to_currency(@member.checkout_balance.balance, :unit => '€')) unless @member.checkout_balance.nil?

      redirect_to root_url
    else
      flash[:errors] = @member.errors.messages
      redirect_to @member
    end
  end

  def payment_whatsapp
    @member = Member.find(params[:member_id])
    @activities = @member.unpaid_activities.where('activities.start_date <= ?', Date.today).distinct
    @participants = @activities.map { |a| Participant.find_by(member: @member, activity: a) }
    render layout: false, content_type: "text/plain"
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
                                   :emergency_phone_number,
                                   :email,
                                   :student_id,
                                   :birth_date,
                                   :join_date,
                                   :comments,
                                   :tags_names => [],
                                   educations_attributes: [:id, :study_id, :status, :start_date, :end_date, :_destroy])
  end
end
