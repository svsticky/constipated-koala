#:nodoc:
class Admin::MembersController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :create, :update ]

  def index
    if params[:search].present?
      @pagination, @members = pagy_array(Member.search(params[:search].clone))
    else
      @pagination, @members = pagy(
        Member.includes(:educations).active
          .select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id)
          .order(:last_name, :first_name)
      )
    end
  end

  # As defined above this is an json call only
  def search
    @members = Member.select(:id, :first_name, :infix, :last_name,
                             :student_id).search(params[:search])
  end

  def show
    @member = Member.find(params[:id])

    # Show all activities from the given year + unpaid past activities.
    # And make a list of years starting from the member's join_date until the last activity
    current_year_activities = @member.activities.study_year(
      params['year']
    ).order(
      start_date: :desc
    ).joins(
      :participants
    ).distinct.where(
      participants: { reservist: false }
    )
    unpaid_old_activities = @member.unpaid_activities.order(start_date: :desc).where(
      'start_date < ?', Date.to_date(Date.today.study_year)
    )
    @activities = (current_year_activities + unpaid_old_activities).uniq

    @years = (@member.join_date.study_year..Date.today.study_year).map do |year|
      ["#{ year }-#{ year + 1 }", year]
    end.reverse
  end

  def new
    @member = Member.new

    # Construct a education so that there is always one visible to fill in
    @member.educations.build(id: '-1')
  end

  def create
    @member = Member.new(member_post_params.except('mailchimp_interests'))

    if @member.save
      unless ENV['MAILCHIMP_DATACENTER'].blank? || member_post_params[:mailchimp_interests].nil?
        MailchimpJob.perform_later(@member.email, @member,
                                   member_post_params[:mailchimp_interests].compact_blank)
      end

      @member.tags_names = params[:member][:tags_names]

      # impressionist is the logging system
      impressionist(@member, 'nieuwe lid')
      redirect_to(@member)
    else

      # If the member hasn't filled in a study, again show an empty field
      @member.educations.build(id: '-1') if @member.educations.empty?

      render('new')
    end
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(params[:id])
    @member.educations.build(id: '-1') if @member.educations.empty?
    WebhookJob.perform_later("member", params[:id])
  end

  def update
    @member = Member.find(params[:id])

    if @member.update(member_post_params.except('mailchimp_interests'))

      unless ENV['MAILCHIMP_DATACENTER'].blank? || member_post_params[:mailchimp_interests].nil?
        MailchimpJob.perform_later(@member.email, @member,
                                   member_post_params[:mailchimp_interests].compact_blank)
      end

      impressionist(@member)
      redirect_to(@member)
    else
      render('edit')
    end
  end

  def force_email_change
    @member = Member.find(params[:member_id])

    MailchimpUpdateAddressJob.perform_later(@member.email, @member.user.unconfirmed_email) unless
      @member.mailchimp_interests.nil? || ENV['MAILCHIMP_DATACENTER'].blank?

    Mailings::Devise.forced_confirm_email(@member, current_user).deliver_later
    @member.user.force_confirm_email!

    redirect_to(@member)
  end

  # Send appropriate email to user for account access, either password reset, user creation, or activation mail.
  def send_email
    @member = Member.find(params[:member_id])

    case params[:type]
    when 'create_user'
      user = User.create_on_member_enrollment!(@member)
      user.resend_confirmation!(:activation_instructions)
      flash[:success] = I18n.t('admin.member_account_status.email_sent')

    when 'resend_confirmation'
      @member.user.resend_confirmation!(:confirmation_instructions)
      flash[:success] = I18n.t('admin.member_account_status.email_sent')

    when 'password_reset'
      @member.user.send_reset_password_instructions
      flash[:success] = I18n.t('admin.member_account_status.email_sent')

    when 'consent'
      Mailings::Status.consent([@member].pluck(:id, :first_name, :infix, :last_name,
                                               :email)).deliver_later
      flash[:success] = I18n.t('admin.member_account_status.consent_sent')

    end

    redirect_to(member_path(@member))
  end

  def destroy
    @member = Member.find(params[:id])

    impressionist(@member)
    flash[:notice] = []

    if @member.destroy
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.info', name: @member.name)
      unless @member.mailchimp_interests.nil?
        flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.mailchimp_queued')
      end

      redirect_to(root_url)
    else
      flash[:errors] = @member.errors.messages
      redirect_to(@member)
    end
  end

  def payment_whatsapp
    @member = Member.find(params[:member_id])
    @activities = @member.unpaid_activities.where('activities.start_date <= ?', Date.today).distinct
    @participants = @activities.map { |a| Participant.find_by(member: @member, activity: a) }
    render(layout: false, content_type: "text/plain")
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
                                   tags_names: [],
                                   mailchimp_interests: [],
                                   educations_attributes: [:id, :study_id, :status, :start_date,
                                                           :end_date, :_destroy])
  end
end
