class Activity < ActiveRecord::Base
  validates :name, presence: true
  validates :start_date, presence: true
#  validates :end_date
#  validates :description

  has_attached_file :poster,
	:styles => { :thumb => ['180', :png], :medium => ['x720', :png] },
	:processors => [:ghostscript, :thumbnail],
	:validate_media_type => false,
	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8'}

  validates_attachment_content_type :poster,
	:content_type => 'application/pdf'

#  validates_attachment_size :less_than => 10.megabytes

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants

  def self.study_year( year )
    year = year.blank? ? (Date.start_studyyear( Date.current().year ).year ) : year.to_i
    where("start_date >= ? AND start_date < ?", Date.start_studyyear( year ), Date.start_studyyear( year +1 ))
  end

  def currency( member )
    participants.where(:member => member).first.price ||= self.price
  end

  def price=( price )
    write_attribute(:price, price.to_s.gsub(',', '.').to_f)
  end
end
