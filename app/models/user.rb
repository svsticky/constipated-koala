#:nodoc:
class User < ApplicationRecord
  is_impressionable

  belongs_to :credentials, polymorphic: true

  enum language: { nl: 0, en: 1 }

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    return true if credentials_type.casecmp('admin').zero?

    return false
  end

  def sender
    "#{ credentials.name } <#{ email }>"
  end

  # Admins must always re-enter their password.
  def remember_me?(token, generated_at)
    !admin? && super
  end

  def resend_confirmation!(template = :confirmation_instructions)
    generate_confirmation_token!
    send_devise_notification(template, @raw_confirmation_token, {})
  end

  def force_confirm_email!
    return if admin?

    confirm

    credentials.update_column(:email, email)
  end

  def active_for_authentication?
    super && !deleted_at
  end

  def self.create_on_member_enrollment!(member)
    password = Devise.friendly_token(128)

    user = User.new(
      credentials: member,
      email: member.email,

      password: password,
      password_confirmation: password
    )

    user.skip_confirmation_notification!
    user.save
    user
  end

  def self.find_by_credentials(object)
    User.where(credentials_type: object.class.name, credentials_id: object.id).first
  end
end
