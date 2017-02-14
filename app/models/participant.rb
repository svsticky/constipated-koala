class Participant < ActiveRecord::Base
  belongs_to :member
  belongs_to :activity

  after_destroy :enroll_reservist

  is_impressionable

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f) unless price.blank?
    write_attribute(:price, NIL) if price.blank?
  end

  def currency
    return activity.price if read_attribute(:price).nil?
    self.price ||= 0
#     self.price ||= activity.price
  end

  before_validation do
    self.paid = false if self.price_changed?
    write_attribute(:price, NIL) if activity.price == self.price
  end

  def enroll_reservist
    self.activity.enroll_reservists
  end
end
