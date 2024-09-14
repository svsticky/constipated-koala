# By default, a class begins with a number of validations. student_id is
# special because in the intro website it cannot be empty. However, an admin can
# make it empty.
# The emergency phone number is only required if the member is not an adult
class Member < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true

  validates :phone_number, presence: true, phone_number: true
  validates :emergency_phone_number, allow_blank: true, phone_number: true
  validates :emergency_phone_number, presence: true, if: :underage?

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A.+@(?!(.+\.)*uu\.nl\z).+\..+\z/i }

  # An attr_accessor is basically a variable attached to the model but not stored in the database
  attr_accessor :require_student_id

  validates :student_id, presence: false, uniqueness: true, allow_blank: true, format: { with: /\A\F\d{6}\z|\A\d{7}\z/ }
  validate :valid_student_id

  validates :birth_date, presence: true
  validates :join_date, presence: true

  enum consent: { pending: 0, yearly: 1, indefinite: 2 }
  # NOTE: prepend true is required, so that it is executed before dependent => destroy
  before_destroy :before_destroy, prepend: true
  after_destroy :fire_webhook
  after_save :fire_webhook

  is_impressionable dependent: :ignore

  # In the model relations are defined (but created in the migration) so that you don't have to do an additional query for for example tags, using these relations rails does the queries for you
  # `delete_all` is used because there is no primary key, poor choice on my end
  has_many :tags, dependent: :delete_all, autosave: true
  accepts_nested_attributes_for :tags, reject_if: :all_blank, allow_destroy: true

  has_many :educations, dependent: :nullify
  has_many :studies, through: :educations
  accepts_nested_attributes_for :educations,
                                reject_if: proc { |attributes| attributes['study_id'].blank? && attributes['status'].blank? },
                                allow_destroy: true

  has_many :participants, dependent: :nullify
  has_many :activities, through: :participants
  has_many :payments, dependent: :nullify

  has_many :confirmed_activities,
           -> { where(participants: { reservist: false }) },
           through: :participants,
           source: :activity
  has_many :reservist_activities,
           -> { where(participants: { reservist: true }) },
           through: :participants,
           source: :activity
  has_many :unpaid_activities,
           -> { where('participants.reservist IS FALSE AND activities.is_payable IS TRUE AND ( (activities.price IS NOT NULL AND participants.paid IS FALSE AND (participants.price IS NULL OR participants.price > 0) ) OR ( activities.price IS NULL AND participants.paid IS FALSE AND participants.price IS NOT NULL))') },
           through: :participants,
           source: :activity

  has_many :group_members, dependent: :nullify
  has_many :groups, through: :group_members

  has_one :user, as: :credentials, dependent: :destroy

  # returns a list of all members that have an outstanding payment
  scope :debtors, lambda {
    joins(:unpaid_activities).uniq
  }

  scope :active, lambda {
    where(id: (
    Education.select(:member_id)
     .where('status = 0')
     .map(&:member_id) +
    Tag.select(:member_id)
      .where(name: Tag.active_by_tag)
      .map(&:member_id)
  ))
  }

  scope :studying, -> { where(educations: Education.where(status: :active)) }
  scope :alumni, -> { where.not(educations: Education.where(status: :active)) }

  include PgSearch::Model
  pg_search_scope :search_by_name,
                  against: [:first_name, :infix, :last_name, :phone_number, :email, :student_id],
                  using:
                    { trigram: {
                      only: [:first_name, :last_name, :student_id, :phone_number, :email],
                      threshold: 0.05
                    },
                      tsearch: { prefix: true } }

  # An attribute can be changed on setting, for example the names are starting with a cap
  def first_name=(first_name)
    write_attribute(:first_name, first_name.downcase.titleize)
  end

  def infix=(infix)
    write_attribute(:infix, infix.downcase)
    write_attribute(:infix, nil) if infix.blank?
  end

  def last_name=(last_name)
    write_attribute(:last_name, last_name.downcase.titleize)
  end

  # lowercase on email
  def email=(email)
    user.update(email: email.downcase) if user.present?
    write_attribute(:email, email.downcase) if user.nil?
  end

  def total_outstanding_payments
    return unpaid_activities.map { |activity| participant_by_activity(activity).currency }.sum
  end

  def active?
    return true if educations.any? { |s| ['active'].include?(s.status) }
    return true if tags.any? { |t| ['merit', 'pardon'].include?(t.name) }

    false
  end

  # Returns the participant that belongs to this member and the given activity.
  # Do not pass an activity to this method that this member is not a participant of!
  def participant_by_activity(activity)
    participants.where(activity_id: activity.id).first
  end

  def language
    if user
      user.language
    else
      :nl
    end
  end

  def address=(address)
    write_attribute(:address, address.strip)
  end

  # remove spaces in postal_code
  def postal_code=(postal_code)
    write_attribute(:postal_code, postal_code.upcase.delete(' '))
  end

  def student_id=(student_id)
    write_attribute(:student_id, student_id.upcase)
    write_attribute(:student_id, nil) if student_id.blank?
  end

  def tags_names
    tags.pluck(:name)
  end

  def tags_names=(tags)
    return if id.nil?

    inversetagnames = Tag.names.keys - tags
    self.tags.where(name: inversetagnames).delete_all

    tags.each do |tag|
      next if tag.empty?

      Tag.where(member_id: id, name: Tag.names[tag]).first_or_create!
    end
  end

  # Some other function can improve your life a lot, for example the name function
  def name
    return "#{ first_name } #{ last_name }" if infix.blank?

    return "#{ first_name } #{ infix } #{ last_name }"
  end

  # TODO: refactor
  def groups
    groups = {}

    group_members.order(year: :desc).each do |group_member|
      if groups.key?(group_member.group.id)
        groups[group_member.group.id][:years].push(group_member.year)

        unless group_member.position.blank? || group_member.group.board?
          groups[group_member.group.id][:positions].push(group_member.position => group_member.year)
        end
      end

      unless groups.key?(group_member.group.id)
        groups.merge!(group_member.group.id => { id: group_member.group.id, name: group_member.group.name, years: [group_member.year], positions: [group_member.position => group_member.year] })
      end
    end

    return groups.values
  end

  # Rails also has hooks you can hook on to the process of saving, updating or deleting. Here the join_date is automatically filled in on creating a new member
  # We also check for a duplicate study, and discard the duplicate if found.
  # (Not doing this would lead to a database constraint violation.)
  before_create do
    self.join_date = Time.new if join_date.blank?
    educations[1].destroy if (educations.length > 1) && (educations[0].study_id == educations[1].study_id)
  end

  before_update do
    if email_changed? && (User.exists?(email: email.downcase) || User.exists?(unconfirmed_email: email.downcase))
      errors.add(:email, I18n.t('activerecord.errors.models.member.attributes.email.taken'))
      raise ActiveRecord::Rollback
    end

    # update consent_at when consent is given
    self.consent_at = Time.now if consent_changed? && %w[indefinite yearly].include?(consent.to_s)
  end

  # Functions starting with self are functions on the model not an instance. For example we can now search for members by calling Member.search with a query
  def self.search(query)
    # return all active members if query is empty
    return Member.active if query.blank?

    # Otherwise we apply the filters and perform a fuzzy search on full name, phone number and email address
    records = filter(query)
    return records.search_by_name(query) if query.present?

    return records
  end

  # Query for fuzzy search, this string is used for building indexes for searching
  def query
    "#{ name } #{ email }"
  end

  def query_changed?
    saved_change_to_first_name? || saved_change_to_infix? || saved_change_to_last_name? || saved_change_to_email?
  end

  def underage?
    !adult?
  end

  def master?
    educations.any? do |education|
      education.status == 'active' && Study.find(education.study_id).masters
    end
  end

  def freshman?
    educations.any? do |education|
      education.status == 'active' && 1.year.ago < education.start_date && !Study.find(education.study_id).masters
    end
  end

  def sophomore?
    !freshman? && educations.any? do |education|
      education.status == 'active' && 2.years.ago < education.start_date && !Study.find(education.study_id).masters
    end
  end

  def senior?
    educations.any? do |education|
      education.status == 'active' && 2.years.ago > education.start_date && !Study.find(education.study_id).masters
    end
  end

  # NOTE: return default value if birth date is blank, required for form validation
  def adult?
    return false if birth_date.blank?

    return 18.years.ago >= birth_date
  end

  def enrolled_in_study?
    return Education.exists?(member: self, status: Education.statuses[:active])
  end

  # Member may enroll when currently enrolled in study, or tagged with one of the whitelisting tags.
  def may_enroll?
    return enrolled_in_study? || Tag.exists?(member: self, name: [:pardon, :merit, :donator, :honorary])
  end

  def suspended?
    Tag.exists?(member: self, name: Tag.names[:suspended])
  end

  # TODO: move search related methods to lib?
  def self.filter(query)
    records = self
    study = query.match(/(studie|study):([A-Za-z-]+)/)

    unless study.nil?
      query.gsub!(/(studie|study):([A-Za-z-]+)/, '')

      code = Study.find_by(code: study[2])

      # Lookup using full names
      if code.nil?
        study_name = Study.all.map { |s| { I18n.t(s.code.downcase, scope: 'activerecord.attributes.study.names').downcase => s.code.downcase } }.find { |hash| hash.keys[0] == study[2].downcase.tr('-', ' ') }
        code = Study.find_by(code: study_name.values[0]) unless study_name.nil?
      end

      records = Member.none if code.nil? # TODO: add active to the selector if status is not in the query
      records = records.where(id: Education.select(:member_id).where(study_id: code.id)) unless code.nil?
    end

    tag = query.match(/tag:([A-Za-z-]+)/)

    unless tag.nil?
      query.gsub!(/tag:([A-Za-z-]+)/, '')

      tag_name = Tag.names.map { |name| { I18n.t(name[0], scope: 'activerecord.attributes.tag.names').downcase => name[1] } }.find { |hash| hash.keys[0] == tag[1].downcase.tr('-', ' ') }

      records = Member.none if tag_name.nil?
      records = records.where(id: Tag.select(:member_id).where(name: tag_name.values[0])) unless tag_name.nil?
    end

    year = query.match(/(year|jaargang):(\d+)/)

    unless year.nil?
      query.gsub!(/(year|jaargang):(\d+)/, '')
      records = records.where("join_date >= ? AND join_date < ?", Date.to_date(year[2].to_i), Date.to_date(1 + year[2].to_i))
    end

    status = query.match(/(status|state):([A-Za-z-]+)/)
    query.gsub!(/(status|state):([A-Za-z]+)/, '')

    records =
      if status.nil? || status[2].casecmp('actief').zero?
        # if already filtered on study, that particular study should be active
        if code.present?
          records.where(id: Education.select(:member_id).where('status = 0 AND study_id = ?', code.id).map(&:member_id))
        else
          records.where(id: (Education.select(:member_id).where('status = 0').map(&:member_id) + Tag.select(:member_id).where(name: Tag.active_by_tag).map(&:member_id)))
        end

      elsif status[2].casecmp('alumni').zero?
        records.where.not(id: Education.select(:member_id).where('status = 0').map(&:member_id))
      elsif status[2].casecmp('studerend').zero?
        records.where(id: Education.select(:member_id).where('status = 0').map(&:member_id))
      elsif status[2].casecmp('iedereen').zero?
        Member.all
      else
        Member.none
      end

    return records
  end

  def mailchimp_interests
    return nil if id.nil? || ENV['MAILCHIMP_DATACENTER'].blank? || ENV['MAILCHIMP_DATACENTER'].empty?

    Rails.cache.fetch("members/#{ id }/mailchimp/interests", expires_in: 30.days) do
      response = RestClient.get(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(email.downcase) }?fields=interests",
        Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
        'User-Agent': 'constipated-koala'
      )

      JSON.parse(response.body)['interests']
    rescue RestClient::ResourceNotFound
      return nil
    end
  end

  def export
    export = attributes.except(:comments)
    export[:educations] = educations.pluck(:id)
    export[:participants] = participants.pluck(:id)
    export[:group_members] = group_members.pluck(:id)

    export.compact

    yield([export.to_json, Digest::MD5.hexdigest(export.to_s)]) if block_given?
  end

  def self.import(import, checksum); end

  def destroyable?
    return false unless unpaid_activities.empty?

    return true
  end

  private

  # NOTE: this doesn't work in a block without prepend:true relations are destroyed before this callback
  def before_destroy
    # check if all activities are paid
    unless unpaid_activities.empty?
      errors.add(:participants, I18n.t('activerecord.errors.models.member.attributes.participants.unpaid_activities'))
      raise(ActiveRecord::Rollback)
    end

    # remove reservist
    Participant.where(activity_id: reservist_activities.pluck(:id), member_id: id).destroy_all

    # remove participants of this member for free activities in the future
    Participant.where(activity_id: confirmed_activities.where('activities.price IS NULL AND participants.price IS NULL AND activities.start_date > ?', Date.today).pluck(:id), member_id: id).destroy_all

    # remove all participant notes
    Participant.where(member_id: id).update_all(notes: nil)

    # set not updated studies to inactive
    Education.where(member_id: id, status: :active).update_all(status: :inactive)

    # remove from mailchimp, unless mailchimp env vars not set
    if ENV['MAILCHIMP_DATACENTER'].present?
      RestClient.post(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(email.downcase) }/actions/delete-permanent",
        {},
        Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
        'User-Agent': 'constipated-koala'
      )
    end
  rescue RestClient::BadRequest => e
    logger.debug(JSON.parse(e.response.body))
  rescue RestClient::NotFound
    logger.debug("Unable to delete Mailchimp user: user not found")
  end

  # Perform an elfproef to verify the student_id
  def valid_student_id
    # on the intro website student_id is required
    if require_student_id && student_id.blank?
      errors.add(:student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.invalid'))
    end

    # do not do the elfproef on a foreign student
    return if student_id =~ /\F\d{6}/
    return if student_id.blank?
  end

  def fire_webhook
    WebhookJob.perform_later("member", id)
  end
end
