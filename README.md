# Operation Constipated Koala
[![Circle CI](https://circleci.com/gh/svsticky/constipated-koala/tree/master.svg?style=svg&circle-token=21e53c86a26918537111d53fa15ba2e66f35a851)](https://circleci.com/gh/svsticky/constipated-koala/tree/master)

This is the repository of the admin system of Study Association Sticky. It has been
written in Ruby with the help of the Rails framework.

Currently, it implements methods to track several things within the association:

 - members and membership,
 - activities and payments,
 - committees and other groups,
 - operation Dead Mongoose (TM) and it's expenses,
 - [OAuth authentication](/app/controllers/api) and authorization endpoint, and
 - basic logging of most operations.

And koala has a an [api](/app/views/api), it is used by RADIO and Checkout at the moment. However the api uses OAuth to create more awesome applications without hacking it into koala itself.

## Starting with koala
**An [extensive tutorial on how to install](/config/deployment) koala on your laptop or on a production server is available.**.

There are a few *strange* things happening in koala. For one, it is integrated with an [ideal platform](https://github.com/svsticky/ideal.local). Without proper setting the [.rbenv-vars](.rbenv-vars-sample) it will nog work. Secondly it uses amazon for storing posters and images of mongoose products. In development this should also work on the local machine without amazon's S3 servers.

And a few regretful things; posters are uploaded as pdf's, they will be resized and stored in two formats. However the parsing of a pdf file is not working very well and I had to hack in ghostscript to get it working. Fuzzily is hacked into to ensure filtering first with a `where` and then perform a search on the subset just created. Both of them are defined in `config/initializers`.

## Future
Constipated koala is started as a tool for the board of Sticky in a very limited way; tracking members. Later on activities, groups, checkout, and user login were added. I would like to see that in ten years it still is a tool for the board of Sticky. Developing started because the previous inhouse-build tool (written in php) started to break down. Rails proven to be a good candidate, a very solid foundation where the model-view-controller paradigm is enforced. At it's core it should remain to be an app for the board and new features should not be implemented at the expense of newly introduced bugs or not workable situations (changing stuff in the database directly would be bad!).

According to the roadmap there are some new features to be implemented which should be added without breaking anything else. Please read the [contributing guideliness](https://github.com/svsticky/constipated-koala/blob/development/CONTRIBUTING.md).

OAuth was added to allow the commit or any other group to play with the data available in koala without hacking it into koala. So if you would like to build an app for Sticky which is not directly affiliated with member administration do so in a different app using OAuth to authenticate and retrieve information (I do recon some things need to be added to the member pages of koala, such as groups and activities).

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
