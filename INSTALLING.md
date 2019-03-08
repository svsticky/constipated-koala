# Constipated koala

Koala is a [Ruby on Rails](http://guides.rubyonrails.org/getting_started.html) application, it uses ruby as language which is quite an easy language running on [rbenv](https://github.com/rbenv/rbenv). Rails is a Model-View-Controller framework denoting an easy to understand file structure. At Sticky we are using [Unicorn](unicorn) to run the application with multiple threads in a rackspace environment on the production server. Unicorn runs the app on `/tmp/unicorn.sock` which in turn is used by [Nginx](koala.svsticky.nl)
 as a proxy. In development and production we use [MariaDB](https://downloads.mariadb.org/mariadb/repositories), it should work with MySQL as well. Finally the package manager called bundler is also required.

 ```shell
 # Let's start; clone the project
 $ git clone git@github.com:svsticky/constipated-koala.git koala.svsticky.nl
 $ cd koala.svsticky.nl
 ```

First I will discuss some information on developing on unix and windows. These steps can be skipped if you're already developing rails applications using rbenv.

### Windows
These steps are required for Windows but can be done on any OS if you want a clean install on a virtual machine. First we have to install [Vagrant](http://www.vagrantup.com/downloads.html) and [Virtualbox](https://www.virtualbox.org/wiki/Downloads).

```shell
# first install vagrant plugins for virtualbox and chef
$ vagrant plugin install vagrant-vbguest
$ vagrant plugin install vagrant-librarian-chef-nochef
```

Now we can setup the virtual machine using Vagrant and chef. The virtual machine runs the rails environment from your working directory on the default port. In the virtual machine your project is located at `/vagrant`

```shell
# create and install a virtual machine, coffee time!
$ vagrant up

# connect to the virtual machine
$ vagrant ssh
$ cd /vagrant
```

Bonus card; _skip to running the app_, the linux steps are all pre-installed on your virtual machine for you!

### Linux
Congratulations, you have access to a superior operating system.

Ruby is a language and requires an environment. We are installing that with the help of rbenv and its [tutorial](https://github.com/rbenv/rbenv#basic-github-checkout). At the end of this specific chapter they are telling about [ruby-build](https://github.com/rbenv/ruby-build#installing-as-an-rbenv-plugin-recommended) which makes your life a lot easier by adding commands to install new versions. We'll do that a little bit later on.

Now we have installed ruby on your system, we have to chose which version we will be using. Currently that is `2.4.1`, but we should update regularly. Updating requires you to check if everything is still working properly, obviously.

```shell
# list all available versions:
$ rbenv install -l

# The version we are using on the moment
$ rbenv install 2.4.1

# Installing rbenv-vars in the existing rbenv installation
$ mkdir -p ~/.rbenv/plugins
$ cd ~/.rbenv/plugins
$ git clone https://github.com/rbenv/rbenv-vars.git
```

Now the hardest part; [active storage](http://edgeguides.rubyonrails.org/active_storage_overview.html). Active storage uses minimagick as a image processor, we have to add imagemagick to our server. Make sure the `identify` and `convert` are installed. For pdf we also need ghostscript to be installed, which can be tested by using `which gs`. You can find the paths out by using `which convert` on your machine.

### Running the app
Deploying koala or any Ruby on Rails application for that matter is not that hard. First we have to clone the repository to a suitable location, we have done that already, usually that would be `/var/www` on any linux server. Then we have to install rbenv-vars, which set environment variables, also check. It sets variables accessible on the entire system, these variables are usually secret so they are not put on Github. To list all environment variables just type `env` and press <kbd>enter</kbd>.

```shell
# Copy example config file and fill in
$ cp .rbenv-vars-sample .rbenv-vars && vim .rbenv-vars

# Generate a private key for the signing key of API
openssl genrsa -out key.pem 2048

# Make sure that in .rben-vars you have OIDC_SIGNING_KEY=key.pem

# Finally install our package manager
$ gem install bundler
$ rbenv rehash
```

In `.rbenv-vars` is a fixed set of variables required for going any further, for example credentials of the database. Create these secrets using `rake secret`. Next we have to install all packages listed in the Gemfile. A package is called a gem and is installed using the package manager bundler. It will output a list of all installed gems. Finally create, migrate, and fill the database with testdata.

```shell
# Install ruby dependencies
$ bundle install

$ bundle exec rake routes

# Create and populate the database for development
$ RAILS_ENV=development bundle exec rake db:create db:setup
```
This will install the gems, setup the database and create an admin and test user account for you: dev@svsticky.nl and test@svsticky.nl respectively. Password for both is sticky123.

Yarn is a package manager for frontend packages. It's currently used for Bootstrap. Install using the [installation guide](https://yarnpkg.com/en/docs/install). Run command `yarn` to initialise Yarn.

So now you have a functioning ruby on rails application, now what?! Exactly a way to run it;

### Development
In development we are using webrick, it is a very basic single threaded server application running your app on port `3000`. It is as easy as you might think. However in koala we have two constrains of [subdomains](../routes.rb), so we need two subdomains to meet that constraint. Adding it to your hostfile works fine. So now you can reach the application [koala.rails.local:3000](http://koala.rails.local:3000). For some functionalities you'll need `sidekiq`. `sidekiq` is used to add and execute jobs later on, in this way a user doesn't have to wait for the response of an external API.

```shell

# Add hosts for different subdomains on your own computer
$ echo "127.0.0.1 koala.rails.local intro.rails.local" >> /etc/hosts

# Run the server using webrick
$ bundle exec rails server

# Run in a different window to execute background jobs
$ bundle exec sidekiq
```

### Production
Well almost there, before running this app on production it would be smart to secure the connection with an ssl certificate. This can be done by letsencrypt where the webroot should be `/var/www/koala.svsticky.nl/public` and the certificate configured in nginx.

Koala needs to run some tasks occasionally runned called cronjobs; one to reindex the search table. Sometimes it doesn't work properly, don't know why, probably due to heavy load. And secondly to update the introductory activities, we check daily if a new study year has started.

```shell
# Reindex the search table, which can be partial because of the load on introduction day!
$ 0 0 10 9 * cd /var/www/koala.svsticy.nl && /usr/local/bin/rake RAILS_ENV=production admin:reindex_members

# Start a cronjob daily (at 2:09AM) to create new membership activity and **hide passed intro_activities**
$ 9 2 * * * cd /var/www/koala.svsticky.nl && /usr/local/bin/rake RAILS_ENV=production admin:start_year['Lidmaatschap',7.5]
```

There are some files in this folder that should be moved to the appropriate location; `koala.svsticky.nl` is the nginx config that works with the production environment settings and probably should be moved to `/etc/nginx/sites-available/`. Now we can add the init.d script which starts unicorn on every restart of the server and gives you commands like `service unicorn reload` to restart unicorn.

```shell
# Add the nginx config to the correct location
$ mv config/development/koala.svsticky.nl /etc/nginx/sites-available/
$ ln -s /etc/nginx/sites-available/koala.svsticky.nl /etc/nginx/sites-enabled/
$ nginx -s reload

# Move the unicorn config and set it to start automatically
$ mv config/deployment/unicorn /etc/init.d/
$ sudo chmod 755 /etc/init.d/unicorn
$ sudo update-rc.d /etc/init.d/unicorn defaults
```

Now run `sudo service unicorn start`, congratulations you are running a rails application! :)

For the background jobs, `sidekiq` is used, in development `bundle exec sidekiq` can be used. However in production a more sustainable method is desired. Adding a [service](https://github.com/mperham/sidekiq/tree/master/examples) could resolve this running sidekiq in the background. 

### A note on databases
There used to be a section here telling you to be a bit fearful of running the
`db:migrate` rake task. This was misinformed. For more information on this historical
perspective you can check out issue 53.

Here are the rake tasks that you will need to use in order to effectively contribute
to this project:

 - When starting out, `rake db:create` will set you up with a nice development
   database. It won't, however fill it with any tables.
 - To create the relevant tables and seed them you can use `rake db:setup`.
 - When there are pending migrations (database changes), `rake db:migrate` will do
   the job nicely. Use this when you create migrations yourself or when the
   `rake db:setup` task fails due to pending migrations (in this latter case notify
   the maintainer and complain about bad code review).
 - Messed something up? Run the task `db:reset`. This will drop the database, create
   it and set it back up again.

`schema.rb` is a file that describes the database schema of this application. Any
changes to it are critical, therefore it is paramount that you check this file into
version control.
