namespace :doorkeeper do
  # rake "doorkeeper:create[Testing test, https://example.com/callback, member-read partipant-read]"
  desc 'Create a new oauth application, using a name, redirect url and a list of scopes seperated with a space.'
  task :create, [:name, :redirect_uri, :scopes] => :environment do |_, args|
    app = Doorkeeper::Application.new(
      :name => args[:name],
      :redirect_uri => args[:redirect_uri],
      :scopes => args[:scopes] ||= nil
    )

    if app.save
      puts "uid:      #{ app.uid }"
      puts "secret:   #{ app.secret }"
      puts "scopes:   #{ app.scopes }"

    else
      puts "failed creating #{ args[:name] }"
      puts app.errors.full_messages
    end
  end

  desc 'Delete an application using the application id.'
  task :delete, [:application] => :environment do |_, args|
    app = Doorkeeper::Application.find_by_uid! args[:application]
    app.destroy
  end
end
