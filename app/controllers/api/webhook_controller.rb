#:nodoc:
class Api::WebhookController < ApiController
  def payment_redirect
    transaction = Payment.find_by_token!(params[:token])
    transaction.finalize! if transaction.update_transaction!

    flash[:notice] = transaction.message if transaction.successful? || transaction.in_progress?

    logger.debug transaction.message.inspect

    flash[:warning] = transaction.message if transaction.failed?

    redirect_to transaction.redirect_uri
  end

  def mollie_hook
    transaction = Payment.find_by_trxid!(params[:id])
    transaction.finalize! if transaction.update_transaction!

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
