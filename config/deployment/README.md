#Constipated koala
Koala is a [Ruby on Rails](http://guides.rubyonrails.org/getting_started.html) application, it uses ruby as language which is quite an easy language running on [rbenv](https://github.com/rbenv/rbenv). Rails is a Model-View-Controller framework denoting an easy to understand file structure. At Sticky we are using [Unicorn](unicorn) to run the application with multiple threads in a rackspace environment in production. Unicorn runs the app on `/tmp/unicorn.sock` which in turn is used by [Nginx](koala.svsticky.nl)
 as a proxy. In development and production we use mysql, it should work with alternatives but never tested. Finally the package manager called bundler is also required.

First I will discuss some information on developing on unix and windows. These steps can be skipped if this is already have rails applications running.

##Windows
virtualbox linux, start at linux
To be continued..

##Linux
Congratulations, you are using a superior operating system.

rbenv!

##Deployment
Deploying koala or any Ruby on Rails application for that matter is just using some commands. It isn't that hard. First we have to clone the repository to a suitable location, usually that would be `/var/www` on any linux server. Then we have to install rbenv-vars, which set environment variables. It sets variables accessible on the entire system, these variables are usually secret so they are not put on Github. To list all environment variables just type `ENV` and press <kbd>enter</kbd>.

```shell
# Clone and switch directories:
$ git clone git@github.com:StickyUtrecht/ConstipatedKoala.git && cd ConstipatedKoala

# Installing rbenv-vars in the existing rbenv installation
$ mkdir -p ~/.rbenv/plugins
$ cd ~/.rbenv/plugins
$ git clone https://github.com/rbenv/rbenv-vars.git

# Copy example config file and fill in
$ cp .rbenv-vars-sample .rbenv-vars && vim .rbenv-vars
```

In the `.rbenv-vars` is a fixed set of variables required for going any further, for example credentials of the database. Next we have to install all packages listed in the Gemfile. A package is called a gem and is installed using the package manager bundler. It will output a list of all installed gems. Finally create, migrate, and fill the database with testdata. Be carefull instead of db:setup you should use db:migrate on a production server.

```shell
# Install ruby dependencies:
$ bundle install

# Create and populate the database
$ bundle exec rake db:create db:setup

```
So now you have a functioning ruby on rails application, now what?! Exactly a way to run it;

###development
In development we are using Webrick, it is a very basic single threaded server application running your app on port `3000`. It is as easy as you might think. However in koala we have two constrains of [subdomains](routes.rb), so we need two subdomains to acquire that constraint. Adding it the your hostfile works on localhost on any linux system. So now you can reach the application [http://koala.rails.dev:3000].

```shell
# Add hosts for different subdomains on localhost
$ echo "127.0.0.1 koala.rails.dev intro.rails.dev" >> /etc/hosts

# Run the server using webrick
$ bundle exec rails server
```

###production
Well almost there, before running this app on production it would be smart to secure the connection with an ssl certficate. This can be done by letsencrypt where the webroot should be `/var/www/koala.svsticky.nl/public`.

Secondly there are some files in this folder that should be moved to the appropriate location; `koala.svsticky.nl` is the nginx config that works with the production environment settings and probably should be moved to `/etc/nginx/sites-available/`. Now we can add the init.d script which starts unicorn on every start and gives you commands like `service unicorn reload` to restart unicorn.

```shell
# Move the directory to the correct folder if you haven't already
$ mv ConstipatedKoala /var/www/koala.svsticky.nl

# Add the nginx config to the correct location
$ mv config/development/koala.svsticky.nl /etc/nginx/sites-available/
$ ln -s /etc/nginx/sites-available/koala.svsticky.nl /etc/nginx/sites-enabled/
$ nginx -s reload

# Move the unicorn config and set it to start automatically
$ mv config/deployment/unicorn /etc/init.d/
$ sudo chmod 755 /etc/init.d/unicorn
$ sudo update-rc.d /etc/init.d/unicorn defaults
```

Now run `sudo service unicorn start`, congratulations! :)
