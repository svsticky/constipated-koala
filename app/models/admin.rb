class Admin < ActiveRecord::Base
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
  
  def sender
    if infix.blank?
      return "#{self.first_name} #{self.last_name} <#{self.user.email}>"
    end
    
    return "#{self.first_name} #{self.infix} #{self.last_name} <#{self.user.email}>"
  end
  
  after_save do
    credentials = User.new(
      email:                  email,
      password:               password,
      password_confirmation:  password_confirmation,
      
      credentials: self
    )
    
    credentials.save
  end
end