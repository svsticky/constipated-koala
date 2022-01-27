namespace :oauthproxy do
  desc 'Create/update OAuth Proxy application according to environment variables'
  task create_application: :environment do
    unless ENV['OAUTH_PROXY_UID'] && ENV['OAUTH_PROXY_SECRET'] && ENV['OAUTH_PROXY_REDIRECTS']
      puts 'Secrets incomplete, no action taken.'
      return
    end

    pxl = Doorkeeper::Application.find_or_initialize_by(uid: ENV['OAUTH_PROXY_UID'])
    uris = ENV['OAUTH_PROXY_REDIRECTS'].split(';').join("\n")
    pxl.assign_attributes(
      name: "Internal Sticky Proxy",
      secret: ENV['OAUTH_PROXY_SECRET'],
      redirect_uri: uris,
      scopes: "openid member-read email profile",
      confidential: true
    )
    pxl.save!
  end
end
