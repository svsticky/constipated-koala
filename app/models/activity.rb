class Activity < ActiveRecord::Base
  validates :name, presence: true
  validates :start_date, presence: true
#  validates :end_date
#  validates :description
  
  has_attached_file :poster, :styles => { :thumb => ['180', :png], :medium => ['x720', :png], :original => '100%' }
  validates_attachment_content_type :poster, :content_type => 'application/pdf'
#  validates_attachment_size

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants
  
  def currency(member)
    participants.where(:member => member).first.price ||= self.price
  end
end