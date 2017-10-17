class Participant < ApplicationRecord
  belongs_to :member
  belongs_to :activity

  after_destroy :enroll_reservist

  validates :notes, length: {maximum: 30}

  is_impressionable

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f) unless price.blank?
    write_attribute(:price, nil) if price.blank?
  end

  def currency
    return activity.price if read_attribute(:price).nil?
    self.price ||= 0
  end

  before_validation do
    self.paid = false if self.price_changed?
    write_attribute(:price, nil) if activity.price == self.price
  end

  def enroll_reservist
    self.activity.enroll_reservists
  end
end
