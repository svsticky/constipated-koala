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
end
