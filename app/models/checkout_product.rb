class CheckoutProduct < ActiveRecord::Base

  validates :name, presence: true
  validates :category, presence: true
  validates :price, presence: true
  validate :valid_image

  enum category: { beverage: 1, chocolate: 2, savory: 3, additional: 4, liquor: 5 }

  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end

  has_attached_file :image,
  	:styles => { :original => ['128x128', :png] },
  	:validate_media_type => false,
  	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8 -gravity center' },
  	:s3_permissions => {
      :original => :public_read
    }

  validates_attachment_content_type :image,
	  :content_type => ['image/jpeg', 'image/png']

  before_update do
    if name_changed? || category_changed? || price_changed?
      record = CheckoutProduct.new
      record.name = self.name
      record.category = self.category
      record.price = self.price
      record.parent = self.id

      self.reload
      self.update_columns( :active => false )

      record.save
    end
  end

  def url
    return self.image.url(:original) if self.image.exists?
    return nil if self.parent.nil?
    return CheckoutProduct.find_by_id( self.parent ).url
  end

  def has_children?
    return true unless CheckoutProduct.find_by_parent( self.id ).nil?
    return false
  end

  def parents
    return [] if self.parent.nil?
    return CheckoutProduct.where( :id => self.parent).select( :id, :name, :price, :category, :created_at ) + CheckoutProduct.find_by_id(self.parent).parents
  end

  def sales( year = nil )
    year = year.blank? ? Date.today.study_year : year.to_i

    sales = CheckoutTransaction.where( "created_at >= ? AND created_at < ? AND items LIKE '%- #{ self.id }\n%'", Date.to_date( year ), Date.to_date( year +1 ) ).group( :items ).count.map{ |k,v| { k => v} }

    count = sales.map{ |hash| hash.keys.first.count(self.id) * hash.values.first }.inject(:+) unless sales.nil?

    return [{ self => count}] if self.parent.nil?
    return [{ self => count}] + CheckoutProduct.find_by_id( self.parent ).sales( year )
  end

  def self.last_version
    self.select{ |product| !product.has_children? }
  end

  private
  def valid_image
    errors.add :image, I18n.t('activerecord.errors.models.checkout_product.blank') unless self.image.present? || parent.present?
  end
end
