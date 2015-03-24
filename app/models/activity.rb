class Activity < ActiveRecord::Base
  include Calendar
  
  validates :name, presence: true
  validates :start_date, presence: true

  after_save(on: :create) do
    self.google_id = create_calendar_event self
    self.save!
  end
  
  after_save(on: :update) do
    if update_calendar_event self
      self.save!
    end
  end
    
  has_attached_file :poster, 
	:styles => { :thumb => ['180', :png], :medium => ['x720', :png] }, 
	:processors => [:ghostscript, :thumbnail], 
	:validate_media_type => false,
	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8'}

  validates_attachment_content_type :poster, 
	:content_type => ['application/pdf', 'image/jpeg', 'image/png']

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants

  def currency(member)
    participants.where(:member => member).first.price ||= self.price
  end
end
