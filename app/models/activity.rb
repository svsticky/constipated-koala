class Activity < ActiveRecord::Base
  validates :name, presence: true
  validates :start_date, presence: true
#  validates :end_date
#  validates :description
  
  has_attached_file :poster, :styles => { :thumb => ['180', :png], :medium => ['x720', :png] }, 
	:processors => [:ghostscript, :thumbnail], :validate_media_type => false,
	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8'}
  validates_attachment_content_type :poster, :content_type => ['application/pdf', 'image/jpeg', 'image/png']
#  validates_attachment_size :less_than => 10.megabytes 

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants

  def currency(member)
    participants.where(:member => member).first.price ||= self.price
  end
end
