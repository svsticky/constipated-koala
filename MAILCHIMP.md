# Mailchimp integration

TODO: sidekiq monitoring can be found at koala.svsticky.nl/sidekiq (admin only).

Koala has integration with Mailchimp.
This integration uses only one list, with are segmented with 5 groups: ALV, MMM, Business, Lectures and Teacher.
First name, last name and emailadress are synced, as are the alumni and pardon statusses.

The solution uses activejob with redis and sidekiq to start jobs on in the background.
These jobs sync with Mailchimp and retry if the connection is failed.
Interests and tags that are not configured in app.yml will be ignored in koala, koala will not change these in mailchimp.

## `The mailchimp manual`

### Mailchimp configuration

The first thing to do is configure Mailchimp.
If you did not create an audience yet, do this first.

In the audience settings, check if all merge tags allign with those in mailchimp_job.rb.

In the group settings (manage contacts > groups > view groups) you need to create the groups (or interests) you want to sync.
Currently these are ALV, MMM, Business, Lectures and Teacher.
The names here don't have to match, we will sync by id.

Also create an api key (or use an existing one).

### Webhook configuration

To sync changes made in Mailchimp back to Koala, a webhook is used.
Create a secret to verify the webhook calls (rails secret).

The webhook can be configured in Mailchimp under audience > settings > webhooks.
The webhook url should be ```https://koala.svsticky.nl/api/hook/mailchipm/\<secret\>```
Turn off email changes (this will result in errors otherwise), campaign sending and API changes.

### Extracting the id's of the interests [OUT OF DATE]

Using your api key you can log in on the Mailchimp [playground](https://us1.api.mailchimp.com/playground/).
You can find the list_id under lists > your list.
Interests can be found under lists > your list > subresources > interest-categories > subresources > interests.
Record the id's of the list and the interest.

### Environment variables

Fill in the following environment variables (in .rben-vars):

- MAILCHIMP_TOKEN: the api key you created before
- MAILCHIMP_SECRET: the webhook secret
- MAILCHIMP_DATACENTER: the part of the token after the hyphen
- MAILCHIMP_LIST_ID: the list id

Also create and fill in a environment variable for each interest you want to sync.
The interests are loaded in application.rb.

### Installation

Install redis.
Redis is used for storing the jobs temporary until the job process can execute it.
This makes sure a user doesn't have to wait on the response of mailchimp.

Create a cronjob or similar to start sidekiq.
The command to run is `bundle exec sidekiq`.

### More info

[The post that inspired us to build this](https://medium.com/@thomasroest/properly-setting-up-redis-and-sidekiq-in-production-on-ubuntu-16-04-f2c4897944b5)
