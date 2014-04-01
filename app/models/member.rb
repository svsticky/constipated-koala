class Member < ActiveRecord::Base
  validates :first_name, presence: true, length: { maximum: 12 }
  validates :infix, length: { maximum: 6 }
  validates :last_name, presence: true, length: { maximum: 20 }
  validates :address, presence: true, format: { with: /\A\D*\Z/ }, length: { maximum: 30 }
  validates :house_number, presence: true, length: { maximum: 6 }
  validates :postal_code, presence: true, format: { with: /\A[1-9][\d]{3}\s{1}(?!(sa|sd|ss|SA|SD|SS))([a-eghj-opr-tv-xzA-EGHJ-OPR-TV-XZ]{2})\z/ }
  validates :city, presence: true, length: { maximum: 15 }
  validates :phone_number, presence: true, format: { with: /(^\+[0-9]{2}|^\+[0-9]{2}\(0\)|^\(\+[0-9]{2}\)\(0\)|^00[0-9]{2}|^0)([0-9]{9}$|[0-9\-\s]{10}$)/, multiline: true }
  validates :email, presence: true, format: { with: /\A[^@]+@[^@]+\.[^@]+\z/ }
  validates :gender, presence: true, inclusion: { in: %w(m f)}
  validates :student_id, presence: true, format: { with: /\A\d{6,7}\z/ }
  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments
end
