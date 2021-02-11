#:nodoc:
class PayconiqTransaction < ApplicationRecord
  require 'request'
  
  self.primary_key = :token

  attr_accessor :message, :qrurl, :deeplink
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :status, presence: true
  belongs_to :member


  validates :transaction_type, presence: true
  serialize :transaction_id, Array

  after_validation(on: :create) do
    http = ConstipatedKoala::Request.new ENV['PAYCONIQ_DOMAIN']
    self.token = Digest::SHA256.hexdigest("#{ member.id }#{ Time.now.to_f }")

    request = http.post("/#{ ENV['PAYCONIQ_VERSION'] }/payments")

    ## TODO: Fixcallback url
    request.body =  { :amount => (amount*100).to_i,
                      :currency => 'EUR',
                      :callbackUrl => "http://f92dc026.ngrok.io/api/hook/payconiq"
                    }.to_json
    request['Authorization'] = "Bearer #{ ENV['PAYCONIQ_TOKEN'] }"
    request.content_type= 'application/json'
    request['Cache-Control'] = "no-cache"
    response = http.send! request
    self.trxid = response.paymentId
    self.qrurl = response[:_links][:qrcode][:href]
    self.deeplink = response[:_links][:deeplink][:href]
  end

  def update!
    http = ConstipatedKoala::Request.new ENV['PAYCONIQ_DOMAIN']
    @status = status

    request = http.get("/#{ ENV['PAYCONIQ_VERSION'] }/payments/#{ trxid }")
    request['Authorization'] = "Bearer #{ ENV['PAYCONIQ_TOKEN'] }"
    request.content_type= 'application/json'
    response = http.send! request
    self.status = response.status
    save!

    # first time paid as a response
    return true if status == 'SUCCEEDED' && @status != 'SUCCEEDED'
    self.message = I18n.t('processed', scope: 'activerecord.errors.models.ideal_transaction')
    return false
  end

  # mark transaction_types as paid
  def finalize!
    case transaction_type.downcase
    when 'activity'

      ##TODO: Make it a atomic transaction
      transaction_id.each do |activity|
        participant = Participant.where("member_id = ? AND activity_id = ?", member.id, activity)
        participant.first.paid = true
        participant.first.save
      end
      transaction = ParticipantTransaction.create!(:member => member, :activity_id => transaction_id)
      self.transaction_id = [transaction.id]

      self.message = I18n.t('success', scope: 'activerecord.errors.models.ideal_transaction')
    when 'checkouttransaction'
      return unless transaction_id.empty?

      # create a single transaction to update the checkoutbalance and mark the ideal transaction as processed
      PayconiqTransaction.transaction do
        transaction = CheckoutTransaction.create!(:price => (amount), :checkout_balance => CheckoutBalance.find_by_member_id!(member), :payment_method => "payconq")

        self.transaction_id = [transaction.id]
        save!

        self.message = I18n.t('success', scope: 'activerecord.errors.models.ideal_transaction')
      end
    end
  end

  def activities
    Activity.find(transaction_id) if transaction_type.casecmp('activity').zero?
  end
end
