# Development setup for Constipated Koala

Koala is written using the [Ruby on Rails] framework, which uses the
programming language [Ruby]. We use [rbenv] to manage the version of Ruby that
is used, and the package manager [Bundler] to manage dependencies.
Rails is based on the Model-View-Controller paradigm, and has an easy to
understand file structure. On the production server, we use [Unicorn] to run
the application with multiple threads, and [Nginx] as a proxy.
In both development and production, we use [Mariadb] as the database.

[Bundler]: https://bundler.io
[Mariadb]: https://mariadb.org
[Ruby on Rails]: https://guides.rubyonrails.org/getting_started.html
[Ruby]: https://www.ruby-lang.org/
[Unicorn]: https://bogomips.org/unicorn/
[rbenv]: https://github.com/rbenv/rbenv

## Requirements

To get started, you will need:

- A Linux installation (we assume you're using Ubuntu 18.04)
- Git (`sudo apt install git`)

You'll install:

- Dependencies to build Ruby and some extensions,
- [rbenv], a Ruby version manager,
- [Ruby] itself,
- [Yarn], a JavaScript package manager,
- Koala's dependencies.

To start, clone the project:

```console
git clone git@github.com:svsticky/constipated-koala.git koala.svsticky.nl
cd koala.svsticky.nl
```

Ruby is a programming language and requires an environment. We can set up the
environment easily with the help of rbenv and its [tutorial][rbenv-tutorial].
Follow this tutorial, and also do the optional step of installing ruby-build.

[rbenv-tutorial]: https://github.com/rbenv/rbenv#basic-github-checkout

After installing rbenv, you'll also need the rbenv-vars plugin, which is used
to read a configuration file. Install it like so:

```console
git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
```

Once you've done this, install the dependencies you'll need to build Ruby, and
then Ruby itself:

```console
# These dependencies copied from https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev mupdf-tools
# Run this step in Koala's source directory, or rbenv won't know which version to install
rbenv install
```

Note that installing Ruby will compile it from source, which can take a bit of
time and will be intensive on your processor. If you're using a laptop, it's
recommended to connect your charger for this.

Once this is done, you'll also need some other packages to run Koala itself and
to build its dependencies. Install these, and then install Koala's Ruby
dependencies:

```console
sudo apt install curl libmariadbclient-dev imagemagick ghostscript

gem install bundler -v 2.1.4

bundle install
rbenv rehash
```

Then follow the instructions on [this page][yarn-install] to install Yarn,
a package manager for our JavaScript dependencies.

[yarn-install]: https://yarnpkg.com/en/docs/install#debian-stable

You should now be able to run the following command:

```console
yarn install
rails assets:precompile
```

This will download our JavaScript and CSS dependencies, and confirm that you're
able to build our CSS and JS bundles.

If all of this worked, you're ready to run Koala!

## Configuring Koala

To actually run Koala, you'll need a running copy of MariaDB or MySQL. In
production, we run MariaDB, and to prevent problems we run the same database in
development as well.

To easily start the database, you can run MariaDB in a container via Docker.
Follow these steps to install Docker and start the database:

```console
# Install Docker and Docker Compose
sudo apt install docker.io docker-compose

# Add yourself to the `docker` system group (needed only once)
# NOTE: You need to log out and log in again to apply this!
sudo usermod -aG docker $USER

# Install and start the database
# If you don't want to log out and log in again, use `sudo` here.
docker-compose up -d
```

MariaDB will now set itself up in the background, and will be available in
a minute or so. You'll need to run the `docker-compose up` command again if you
reboot your computer to start the database again.

If you're already running a copy of MariaDB, you can use this copy to contain
Koala's files as well. You'll need to create a user with all privileges for the
databases `koala-development` and `koala-test`, this is out of scope for this
tutorial.

There is an example file in the root of this repository called
`.rbenv-vars-sample`. This file is a template for the actual configuration file
`.rbenv-vars`, which sets some configuration values for Koala. Copy
`.rbenv-vars-sample` to `.rbenv-vars`, and edit it according to the
instructions in the file.

Once you're done, you can set up the database with this command:

```console
rails db:setup
```

This creates the database for you and fills it with fake test data.
It generates two users that you can use:

- `dev@svsticky.nl`, an admin user (password is `sticky123`),
- `test@svsticky.nl`, a member user (same password).

## Running Koala

You can run Koala itself by running this command:

```console
rails server
# This works as well:
rails s
```

This will start a server that listens until you press Ctrl-C in the window
where it's running.

The server will listen for connections from localhost, which means that it's
only accessible from the computer where you're running the server.
In order to have the server actually work, you'll need to run this command once:

```console
echo "127.0.0.1    koala.rails.local members.rails.local leden.rails.local intro.rails.local" | sudo tee -a /etc/hosts
```

After this, when the server is running, you can open
<http://koala.rails.local:3000> in your browser, and you should get Koala's login
screen.

Happy hacking!

## Production

The development setup is set up to consume less resources, and to allow rapid
development by automatically loading changed code. In production, we use
a different setup to be able to handle more requests at once and to integrate
with some of our other websites. If you're interested, you can view the script
that is used to set up the actual Koala instance in the [Sadserver repository]
under `ansible/tasks/koala.yml`.

[Sadserver repository]: https://github.com/svsticky/sadserver

## Mailchimp synchronization

To utilize and set up the mailchimp synchronization have a look at [MAILCHIMP.md](MAILCHIMP.md).

## Background jobs

There are three background jobs that need to be run periodically in production:

- `rails admin:reindex_members`, which rebuilds the search index, which ensures
  that the member search works properly,
- `rails admin:start_year['Lidmaatschap',7.5]`, which starts a new study year
  when it's appropriate to do so.
- `rails status:mail`, which should be run once a year, preferably in the summer
  holidays. The tasks asks appropiate members if they are still studying and if
  they are okay with us storing their data (our version of GDPR compliancy).

You shouldn't need to run these in development.

## Database management

Some database commands that you might need if something breaks:

- `rails db:create`: Create a database, but don't fill it with tables or data.
- `rails db:setup`: Create the database and fill it with random test data.
  Doesn't work if there already is a database, but does delete your data!
- `rails db:reset`: Delete and recreate the database, with new test data.
- `rails db:migrate`: Apply all pending migrations. If the migrations are new,
  this will alter `db/schema.rb`. If this happens, commit this file!
- `rails db:rollback`: Roll back the most recent migration.

See [the migrations guide] for more info on how migrations work.

[the migrations guide]: https://guides.rubyonrails.org/active_record_migrations.html
