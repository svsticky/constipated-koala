#:nodoc:
class Education < ApplicationRecord
  belongs_to :study
  belongs_to :member

  validates :start_date, presence: true
  # validates :end_date

  validates :status, presence: true
  # validates :study, presence: true
  # validates :member, presence: true

  enum status: [:active, :stopped, :graduated, :inactive]

  def self.find_by_year_and_study_code(year, code)
    study = Study.find_by_code(code)
    return where('extract(year from start_date) = ? AND study_id = ?', year, study.id).first
  end

  before_validation do
    self.start_date = Time.new if start_date.nil?
    self.status = :active if status.nil?
  end

  before_update do
    self.end_date = Time.now if ['stopped', 'graduated'].include?(status) && !end_date_changed?
  end
end
