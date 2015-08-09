class Participant < ActiveRecord::Base
  belongs_to :member
  belongs_to :activity
  
  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end
  
  def currency
    self.price ||= activity.price
  end
  
  before_validation do
    self.paid = false if self.price_changed?
    self.paid = true if self.price == 0
    
    write_attribute(:price, NIL) if activity.price == self.price 
  end
end