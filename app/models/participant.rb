#:nodoc:
class Participant < ApplicationRecord
  belongs_to :member
  belongs_to :activity

  validates :notes, length: { maximum: 30 }
  validates :notes, presence: true, if: -> { activity.notes_mandatory }

  validate :is_enrollable
  validate :age_restriction

  attr_accessor :notice
  is_impressionable

  scope :upcoming, -> { joins(:activity).where('(activities.end_date IS NULL AND activities.start_date >= ?) OR activities.end_date >= ? AND activities.is_viewable = TRUE', Date.today, Date.today).order(:start_date, :start_time) }
  scope :debt, -> { where(paid: false, reservist: false).joins(:activity).where('activities.start_date < NOW()').sum('case when participants.price IS NULL then activities.price else participants.price end') }

  def price=(price)
    write_attribute(:price, price.to_s.tr(',', '.').to_f) unless price.blank?
    write_attribute(:price, nil) if price.blank?
  end

  # TODO: rename to price?
  def currency
    return activity.price if read_attribute(:price).nil?

    self.price ||= 0
  end

  before_update do
    # if paid, fix price in participant
    self.price = activity.price if paid_changed? && self.price.nil?
  end

  before_validation do
    # if not paid, let the price be default for possible changes
    write_attribute(:price, nil) if activity.price == self.price && !paid
  end

  def reservist!
    # check if member should be a reservist for this activity
    if activity.participant_limit.present? && activity.participant_limit <= activity.attendees.count
      self.reservist = true
      (notice ||= []) << I18n.t(:participant_limit_reached, scope: 'activerecord.errors.models.activity', activity: activity.name)

    elsif !member.masters? && activity.is_masters?
      self.reservist = true
      (notice ||= []) << I18n.t(:participant_no_masters, scope: 'activerecord.errors.models.activity', activity: activity.name)

    elsif !member.freshman? && activity.is_freshmans?
      self.reservist = true
      (notice ||= []) << I18n.t(:participant_no_freshman, scope: 'activerecord.errors.models.activity', activity: activity.name)
    end

    return notice
  end

  private

  def is_enrollable
    errors.add(:base, I18n.t(:not_enrollable, scope: 'activerecord.errors.models.activity')) unless activity.is_enrollable?
    errors.add(:base, I18n.t(:participant_no_student, scope: 'activerecord.errors.models.activity')) unless member.may_enroll?
    errors.add(:base, I18n.t(:participant_suspended, scope: 'activerecord.errors.models.activity')) if member.suspended?
  end

  def age_restriction
    errors.add(:base, I18n.t(:participant_underage, scope: 'activerecord.errors.models.activity', activity: activity.name)) if activity.is_alcoholic? && !member.adult?
  end
end
