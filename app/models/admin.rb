class Admin < ActiveRecord::Base
  has_one :user, as: :credentials
  
  attr_accessor :email
  attr_accessor :password
  attr_accessor :password_confirmation
  
  after_save do
    
    credentials = User.new(
      email:                  email,
      password:               password,
      password_confirmation:  password_confirmation,
      
      credentials_id:               self.id,
      credentials_type:             'admin'
    )
    
    puts credentials.save
    puts credentials.errors.full_messages
  end
end