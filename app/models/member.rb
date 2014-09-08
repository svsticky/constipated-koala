class Member < ActiveRecord::Base
  validates :first_name, presence: true
  #validates :infix
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, format: { with: /\A[A-Za-z0-9.+-_]+@(?![A-Za-z]*\.?uu\.nl)([A-Za-z]+\.[A-Za-z.]+\z)/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}
  validates :student_id, presence: true, format: { with: /\F?\d{6,7}/ }
  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments

  attr_accessor :tags_name_ids

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

  before_create :before_create

  def phone_number=(phone_number)
    #change landcode to 00 and remove all not numbers
    write_attribute(:phone_number, phone_number.sub('+', '00').gsub(/\D/, ''))
  end

  def postal_code=(postal_code)
    write_attribute(:postal_code, postal_code.sub(' ', ''))
  end

  def gravatar
    Digest::MD5.hexdigest(self.email)
  end

  def self.search(query)
    Member.where("first_name LIKE ? OR last_name like ? OR student_id like ?", "%#{query}%", "%#{query}%", "%#{query}%")
  end

  def before_create
    self.join_date = Time.new
  end
end
