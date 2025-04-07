<p align="center">
<img src="https://cloud.githubusercontent.com/assets/5732642/15008505/fa32a904-11e0-11e6-900a-98622e3f797a.png" alt="constipated-koala" style="max-width:100%;">
</p>

# Operation Constipated Koala

![Master:](https://github.com/svsticky/constipated-Koala/actions/workflows/build.yml/badge.svg?branch=master)
![Development:](https://github.com/svsticky/constipated-Koala/actions/workflows/build.yml/badge.svg)

This is the repository of the admin system used by Study Association Sticky. It has been
written in Ruby with the help of the Rails framework and some libraries.

Currently, it implements methods to track several things within the association:

- Members and membership status;
- Activities and participants;
- Payments via iDeal;
- Committees and other groups;
- Operation Dead Mongoose (TM) and Mongoose credit
- [OAuth authentication](/app/controllers/api) and authorization endpoint;
- Basic logging of most operations.

Koala has an [api](/app/views/api), it is used by [Radio](https://github.com/svsticky/radio), [static-sticky](https://github.com/svsticky/static-sticky) and [magnificent-sloth](https://github.com/svsticky/magnificent-sloth) at the moment. However this api uses OAuth to create more awesome applications without hacking it into Koala itself, so anybody can build an application.

## Starting with Koala

**An extensive tutorial on [how to install Koala](/INSTALLING.md) on your laptop or on a production server is available.**.

Koala is quite a large program, and has many integrations.
To test and use some of the functionality, access to external api's is needed.
Credentials can be found in the IT Crowd or CommIT password managers.
Most notably, Koala integrates with MailChimp, MailGun and Mollie.

```shell
# Add hosts for different subdomains on your own computer for development
$ echo "127.0.0.1 koala.rails.local wordlid.rails.local" >> /etc/hosts
```

## Running Koala

```console
# Start the database again
$ docker-compose up
```

You can run Koala itself by running this command:

```console
$ nix-shell
$ rails s
```

This will start a server that listens until you press Ctrl-C in the window where it's running.

It might be neccesary to remove your existing node_modules folder, if it exists.
Yarn might fail otherwise.

To precompile the assets, run (in the Nix shell):

``` bash
dotenv rails assets:precompile
```

When editing JavaScript or CSS that is managed by Webpack, run the webpack development server.
This can be started with (again in the Nix shell):

``` bash
bundle exec bin/webpack-dev-server
```

## Future

Constipated Koala is started as a tool for the board of Sticky in a very limited way; tracking members.
Later on activities, groups, checkout ([POS](https://en.wikipedia.org/wiki/Point_of_sale)), user login and payments were added.

Because of the sheer size of the codebase, we are looking into option to split parts off.
For example, the Mongoose ecosystem deserves it's own backend.
We think the core of Koala is, and always should be, member management.
All other features are just extra's that might as well live in their own application.
This should keep the codebase to a workable size, and ensure a bright future for Koala.
We hope this alligns with the vision of the original creator, Martijn Casteel, who once wrote here: "I would like to see that in ten years it still is a tool for the board of Sticky."

## Contributing

Please read the [contributing guideliness](./CONTRIBUTING.md).
If you are updating dependencies, please read the [dependency managment guideline](./DEPENDENCIES.md)

## OAuth

OAuth was added to allow the commit or any other group to play with the data available in Koala without hacking it into Koala itself.
So if you would like to build an app for Sticky which is not directly affiliated with member administration do so in a different app using OAuth to authenticate and retrieve information (I do recon some things need to be added to the member pages of Koala, such as groups and activities).

Contact the IT Crowd if you want to provide an Sticky related application with OAuth login.

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

