class CheckoutCard < ActiveRecord::Base
  validates :uuid, presence: true
  validates :member, presence: true
  validates :checkout_balance, presence: true
  validates :active, presence: true
  
  has_many :checkout_transactions
  
  belongs_to :member
  belongs_to :checkout_balance
  
  before_create do
    self.active = false
    
    #find balance otherwise create a new one
    balance = CheckoutBalance.find_or_create_by!(member: self.member)

    if balance.save
      self.checkout_balance = balance
    else
      return false
    end
  end
end