# Development setup for Constipated Koala

Koala is written using the [Ruby on Rails] framework, which uses the programming
language [Ruby]. (Also see the [dependency managment readme](/DEPENDENCIES.md)).
Rails is based on the Model-View-Controller paradigm, and has an easy to
understand file structure. On the production server, we use [Unicorn] to run the
application with multiple threads, and [Nginx] as a proxy. In both development
and production, we use [PostgreSQL] as the database.

[PostgreSQL]: https://www.postgresql.org/
[Ruby on Rails]: https://guides.rubyonrails.org/getting_started.html
[Ruby]: https://www.ruby-lang.org/
[Unicorn]: https://bogomips.org/unicorn/

## Requirements

To get started, you will need:

- Preferably a Linux installation, but MacOS or WSL2 should work too
- Git
- Docker and docker-compose\

```shell
sudo apt install git docker.io docker-compose
```

NOTE: You need to log out and log in again to apply this!

```shell
sudo usermod -aG docker $USER
```

To start, clone the project:

```console
$ git clone git@github.com:svsticky/constipated-koala
Cloning into 'constipated-koala'...
```

## Configuring Koala

Koala is configured with environment variables. We have an example file
containing the default settings for development. Copy this file to the correct
location:

``` shell
cp sample.env .env
```

To actually run Koala, we need to set up the database. Let's first start the
database and Koala:

``` shell
docker-compose up --build
```

Docker wil now download and set up PostgreSQL, Redis and Koala itself. This can
take a little while.

Once this is done, you can set up the database with this command:

```console
docker-compose exec koala-development rails db:setup
```

This creates the database for you and fills it with fake test data.
It generates two users that you can use:

- `dev@svsticky.nl`, an admin user (password is `sticky123`),
- `test@svsticky.nl`, a member user (same password).

## Running Koala

The server will listen for connections from localhost, which means that it's
only accessible from the computer where you're running the server. In order to
have the server actually work, you'll need to run this command once:

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
