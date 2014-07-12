class Participant < ActiveRecord::Base
  validates :paid, presence: true

  belongs_to :member
  belongs_to :activity
  
  def currency
    self.price ||= activity.price
  end
end