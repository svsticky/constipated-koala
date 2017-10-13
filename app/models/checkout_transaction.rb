#:nodoc:
class CheckoutTransaction < ApplicationRecord
  validates :price, presence: true, numericality: { other_than: 0 }
  validate :validate_sufficient_credit, :validate_payment_method, :validate_liquor_items

  belongs_to :checkout_card, optional: true
  belongs_to :checkout_balance

  has_many :checkout_transaction_items
  has_many :contained_products, through: :checkout_transaction_items, source: :checkout_product_type # Working title TODO

  after_save :items_to_link_table # Before commit
  after_save :create_stocky_transaction

  attr_accessor :skip_liquor_time_validation
  attr_accessor :items

  is_impressionable

  class_attribute :i18n_error_scope
  self.i18n_error_scope = %i[activerecord errors models checkout_transaction attributes]

  before_validation do
    @checkout_product_type_cache = self.items.map { |i| CheckoutProductType.find(i) }
    # add items for a price
    self.price ||= 0
    unless @checkout_product_type_cache.none?
      self.price = -@checkout_product_type_cache.reduce(0) { |total, item| total + item.price }
    end

    if checkout_balance.nil?
      self.checkout_balance = checkout_card.checkout_balance
    end
  end

  after_validation do
    CheckoutBalance.where(id: checkout_balance.id).limit(1).update_all("balance = balance + #{ price }, updated_at = NOW()") # XXX Nee
  end

  def validate_sufficient_credit
    errors.add(:price, I18n.t('price.insufficient_credit', scope: i18n_error_scope)) if price + checkout_balance.balance < 0
  end

  def validate_payment_method
    errors.add(:payment_method, I18n.t('payment_method.blank', scope: i18n_error_scope)) if payment_method.blank? && items.none?
  end

  def validate_liquor_items
    return unless @checkout_product_type_cache.any?(&:liquor?)

    # only place you should use now, because liquor_time is without zone
    if Time.now.before(Settings.liquor_time) && !skip_liquor_time_validation
      errors.add(
        :items,
        I18n.t('items.not_liquor_time', scope: i18n_error_scope, liquor_time: Settings.liquor_time)
      )
    end

    errors.add(:items, I18n.t('items.member_under_age', scope: i18n_error_scope)) if checkout_balance.member.underage?
  end

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f)
  end

  def products
    return '-' if contained_products.none?

    counts = Hash.new 0 # Non-existent keys will be zero
    contained_products.each do |item|
      counts[item.name] += 1
    end

    strings = counts.map do |item, count|
      if count > 1
        "#{ count }x #{ item }"
      else
        item.to_s
      end
    end

    strings.join(', ')
  end

  def items_to_link_table
    return unless items
    CheckoutTransactionItem.transaction do
      # Clear all existing CheckoutTransactionItems just to be sure
      old_ctis = CheckoutTransactionItem.where(checkout_transaction: self)
      old_ctis.each(&:destroy!)

      # Save all items in `items` as separate `CheckoutTransactionItems`.
      @checkout_product_type_cache.each do |cpt|
        cti = CheckoutTransactionItem.new(
          checkout_product_type: cpt,
          checkout_transaction: self,
          price: cpt.price
        )
        cti.save!
      end
    end
  end

  # Create a StockyTransaction for each item
  def create_stocky_transaction
    return unless items

    counts = contained_products.group(:id).count

    counts.each do |product_id, count|
      StockyTransaction.create!(
        from: 'mongoose',
        to: 'member',
        checkout_product_type_id: product_id,
        amount: count
      )
    end
  end
end
