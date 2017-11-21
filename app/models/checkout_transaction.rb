class CheckoutTransaction < ApplicationRecord
  validates :price, presence: true, numericality: { other_than: 0 }
  validate :validate_sufficient_credit, :validate_payment_method, :validate_liquor_items

  belongs_to :checkout_card, optional: true
  belongs_to :checkout_balance

  attr_accessor :skip_liquor_time_validation

  serialize :items, Array

  class_attribute :i18n_error_scope
  self.i18n_error_scope = %i[activerecord errors models checkout_transaction attributes]

  before_validation do
    # add items for a price
    unless items.blank?
      self.price = -items.reduce(0) { |total, item_id| total + CheckoutProduct.find(item_id).price }
    end

    if checkout_balance.nil?
      self.checkout_balance = checkout_card.checkout_balance
    end
  end

  after_validation do
    CheckoutBalance.where(id: checkout_balance.id).limit(1).update_all("balance = balance + #{self.price}, updated_at = NOW()")
  end

  after_commit :update_product_stock

  def validate_sufficient_credit
    errors.add(:price, I18n.t('price.insufficient_credit', scope: i18n_error_scope)) if price + checkout_balance.balance < 0
  end

  def validate_payment_method
    errors.add(:payment_method, I18n.t('payment_method.blank', scope: i18n_error_scope)) if payment_method.blank? && items.blank?
  end

  def validate_liquor_items
    return unless items.any? {|item| CheckoutProduct.find(item).liquor?}

    # only place you should use now, because liquor_time is without zone
    errors.add(:items, I18n.t('items.not_liquor_time', scope: i18n_error_scope)) if Time.now.before(Settings.liquor_time) && !skip_liquor_time_validation
    errors.add(:items, I18n.t('items.member_under_age', scope: i18n_error_scope)) if checkout_balance.member.is_underage?
  end

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f)
  end

  def update_product_stock
    items.each do |item_id|
      item = CheckoutProduct.find(item_id)
      item.decrement!(:chamber_stock)
    end
  end

  def products
    return '-' if items.empty?

    counts = {}
    items.each do |item|
      counts[CheckoutProduct.find_by_id(item).name] = 0 unless counts.key?(CheckoutProduct.find_by_id(item).name)
      counts[CheckoutProduct.find_by_id(item).name] += 1
    end

    strings = counts.map do |item, count|
      if count > 1
        "#{count}x #{item}"
      else
        item.to_s
      end
    end

    strings.join(', ')
  end
end
