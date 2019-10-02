Doorkeeper::OAuth::TokenResponse.class_eval do
  def body
    response = {
      'access_token'  => token.token,
      'token_type'    => token.token_type,
      'expires_in'    => token.expires_in_seconds,
      'refresh_token' => token.refresh_token,
      'scope'         => token.scopes_string,
      'created_at'    => token.created_at.to_i
    }

    # added some information about the user that is loggedin
    user = User.find_by_id(token.resource_owner_id)
    response = response.merge(user.as_json.reject { |k, _v| k == "id" }) unless user.nil?
    response['id_token'] = user.email unless user.nil?

    return response.reject { |_, value| value.blank? }
  end
end

# Custom authorization
require 'authorization/authorization'
ApiController.include Authorization

require 'rabl'
Rabl.configure do |config|
  config.include_json_root = false
  config.include_msgpack_root = false
  config.include_bson_root = false
  config.include_xml_root  = false
  config.include_child_root = false
  config.xml_options = { :dasherize => true, :skip_types => true }

  config.replace_empty_string_values_with_nil_values = true
  config.exclude_nil_values = true
  config.exclude_empty_values_in_collections = true
end

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (needs plugins)
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    current_user || begin
      session[:user_return_to] = request.fullpath
      redirect_to new_user_session_url
      nil
    end
  end

   admin_authenticator do
     current_user&.admin? || redirect_to(new_user_session_url)
   end

  # Authorization Code expiration time (default 10 minutes).
  authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  access_token_expires_in 4.hours

  # Assign a custom TTL for implicit grants.
  # custom_access_token_expires_in do |oauth_client|
  #   oauth_client.application.additional_settings.implicit_oauth_expiration
  # end

  # Use a custom class for generating the access token.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
  # access_token_generator "::Doorkeeper::JWT"

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  # enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  default_scopes  :'member-read', :'activity-read'
  optional_scopes :'activity-read', :'group-read', :'participant-read', :'participant-write', :'checkout-read', :'checkout-write', :openid, :email, :profile

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  force_ssl_in_redirect_uri Rails.env.production?

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  # "implicit_oidc"      => Requiredi f you want to use the `id_token` or `id_token token` response types (https://github.com/doorkeeper-gem/doorkeeper-openid_connect#configuration)
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #
  grant_flows %w[authorization_code client_credentials implicit_oidc]

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  skip_authorization do |resource_owner, client|
    client.uid == ENV['OAUTH_PROXY_UID']
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  realm "sticky"
end
