class Participant < ActiveRecord::Base
  belongs_to :member
  belongs_to :activity
  
  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end
  
  def currency
    self.price ||= activity.price
  end
end