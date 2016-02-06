#Constipated koala
Koala is a [Ruby on Rails](http://guides.rubyonrails.org/getting_started.html) application, it uses ruby as language which is quite an easy language running on [rbenv](https://github.com/rbenv/rbenv). Rails is a Model-View-Controller framework denoting an easy to understand file structure. At Sticky we are using [Unicorn](unicorn) to run the application with multiple threads in a rackspace environment on the production server. Unicorn runs the app on `/tmp/unicorn.sock` which in turn is used by [Nginx](koala.svsticky.nl)
 as a proxy. In development and production we use mysql, it should work with alternatives but never tested. Finally the package manager called bundler is also required.

First I will discuss some information on developing on unix and windows. These steps can be skipped if you're already developing rails applications.

###Windows
virtualbox linux, start at linux
To be continued..

###Linux
Congratulations, you now have access to a superior operating system.

Ruby is a language and requires a environment. We are installing that with the help of rbenv and its [tutorial](https://github.com/rbenv/rbenv#basic-github-checkout). Add the end of this specific chapter they are telling about [ruby-build](https://github.com/rbenv/ruby-build#installing-as-an-rbenv-plugin-recommended) which makes your life a lot easier by adding commands to install new versions. We'll do that a little bit later on.

Now whe have installed ruby on your system, we have to chose which version we will be using. Currently that is 2.1.3, but we should update soon. Updating requires you to check if everything is still working properly.
```shell
# list all available versions:
$ rbenv install -l

# The version we are using on the moment
$ rbenv install 2.1.2
```

###Deployment
Deploying koala or any Ruby on Rails application for that matter is just using some commands. It isn't that hard. First we have to clone the repository to a suitable location, usually that would be `/var/www` on any linux server. Then we have to install rbenv-vars, which set environment variables. It sets variables accessible on the entire system, these variables are usually secret so they are not put on Github. To list all environment variables just type `env` and press <kbd>enter</kbd>.

```shell
# Clone and switch directories:
$ cd /var/www
$ git clone git@github.com:StickyUtrecht/ConstipatedKoala.git koala.svsticky.nl

# Installing rbenv-vars in the existing rbenv installation
$ mkdir -p ~/.rbenv/plugins
$ cd ~/.rbenv/plugins
$ git clone https://github.com/rbenv/rbenv-vars.git

# Copy example config file and fill in
$ cd /var/www/koala.svsticky.nl
$ cp .rbenv-vars-sample .rbenv-vars && vim .rbenv-vars

# Finally install our package manager
$ gem install bundler
```

In the `.rbenv-vars` is a fixed set of variables required for going any further, for example credentials of the database. Next we have to install all packages listed in the Gemfile. A package is called a gem and is installed using the package manager bundler. It will output a list of all installed gems. Finally create, migrate, and fill the database with testdata.

```shell
# Install ruby dependencies:
$ bundle install

# Create and populate the database
$ bundle exec rake db:create db:setup
```

Now the hardest part; [paperclip](https://github.com/thoughtbot/paperclip#image-processor). Paperclip is a image processor, however because we use pdf as posters we have to add imagemagick to our server. Make sure the `identify` and `convert` are reachable from the path configured [here](../environment.rb). You can find the paths out by using `which convert` on your machine.

So now you have a functioning ruby on rails application, now what?! Exactly a way to run it;

###Development locally
In development we are using Webrick, it is a very basic single threaded server application running your app on port `3000`. It is as easy as you might think. However in koala we have two constrains of [subdomains](../routes.rb), so we need two subdomains to meet that constraint. Adding it to your hostfile works on localhost on any linux system. So now you can reach the application [koala.rails.dev:3000](http://koala.rails.dev:3000).

```shell
# Add hosts for different subdomains on localhost
$ echo "127.0.0.1 koala.rails.dev intro.rails.dev" >> /etc/hosts

# Run the server using webrick
$ bundle exec rails server

# If you get errors with mkdir
$ sudo chmod 777 public/
```

###Production on a server
Well almost there, before running this app on production it would be smart to secure the connection with an ssl certificate. This can be done by letsencrypt where the webroot should be `/var/www/koala.svsticky.nl/public` and the certificate configured in nginx.

Koala needs to run some tasks occasionally called cronjobs; one to reindex the search table. Sometimes it doesn't work properly, don't know why. And secondly to update the introductory activities, we check daily if a new study year has started.
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

One final action should be performed, adding at least one admin. This can be done by a rake task; `bundle exec rake admin:create['martijn@stickyutrecht.nl','sticky123']` and goto the url displayed or mailed if you set mailgun correctly!

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

### A note on versions
Unfortunatly we can not update to rails 4.2 because of the mechanism hacked into `devise` to let members create there own accounts. Same counts for `mysq2` and `paperclip`. The latter is an awesome gem that works sometimes, it is very precise in the version is should be able to work with and it needs Imagemagick and Ghostscript installed on the computer with the correct paths.
