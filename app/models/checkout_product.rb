#:nodoc:
class CheckoutProduct < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true
  validates :price, presence: true
  validate :valid_image, unless: :skip_image_validation

  attr_accessor :skip_image_validation

  enum category: { beverage: 1, chocolate: 2, savory: 3, additional: 4, liquor: 5 }

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f)
  end

  has_attached_file :image,
                    :styles              => { :original => ['128x128', :png] },
                    :validate_media_type => false,
                    :convert_options     => { :all => '-colorspace CMYK -quality 100 -density 8 -gravity center' }

  validates_attachment_content_type :image,
                                    :content_type => ['image/jpeg', 'image/png']

  before_update do
    if name_changed? || category_changed? || price_changed?
      record          = CheckoutProduct.new
      record.name     = name
      record.category = category
      record.price    = price
      record.parent   = id

      reload
      update_columns(:active => false)

      record.save
    end
  end

  def url
    return image.url(:original) if image.exists?
    return nil if parent.nil?

    return CheckoutProduct.find_by_id(parent).url
  end

  def children?
    return true unless CheckoutProduct.find_by_parent(id).nil?

    return false
  end

  def parents
    return [] if parent.nil?

    return CheckoutProduct.where(:id => parent).select(:id, :name, :price, :category, :created_at) + CheckoutProduct.find_by_id(parent).parents
  end

  def sales(year = nil)
    year = year.blank? ? Date.today.study_year : year.to_i

    sales = CheckoutTransaction.where("created_at >= ? AND created_at < ? AND items LIKE '%- #{ id }\n%'", Date.to_date(year), Date.to_date(year + 1)).group(:items).count.map { |k, v| { k => v } }

    count = sales.map { |hash| hash.keys.first.count(id) * hash.values.first }.inject(:+) unless sales.nil?

    return [{ self => count }] if parent.nil?

    return [{ self => count }] + CheckoutProduct.find_by_id(parent).sales(year)
  end

  def self.last_version
    CheckoutProduct.select { |product| !product.children? } # rubocop:disable Style/InverseMethods
  end

  private

  def valid_image
    errors.add :image, I18n.t('activerecord.errors.models.checkout_product.blank') unless image.present? || parent.present?
  end
end
