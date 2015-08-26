class CheckoutTransaction < ActiveRecord::Base
  validates :price, presence: true
  belongs_to :checkout_card
  belongs_to :checkout_balance

  serialize :items, Array

  before_validation do

    # add items for a price
    if !self.items.blank?
      self.price = 0

      self.items.each do |item|
        self.price -= CheckoutProduct.find(item).price
      end
    end

    if self.price.nil? || self.price == 0
      raise ActiveRecord::RecordInvalid.new('no items supplied')
    end

    if self.checkout_balance.nil?
      self.checkout_balance = self.checkout_card.checkout_balance
    end

    if self.checkout_balance.balance + self.price < 0
      raise ActiveRecord::RecordNotSaved.new('insufficient funds')
    end

    self.checkout_balance.update_attribute(:balance, self.checkout_balance.balance + self.price)
    self.checkout_balance.save!
  end

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end

  def products
    return '-' if items.empty?

    counts = Hash.new
    items.each do |item|
      counts[ CheckoutProduct.find_by_id(item).name ] = 0 unless counts.has_key?( CheckoutProduct.find_by_id(item).name )
      counts[ CheckoutProduct.find_by_id(item).name ] += 1
    end

    strings = counts.map do |item, count|
      if count > 1
        "#{count}x #{item}"
      else
        "#{item}"
      end
    end

    return strings.join(', ')
  end
end
