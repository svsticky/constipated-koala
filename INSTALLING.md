# Development setup for Constipated Koala

Koala is written using the [Ruby on Rails] framework, which uses the
programming language [Ruby]. We use [Nix] to manage dependencies.
(Also see the [dependency managment readme](/DEPENDENCIES.md)).
Rails is based on the Model-View-Controller paradigm, and has an easy to
understand file structure. On the production server, we use [Unicorn] to run
the application with multiple threads, and [Nginx] as a proxy.
In both development and production, we use [Mariadb] as the database.

[Nix]: https://nixos.org/
[Mariadb]: https://mariadb.org
[Ruby on Rails]: https://guides.rubyonrails.org/getting_started.html
[Ruby]: https://www.ruby-lang.org/
[Unicorn]: https://bogomips.org/unicorn/

## Requirements

To get started, you will need:

- Preferably a Linux installation, but MacOS or WSL2 should work too
- Git (`sudo apt install git`)
- Nix (<https://nixos.org/download.html>)

To start, clone the project:

```console
$ git clone git@github.com:svsticky/constipated-koala
Cloning into 'constipated-koala'...
```

To speed up the build, you can install and set up Cachix

```console
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
installing 'cachix-0.3.8'

$ cachix use svsticky-constipated-koala
Configured https://svsticky-constipated-koala.cachix.org binary cache in ~/.config/nix/nix.conf
```

Now we can run nix-shell for the first time

```console
$ nix-shell
[nix-shell:~/projects/koala.svsticky.nl]$
```

This should install all dependencies and launch a shell.
Next time you'll call `nix-shell` will be a whole lot faster, don't worry.

## Configuring Koala

To actually run Koala, you'll need a running copy of PostgreSQL and Redis
To easily start both, you can run these in a container via Docker.
Follow these steps to install Docker and start the database:

``` shell
# Install Docker and Docker Compose
sudo apt install docker.io docker-compose

# Add yourself to the `docker` system group (needed only once)
# NOTE: You need to log out and log in again to apply this!
sudo usermod -aG docker $USER

# Install and start the database
# If you don't want to log out and log in again, use `sudo` here.
docker-compose up -d
```

PostgreSQL and Redis will now set itself up in the background, and will be available in
a minute or so.
You'll need to run the `docker-compose up` command again if you
reboot your computer to start the database again.

If you're already running a copy of PostgreSQL, you can use this too.
You'll need to create a user with all privileges for the
databases `koala-development` and `koala-test`, and set this in the `.env` file.

There is an example file in the root of this repository called
`sample.env`. This file is a template for the actual configuration file
`.env`, which sets some configuration values for Koala. Copy
`sample.env` to `.env`, and edit it according to the
instructions in the file.

Once you're done, you can set up the database with this command (in the Nix shell):

```console
rails db:setup
```

This creates the database for you and fills it with fake test data.
It generates two users that you can use:

- `dev@svsticky.nl`, an admin user (password is `sticky123`),
- `test@svsticky.nl`, a member user (same password).

## Running Koala

You can run Koala itself by running this command (again, in the Nix shell):

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

There are some background jobs that need to be run periodically in production:

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
