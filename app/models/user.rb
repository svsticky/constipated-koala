class User < ActiveRecord::Base
  is_impressionable

  belongs_to :credentials, :polymorphic => true

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    return true if credentials_type.downcase == 'admin'
    return false
  end

  def gravatar
    return Digest::MD5.hexdigest(self.email)
  end

  def hash
    {
      'member_id'       => self.credentials.id,
      'member_name'     => self.credentials.name,
      'member_email'    => self.email,
    }
  end
end
