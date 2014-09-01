class Education < ActiveRecord::Base
  belongs_to :study  
  belongs_to :member

  validates :start_date, presence: true
  #validates :end_date
end
