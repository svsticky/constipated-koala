class Member < ActiveRecord::Base
  validates :first_name, presence: true
  #validates :infix
  validates :last_name, presence: true
  validates :address, presence: true, format: { with: /\A\D*\Z/ }
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, format: { with: /\A[^@]+@[^@]+\.[^@]+\z/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}
  validates :student_id, presence: true, format: { with: /\A\d{6,7}\z/ }
  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments
  
  attr_accessor :tags_name_ids
  
  has_many :educations, 
    :dependent => :destroy, 
    :autosave => true
  
  accepts_nested_attributes_for :educations, 
    :reject_if => :all_blank,
    :allow_destroy => true
    
  has_many :tags,
    :dependent => :destroy,
    :autosave => true
    
  accepts_nested_attributes_for :tags,
    :reject_if => :all_blank,
    :allow_destroy => true
    
  has_many :participants
  has_many :activities, 
    :through => :participants

  def gravatar
    Digest::MD5.hexdigest(self.email)
  end

  def studies
    list = self.educations
  
    if(list.length == 0)
      return ''
    end
    
    string = ''
    
    self.educations.each do |i|
      string += i.name_id
      
      if(i != list.last)
        string += ', '
      end
    end
    
    return string
  end

  def self.search(query)
    Member.where("first_name LIKE ? OR last_name like ? OR student_id like ?", "%#{query}%", "%#{query}%", "%#{query}%")
  end

end
