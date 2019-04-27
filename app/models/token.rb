#:nodoc:
class Token < ApplicationRecord
  belongs_to :object, :polymorphic => true

  before_create do
    # generate a token not already used
    self.token = loop do
      token = SecureRandom.urlsafe_base64
      break token unless Token.exists?(token: token)
    end

    # default expiry time of a token is 30 days
    self.expires_at = 30.days.from_now if expires_at.blank?
  end

  # usage token.expires_in 30.days
  def expires_in(duration)
    self.expires_at = duration.from_now
  end
end
