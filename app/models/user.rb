class User < ActiveRecord::Base  
  is_impressionable
  
  belongs_to :credentials, :polymorphic => true
  
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  def gravatar
    Digest::MD5.hexdigest(self.email)
  end
end