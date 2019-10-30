#:nodoc:
class CheckoutCard < ApplicationRecord
  validates :uuid, presence: true
  validates :member, presence: true
  validates :checkout_balance, presence: true

  has_many :checkout_transactions

  belongs_to :member
  belongs_to :checkout_balance

  is_impressionable

  before_validation(on: :create) do
    # find balance otherwise create a new one
    balance = CheckoutBalance.find_or_create_by!(member: member)

    if balance.save
      self.checkout_balance = balance
    else
      throw :abort
    end
  end

  def send_confirmation!
    # Generate token
    digest = OpenSSL::Digest.new('sha1')
    token  = OpenSSL::HMAC.hexdigest(digest, ENV['CHECKOUT_TOKEN'], uuid)

    # Save token to card & mail confirmation link
    Mailings::Checkout.confirmation_instructions(self, Rails.application.routes.url_helpers. confirmation_url(confirmation_token: token)).deliver_now if update(confirmation_token: token)
  end
end
