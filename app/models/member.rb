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
  
  has_many :educations, 
    :dependent => :destroy, 
    :autosave => true
  
  accepts_nested_attributes_for :educations, 
    :reject_if => :all_blank,
    :allow_destroy => true

  def gravatar
    Digest::MD5.hexdigest(self.email)
  end
  
  def studies
    list = self.educations;
  
    if(list.length == 0)
      return ''
    end
    
    string = ''
    
    self.educations.each do |i|
      string += i.name_id
#       string += i.name(i)
      
      if(i != list.last)
        string += ', '
      end
    end
    
    return string
  end

  def self.search(query)
    #uber ugly, kijken of het beter kan
    #find(:all, :conditions => ['first_name || \' \' || last_name || \' \' || student_id || \' \' || last_name || \' \' || first_name LIKE ?', "%#{query}%"])
    
    #find(:all, :conditions => [' first_name LIKE ?', "%#{query}%"])
    where(:all, :conditions => ['first_name LIKE :query OR last_name LIKE :query', {:query => "%#{query}%"}])
  end

end
