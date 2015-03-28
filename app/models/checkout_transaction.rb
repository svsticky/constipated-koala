class CheckoutTransaction < ActiveRecord::Base
  validates :price, presence: true
  belongs_to :checkout_card
  belongs_to :checkout_balance

  before_validation :before_validation

  private  
  def before_validation
    
    # TODO als er ook geen kaart is een nieuw balans aanmaken
    if self.checkout_balance.nil?    
      self.checkout_balance = self.checkout_card.checkout_balance
    end
    
    if( self.checkout_balance.balance + self.price < 0 )
      logger.debug 'insufficient funds'
      raise ActiveRecord::RecordNotSaved
    end

    # if validation failes, this is rolledback
    self.checkout_balance.update_attribute(:balance, self.checkout_balance.balance + self.price)
    self.checkout_balance.save!
  end
end
