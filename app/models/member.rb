# By default, a class begins with a number of validations. student_id is
# special because in the intro website it cannot be empty. However, an admin can
# make it empty.
# The emergency phone number is only required if the member is not an adult
#:nodoc:
class Member < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :emergency_phone_number, presence: false, :allow_blank => true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validate  :require_emergency_phone_number
  validates :email, presence: true, uniqueness: { :case_sensitive => false }, format: { with: /\A.+@(?!(.+\.)*uu\.nl\z).+\..+\z/i }
  validates :gender, presence: true, inclusion: { in: %w[m f] }

  # An attr_accessor is basically a variable attached to the model but not stored in the database
  attr_accessor :require_student_id
  validates :student_id, presence: false, uniqueness: true, :allow_blank => true, format: { with: /\F?\d{6,7}/ }
  validate :valid_student_id

  validates :birth_date, presence: true
  validates :join_date, presence: true

  fuzzily_searchable :query
  is_impressionable :dependent => :ignore

  # In the model relations are defined (but created in the migration) so that you don't have to do an additional query for for example tags, using these relations rails does the queries for you
  has_many :tags,
           :dependent => :destroy,
           :autosave => true

  accepts_nested_attributes_for :tags,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_many :checkout_cards,
           :dependent => :destroy
  has_one :checkout_balance,
          :dependent => :destroy

  has_many :educations,
           :dependent => :destroy
  has_many :studies,
           :through => :educations

  accepts_nested_attributes_for :educations,
                                :reject_if => proc { |attributes| attributes['study_id'].blank? },
                                :allow_destroy => true

  has_many :participants,
           :dependent => :destroy
  has_many :activities,
           :through => :participants

  has_many :confirmed_activities,
           -> { where(participants: { reservist: false }) },
           :through => :participants,
           :source => :activity
  has_many :reservist_activities,
           -> { where(participants: { reservist: true }) },
           :through => :participants,
           :source => :activity

  has_many :group_members,
           :dependent => :destroy
  has_many :groups,
           :through => :group_members

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

  # remove nonnumbers and change + to 00
  def phone_number=(phone_number)
    write_attribute(:phone_number, phone_number.sub('+', '00').gsub(/\D/, ''))
  end

  def emergency_phone_number=(emergency_phone_number)
    write_attribute(:emergency_phone_number, emergency_phone_number.sub('+', '00'))
  end

  def require_emergency_phone_number
    return unless :emergency_phone_number.blank?

    errors.add :emergency_phone_number, I18n.t('activerecord.errors.models.member.attributes.emergency_phone_number.not_provided') if underage?
  end

  # lowercase on email
  def email=(email)
    write_attribute(:email, email.downcase)
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

  # If set to true, a User is created after committing
  attr_reader :create_account

  def create_account=(value)
    v = value
    unless value.is_a?(FalseClass) || value.is_a?(TrueClass)
      v = value.to_b # to_b does not exist for booleans, required for handling truthy "0" and "1" from forms.
    end
    @create_account = v
  end

  def tags_names
    tags.pluck(:name)
  end

  def tags_names=(tags)
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

  # create hash for gravatar
  def gravatar
    return Digest::MD5.hexencode(email)
  end

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

  after_commit :create_user, on: :create

  def create_user
    return unless @create_account
    user = User.new
    user.skip_confirmation_notification!
    user.email = email
    user.credentials = self
    user.require_activation!
    user.save
  end

  # Devise uses e-mails for login, and this is the only redundant value in the database. The e-mail, so if someone chooses the change their e-mail the e-mail should also be changed in the user table if they have a login
  before_update do
    if email_changed?

      # abort if email is already used for another account, abort is the only method to brake in future versions
      if User.taken?(email)
        errors.add :email, I18n.t('activerecord.errors.models.member.attributes.email.taken')
        raise ActiveRecord::Rollback
      end

      # find user by old email
      credentials = User.find_by_email(Member.find(id).email)

      unless credentials.nil?
        # update_attribute has no validation so it should be done manually
        credentials.update_attribute('email', email)
        credentials.save
      end
    end
  end

  # destroy account on removal of member
  before_destroy do
    logger.debug inspect

    user = User.find_by_email(email)
    user.delete if user.present?
  end

  # Functions starting with self are functions on the model not an instance. For example we can now search for members by calling Member.search with a query
  def self.search(query)
    student_id = query.match(/^\F?\d{6,7}$/i)
    return where("student_id like ?", "%#{ student_id }%") unless student_id.nil?

    phone_number = query.match(/^(?:\+\d{2}|00\d{2}|0)(\d{9})$/)
    return where("phone_number like ?", "%#{ phone_number[1] }") unless phone_number.nil?

    # If query is blank, no need to filter. Default behaviour would be to return Member class, so we override by passing all
    return where(:id => (Education.select(:member_id).where('status = 0').map(&:member_id) + Tag.select(:member_id).where(:name => Tag.active_by_tag).map(&:member_id))) if query.blank?

    records = filter(query)
    return records.find_by_fuzzy_query(query) unless query.blank?
    return records
  end

  # Query for fuzzy search, this string is used for building indexes for searching
  def query
    "#{ name } #{ email }"
  end

  def query_changed?
    saved_change_to_first_name? || saved_change_to_infix? || saved_change_to_last_name? || saved_change_to_email?
  end

  # Update studies based on studystatus output, the only way to run this function is by the rake task, and it updates the study status of a person, nothing more, nothing less
  def update_studies(studystatus_output)
    result_id, *studies = studystatus_output.split(/; /)
    puts "#{ student_id } returns empty result;" if result_id.blank?

    if student_id != result_id
      logger.error 'Student id received from studystatus is different'
      return
    end

    if studies == 'NOT FOUND'
      puts "#{ student_id } not found"
      return
    end

    studies.each do |study|
      code, year, status, end_date = study.split(/, /)

      if Study.find_by_code(code).nil?
        puts "#{ code } is not found as a study in the database"
        next
      end

      education = educations.find_by_year_and_study_code(year, code)

      # If not found as informatica, we can try for gametech. This only works if the student filled in GT from the subscribtion
      if education.nil? && code == 'INCA'
        education = educations.find_by_year_and_study_code(year, 'GT')
        code = 'GT'
      end

      if education.nil?
        education = Education.new(:member => self, :study => Study.find_by_code(code), :start_date => Date.new(year.to_i, 9, 1))
        puts " + #{ code } (#{ status })"
      else
        puts " ± #{ code } (#{ status })"
      end

      if status.eql?('gestopt')
        education.update_attribute('status', 'stopped')
      elsif status.eql?('afgestudeerd')
        education.update_attribute('status', 'graduated')
      elsif status.eql?('actief')
        education.update_attribute('status', 'active')
      else
        next
      end

      # TODO: check if student joined this year, has no studies, and study is a bachelor

      education.update_attribute('end_date', Date.parse(end_date.split(' ')[1])) if status != 'actief' && end_date.present? && end_date.split(' ')[1].present?
      education.save
    end

    # remove studies no longer present
    educations.each do |education|
      check = "#{ education.study.code } | #{ education.start_date.year }"
      check = "INCA | #{ education.start_date.year }" if education.study.code == 'GT' # NOTE dirty fix for gametechers

      unless studies.map { |string| "#{ string.split(/, /)[0] } | #{ string.split(/, /)[1] }" }.include?(check)
        puts " - #{ education.study.code }"
        education.destroy
      end
    end
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

  def adult?
    # return default value if birth date is blank, required for form validation
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

  def unpaid_activities
    # All participants who will receive payment reminders
    participants.joins(:activity).where('
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

  # Perform an elfproef to verify the student_id

  private

  def valid_student_id
    # on the intro website student_id is required
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.invalid') if require_student_id && student_id.blank?

    # do not do the elfproef if a foreign student
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
