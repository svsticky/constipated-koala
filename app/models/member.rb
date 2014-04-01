class Member < ActiveRecord::Base
  validates :first_name, presence: true
  #validates :infix
  validates :last_name, presence: true
  validates :address, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true
  validates :email, presence: true
  validates :gender, presence: true
  validates :student_id, presence: true
  validates :birth_date, presence: true
  validates :join_date, presence: true
  #validates :comments
end
