class CheckoutTransaction < ActiveRecord::Base
  validates :price, presence: true
  belongs_to :checkout_card
  belongs_to :checkout_balance
  
  serialize :items, Array

  before_validation do
    self.price = 0
    
    self.items.each do |item|
      self.price -= CheckoutProduct.find(item).price
    end
    
    # TODO als er ook geen kaart is een nieuw balans aanmaken
    if self.checkout_balance.nil?    
      self.checkout_balance = self.checkout_card.checkout_balance
    end
    
    if self.checkout_balance.balance + self.price < 0 
      logger.error 'insufficient funds'
      raise ActiveRecord::RecordNotSaved
    end
    
    if self.price == 0
      logger.error 'no items supplied'
      raise ArgumentError
    end

    self.checkout_balance.update_attribute(:balance, self.checkout_balance.balance + self.price)
    self.checkout_balance.save!
  end
end
