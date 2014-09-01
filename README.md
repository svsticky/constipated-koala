# Operation Constipated Koala

## Dev setup

All you need to get started with this repository is to install two dependencies.

### External dependencies

Install before continuing:

 - Ruby v2.1.2 (via [`rvm`](http://rvm.io/) or [`rbenv`](https://github.com/sstephenson/rbenv))
 - MySQL; with an empty testing database

### Running the Rails app

This is how you can get started with the development setup.

```shell
# Clone and switch directories:
$ git clone git@github.com:StickyUtrecht/ConstipatedKoala.git && cd ConstipatedKoala

# Install ruby dependencies:
$ bundle install

# Create `config/database.yml` with adapter `mysql2` and database credentials
$ mvim config/database.yml

# Populate the database
$ bundle exec rake db:migrate && bundle exec rake db:seed

# Run the server
$ bundle exec rails server

# Add dev host to hosts file
$ echo "127.0.0.1 admin.koala.dev public.koala.dev >> /etc/hosts
```

All done! Now view at: [`http://admin.koala.dev/`](http://admin.koala.dev/)

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
