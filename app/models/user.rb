#:nodoc:
class User < ApplicationRecord
  is_impressionable

  belongs_to :credentials, :polymorphic => true

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    return true if credentials_type.casecmp('admin').zero?
    return false
  end

  def gravatar
    return Digest::MD5.hexdigest(email)
  end

  def sender
    "#{ credentials.name } <#{ email }>"
  end

  # Admins must always re-enter their password.
  def remember_me?(token, generated_at)
    !admin? && super
  end

  # Clear the accounts password, and send a customized 'welcome to Sticky!'-mail if not confirmed already
  def require_activation!
    return if confirmed?
    generate_confirmation_token!
    skip_confirmation_notification!

    pw = Devise.friendly_token 128
    self.password = pw
    self.password_confirmation = pw

    self.confirmation_sent_at = Time.now
    save
    send_devise_notification(:activation_instructions, @raw_confirmation_token, {})
  end

  def self.find_by_credentials(object)
    User.where(credentials_type: object.class.name, credentials_id: object.id).first
  end
end
