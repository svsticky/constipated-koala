class User < ApplicationRecord
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

  def sender
    "#{credentials.name} <#{self.email}>"
  end

  def hash
    {
      "#{credentials_type.downcase}" => {
        'id'       => self.credentials.id,
        'name'     => self.credentials.name,
        'email'    => self.email,
      }
    }
  end

  def self.taken?(email)
    User.exists?(email: email) || User.exists?(unconfirmed_email: email)
  end

  # Admins must always re-enter their password.
  def remember_me?(token, generated_at)
    not self.admin? and super
  end
end
