class Education < ActiveRecord::Base
  belongs_to :study
  belongs_to :member

  validates :start_date, presence: true
  #validates :end_date

  validates :status, presence: true
  validates :study, presence: true
  validates :member, presence: true

  enum status: [ :active, :stopped, :graduated ]

  def self.find_by_start_date_and_study_code(year, code)
    study = Study.find_by_code(code)
    return where('extract(year from start_date) = ? AND study_id = ?', year, study.id).first
  end

  before_validation do
    self.start_date = Time.new if self.start_date.nil?
    self.status = :active if self.status.nil?
  end
end
