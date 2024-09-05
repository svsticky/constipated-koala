require 'icalendar' # https://github.com/icalendar/icalendar

# Represents an activity in the database.
#:nodoc:
class Activity < ApplicationRecord
  validates :name, presence: true
  validates :name, length: { maximum: 52 }

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

  validate :content_type
  def content_type
    # NOTE: required to be an pdf, jpg, png or gif but file can also be empty
    return unless poster.attached?

    if poster.attached? && !poster.content_type.in?([
                                                      'application/pdf', 'image/jpeg', 'image/png', 'image/gif'
                                                    ])
      errors.add(:poster, I18n.t(
                            'activerecord.errors.unsupported_content_type',
                            type: poster.content_type.to_s,
                            allowed: 'application/pdf image/jpeg image/png image/gif'
                          ))
    end
  end

  validates :notes, presence: true, if: proc { |a| a.notes_public? || a.notes_mandatory? }

  is_impressionable

  before_validation :validate_enrollable
  after_update :enroll_reservists!, if: proc { |a| a.saved_change_to_participant_limit }
  before_destroy :rewrite_logs_before_delete, prepend: true

  has_one_attached :poster
  has_one :group, as: :organized_by

  has_many :participants, dependent: :destroy
  has_many :members, through: :participants

  attr_accessor :magic_enrolled_reservists

  scope :late_unpayable, lambda {
    # All participants who will receive payment reminders
    where('NOT activities.is_payable AND activities.start_date <= ?', Date.today).joins(:participants)
                                                                                 .where('participants.reservist IS FALSE
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
        )').distinct
  }

  before_validation do
    self.start_date = Date.today if start_date.blank?
    self.end_date = start_date if end_date.blank?
    self.unenroll_date = start_date - 2.days if unenroll_date.blank?
  end

  def name=(name)
    write_attribute(:name, name.strip)
  end

  # When the activity is set to payable we store the date so we can track for how long people have been able to pay.
  # This only updates when the previous value was false and it becomes true
  def is_payable=(is_payable)
    self[:payable_updated_at] = Date.today if !self[:is_payable] && is_payable
    write_attribute(:is_payable, is_payable)
  end

  def escaped_name
    # Strip an activity name from all characters banks do not support

    # Remove all non-ascii characters (no language extension)
    ascii = name.encode('ASCII', invalid: :replace, undef: :replace, replace: '')

    # Remove the other illegal characters
    # Non-printable characters are ignored
    # source: https://www.sepaforcorporates.com/sepa-implementation/valid-xml-characters-sepa-payments/
    return ascii.delete("!\"#$%&*;<=>@[\\]^_`{|}~")
  end

  def self.study_year(year)
    year = year.blank? ? Date.today.study_year : year.to_i
    where('start_date >= ? AND start_date < ?', Date.to_date(year), Date.to_date(year + 1))
  end

  def self.debtors
    # All participants who will receive payment reminders
    joins(:participants).where('
      activities.is_payable
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
      )').distinct
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
    Group.find_by(id: organized_by)
  end

  def currency(member)
    participants.where(member: member).first.price ||= price
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
    return participants.where(reservist: false, paid: true).sum(:price) +
           (participants.where(reservist: false, paid: true, price: nil).count * price)
  end

  def price_sum
    return participants.where(reservist: false).sum(:price) +
           (participants.where(reservist: false, price: nil).count * price)
  end

  def start
    Activity.combine_dt(start_date, start_time)
  end

  def end
    Activity.combine_dt(end_date, end_time)
  end

  def whole_day?
    return !start_time && !end_time
  end

  # Format a datetime in UTC for the iCalendar format
  def format_utc(datetime)
    datetime.utc.strftime('%Y%m%dT%H%M%SZ')
  end

  # Format a datetime to a whole day for the iCalendar format
  def format_whole_day(datetime)
    datetime.utc.strftime('%Y%m%d')
    # For whole days, do not convert to UTC, because if 'start' is a date, it's
    # time will be 00:00:00 and will be converted to the previous day
  end

  # Properly format the start datetime, depending on if the event is a whole day event or not
  def calendar_start
    normalised_start = start_time ? start : start.change(hour: 0, min: 0) # Won't have effect if whole_day
    return whole_day? ? format_whole_day(normalised_start) : format_utc(normalised_start)
  end

  # Properly format the end datetime, depending on if the event is a whole day event or not
  def calendar_end
    normalised_end = end_time ? self.end : self.end.change(hour: 23, min: 59) # Won't have effect if whole_day
    return whole_day? ? format_whole_day(normalised_end + 1.day) : format_utc(normalised_end) # +1 day, end is exclusive
  end

  def when_open
    Activity.combine_dt(open_date, open_time)
  end

  def open_present?
    return open_date.present? && open_time.present?
  end

  def open?
    return is_enrollable && (!open_present? || DateTime.now > when_open)
  end

  # used for the is_enrollable checkmark
  def validate_enrollable
    unless open_present? && DateTime.now < when_open
      # activity does not have open date or is already opened
      return
    end

    if is_enrollable # we want to open the activity anyway (override)
      self.open_date = nil
      self.open_time = nil
    else
      # open? will give the checkmark a value of false, but we want is_enrollable to stay true
      # as long as there is an open date pending
      self.is_enrollable = true
    end
  end

  def end_is_possible
    errors.add(:end_date, :before_start_date) if end_date < start_date

    errors.add(:start_time, :blank_and_end_time) if start_time.nil? &&
                                                    end_time.present?

    errors.add(:end_time, :before_start_time) if start_time.present? &&
                                                 end_time.present? &&
                                                 end_date == start_date &&
                                                 end_time < start_time
  end

  def unenroll_before_start
    errors.add(:unenroll_date, :after_start_date) if start_date < unenroll_date
  end

  def enroll_reservists!
    # Check whether it is possible to enroll some reservists
    # (participants.count < participant_limit), and then do that.
    #
    # Will not run if the unenroll_date has passed.
    #
    # This uses a magic instance variable to list any reservists that were
    # enrolled, ignore at your own risk.
    return unless open? && unenroll_date.end_of_day >= Time.now

    return unless reservists.count > 0

    spots = 0

    spots = reservists.count if participant_limit.nil?
    spots = participant_limit - attendees.count if participant_limit.present? && attendees.count < participant_limit

    return if spots == 0

    reservistpool = reservists.order(:created_at).to_a # to_a because in-place `select!`

    # Filter non-masters if masters-only, non-freshmen if freshman-only.
    if filters?
      pool = []
      pool += reservistpool.select { |m| m.member.master? } if is_masters?
      pool += reservistpool.select { |m| m.member.freshman? } if is_freshmans?
      pool += reservistpool.select { |m| m.member.sophomore? } if is_sophomores?
      pool += reservistpool.select { |m| m.member.senior? } if is_seniors?
      reservistpool = pool.sort_by { |participant| [participant.created_at] }
    end
    luckypeople = reservistpool.first(spots)

    Participant.where(id: luckypeople.pluck(:id)).update_all(reservist: false)
    luckypeople.each { |p| Mailings::Participants.enrolled(p).deliver_later }
    @magic_enrolled_reservists = luckypeople
    return luckypeople
  end

  def filters?
    is_freshmans? || is_sophomores? || is_seniors? || is_masters?
  end

  def participant_counts
    # Helper method to get counts of both types of Participants for this activity at once
    [participants.count, attendees.count, reservists.count]
  end

  def fullness
    # Helper method for use in displaying the remaining spots etc. Used both in API and in the activities view.
    return '' unless open?

    # Use attendees.count instead of participants.count because in case of filtered activities
    # there can be reservists even if activity isn't full.
    if participant_limit
      return I18n.t('members.activities.full') if attendees.count >= participant_limit

      return "#{ attendees.count }/#{ participant_limit }"
    end

    attendees.count.to_s
  end

  def ended?
    (end_time && self.end < Time.zone.now) ||
      (end_time.nil? && start < Time.zone.now)
  end

  def poster_representation
    return unless poster.attached?

    if poster.content_type.to_s == 'image/gif'
      poster
    else
      poster.representation(resize: '764x1080!')
    end
  end

  def thumbnail_representation
    return unless poster.attached?

    if poster.content_type.to_s == 'image/gif'
      poster
    else
      poster.representation(resize: '254x360!')
    end
  end

  def activity_url
    return "https://koala.svsticky.nl/activities/#{ id }"
  end

  def description_localised(locale)
    return locale == :nl ? description_nl : description_en
  end

  # This generates an URL representing a calendar activity template, filled with data from the koala activity
  def google_event(loc = nil)
    return nil if start.nil? || self.end.nil?

    loc = I18n.locale if loc.nil?

    disclaimer_en = "[Data on this activity may be outdated, as it was addes as a one-time copy of the information " \
                    "given at that time]"
    disclaimer_nl = "[Gegevens in deze afspraak kunnen outdated zijn, omdat deze waren toegevoegd als een eenmalig " \
                    "kopie van wat toen bekend was]"
    disclaimer = loc == :nl ? disclaimer_nl : disclaimer_en

    description = "#{ activity_url }\n\n#{ description_localised(loc) }\n\n#{ disclaimer }"
    uri_name = URI.encode_www_form_component(name)
    uri_description = URI.encode_www_form_component(description)
    uri_location = URI.encode_www_form_component(location)
    return "https://www.google.com/calendar/render?action=TEMPLATE&text=#{ uri_name }&dates=#{ calendar_start }%2F#{ calendar_end }&details=#{ uri_description }&location=#{ uri_location }&sf=true&output=xml"
  end

  # Add a message containing the Activity's id and name to the logs before deleting the activity.
  def rewrite_logs_before_delete
    impressions.update_all(message: "#{ name } (#{ id })")
  end

  # Pass loc to force a specific language
  def whatsapp_message(loc)
    pc = if price <= 0
           I18n.t('activerecord.missing_value_placeholders.activity.free', locale: loc)
         else
           "€#{ price }"
         end

    return I18n.t('admin.activities.wa_msg',
                  act_name: name,
                  datetime: gen_time_string(loc),
                  location: location,
                  price: pc,
                  url: activity_url,
                  description: description_localised(loc),
                  locale: loc)
  end

  # Generate the time string for the whatsapp message eg: Sunday 24 September 05:00 - 06:00
  def gen_time_string(loc)
    fmt_dt = ->(dt) { dt.nil? ? "" : " #{ I18n.l(dt, format: :name_day_month, locale: loc) }" }
    fmt_tm = ->(tm) { tm.nil? ? "" : " #{ I18n.l(tm, format: :short) }" }

    end_dt = start_date == end_date ? "" : fmt_dt.call(end_date)
    edt = end_dt + fmt_tm.call(end_time)
    edt = edt.present? ? " -#{ edt }" : ""

    return fmt_dt.call(start_date) + fmt_tm.call(start_time) + edt
  end

  # Converts a sticky activity to an iCalendar event
  def to_calendar_event(locale)
    event = Icalendar::Event.new
    event.uid = id.to_s

    if whole_day? # Adhire to the iCalendar spec
      event.dtstart = Icalendar::Values::Date.new(calendar_start)
      event.dtstart.ical_param("VALUE", "DATE")
      event.dtend = Icalendar::Values::Date.new(calendar_end)
      event.dtend.ical_param("VALUE", "DATE")
    else
      event.dtstart = calendar_start
      event.dtend = calendar_end
    end

    event.summary = name
    event.description = description_localised(locale)
    event.location = location
    return event
  end
end
