#:nodoc:
class Payment < ApplicationRecord
  self.primary_key = :token

  attr_accessor :issuer, :payment_uri, :message

  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :status, presence: true
  validates :payment_type, presence: true

  enum status: { failed: 0, in_progress: 1, successful: 2 }

  # Keep payconiq_online because it is still present in the database
  enum payment_type: { ideal: 0, payconiq_online: 1, pin: 3 }
  enum transaction_type: { checkout: 0, activity: 1 }
  belongs_to :member

  validates :transaction_type, presence: true

  serialize :transaction_id, Array

  validates :redirect_uri, presence: true, if: :ideal?

  after_validation :request_payment, on: :create

  include PgSearch::Model

  pg_search_scope :search_by_name,
                  against: [:trxid],
                  associated_against: {
                    member: [:first_name, :infix, :last_name]
                  },
                  using: {
                    trigram: {
                      only: [:first_name, :last_name, :trxid],
                      threshold: 0.1
                    }
                  }

  def request_payment
    self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }")
    self.amount += transaction_fee

    # To make seeding possible, possible cleaner way to do this but couldn't find it easily
    return unless message != 'seeding'

    case payment_type.to_sym
    when :ideal
      self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }#{ redirect_uri }")

      webhook_url = if Rails.env.development?
                      "#{ ENV['NGROK_HOST'] }/api/hook/mollie"
                    else
                      Rails.application.routes.url_helpers.mollie_hook_url
                    end

      payment = Mollie::Payment.create(
        amount: { value: amount.to_s, currency: 'EUR' },
        description: description,
        webhookUrl: webhook_url,
        redirectUrl: Rails.application.routes.url_helpers.payment_redirect_url(token: token)
      )

      self.trxid = payment.id
      self.payment_uri = payment._links['checkout']['href']
      self.status = :in_progress

      # pin payment shouldn't have any extra work
    when :pin
    end
  end

  def update_transaction!
    case payment_type.to_sym
    when :ideal
      @status = status

      payment = Mollie::Payment.get(trxid)

      status_update(payment.status)

      save!

      # first time paid as a response
      if successful? && @status != :successful
        I18n.t('success', scope: 'activerecord.errors.models.payment')
        return true
      end

      self.message = I18n.t('processed', scope: 'activerecord.errors.models.payment') if successful?
      self.message = I18n.t('failed', scope: 'activerecord.errors.models.payment') if failed?

      return false
    when :pin
    end
  end

  # mark transaction_types as paid
  def finalize!
    case transaction_type.to_sym
    when :activity

      transaction_id.each do |activity_id|
        participant = Participant.where("member_id = ? AND activity_id = ?", member.id, activity_id)
        participant.first.paid = true
        participant.first.save
      end

      self.message = I18n.t('success', scope: 'activerecord.errors.models.payment')

    when :checkout
      # additional check if not already added checkout funds
      return unless transaction_id.empty?

      # create a single transaction to update the checkoutbalance and mark the Payment as processed
      Payment.transaction do
        transaction = CheckoutTransaction.create!(
          price: (amount - transaction_fee),
          checkout_balance: CheckoutBalance.find_by!(member_id: member),
          payment_method: payment_type
        )

        self.transaction_id = [transaction.id]
        save!

        self.message = I18n.t('success', scope: 'activerecord.errors.models.payment')
      end
    end
  end

  def transaction_fee
    case payment_type.to_sym
    when :ideal
      Settings.mongoose_ideal_costs
    when :payconiq_online
      0
    when :pin
      0
    end
  end

  def self.ideal_issuers
    # cache the payment issuers for 12 hours, don't request it to often. Stored in tmp/cache
    return [] if ENV['MOLLIE_TOKEN'].blank?

    Rails.cache.fetch('mollie_issuers', expires_in: 12.hours) do
      method = Mollie::Method.get('ideal', include: 'issuers')

      method.issuers.map { |issuer| [issuer["name"], issuer["id"]] }
    end
  end

  def activities
    Activity.find(transaction_id) if activity?
  end

  private

  def status_update(new_status)
    self.status = case new_status.downcase
                  when "succeeded", "paid"
                    :successful
                  when "expired", "canceled", "failed", "cancelled", "authorization_failed"
                    :failed
                  else
                    :in_progress
                  end
  end
end
