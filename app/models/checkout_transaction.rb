#:nodoc:
class CheckoutTransaction < ApplicationRecord
  validates :price, presence: true, numericality: { other_than: 0 }
  validate :validate_sufficient_credit, :validate_payment_method, :validate_liquor_items

  belongs_to :checkout_card, optional: true
  belongs_to :checkout_balance

  serialize :items, Array

  is_impressionable

  class_attribute :i18n_error_scope
  self.i18n_error_scope = %i[activerecord errors models checkout_transaction attributes]

  before_validation do
    # add items for a price
    calculate_price if items.present?

    self.checkout_balance = checkout_card.checkout_balance if checkout_balance.nil?
  end

  after_validation do
    CheckoutBalance.where(id: checkout_balance.id).limit(1).update_all(
      "balance = balance + #{ price }, updated_at = NOW()"
    )
  end

  def validate_sufficient_credit
    return unless price + checkout_balance.balance < 0

    errors.add(:price,
               I18n.t('price.insufficient_credit',
                      scope: i18n_error_scope))
  end

  def validate_payment_method
    return unless payment_method.blank? && items.blank?

    errors.add(:payment_method,
               I18n.t('payment_method.blank',
                      scope: i18n_error_scope))
  end

  def validate_liquor_items
    return unless items.any? { |item| CheckoutProduct.find(item).liquor? }

    # only place you should use now, because liquor_time is without zone
    if Time.now.before(Settings.liquor_time) && Rails.env.production?
      errors.add(:items,
                 I18n.t('items.not_liquor_time',
                        scope: i18n_error_scope))
    end

    return unless checkout_balance.member.underage?

    errors.add(:items,
               I18n.t('items.member_under_age',
                      scope: i18n_error_scope))
  end

  def calculate_price
    self.price = -items.reduce(0) do |total, item_id|
      item = CheckoutProduct.find(item_id)
      total + item.price
    end
    price
  end

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f)
  end

  def products
    return '-' if items.empty?

    counts = {}
    items.each do |item|
      unless counts.key?(CheckoutProduct.find_by(id: item).name)
        counts[CheckoutProduct.find_by(id: item).name] =
          0
      end
      counts[CheckoutProduct.find_by(id: item).name] += 1
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
end
