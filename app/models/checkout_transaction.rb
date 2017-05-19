class CheckoutTransaction < ApplicationRecord
  validates :price, presence: true
  belongs_to :checkout_card, optional: true
  belongs_to :checkout_balance

  serialize :items, Array
#  is_impressionable

  before_validation do

    # add items for a price
    if !self.items.blank?
      self.price = 0

      self.items.each do |item|
        self.price -= CheckoutProduct.find(item).price
      end
    else
      if self.payment_method.blank?
        raise ActiveRecord::RecordNotSaved.new('Betaalmethode niet opgegeven')
      end
    end

    if self.price.nil? || self.price == 0
      raise ActiveRecord::RecordNotSaved.new('De opwaardering kan niet nul zijn')
    end

    if self.checkout_balance.nil?
      self.checkout_balance = self.checkout_card.checkout_balance
    end

    if self.checkout_balance.balance + self.price < 0
      raise ActiveRecord::RecordNotSaved.new('Er is te weinig saldo')
    end

    if items.any? { |item| CheckoutProduct.find( item ).liquor? }
      #only place you should use now, because liquor_time is without zone
      raise ActiveRecord::RecordNotSaved.new('not_allowed') if Time.now.before( Settings.liquor_time )
      raise ActiveRecord::RecordNotSaved.new('not_allowed') if self.checkout_balance.member.is_underage?
    end

    CheckoutBalance.where(id: self.checkout_balance.id).limit(1).update_all("balance = balance + %{amount}, updated_at = NOW()" % { amount: self.price })
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
