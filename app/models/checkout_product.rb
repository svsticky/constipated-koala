class CheckoutProduct < ActiveRecord::Base
  validates :name, presence: true
#  validates :category, presence: true
  validates :active, presence: true
  
  validates :price, presence: true
#  validates :image, presence: true
  
  enum category: [ :beverage, :chocolate, :savory, :additional ]
  
  def price=(price)
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end

  has_attached_file :image, 
  	:styles => { :original => ['128x128', :png] }, 
  	:validate_media_type => false,
  	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8 center' },
  	:path => '/:class/:id'

  validates_attachment_content_type :image, 
	  :content_type => ['image/jpeg', 'image/png']
end
