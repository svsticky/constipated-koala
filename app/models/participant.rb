class Participant < ActiveRecord::Base
  belongs_to :member
  belongs_to :activity

  is_impressionable

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f) unless price.blank?
  end

  def currency
    activity.price if read_attribute(:price).nil?
    self.price ||= 0
  end

  before_validation do
    self.paid = false if self.price_changed?
    write_attribute(:price, NIL) if activity.price == self.price
  end
end
