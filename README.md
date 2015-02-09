# Operation Constipated Koala

## Dev setup

You will need a working package manager, and a working ruby version manager and/or
build tools.

### External dependencies

Install before continuing:

 - `ruby-2.1.2` (install with [`rbenv install`][rbenv] or, if you must, [`rvm`][rvm]);
 - MySQL with database created.

  [rbenv]: https://github.com/sstephenson/rbenv
  [rvm]: http://rvm.io/

### Running the Rails app

This is how you can get started with the development setup.

```shell
# Clone and switch directories:
$ git clone git@github.com:StickyUtrecht/ConstipatedKoala.git && cd ConstipatedKoala

# Install ruby dependencies:
$ bundle install

# Create `config/database.yml` with adapter `mysql2` and database credentials
$ mvim config/database.yml

# Create and populate the database
$ bundle exec rake db:create && bundle exec rake db:setup

# Run the server
$ bundle exec rails server

# Add dev host to hosts file
$ echo "127.0.0.1 koala.rails.dev intro.rails.dev" >> /etc/hosts
```

All done! Now you have the admin system and intro website running at:

 - [`http://koala.rails.dev:3000`](http://koala.rails.dev:3000)
 - [`http://intro.rails.dev:3000`](http://intro.rails.dev:3000)

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

## Contributing

For new features, create a new branch starting with `feature/` in this way the
features will be grouped. After developing and testing the feature locally request a
pull request and the feature will be merged with the master branch.

## License

```
ConstipatedKoala is licensed under the GPLv3 license.

Copyright (C) 2014 Tako Marks, Martijn Casteel, Laurens Duijvesteijn

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
