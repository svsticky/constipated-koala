#:nodoc:
class Api::WebhookController < ApiController
  def mollie_redirect
    transaction = IdealTransaction.find_by_token!(params[:token])
    transaction.finalize! if transaction.update!

    flash[:notice] = transaction.message
    logger.debug transaction.message.inspect

    flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction') if transaction.message.blank?

    redirect_to transaction.redirect_uri
  end

  def mollie_hook
    transaction = IdealTransaction.find_by_trxid!(params[:id])
    transaction.finalize! if transaction.update!

    head :ok
  end

  # update cache with new information
  def mailchimp
    head(:unauthorized) && return unless params[:secret] == ENV['MAILCHIMP_SECRET']
    head(:precondition_failed) && return unless params[:data][:list_id] == ENV['MAILCHIMP_LIST_ID']
    head(:method_not_allowed) && return unless ['subscribe', 'unsubscribe', 'profile', 'cleaned'].include? params[:type]

    member = Member.find_by_email! params[:data][:email]

    case params[:type]
    when 'subscribe', 'profile'
      Rails.cache.write(
        "members/#{ member.id }/mailchimp/interests",
        Settings['mailchimp.interests'].map { |k, v| { v => params[:data][:merges][:INTERESTS].split(',').include?(k) } }.reduce(&:merge),
        expires_in: 30.days
      )

    when 'unsubscribe', 'cleaned'
      Rails.cache.write("members/#{ member.id }/mailchimp/interests", [], expires_in: 30.days)

    end

    head :no_content
  end
end
