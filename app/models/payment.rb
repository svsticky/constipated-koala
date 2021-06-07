#:nodoc:
class Payment < ApplicationRecord
  require 'request'

  self.primary_key = :token

  attr_accessor :issuer, :payment_uri, :message, :payconiq_qrurl, :payconiq_deeplink

  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :status, presence: true
  validates :payment_type, presence: true

  enum :status => [:failed, :in_progress, :successful]
  enum :payment_type => [:ideal, :payconiq_online, :payconiq_display, :pin]
  enum :transaction_type => [:checkout, :activity]
  belongs_to :member

  validates :transaction_type, presence: true

  serialize :transaction_id, Array

  validates :redirect_uri, presence: true, if: :ideal? || :payconiq_online

  after_validation :request_payment, on: :create

  def request_payment
    self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }")
    self.amount += transaction_fee

    # To make seeding possible, possible cleaner way to do this but couldn't find it easily
    return unless message != 'seeding'

    case payment_type.to_sym
    when :ideal
      http = ConstipatedKoala::Request.new ENV['MOLLIE_DOMAIN']
      self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }#{ redirect_uri }")

      request = http.post("/#{ ENV['MOLLIE_VERSION'] }/payments",
                          :amount => amount,
                          :description => description,

                          :method => 'ideal',
                          :issuer => issuer,

                          :metadata => {
                            :member => member.name,
                            :transaction_type => transaction_type,
                            :transaction_id => transaction_id

                          },
                          :webhookUrl => Rails.env.development? ? "#{ ENV['NGROK_HOST'] }/api/hook/mollie" : Rails.application.url_helpers.mollie_hook_url,
                          :redirectUrl => Rails.application.routes.url_helpers.payment_redirect_url(:token => token))

      request['Authorization'] = "Bearer #{ ENV['MOLLIE_TOKEN'] }"
      response = http.send! request

      self.trxid = response.id
      self.payment_uri = response.links.paymentUrl
      self.status = :in_progress
    # pin payment shouldn't have any extra work
    when :pin

    # Payconiq payments
    else
      http = ConstipatedKoala::Request.new ENV['PAYCONIQ_DOMAIN']
      self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }")

      request = http.post("/#{ ENV['PAYCONIQ_VERSION'] }/payments")

      request.body = { :amount => (amount * 100).to_i,
                       :reference => payment_type,
                       :description => description,
                       :currency => 'EUR',
                       :callbackUrl => Rails.env.development? ? "#{ ENV['NGROK_HOST'] }/api/hook/payconiq" : Rails.application.url_helpers.payconiq_hook_url,
                       :returnUrl => Rails.application.routes.url_helpers.payment_redirect_url(:token => token) }.to_json

      request['Authorization'] = "Bearer #{ payconiq_online? ? ENV['PAYCONIQ_ONLINE_TOKEN'] : ENV['PAYCONIQ_DISPLAY_TOKEN'] }"
      request.content_type = 'application/json'
      request['Cache-Control'] = "no-cache"

      response = http.send! request

      self.trxid = response.paymentId
      self.payconiq_qrurl = response[:_links][:qrcode][:href]
      self.payconiq_deeplink = response[:_links][:deeplink][:href]
      self.payment_uri = response[:_links][:checkout][:href]

      # Currently the test environment has an error where the link goes to the production environment while the transaction only exists in the test environment this fixes it for now.
      self.payment_uri = payment_uri.gsub(/payconiq/, 'ext.payconiq') if Rails.env.development?
      self.status = :in_progress
    end
  end

  def update_transaction!
    case payment_type.to_sym
    when :ideal
      http = ConstipatedKoala::Request.new ENV['MOLLIE_DOMAIN']
      @status = status

      request = http.get("/#{ ENV['MOLLIE_VERSION'] }/payments/#{ trxid }")
      request['Authorization'] = "Bearer #{ ENV['MOLLIE_TOKEN'] }"

      response = http.send! request

      status_update(response.status)

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
    else
      http = ConstipatedKoala::Request.new ENV['PAYCONIQ_DOMAIN']
      @status = status

      request = http.get("/#{ ENV['PAYCONIQ_VERSION'] }/payments/#{ trxid }")
      request['Authorization'] = "Bearer #{ payconiq_online? ? ENV['PAYCONIQ_ONLINE_TOKEN'] : ENV['PAYCONIQ_DISPLAY_TOKEN'] }"
      request.content_type = 'application/json'

      response = http.send! request

      status_update(response.status)

      save!

      # first time paid as a response
      if successful? && @status != :successful
        I18n.t('success', scope: 'activerecord.errors.models.payment')
        return true
      end

      self.message = I18n.t('processed', scope: 'activerecord.errors.models.payment') if successful?
      self.message = I18n.t('failed', scope: 'activerecord.errors.models.payment') if failed?
      return false
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
        transaction = CheckoutTransaction.create!(:price => (amount - transaction_fee), :checkout_balance => CheckoutBalance.find_by_member_id!(member), :payment_method => payment_type)

        self.transaction_id = [transaction.id]
        save!

        self.message = I18n.t('success', scope: 'activerecord.errors.models.payment')
      end
    end
  end

  def transaction_fee
    case payment_type.to_sym
    when :ideal
      return Settings.mongoose_ideal_costs
    when :pin
      return 0
    when :payconiq_online
      return Settings.payconiq_transaction_costs
    when :payconiq_display
      return 0
    else
      return 0
    end
  end

  def self.ideal_issuers
    # cache the payment issuers for 12 hours, don't request it to often. Stored in tmp/cache
    return [] unless ENV['MOLLIE_TOKEN'].present?

    Rails.cache.fetch('mollie_issuers', expires_in: 12.hours) do
      http = ConstipatedKoala::Request.new ENV['MOLLIE_DOMAIN']

      request = http.get("/#{ ENV['MOLLIE_VERSION'] }/issuers")
      request['Authorization'] = "Bearer #{ ENV['MOLLIE_TOKEN'] }"

      response = http.send! request
      response.data.map { |issuer| [issuer.name, issuer.id] }
    end
  end

  def activities
    Activity.find(transaction_id) if activity?
  end

  private

  def status_update(new_status)
    case new_status.downcase
    when "succeeded", "paid"
      self.status = :successful
    when "expired", "canceled", "failed", "cancelled", "expired", "authorization_failed"
      self.status = :failed
    else
      self.status = :in_progress
    end
  end
end
