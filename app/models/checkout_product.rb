class CheckoutProduct < ActiveRecord::Base
  validates :name, presence: true
  validates :category, presence: true
  validates :active, presence: true
  
  validates :price, presence: true
  validates :image, presence: true
  
  enum category: [ :beverage, :chocolate, :savory, :additional ]
  
  def self.categories
    return [[ "Drinken", :beverage ], [ "chocolade", :chocolate ], [ "hartig", :savory ], [ "overig", :additional ]]
  end
  
  has_attached_file :image, 
  	:styles => { :original => ['128x128', :png] }, 
  	:processors => [ :ghostscript, :thumbnail ], 
  	:validate_media_type => false,
  	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8 center' },
  	:path => '/:class/:id'

  validates_attachment_content_type :image, 
	  :content_type => ['application/pdf', 'image/jpeg', 'image/png']
end