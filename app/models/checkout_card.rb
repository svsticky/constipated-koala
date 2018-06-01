class CheckoutCard < ApplicationRecord
  validates :uuid, presence: true
  validates :member, presence: true
  validates :checkout_balance, presence: true

  has_many :checkout_transactions,
           :dependent => :destroy

  belongs_to :member
  belongs_to :checkout_balance

  before_validation(on: :create) do
    # find balance otherwise create a new one
    balance = CheckoutBalance.find_or_create_by!(member: member)

    if balance.save
      self.checkout_balance = balance
    else
      throw :abort
    end
  end
end
