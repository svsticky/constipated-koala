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
  
  def gravatar
    Digest::MD5.hexdigest(self.email)
  end

  def self.search(query)
    where("first_name like ? OR last_name like ? OR student_id like ?", "%#{query}%", "%#{query}%", "%#{query}%")
  end
end
