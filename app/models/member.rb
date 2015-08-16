# Default a class begins with a number of validations. student_id is special because in the intro website it cannot be empty. However an admin can make it empty
class Member < ActiveRecord::Base
  validates :first_name, presence: true
  #validates :infix
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, uniqueness: { :case_sensitive => false }, format: { with: /[A-Za-z0-9.+-_]+@(?![A-Za-z]*\.?uu\.nl)([A-Za-z0-9.+-_]+\.[A-Za-z.]+)/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}

  # An attr_accessor is basically a variable attached to the model but not stored in the database
  attr_accessor :require_student_id
  validates :student_id, presence: false, uniqueness: true, :allow_blank => true, format: { with: /\F?\d{6,7}/ }
  validate :valid_student_id

  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments

  attr_accessor :tags_names
  fuzzily_searchable :query
  is_impressionable

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
    :reject_if => :all_blank,
    :allow_destroy => true

  has_many :participants,
    :dependent => :destroy
  has_many :activities,
    :through => :participants

  has_many :group_members,
    :dependent => :destroy
  has_many :groups,
    :through => :group_members

  # An attribute can be changed on setting, for example the names are starting with a cap
  def first_name=(first_name)
    write_attribute(:first_name, first_name.capitalize)
  end

  def last_name=(last_name)
    write_attribute(:last_name, last_name.capitalize)
  end

  # remove nonnumbers and change + to 00
  def phone_number=(phone_number)
    write_attribute(:phone_number, phone_number.sub('+', '00').gsub(/\D/, ''))
  end

  # remove spaces in postal_code
  def postal_code=(postal_code)
    write_attribute(:postal_code, postal_code.upcase.gsub(' ', ''))
  end

  def tags_names=(tags)
    Tag.delete_all( :member_id => id, :name => Tag.names.map{ |tag, i| i unless tags.include?(tag) })

    tags.each do |tag|
      next if tag.empty?

      puts Tag.where( :member_id => id, :name => Tag.names[tag] ).first_or_create!
    end
  end

  # Some other function can improve your life a lot, for example the name function
  def name
    return "#{self.first_name} #{self.last_name}" if infix.blank?
    return "#{self.first_name} #{self.infix} #{self.last_name}"
  end

  # create hash for gravatar
  def gravatar
    return Digest::MD5.hexdigest(self.email)
  end

  def groups
    groups = Hash.new

    group_members.order( year: :desc ).each do |group_member|
      if groups.has_key?( group_member.group.id )
        groups[ group_member.group.id ][ :years ].push( group_member.year )

        groups[ group_member.group.id ][ :positions ].push( group_member.position => group_member.year ) unless group_member.position.blank? || group_member.group.board?
      end

      groups.merge!( group_member.group.id => { :id => group_member.group.id, :name => group_member.group.name, :years => [ group_member.year ], :positions => [ group_member.position => group_member.year ]} ) unless groups.has_key?( group_member.group.id )
    end

    return groups.values
  end

  # Rails also has hooks you can hook on to the process of saving, updating or deleting. Here the join_date is automatically filled in on creating a new member
  before_create do
    self.join_date = Time.new
  end

  # Devise uses e-mails for login, and this is the only redundant value in the database. The e-mail, so if someone chooses the change their e-mail the e-mail should also be changed in the user table if they have a login
  before_update do
    if email_changed?
      credentials = User.find_by_email( Member.find(self.id).email )

      puts 'email has changed!'

      if !credentials.nil?
        credentials.update_attribute('email', self.email)
        credentials.save
      end
    end
  end

  # Functions starting with self are functions on the model not an instance. For example we can now search for members by calling Member.search with a query
  def self.search(query, all = false)
    return self.where("student_id like ?", "%#{query}%") if query.is_number?

    all = true if all == 'on'
    all = all.to_b if all.is_a? String

    # If query is blank, no need to filter. Default behaviour would be to return Member class, so we override by passing all
    return Member.all if query.blank? && all
    return Member.currently_active if query.blank?

    records = self.currently_active.filter( query ) unless all
    records = self.filter( query ) if all

    return records if query.blank?
    return records.find_by_fuzzy_query( query )
  end

  # Query for fuzzy search, this string is used for building indexes for searching
  def query
    "#{self.first_name} #{self.last_name} #{self.student_id}"
  end

  def query_changed?
    first_name_changed? || infix_changed? || last_name_changed? || student_id_changed?
  end

  # Update studies based on studystatus output, the only way to run this function is by the rake task, and it updates the study status of a person, nothing more, nothing less
  def update_studies(studystatus_output)
    result_id, *studies = studystatus_output.split(/; /)

    if self.student_id != result_id
      logger.error 'Student id received from studystatus is different'
      return
    end

    if studies == 'NOT FOUND'
      puts "#{student_id} not found"
      return
    end

    for study in studies do
      code, start_date, status, end_date = study.split(/, /)

      if Study.find_by_code(code).nil?
        puts "#{code} is not found as a study in the database"
        next
      end

      education = self.educations.find_by_start_date_and_study_code(start_date, code)

      # If not found as informatica, we can try for gametech. This only works if the student filled in GT from the subscribtion
      if education.nil? && code == 'INCA'
        education = self.educations.find_by_start_date_and_study_code(start_date, 'GT')
        code = 'GT'
      end

      if education.nil?
        education = Education.new( :member => self, :study => Study.find_by_code(code), :start_date => Date.new(start_date.to_i, 9, 1))
        puts " + #{code} (#{status})"
      else
        puts " ± #{code} (#{status})"
      end

      if !end_date.nil? && !end_date[5..-1].nil?
        education.update_attribute('end_date', Date.parse(end_date[5..-1]))
      end

      if status.eql?('gestopt')
        education.update_attribute('status', 'stopped')
      elsif status.eql?('afgestudeerd')
        education.update_attribute('status', 'graduated')
      else #actief
        education.update_attribute('status', 'active')
      end

      education.save!
    end

    # remove studies no longer present
    for education in self.educations do
      check = "#{education.study.code} | #{education.start_date.year}"
      check = "INCA | #{education.start_date.year}" if education.study.code == 'GT' #dirty fix for gametechers

      unless studies.map{ |string| "#{string.split(/, /)[0]} | #{string.split(/, /)[1]}" }.include?( check )
        puts " - #{education.study.code}"
        education.destroy
      end
    end
  end

  # Private function cannot be called from outside this class
  private
  # An student is active if he is currently studying or has a tag which makes him active like a pardon
  def self.currently_active
    return self.where( :id => ( Education.select( :member_id ).where( 'status = 0' ) + Tag.select( :member_id ).where( :name => Tag.active_by_tag ) ).map{ | i | i.member_id } )
  end

  def self.filter( query )
    records = self
    study = query.match /(studie|study):([A-Za-z-]+)/

    unless study.nil?
      query.gsub! /(studie|study):([A-Za-z-]+)/, ''

      code = Study.find_by_code( study[2] )

      # Lookup using full names
      if code.nil?
        study_name = Study.all.map{ |study| { I18n.t(study.code.downcase, scope: 'activerecord.attributes.study.names').downcase => study.code.downcase} }.find{ |hash| hash.keys[0] == study[2].downcase.gsub( '-', ' ' ) }
        code = Study.find_by_code( study_name.values[0] ) unless study_name.nil?
      end

      records = Member.none if code.nil?
      records = records.where( :id => Education.select( :member_id ).where( 'study_id = ?', code.id )) unless code.nil?
    end

    tag = query.match /tag:([A-Za-z-]+)/

    unless tag.nil?
      query.gsub! /tag:([A-Za-z-]+)/, ''

      tag_name = Tag.names.map{ |tag| { I18n.t(tag[0], scope: 'activerecord.attributes.tag.names').downcase => tag[1]} }.find{ |hash| hash.keys[0] == tag[1].downcase.gsub( '-', ' ' ) }

      records = Member.none if tag_name.nil?
      records = records.where( :id => Tag.select( :member_id ).where( 'name = ?', tag_name.values[0] )) unless tag_name.nil?
    end

    year = query.match /(year|jaargang):(\d+)/

    unless year.nil?
      query.gsub! /(year|jaargang):(\d+)/, ''
      records = records.where("join_date >= ? AND join_date < ?", Date.study_year( year[2].to_i ), Date.study_year( 1+ year[2].to_i ))
    end

    return records
  end

  # Perform an elfproef to verify the student_id
  def valid_student_id
    # on the intro website student_id is required
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.invalid') if require_student_id && student_id.blank?

    # do not do the elfproef if a foreign student
    return if ( student_id =~ /\F\d{6}/)

    numbers = student_id.split("").map(&:to_i).reverse

    sum = 0
    numbers.each_with_index do |digit, i|
      i = i+1
      sum += digit * i
    end

    # Errors are added direclty to the model, so it easy to show in the views. We are using I18n for translating purposes, a lot is still hardcoded dutch, but not the intro website and studies
    errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.elfproef') if sum % 11 != 0
  end
end
