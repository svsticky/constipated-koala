class CheckoutProductType < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true
  validates :price, presence: true
  validate :valid_image, unless: :skip_image_validation

  has_many :checkout_products

  attr_accessor :skip_image_validation

  enum category: { beverage: 1, chocolate: 2, savory: 3, additional: 4, liquor: 5 }

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end

  has_attached_file :image,
                    :styles              => { :original => ['128x128', :png] },
                    :validate_media_type => false,
                    :convert_options     => { :all => '-colorspace CMYK -quality 100 -density 8 -gravity center' },
                    :s3_permissions      => {
                      :original => :'public-read'
                    }

  validates_attachment_content_type :image,
                                    :content_type => ['image/jpeg', 'image/png']

  def url
    self.image.url(:original) if self.image.exists?
  end

  def sales(year = nil)
    year = year.blank? ? Date.today.study_year : year.to_i

    sales = CheckoutTransactionItem
      .where(checkout_product_type: self)
      .joins(:checkout_product_type)
      .where('created_at >= ? AND created_at < ?', Date.to_date(year), Date.to_date(year + 1))
      .count

    return [{ self => sales }]
  end

  private

  def valid_image
    errors.add :image, I18n.t('activerecord.errors.models.checkout_product.blank') unless self.image.present?
  end
end
