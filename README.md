<p align="center">
<img src="https://cloud.githubusercontent.com/assets/5732642/15008505/fa32a904-11e0-11e6-900a-98622e3f797a.png" alt="constipated-koala" style="max-width:100%;">
</p>

# Operation Constipated Koala
[![Circle CI](https://circleci.com/gh/svsticky/constipated-koala/tree/master.svg?style=svg&circle-token=21e53c86a26918537111d53fa15ba2e66f35a851)](https://circleci.com/gh/svsticky/constipated-koala/tree/master)

This is the repository of the admin system used by Study Association Sticky. It has been
written in Ruby with the help of the Rails framework and some libraries.

Currently, it implements methods to track several things within the association:

 - members and membership,
 - activities and payments,
 - committees and other groups,
 - operation Dead Mongoose (TM) and it's expenses,
 - [OAuth authentication](/app/controllers/api) and authorization endpoint, and
 - basic logging of most operations.

Koala has an [api](/app/views/api), it is used by RADIO and Checkout at the moment. However this api uses OAuth to create more awesome applications without hacking it into koala itself, so anybody can build an application.

## Starting with koala
**An extensive tutorial on [how to install koala](/INSTALLING.md) on your laptop or on a production server is available.**.

There are a few *strange* things happening in koala. For one, Mollie is used as the ideal provider. Without proper setting the [.env](sample.env) it will not work.

And a regretful thing; Fuzzily is hacked into to ensure filtering first with a `where` and then perform a search on the subset just created. Both of them are defined in `config/initializers`. Currently I made a fuzzily-fork to fix some problems, I will try to move these changes to the fork.

```shell
# Add hosts for different subdomains on your own computer for development
$ echo "127.0.0.1 koala.rails.local intro.rails.local" >> /etc/hosts
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

This will start a server that listens until you press Ctrl-C in the window
where it's running.

## Future
Constipated koala is started as a tool for the board of Sticky in a very limited way; tracking members. Later on activities, groups, checkout ([POS](https://en.wikipedia.org/wiki/Point_of_sale)), and user login was added. I would like to see that in ten years it still is a tool for the board of Sticky. Developing started because the previous inhouse-build tool (written in php) started to break down. Rails proven to be a good candidate, a very solid foundation where the model-view-controller paradigm is enforced. At it's core it should remain to be an app for the board and new features should not be implemented at the expense of newly introduced bugs or not workable situations (changing stuff in the database directly would be bad!).

According to the roadmap there are some new features to be implemented which should be added without breaking anything else. Please read the [contributing guideliness](https://github.com/svsticky/constipated-koala/blob/development/CONTRIBUTING.md).

OAuth was added to allow the commit or any other group to play with the data available in koala without hacking it into koala itself. So if you would like to build an app for Sticky which is not directly affiliated with member administration do so in a different app using OAuth to authenticate and retrieve information (I do recon some things need to be added to the member pages of koala, such as groups and activities).

_Sidenote; As most of you guys I'm a programmer, design is yuk, however I do like the looks at the moment and if you implement something new it **should** look somewhat similar and presentable for all users; members, admins, and informatiekundigen._

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
