#:nodoc:
class Admin < ApplicationRecord
  has_one :user, as: :credentials

  attr_accessor :email
  attr_accessor :password
  attr_accessor :password_confirmation
  attr_accessor :skip_confirmation

  def name
    return "#{ first_name } #{ last_name }" if infix.blank?

    "#{ first_name } #{ infix } #{ last_name }"
  end

  after_create do
    user = User.new(
      email:                  email,
      password:               password,
      password_confirmation:  password_confirmation,

      credentials: self
    )
    # TODO: is this safe?
    user.skip_confirmation! if skip_confirmation
    user.save!
  end
end
