class Advertisement < ActiveRecord::Base
  validates :name, presence: true

  has_attached_file :poster,
  	:styles => { :original => ['x720', :png] },
  	:processors => [ :ghostscript, :thumbnail ],
  	:validate_media_type => false,
  	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8' },
    :s3_permissions => {
      :original => :public_read
    }

  validates_attachment_content_type :poster,
	  :content_type => ['application/pdf', 'image/jpeg', 'image/png']

  def self.list
    return Advertisement.all.map{ |item| (item.attributes.merge({ :poster => Advertisement.find(item.id).poster.url(:original) }) if !item.poster_updated_at.nil?)}.compact
  end
end
