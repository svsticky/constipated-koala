#:nodoc:
class Public::StatusController < PublicController
  protect_from_forgery with: :exception, except: [:destroy]

  def edit
    # adding intent so that you're not on the wrong page.
    @token = Token.find_by!(token: params[:token], intent: :consent)
    @member = @token.object
    @member.educations.build(id: -1)
  end

  def update
    @token = Token.find_by!(token: params[:token], intent: :consent)
    @member = @token.object

    flash[:notice] = []
    if @member.update(member_post_params.except('mailchimp_interests'))
      impressionist(@member)
      # Update mailchimp interests since member became alumni / is alumni.
      unless ENV['MAILCHIMP_DATACENTER'].blank? && !@member.active?
        MailchimpJob.perform_later(@member.email, @member,
                                   if member_post_params[:mailchimp_interests].nil?
                                     []
                                   else
                                     member_post_params[:mailchimp_interests].compact_blank
                                   end)
      end
      if @member.educations.none?(&:active?) && %w[yearly indefinite].exclude?(@member.consent)
        @member.errors.add(:base, I18n.t('activerecord.errors.no_consent'))
        flash[:errors] = @member.errors.messages

        @member.educations.build(id: -1)
        render('edit')
        return
      end

      @token.destroy
      flash[:notice] << 'success!'

      redirect_to(users_root_url)
      return
    end

    flash[:errors] = @member.errors.messages
    @member.educations.build(id: -1)
    render('edit')
  end

  def destroy
    @token = Token.find_by!(token: params[:token], intent: :consent)
    @member = Member.find(@token.object.id)

    impressionist(@member)
    flash[:notice] = []

    # update studies one last time if possible
    @member.update(member_post_params.except('mailchimp_interests'))

    if @member.destroy
      @token.destroy
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.info', name: @member.name)

      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.mailchimp_queued')
      redirect_to(users_root_url)
    else
      flash[:errors] = @member.errors.messages

      @member.educations.build(id: -1)
      redirect_to(status_path(token: params[:token]))
    end
  end

  private

  def member_post_params
    params[:member][:consent] = 'yearly' if params[:yearly] == '1'
    params[:member][:consent] = 'indefinite' if params[:indefinite] == '1'
    params[:member][:mailchimp_interests] = params[:mailchimp_interests].keys if params[:mailchimp_interests]

    params.require(:member).permit(:consent, educations_attributes: [:id, :study_id, :status],
                                             mailchimp_interests: [])
  end
end
