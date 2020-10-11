#:nodoc:
class Api::WebhookController < ApiController
  def mollie_redirect
    transaction = Payment.find_by_token!(params[:token])
    transaction.finalize! if transaction.update!

    flash[:notice] = transaction.message
    logger.debug transaction.message.inspect

    flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction') if transaction.message.blank?

    redirect_to transaction.ideal_redirect_uri
  end

  def mollie_hook
    transaction = Payment.find_by_trxid!(params[:id])
    transaction.finalize! if transaction.update!

    head :ok
  end

  def payconiq_hook
    transaction = Payment.find_by_trxid!(params[:paymentId])
    transaction.finalize! if transaction.update!

    head :ok
  end

  # send ok status to convince mailchimp everything works
  def mailchimp_confirm_callback
    head(:unauthorized) && return unless params[:token] == ENV['MAILCHIMP_SECRET']

    head :ok
  end

  # invalidate cache on mailchimp change
  def mailchimp
    head(:unauthorized) && return unless params[:token] == ENV['MAILCHIMP_SECRET']
    head(:precondition_failed) && return unless params[:data][:list_id] == ENV['MAILCHIMP_LIST_ID']
    head(:method_not_allowed) && return unless ['subscribe', 'unsubscribe', 'profile', 'cleaned'].include? params[:type]

    member = Member.find_by_email! params[:data][:email]

    Rails.cache.delete("members/#{ member.id }/mailchimp/interests")

    head :no_content
  end
end
