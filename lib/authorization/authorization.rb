module Authorization
  # Controller-independent method for retrieving the current user.
  # Needed for model/view security where the current controller is not available.
  def self._user
    Thread.current["authenticated_user"]
  end

  # Controller-independent method for setting the current user.
  def self._user=( user )
    Thread.current["authenticated_user"] = user
  end

  def self._client
    app = Thread.current["authenticated_client"]
    return app.scopes if app.present? && Authorization._user.nil?
    
    []
  end

  def self._client=( app )
    Thread.current["authenticated_client"] = app
  end

  def self._member
    user = Authorization._user
    return user.credentials unless user.nil? || user.admin?

    false
  end

  def self._clear!
    Thread.current["authenticated_user"] = nil
    Thread.current["authenticated_client"] = nil
  end
end
