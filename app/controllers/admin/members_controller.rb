#:nodoc:
class Admin::MembersController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :create, :update ]
  respond_to :json, only: [:search]

  def index
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @page = @offset / @limit

    # If a search query is send, change the limit and offset accordingly. The param all is whether the query should also look into alumni
    if params[:search]
      @results = Member.search(params[:search].clone)

      @pages = (@results.size / @limit.to_f).ceil
      @members = @results[@offset, @limit]

      @members = Member.none if @members.nil?
      @search = params[:search]

      redirect_to @members.first if @members.size == 1 && @offset == 0 && @limit > 1

    else
      @members = Member.includes(:educations).where(:id => (Education.select(:member_id).where('status = 0').map(&:member_id) + Tag.select(:member_id).where(:name => Tag.active_by_tag).map(&:member_id))).select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id).order(:last_name, :first_name).limit(@limit).offset(@offset)
      @pages = (Member.count / @limit.to_f).ceil
    end
  end

  # As defined above this is an json call only
  def search
    @members = Member.select(:id, :first_name, :infix, :last_name, :student_id).search(params[:search])
    respond_with @members
  end

  def show
    @member = Member.find(params[:id])

    # Show all activities from the given year + unpaid past activities. And make a list of years starting from the member's join_date until the last activity
    @activities = (@member.activities.study_year(params['year']).order(start_date: :desc).joins(:participants).distinct.where("participants.reservist = ?", false) +
                  @member.unpaid_activities.order(start_date: :desc).where('start_date < ?', Date.to_date(Date.today.study_year))).uniq

    @years = (@member.join_date.study_year..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

    # I think this should be in a view TODO
    @account_button_text =
      if @member.user&.confirmed?
        then I18n.t 'admin.member_account_status.send_password_reset'
      elsif @member.user && !@member.user.confirmed?
        then I18n.t 'admin.member_account_status.resend_confirmation'
      else
        I18n.t 'admin.member_account_status.send_create_email'
      end

    # Pagination for checkout transactions, limit is the number of results per page and offset is the number of the first record
    @limit = params[:limit] ? params[:limit].to_i : 10
    @offset = params[:offset] ? params[:offset].to_i : 0
    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(params[:id])).order(created_at: :desc).limit(@limit).offset(@offset)
  end

  # Send appropriate email to user for account access, either password reset, user creation, or activation mail.
  def send_user_email
    @member = Member.find(params[:member_id])

    if !@member.user
      # Send create
      user = User.create_on_member_enrollment! @member
      user.resend_confirmation! :activation_instructions
    elsif !@member.user.confirmed?
      # Send activate
      @member.user.resend_confirmation! :confirmation_instructions
    else
      # Send password reset
      @member.user.send_reset_password_instructions
    end

    flash[:success] = I18n.t 'admin.member_account_status.email_sent'
    redirect_to member_path @member
  end

  def new
    @member = Member.new

    # Construct a education so that there is always one visible to fill in
    @member.educations.build(:id => '-1')
  end

  def create
    @member = Member.new member_post_params.except 'mailchimp_interests'

    if @member.save
      MailchimpJob.perform_later @member.email, @member, params[:member][:mailchimp_interests].reject(&:blank?)

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
    email = @member.email

    if @member.update member_post_params.except 'mailchimp_interests'
      MailchimpJob.perform_later email, @member, params[:member][:mailchimp_interests].reject(&:blank?)

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

  def destroy
    @member = Member.includes(:checkout_balance).find(params[:id])

    impressionist @member
    flash[:notice] = []

    if @member.destroy
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.info', :name => @member.name)
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.checkout_emptied', :balance => view_context.number_to_currency(@member.checkout_balance.balance, :unit => '€')) unless @member.checkout_balance.nil?
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.mailchimp_queued') unless @member.mailchimp_interests.nil?

      redirect_to root_url
    else
      flash[:errors] = @member.errors.messages
      redirect_to @member
    end
  end

  def payment_whatsapp
    @member = Member.find(params[:member_id])
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
                                   :mailchimp_interests => [],
                                   educations_attributes: [:id, :study_id, :status, :start_date, :end_date, :_destroy])
  end
end
