class Advertisement < ActiveRecord::Base
  validates :name, presence: true
  validates :visible, presence: true

  has_attached_file :poster, 
	:styles => { :thumb => ['180', :png], :medium => ['x720', :png] }, 
	:processors => [ :ghostscript, :thumbnail ], 
	:validate_media_type => false,
	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8'}

  validates_attachment_content_type :poster, 
	:content_type => ['application/pdf', 'image/jpeg', 'image/png']
 
end