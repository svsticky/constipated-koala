class Activity < ActiveRecord::Base
  validates :name, presence: true
  validates :start_date, presence: true
  #validates :end_date, presence: true

  has_many :participants,
    :dependent => :destroy
  has_many :members, :through => :participants
  
  belongs_to :committee

  def currency(member)
    participants.where(:member => member).first.price ||= self.price
  end
end