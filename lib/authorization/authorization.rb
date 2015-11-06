module Authorization
  # Controller-independent method for retrieving the current user.
  # Needed for model security where the current controller is not available.
  def self._user
    Thread.current["authenticated_user"]
  end

  # Controller-independent method for setting the current user.
  def self._user=(user)
    Thread.current["authenticated_user"] = user
  end

  def self._member
    Authorization._user.credentials unless Authorization._user.admin?
  end

  def self._clear!
    Thread.current["authenticated_user"] = nil
  end
end
