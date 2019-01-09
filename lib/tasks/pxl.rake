namespace :pxl do
  desc 'Create/update PXL application according to environment variables'
  task :create_application => :environment do
    unless ENV['PXL_UID'] && ENV['PXL_SECRET'] && ENV['PXL_REDIRECT_URI']
      puts 'Secrets incomplete, no action taken.'
      return
    end

    pxl = Doorkeeper::Application.find_or_initialize_by(uid: ENV['PXL_UID'])
    pxl.assign_attributes(
      name: "Sticky PXL",
      secret: ENV['PXL_SECRET'],
      redirect_uri: ENV['PXL_REDIRECT_URI'],
      scopes: "openid member-read email profile",
      confidential: true
    )
    pxl.save!
  end
end
