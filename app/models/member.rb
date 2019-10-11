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
  validates :emergency_phone_number, :allow_blank => true, phone_number: true
  validates :emergency_phone_number, presence: true, if: :underage?

  validates :email, presence: true, uniqueness: { :case_sensitive => false }, format: { with: /\A.+@(?!(.+\.)*uu\.nl\z).+\..+\z/i }

  # An attr_accessor is basically a variable attached to the model but not stored in the database
  attr_accessor :require_student_id
  validates :student_id, presence: false, uniqueness: true, :allow_blank => true, format: { with: /\F?\d{6,7}/ }
  validate :valid_student_id

  validates :birth_date, presence: true
  validates :join_date, presence: true

  enum consent: [:pending, :yearly, :indefinite]

  fuzzily_searchable :query
  is_impressionable :dependent => :ignore

  # NOTE: prepend true is required, so that it is executed before dependent => destroy
  before_destroy :before_destroy, prepend: true

  # In the model relations are defined (but created in the migration) so that you don't have to do an additional query for for example tags, using these relations rails does the queries for you
  # `delete_all` is used because there is no primary key, poor choice on my end
  has_many :tags, :dependent => :delete_all, :autosave => true
  accepts_nested_attributes_for :tags, :reject_if => :all_blank, :allow_destroy => true

  has_many :checkout_cards, :dependent => :destroy
  has_one :checkout_balance, :dependent => :nullify

  has_many :educations, :dependent => :nullify
  has_many :studies, :through => :educations
  accepts_nested_attributes_for :educations,
                                :reject_if => proc { |attributes| attributes['study_id'].blank? && attributes['status'].blank? },
                                :allow_destroy => true

  has_many :participants, :dependent => :nullify
  has_many :activities, :through => :participants

  has_many :confirmed_activities,
           -> { where(participants: { reservist: false }) },
           :through => :participants,
           :source => :activity
  has_many :reservist_activities,
           -> { where(participants: { reservist: true }) },
           :through => :participants,
           :source => :activity
  has_many :unpaid_activities,
           -> { where('participants.reservist IS FALSE AND ( (activities.price IS NOT NULL AND participants.paid IS FALSE AND (participants.price IS NULL OR participants.price > 0) ) OR ( activities.price IS NULL AND participants.paid IS FALSE AND participants.price IS NOT NULL))') },
           :through => :participants,
           :source => :activity

  has_many :group_members, :dependent => :nullify
  has_many :groups, :through => :group_members

  has_one :user, as: :credentials, :dependent => :destroy

  scope :studying, -> { where(id: Education.where(status: :active)) }
  scope :alumni, -> { where.not(id: Education.where(status: :active)) }

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

      puts Tag.where(:member_id => id, :name => Tag.names[tag]).first_or_create!
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

        groups[group_member.group.id][:positions].push(group_member.position => group_member.year) unless group_member.position.blank? || group_member.group.board?
      end

      groups.merge!(group_member.group.id => { :id => group_member.group.id, :name => group_member.group.name, :years => [group_member.year], :positions => [group_member.position => group_member.year] }) unless groups.key?(group_member.group.id)
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
    if email_changed?
      # abort email change if email is already used for another account
      if User.exists?(email: email.downcase) || User.exists?(unconfirmed_email: email.downcase)
        errors.add :email, I18n.t('activerecord.errors.models.member.attributes.email.taken')
        raise ActiveRecord::Rollback
      end
    end

    # update consent_at when consent is given
    self.consent_at = Time.now if consent_changed? && %w[indefinite yearly].include?(consent.to_s)
  end

  # Functions starting with self are functions on the model not an instance. For example we can now search for members by calling Member.search with a query
  def self.search(query, offset = 0, limit = 50)
    student_id = query.match(/^\F?\d{6,7}$/i)
    return where("student_id like ?", "%#{ student_id }%") unless student_id.nil?

    phone_number = query.match(/^(?:\+\d{2}|00\d{2}|0)(\d{9})$/)
    return where("phone_number like ?", "%#{ phone_number[1] }") unless phone_number.nil?

    # If query is blank, no need to filter. Default behaviour would be to return Member class, so we override by passing all
    return where(:id => (Education.select(:member_id).where('status = 0').map(&:member_id) + Tag.select(:member_id).where(:name => Tag.active_by_tag).map(&:member_id))) if query.blank?

    records = filter(query)
    return records.find_by_fuzzy_query(query, limit: limit, offset: offset) unless query.blank?

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

  def masters?
    !educations.empty? && educations.any? { |education| Study.find(education.study_id).masters }
  end

  def freshman?
    educations.any? do |education|
      education.status == 'active' && 1.year.ago < education.start_date && !Study.find(education.study_id).masters
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

  # TODO: move search related methods to lib?
  def self.filter(query)
    records = self
    study = query.match(/(studie|study):([A-Za-z-]+)/)

    unless study.nil?
      query.gsub!(/(studie|study):([A-Za-z-]+)/, '')

      code = Study.find_by_code(study[2])

      # Lookup using full names
      if code.nil?
        study_name = Study.all.map { |s| { I18n.t(s.code.downcase, scope: 'activerecord.attributes.study.names').downcase => s.code.downcase } }.find { |hash| hash.keys[0] == study[2].downcase.tr('-', ' ') }
        code = Study.find_by_code(study_name.values[0]) unless study_name.nil?
      end

      records = Member.none if code.nil? # TODO: add active to the selector if status is not in the query
      records = records.where(:id => Education.select(:member_id).where('study_id = ?', code.id)) unless code.nil?
    end

    tag = query.match(/tag:([A-Za-z-]+)/)

    unless tag.nil?
      query.gsub!(/tag:([A-Za-z-]+)/, '')

      tag_name = Tag.names.map { |name| { I18n.t(name[0], scope: 'activerecord.attributes.tag.names').downcase => name[1] } }.find { |hash| hash.keys[0] == name[1].downcase.tr('-', ' ') }

      records = Member.none if tag_name.nil?
      records = records.where(:id => Tag.select(:member_id).where('name = ?', tag_name.values[0])) unless tag_name.nil?
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
          records.where(:id => Education.select(:member_id).where('status = 0 AND study_id = ?', code.id).map(&:member_id))
        else
          records.where(:id => (Education.select(:member_id).where('status = 0').map(&:member_id) + Tag.select(:member_id).where(:name => Tag.active_by_tag).map(&:member_id)))
        end

      elsif status[2].casecmp('alumni').zero?
        records.where.not(:id => Education.select(:member_id).where('status = 0').map(&:member_id))
      elsif status[2].casecmp('studerend').zero?
        records.where(:id => Education.select(:member_id).where('status = 0').map(&:member_id))
      elsif status[2].casecmp('iedereen').zero?
        Member.all
      else
        Member.none
      end

    return records
  end

  def export
    export = attributes.except(:comments)
    export[:educations] = educations.pluck(:id)
    export[:participants] = participants.pluck(:id)
    export[:group_members] = group_members.pluck(:id)
    export[:checkout_balance] = checkout_balance&.id

    export.compact

    yield [export.to_json, Digest::MD5.hexdigest(export.to_s)] if block_given?
  end

  def self.import(import, checksum); end

  def destroyable?
    return false unless unpaid_activities.empty?

    return true
  end

  # Normalize the Member's phone number for use in payment Whatsapps.
  def whatsappable_phone_number
    return unless phone_number.present?

    pn = phone_number.gsub(/\s/, '') # Remove whitespace

    return pn.sub(/^06/, "316") if /^06\d{8}$/.match?(pn) # Replace '06' with '316' if it's a Dutch phone number

    return pn.sub(/^+?(00)?/, '') if /^(\+|00)?316\d{8}$/.match?(pn) # Replace 00316, +316 if it's international notation

    nil
  end

  private

  # NOTE: this doesn't work in a block without prepend:true relations are destroyed before this callback
  def before_destroy
    # check if all activities are paid
    unless unpaid_activities.empty?
      errors.add :participants, I18n.t('activerecord.errors.models.member.attributes.participants.unpaid_activities')
      raise ActiveRecord::Rollback
    end

    # remove reservist
    Participant.where(activity_id: reservist_activities.pluck(:id), member_id: id).destroy_all

    # remove participants of this member for free activities in the future
    Participant.where(activity_id: confirmed_activities.where('activities.price IS NULL AND participants.price IS NULL AND activities.start_date > ?', Date.today).pluck(:id), member_id: id).destroy_all

    # remove all participant notes
    Participant.where(:member_id => id).update_all(notes: nil)

    # set not updated studies to inactive
    Education.where(:member_id => id, :status => :active).update_all(status: :inactive)

    # create transaction for emptying checkout_balance
    CheckoutTransaction.create(checkout_balance: checkout_balance, price: -checkout_balance.balance, payment_method: 'deleted') if checkout_balance.present? && checkout_balance.balance != 0
  end

  # Perform an elfproef to verify the student_id
  def valid_student_id
    # on the intro website student_id is required
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.invalid') if require_student_id && student_id.blank?

    # do not do the elfproef on a foreign student
    return if student_id =~ /\F\d{6}/
    return if student_id.blank?

    numbers = student_id.split("").map(&:to_i).reverse

    sum = 0
    numbers.each_with_index do |digit, i|
      i += 1
      sum += digit * i
    end

    # Errors are added direclty to the model, so it easy to show in the views. We are using I18n for translating purposes, a lot is still hardcoded dutch, but not the intro website and studies
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.elfproef') if sum % 11 != 0
  end
end
