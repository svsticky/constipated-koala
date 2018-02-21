class CheckoutBalance < ApplicationRecord
  validates :balance, presence: true
  validates :member, presence: true

  belongs_to :member
  has_many :checkout_cards,
           :dependent => :destroy
end
