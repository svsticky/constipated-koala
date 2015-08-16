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

  has_one :group, :as => :organized_by

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants

  def self.study_year( year )
    year = year.blank? ? Date.today.study_year : year.to_i
    where("start_date >= ? AND start_date < ?", Date.study_year( year ), Date.study_year( year +1 ))
  end

  def group
    Group.find_by_id( self.organized_by )
  end

  def currency( member )
    participants.where(:member => member).first.price ||= self.price
  end

  def price=( price )
    price = price.to_s.gsub(',', '.').to_f

    write_attribute(:price, price)
    write attribute(:price, NIL) if price == 0
  end
end
