class CheckoutCard < ActiveRecord::Base
  validates :uuid, presence: true
  validates :member, presence: true
  #validates :checkout_balance, presence: true
  validates :active, presence: true
  
  belongs_to :member
  belongs_to :checkout_balance
  
  before_validation :create_balance
  
  before_validation(on: :create) do
    self.active = false
  end
  
  private
  def create_balance
    #find balance otherwise create a new one
    balance = CheckoutBalance.find_or_initialize_by(member: self.member)

    if balance.save
      logger.debug balance
      self.checkout_balance = balance
    else
      logger.error "balance #{balance.inspect}"
    end
  end
end