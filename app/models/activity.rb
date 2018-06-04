# Represents an activity in the database.
#:nodoc:
class Activity < ApplicationRecord
  validates :name, presence: true

  validates :start_date, presence: true
  validate :end_is_possible, unless: proc { |a| a.start_date.nil? }
  validate :unenroll_before_start, unless: proc { |a| a.unenroll_date.nil? }
  validates :participant_limit, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    allow_nil: true
  }
  validates :price, numericality: {
    greater_than_or_equal_to: 0
  }

  # Disabled validations
  # validates :end_date
  # validates :description
  # validates :unenroll_date

  is_impressionable

  after_update :enroll_reservists, if: proc { |a| a.saved_change_to_participant_limit }

  has_attached_file :poster,
                    :styles => {
                      :thumb => ['180', :png],
                      :medium => ['x1080', :png]
                    },
                    :processors => [:ghostscript, :thumbnail],
                    :validate_media_type => false,
                    :convert_options => {
                      :all => '-colorspace CMYK -flatten -quality 100 -density 8'
                    }

  validates_attachment_content_type :poster, :content_type => 'application/pdf'

  has_one :group, :as => :organized_by

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants

  before_validation do
    self.start_date = Date.today if start_date.blank?
    self.end_date = start_date if end_date.blank?
    self.unenroll_date = start_date - 2.days if unenroll_date.blank?
  end

  def name=(name)
    write_attribute(:name, name.strip)
  end

  def self.study_year(year)
    year = year.blank? ? Date.today.study_year : year.to_i
    where('start_date >= ? AND start_date < ?', Date.to_date(year), Date.to_date(year + 1))
  end

  def self.debtors
    # All participants who will receive payment reminders
    joins(:participants).where('
      activities.start_date <= ?
      AND
      participants.reservist IS FALSE
      AND
       (
        (activities.price IS NOT NULL
         AND
         participants.paid IS FALSE
         AND
         (participants.price IS NULL
          OR
          participants.price > 0)
        )
        OR
        (
         activities.price IS NULL
         AND
         participants.paid IS FALSE
         AND
         participants.price IS NOT NULL
        )
      )', Date.today).distinct
  end

  def payment_mail_recipients
    participants
      .order('members.first_name', 'members.last_name')
      .joins(:member)
      .where('participants.paid = FALSE
                AND
                participants.reservist = FALSE
                AND
                (participants.price IS NULL
                 OR
                 participants.price > 0
                )')
      .select(:id, :member_id, :first_name, :email)
  end

  def ordered_attendees
    attendees
      .order('members.first_name', 'members.last_name')
      .joins(:member)
  end

  def ordered_reservists
    reservists
      .order(id: :asc) # Explicit ordering: first come, first serve
      .joins(:member)
  end

  # Prevents duplication in hiding information in the API if notes_public is false.
  def participant_filter(participants)
    if notes_public
      participants.map { |p| { name: p.member.name, notes: p.notes } }
    else
      participants.map { |p| { name: p.member.name } }
    end
  end

  def group
    Group.find_by_id organized_by
  end

  def currency(member)
    participants.where(:member => member).first.price ||= price
  end

  def attendees
    participants.where(reservist: false)
  end

  def reservists
    participants.where(reservist: true)
  end

  def price
    return 0 if read_attribute(:price).nil?
    return read_attribute(:price)
  end

  def price=(price)
    price = price.to_s.tr(',', '.').to_f
    write_attribute(:price, price)
    write_attribute(:price, nil) if price == 0
  end

  def self.combine_dt(date, time)
    return Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec) if time
    return Time.zone.local(date.year, date.month, date.day) if date

    return nil
  end

  def paid_sum
    return participants.where(:reservist => false, :paid => true).sum(:price) +
           participants.where(:reservist => false, :paid => true, :price => nil).count * price
  end

  def price_sum
    return participants.where(:reservist => false).sum(:price) +
           participants.where(:reservist => false, :price => nil).count * price
  end

  def start
    Activity.combine_dt(start_date, start_time)
  end

  def end
    Activity.combine_dt(end_date, end_time)
  end

  def end_is_possible
    errors.add(:end_date, :before_start_date) if end_date < start_date

    errors.add(:start_time, :blank_and_end_time) if start_time.nil? &&
                                                    end_time.present?

    errors.add(:end_time, :before_start_time) if end_time.present? &&
                                                 end_date == start_date &&
                                                 end_time < start_time
  end

  def unenroll_before_start
    errors.add(:unenroll_date, :after_start_date) if start_date < unenroll_date
  end

  def enroll_reservists
    # Check whether it is possible to enroll some reservists
    # (participants.count < participant_limit), and then do that.
    #
    # Will not run if the unenroll_date has passed.
    #
    # This uses a magic instance variable to list any reservists that were
    # enrolled, ignore at your own risk.
    return unless is_enrollable &&
                  unenroll_date.end_of_day >= Time.now
    
    return unless reservists.count > 0

    spots = 0
    spots = reservists.count if participant_limit.nil?

    spots = participant_limit - attendees.count if attendees.count <
                                                   participant_limit

    reservistpool = reservists.to_a # to_a because in-place `select!`

    # Filter non-masters if masters-only, non-freshmen if freshman-only.
    # Note: this will leave nobody if someone enables both is_masters and
    # is_freshmans, as freshman? explicitly rejects masters.
    reservistpool.select! { |m| m.member.masters? } if is_masters?
    reservistpool.select! { |m| m.member.freshman? } if is_freshmans?

    luckypeople = reservistpool.first(spots)

    luckypeople.each do |peep|
      peep.update!(reservist: false)
      Mailings::Participants.enrolled(peep).deliver_later
    end

    @magic_enrolled_reservists = luckypeople
  end

  def participant_counts
    # Helper method to get counts of both types of Participants for this activity at once
    [participants.count, attendees.count, reservists.count]
  end

  def fullness
    # Helper method for use in displaying the remaining spots etc. Used both in API and in the activities view.
    return '' unless is_enrollable

    # Use attendees.count instead of participants.count because in case of masters activities there can be reservists even if activity isn't full.
    if participant_limit
      return 'VOL!' if attendees.count >= participant_limit
      return "#{ attendees.count }/#{ participant_limit }"
    end

    return attendees.count.to_s
  end

  def ended?
    (end_time && self.end < Time.zone.now) ||
      (end_time.nil? && start < Time.zone.now)
  end
end
