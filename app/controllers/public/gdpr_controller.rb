#:nodoc:
class Public::GdprController < PublicController
  def edit
    # adding intent so that you're not on the wrong page.
    @token = Token.find_by!(token: params[:token], intent: :consent)
    @member = @token.object
  end

  def update
    @token = Token.find_by!(token: params[:token], intent: :consent)
    @member = @token.object

    flash[:notice] = []

    if consent_post_params.empty?
      flash[:error] = 'consent is blank'
      render 'edit'

    elsif @member.update(consent: consent_post_params.select { |_, v| v == '1' }.keys.first)
      @token.destroy

      flash[:notice] << 'success!'

      impressionist @member
      redirect_to public_path
    else
      flash[:error] = 'failed'

      render 'edit'
    end
  end

  def destroy
    @token = Token.find_by!(token: params[:token], intent: :consent)
    @member = Member.includes(:checkout_balance).find(@token.object.id)

    impressionist @member
    flash[:notice] = []

    if @member.destroy
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.info', :name => @member.name)
      flash[:notice] << I18n.t('activerecord.errors.models.member.destroy.checkout_emptied', :balance => view_context.number_to_currency(@member.checkout_balance.balance, :unit => '€')) unless @member.checkout_balance.nil?

      redirect_to public_path
    else
      puts @member.errors.messages
      flash[:errors] = @member.errors.messages
      render 'edit'
    end
  end

  private

  def consent_post_params
    params.permit(:authenticity_token, :token, :utf8, :yearly, :indefinite).slice(:yearly, :indefinite)
  end
end
