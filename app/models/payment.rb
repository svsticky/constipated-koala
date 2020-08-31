#:nodoc:
class Payment < ApplicationRecord
  require 'request'
  include SearchCop

  self.primary_key = :token

  attr_accessor :issuer, :ideal_uri, :message, :payconiq_qrurl, :payconiq_deeplink

  search_scope :search do
    attributes :status, :description, :payment_type, :token, :trxid
    attributes member: %w[member.first_name member.infix member.last_name]
  end
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :status, presence: true
  validates :payment_type, presence: true

  enum :payment_type => [:ideal, :payconiq_online, :payconiq_display, :pin]

  belongs_to :member
  # validates :member, presence: true

  validates :transaction_type, presence: true
  enum :transaction_type => [:checkout, :activity]

  serialize :transaction_id, Array

  validates :ideal_redirect_uri, presence: true, if: :ideal?

  after_validation(on: :create) do
    self.amount += transaction_fee
    case payment_type.to_sym
    when :ideal
      http = ConstipatedKoala::Request.new ENV['MOLLIE_DOMAIN']
      self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }#{ ideal_redirect_uri }")

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

                          :redirectUrl => Rails.application.routes.url_helpers.mollie_redirect_url(:token => token))

      request['Authorization'] = "Bearer #{ ENV['MOLLIE_TOKEN'] }"
      response = http.send! request

      self.trxid = response.id
      self.ideal_uri = response.links.paymentUrl
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
                       :callbackUrl => Rails.env.development? ? "#{ ENV['PAYCONIQ_CALLBACKURL'] }/api/hook/payconiq" : Rails.application.url_helpers.payconiq_hook_url }.to_json

      request['Authorization'] = "Bearer #{ payconiq_online? ? ENV['PAYCONIQ_ONLINE_TOKEN'] : ENV['PAYCONIQ_DISPLAY_TOKEN'] }"
      request.content_type = 'application/json'
      request['Cache-Control'] = "no-cache"

      response = http.send! request

      self.trxid = response.paymentId
      self.payconiq_qrurl = response[:_links][:qrcode][:href]
      self.payconiq_deeplink = response[:_links][:deeplink][:href]
    end
  end

  def update!
    case payment_type.to_sym
    when :ideal
      http = ConstipatedKoala::Request.new ENV['MOLLIE_DOMAIN']
      @status = status

      request = http.get("/#{ ENV['MOLLIE_VERSION'] }/payments/#{ trxid }")
      request['Authorization'] = "Bearer #{ ENV['MOLLIE_TOKEN'] }"

      response = http.send! request
      self.status = response.status
      save!

      # first time paid as a response
      return true if status == 'paid' && @status != 'paid'

      self.message = I18n.t('processed', scope: 'activerecord.errors.models.ideal_transaction')
      return false
    when :pin
    else
      http = ConstipatedKoala::Request.new ENV['PAYCONIQ_DOMAIN']
      @status = status

      request = http.get("/#{ ENV['PAYCONIQ_VERSION'] }/payments/#{ trxid }")
      request['Authorization'] = "Bearer #{ payconiq_online? ? ENV['PAYCONIQ_ONLINE_TOKEN'] : ENV['PAYCONIQ_DISPLAY_TOKEN'] }"
      request.content_type = 'application/json'

      response = http.send! request

      self.status = response.status

      save!

      # first time paid as a response
      return true if status == 'SUCCEEDED' && @status != 'SUCCEEDED'

      self.message = I18n.t('processed', scope: 'activerecord.errors.models.ideal_transaction')
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

      self.message = I18n.t('success', scope: 'activerecord.errors.models.ideal_transaction')

    when :checkout
      # additional check if not already added checkout funds
      return unless transaction_id.empty?

      # create a single transaction to update the checkoutbalance and mark the Payment as processed
      Payment.transaction do
        transaction = CheckoutTransaction.create!(:price => (amount - transaction_fee), :checkout_balance => CheckoutBalance.find_by_member_id!(member), :payment_method => payment_type)

        self.transaction_id = [transaction.id]
        save!

        self.message = I18n.t('success', scope: 'activerecord.errors.mode ls.ideal_transaction')
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
end
