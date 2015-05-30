class Member < ActiveRecord::Base
  validates :first_name, presence: true
  #validates :infix
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, format: { with: /[A-Za-z0-9.+-_]+@(?![A-Za-z]*\.?uu\.nl)([A-Za-z0-9.+-_]+\.[A-Za-z.]+)/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}
  
  validates :student_id, presence: true, format: { with: /\F?\d{6,7}/ }
  validate :valid_student_id
  
  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments

  attr_accessor :tags_names
  fuzzily_searchable :query
  is_impressionable


  has_many :tags,
    :dependent => :destroy,
    :autosave => true

  accepts_nested_attributes_for :tags,
    :reject_if => :all_blank,
    :allow_destroy => true


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
    
    
  has_one :checkout_balance
  has_many :checkout_cards


  # fix caps
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
    write_attribute(:postal_code, postal_code.upcase.sub(' ', ''))
  end

  def tags_names=(tags)
    Tag.delete_all( :member_id => id, :name => Tag.names.map{ |tag, i| i unless tags.include?(tag) })
    
    tags.each do |tag|
      if tag.empty?
        next
      end
      
      puts Tag.where( :member_id => id, :name => Tag.names[tag] ).first_or_create!
    end
  end

  # return full name
  def name
    if infix.blank?
      return "#{self.first_name} #{self.last_name}"
    end
    
    return "#{self.first_name} #{self.infix} #{self.last_name}"
  end

  # create hash for gravatar
  def gravatar
    return Digest::MD5.hexdigest(self.email)
  end

  before_create do
    self.join_date = Time.new
  end
  
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
  
  def self.search(query, all = false)    
    if query.is_number?
      return Member.where("student_id like ?", "%#{query}%")
    end
    
    all = true if all == 'on'
    all = all.to_b if all.is_a? String
    
    if all
      return Member.find_by_fuzzy_query(query)
    end
    
    return Member.currently_active.find_by_fuzzy_query(query)
  end
  
  # guery for fuzzy search 
  def query 
    "#{self.first_name} #{self.last_name} #{self.student_id}"
  end
  
  def query_changed?
    first_name_changed? || infix_changed? || last_name_changed? || student_id_changed?
  end

  # update studies based on studystatus output
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
      
#       # if gametech also allow
#       if education.nil? && code == 'INCA'
#         education = self.educations.find_by_start_date_and_study_code(start_date, 'GT')
#       end
      
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
      unless studies.map{ |string| "#{string.split(/, /)[0]} | #{string.split(/, /)[1]}" }.include?("#{education.study.code} | #{education.start_date.year}")
        puts " - #{education.study.code}"
        education.destroy
      end
    end
  end
  
  private 
  def self.currently_active
    return Member.where( :id => ( Education.select( :member_id ).where( 'status = 0' ) + Tag.select( :member_id ).where( :name => Tag.active_by_tag ) ).map{ | i | i.member_id } )
  end
  
  def valid_student_id
    numbers = student_id.split("").map(&:to_i).reverse

    sum = 0
    numbers.each_with_index do |digit, i|
      i = i+1
      sum += digit * i
    end

    if sum % 11 != 0
      errors.add :student_id, I18n.t('activerecord.errors.models.member.attributes.student_id.elfproef')
    end
  end
end
