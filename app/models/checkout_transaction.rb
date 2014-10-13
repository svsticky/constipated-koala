class CheckoutTransaction < ActiveRecord::Base
  validates :price, presence: true
  has_one :checkout_card

  before_validation :before_validation
  after_save :after_save

  private
  def before_validation
    @balance = self.checkout_card.checkout_balance

    if( @balance.balance + self.price < 0)
      return false
    end
  end

  def after_save
    @balance = self.checkout_card.checkout_balance

    @balance.balance = @balance.balance - self.price
    @balance.save
  end
end
