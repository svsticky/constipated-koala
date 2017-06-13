class Advertisement < ApplicationRecord
  validates :name, presence: true

  has_attached_file :poster,
  	:styles => { :original => ['x1080', :png] },
  	:processors => [ :ghostscript, :thumbnail ],
  	:validate_media_type => false,
  	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8' },
    :s3_permissions => {
      :original => :'public-read'
    }

  validates_attachment_content_type :poster,
	  :content_type => ['application/pdf', 'image/jpeg', 'image/png']

end
