#:nodoc:
class Public::HomeController < PublicController
  layout false

  def index
    @member = Member.new
    @member.educations.build(id: '-1')
    @member.educations.build(id: '-2')

    @membership = Activity.find(Settings['intro.membership'])
    @activities = Activity.find(Settings['intro.activities'])

    @participate = @activities.map(&:id)
  end

  def redirect_to_locale
    # Check if the URL already contains a locale
    return if request.path.match?(/^\/\?l=(nl|en)(\/|$)/)

    # Get the language from the Accept-Language header
    locale = request.env['HTTP_ACCEPT_LANGUAGE'].to_s.start_with?('nl') ? 'nl' : 'en'

    # Redirect to /?l=nl/... or /?l=en/...
    redirect_to("/?l=#{ locale }#{ request.path }", allow_other_host: false)
  end

  def create
    @member = Member.new(public_post_params.except(:participant_attributes))
    @member.require_student_id = true

    activities = Activity.find(public_post_params[:participant_attributes].to_h.select { |_, participant| participant['participate'].nil? || participant['participate'].to_b == true }.map { |_, participant| participant['id'].to_i })
    total = 0

    @member.valid? unless flash[:error].nil?

    if flash[:error].nil? && @member.save
      # create account and send welcome email
      user = User.create_on_member_enrollment!(@member)
      if request.path.start_with?('/?l=nl')
        user.language = 0
      elsif request.path.start_with?('/?l=en')
        user.language = 1
      end
      user.save
      user.resend_confirmation!(:activation_instructions)

      impressionist(@member)
      flash[:notice] = I18n.t(:success_without_payment, scope: 'activerecord.errors.subscribe')

      # add user to mailchimp
      interests = mailchimp_interests(params[:member])

      MailchimpJob.perform_later(@member.email, @member, interests) if
        ENV['MAILCHIMP_DATACENTER'].present?

      # if a masters student no payment required, also no access to activities for bachelors
      if !@member.educations.empty? && @member.educations.any? { |education| Study.find(education.study_id).masters }
        flash[:notice] = I18n.t(:success_without_payment, scope: 'activerecord.errors.subscribe')
        redirect_to(public_path)
        return
      end

      activities.each do |activity|
        participant = Participant.create(member: @member, activity: activity)
        total += participant.currency
      end

      transaction = Payment.new(
        description: I18n.t("form.introduction", user: @member.name),
        amount: total - Settings.mongoose_ideal_costs, # Transaction costs are paid by the association
        member: @member,
        transaction_id: activities.map(&:id),
        transaction_type: :activity,
        payment_type: :ideal,
        redirect_uri: public_url
      )

      if transaction.save
        redirect_to(transaction.payment_uri)
        return
      else
        flash[:notice] = I18n.t(:failed, scope: 'activerecord.errors.subscribe')
      end

      redirect_to(public_path)
      return
    else
      # @participants = public_post_params[ :participant_attributes ]

      # number the already filled in educations to bypass an 500 error
      @member.educations.each_with_index { |education, index| education.id = ((index + 1) * -1) }

      # create empty study field if not present
      @member.educations.build(id: '-1') if @member.educations.empty?
      @member.educations.build(id: '-2') if @member.educations.length < 2

      @membership = Activity.find(Settings['intro.membership'])

      @activities = Activity.find(Settings['intro.activities'])
      @participate = public_post_params[:participant_attributes].to_h.map do |key, value|
        key.to_i if value['participate'] == '1'
      end.compact

      @bank = params[:bank]

      render('index')
    end
  end

  private

  def mailchimp_interests(member)
    # add user to mailchimp
    interests = [Rails.configuration.mailchimp_interests[:alv]]
    interests.push(Rails.configuration.mailchimp_interests[:mmm]) if member[:mmm_subscribe] == "1"
    interests.push(Rails.configuration.mailchimp_interests[:business]) if member[:business_subscribe] == "1"
    interests.push(Rails.configuration.mailchimp_interests[:lectures]) if member[:lectures_subscribe] == "1"
    interests.push(Rails.configuration.mailchimp_interests[:teacher]) if member[:teachers_subscribe] == "1"
    interests
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
                                   :emergency_phone_number,
                                   :email,
                                   :student_id,
                                   :birth_date,
                                   :join_date,
                                   participant_attributes: [:id, :participate],
                                   educations_attributes: [:id, :study_id, :_destroy])
  end
end
