Doorkeeper::OpenidConnect.configure do
  issuer ENV['KOALA_DOMAIN']

  # This key should always exists, otherwise OIDC logins are unsecured
  signing_key File.read(ENV['OIDC_SIGNING_KEY'])

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find_by_id(access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  subject do |resource_owner, application|
    resource_owner.id
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  protocol do
    if Rails.env.development? then :http else :https end
  end
  #
  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  claims do
    claim :email, response: [:id_token, :user_info] do |resource_owner|
      resource_owner.email
    end

    claim :is_admin, response: [:id_token, :user_info] do |resource_owner|
      resource_owner.admin?
    end

    claim :full_name, response: [:id_token, :user_info] do |resource_owner|
      resource_owner.credentials.name
    end
  end
  # Example claims:
  # claims do
  #   normal_claim :_foo_ do |resource_owner|
  #     resource_owner.foo
  #   end

  #   normal_claim :_bar_ do |resource_owner|
  #     resource_owner.bar
  #   end
  # end
end
