class CheckoutTransaction < ActiveRecord::Base
  validates :price, presence: true
  belongs_to :checkout_card

  before_validation :before_validation

  private
  def before_validation
    balance = self.checkout_card.checkout_balance

    if( balance.balance + self.price < 0 )
      logger.debug 'insufficient funds'
      raise ActiveRecord::RecordNotSaved
    end

    # if validation failes, this is rolledback
    balance.update_attribute(:balance, balance.balance + self.price)
    balance.save!
  end
end
