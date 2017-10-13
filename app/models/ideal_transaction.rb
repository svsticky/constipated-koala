#:nodoc:
class IdealTransaction < ApplicationRecord
  require 'request'

  self.primary_key = :token

  attr_accessor :issuer, :mollie_uri, :message
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :status, presence: true

  belongs_to :member
  # validates :member, presence: true

  validates :transaction_type, presence: true
  serialize :transaction_id, Array

  validates :redirect_uri, presence: true

  after_validation(on: :create) do
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

                        :redirectUrl => Rails.application.routes.url_helpers.mollie_redirect_url(:token => token))

    request['Authorization'] = "Bearer #{ ENV['MOLLIE_TOKEN'] }"
    response = http.send! request

    self.trxid = response.id
    self.mollie_uri = response.links.paymentUrl
  end

  def self.issuers
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

  def update!
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
  end

  # mark transaction_types as paid
  def finalize!
    case transaction_type.downcase
    when 'activity'

      # loop thru activities and mark one as paid
      transaction_id.each do |activity|
        participant = Participant.where("member_id = ? AND activity_id = ?", member.id, activity)
        participant.first.paid = true
        participant.first.save
      end

      self.message = I18n.t('success', scope: 'activerecord.errors.models.ideal_transaction')

    when 'checkouttransaction'
      # additional check if not already added checkout funds
      return unless transaction_id.empty?

      # create a single transaction to update the checkoutbalance and mark the ideal transaction as processed
      IdealTransaction.transaction do

        self.transaction_id = [transaction.id]
        save!

    Activity.find(transaction_id) if transaction_type.casecmp('activity').zero?
  end
end
