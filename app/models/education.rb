class Education < ActiveRecord::Base
  belongs_to :study  
  belongs_to :member

  validates :start_date, presence: true
  #validates :end_date
  
  enum status: [ :active, :stopped, :graduated ]
  
  before_validation do
    if self.start_date.nil?
      self.start_date = Time.new
    end
  end
  
  def self.statusen
    return [[ "studerend", :active ], [ "gestopt", :stopped ], [ "geslaagd", :graduated ]]
  end
  
  def self.find_by_start_date_and_study_code(year, code)
    study = Study.find_by_code(code)
    return where('extract(year from start_date) = ? AND study_id = ?', year, study.id).first
  end
end
