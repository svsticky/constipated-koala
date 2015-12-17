namespace :admin do

  desc 'Create a new admin user'
  task :create, [:email, :password] => :environment do |t, args|

    if !User.find_by_email( args[:email] ).nil?
      puts "#{args[:email]} is already an admin"
      exit
    end

    if !Member.find_by_email( args[:email] ).nil?
      puts "#{args[:email]} is already a member"
      exit
    end

    admin = Admin.create(
      email:                  args[:email],
      password:               args[:password],
      password_confirmation:  args[:password]
    )

    if admin
      puts "#{args[:email]} created!"
    else
      puts 'Admin not created, does the password meet the requirements?'
    end
  end

  desc 'Delete a normal user, that is it\'s login access'
  task :remove, [:email] => :environment do |t, args|

    user = User.find_by_email args[:email]

    if user.nil?
      puts "#{args[:email]} not found"
      exit
    elsif user.admin?
      puts "#{args[:email]} is an admin account and its login access can not be removed"
      exit
    end

    puts "#{args[:email]} removed" if user.destroy
  end

  desc 'Delete an admin account and user'
  task :delete, [:email] => :environment do |t, args|

    user = User.find_by_email args[:email]

    if user.nil? || !user.admin?
      puts "#{args[:email]} not found"
      exit
    end

    puts "#{args[:email]} removed" if user.credentials.destroy
  end

  desc 'Reindex fuzzily for all members'
  task :reindex_members => :environment do |t|
    puts 'reindex members..'
    Member.bulk_update_fuzzy_query
    puts 'reindex done!'
  end

  desc 'Start a new year, create a new membership activity if given and set in config'
  task :start_year, [:membership, :price] => :environment do |t, args|
    #TODO intro activities

    exit if ENV['BEGIN_STUDY_YEAR'].nil? || Date.parse( ENV['BEGIN_STUDY_YEAR'] ) != Date.today

    #TODO dump all impressions

    exit if args[:membership].nil?

    #create new activity
    activity = Activity.create(
      name:                 args[:membership],
      price:                args[:price],
      start_date:           ENV['BEGIN_STUDY_YEAR']
    )

    #change configuration
    membership = UserConfiguration.where( :abbreviation => 'intro_membership' )
    membership.update_attributes :value => activity.id
    membeship.save
  end
end
