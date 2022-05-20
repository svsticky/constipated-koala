#:nodoc:
class CheckoutProduct < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_one_attached :image
  validate :content_type, unless: :skip_image_validation
  attr_accessor :skip_image_validation

  def content_type
    return if !image.attached? || image.content_type.in?(['image/jpeg', 'image/png'])

    errors.add(:image,
               I18n.t('activerecord.errors.unsupported_content_type', type: image.content_type.to_s,
                                                                      allowed: 'image/jpeg image/png'))
  end

  enum category: { beverage: 1, chocolate: 2, savory: 3, additional: 4, liquor: 5 }

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f)
  end

  before_update do
    if name_changed? || category_changed? || price_changed?
      record          = CheckoutProduct.new
      record.name     = name
      record.category = category
      record.price    = price
      record.parent   = id

      reload
      update_columns(active: false)

      record.save
    end
  end

  def url
    if image.attached?
      return image.variant(thumbnail: '128x128^', gravity: 'center',
                           extent: '128x128')
    end

    return nil if parent.nil?

    return CheckoutProduct.find_by(id: parent).url
  end

  def children?
    return true unless CheckoutProduct.find_by(parent: id).nil?

    return false
  end

  def parents
    return [] if parent.nil?

    return CheckoutProduct.where(id: parent).select(:id, :name, :price, :category,
                                                    :created_at) + CheckoutProduct.find_by(id: parent).parents
  end

  def sales(year = nil)
    year = year.blank? ? Date.today.study_year : year.to_i

    sales = CheckoutTransaction.where(
      "created_at >= ? AND created_at < ? AND items LIKE '%- #{ id }\n%'", Date.to_date(year), Date.to_date(year + 1)
    ).group(:items).count.map do |k, v|
      { k => v }
    end

    unless sales.nil?
      count = sales.map do |hash|
        hash.keys.first.count(id) * hash.values.first
      end.inject(:+)
    end

    return [{ self => count }] if parent.nil?

    return [{ self => count }] + CheckoutProduct.find_by(id: parent).sales(year)
  end

  def self.last_version
    CheckoutProduct.select { |product| !product.children? } # rubocop:disable Style/InverseMethods
  end

  private

  def valid_image
    return if image.present? || parent.present?

    errors.add(:image,
               I18n.t('activerecord.errors.models.checkout_product.blank'))
  end
end
