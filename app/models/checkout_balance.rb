class CheckoutBalance < ActiveRecord::Base
  validates :balance, presence: true
  validates :member, presence: true

  belongs_to :member
  has_many :checkout_cards,
    :dependent => :destroy

  before_validation(on: :create) do
    self.balance = 0
  end
end
