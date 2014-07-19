class Admin < ActiveRecord::Base  
  is_impressionable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  def gravatar
    Digest::MD5.hexdigest(self.email)
  end
end