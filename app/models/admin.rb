#:nodoc:
class Admin < ApplicationRecord
  has_one :user, as: :credentials
  has_one_attached :avatar

  attr_accessor :email, :password, :password_confirmation

  def language; end

  def name
    return "#{ first_name } #{ last_name }" if infix.blank?

    "#{ first_name } #{ infix } #{ last_name }"
  end

  def avatar_representation
    avatar.representation(resize: '50x50!') if avatar.attached?
  end

  after_create do
    user = User.new(
      email: email,
      password: password,
      password_confirmation: password_confirmation,

      credentials: self
    )

    user.skip_confirmation! if Rails.env.development? || Rails.env.staging?
    user.save!
  end
end
