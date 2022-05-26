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
    if @member.update(member_post_params)
      impressionist(@member)

      # Update mailchimp interests since member became inactive / is inactive.
      unless ENV['MAILCHIMP_DATACENTER'].blank? && !@member.is_active?
        MailchimpJob.perform_later(@member.email, @member, member_post_params[:mailchimp_interests].nil? ? [] : member_post_params[:mailchimp_interests].compact_blank)
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
    @member = Member.includes(:checkout_balance).find(@token.object.id)

    impressionist(@member)
    flash[:notice] = []

    # update studies one last time if possible
    @member.update(member_post_params.except('mailchimp_interests'))

    if @member.destroy
      @token.destroy
      puts '=========================='
      puts member_post_params[:mailchimp_interests]
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.info', name: @member.name)
      unless @member.checkout_balance.nil?
        flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.checkout_emptied',
                                 balance: view_context.number_to_currency(@member.checkout_balance.balance,
                                                                          unit: '€'))
      end

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

    params.require(:member).permit(:consent, educations_attributes: [:id, :study_id, :status], :mailchimp_interests => [])
  end
end
