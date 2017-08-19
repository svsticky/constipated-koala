class Admin < ApplicationRecord
  has_one :user, as: :credentials

  attr_accessor :email
  attr_accessor :password
  attr_accessor :password_confirmation

  def name
    if infix.blank?
      return "#{self.first_name} #{self.last_name}"
    end

    return "#{self.first_name} #{self.infix} #{self.last_name}"
  end

  after_create do
    credentials = User.create!(
      email:                  email,
      password:               password,
      password_confirmation:  password_confirmation,

      credentials: self
    )
  end
end
