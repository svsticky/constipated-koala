# Deploying Koala while having less of a risk of data loss

Note: this guide assumes only a upgrade of Koala's codebase. Changing the nginx
config is out of scope, and will be done separately.

1. Ensure that the outage is known by at least one person who is not imaginary
	and who is a board member (bestuurslid). You might want to shut Checkout
	down to prevent inconsistencies.
1. Ensure that there is a tag at the current revision running on the server,
	and a tag at the revision to be deployed.
1. Log in to the server.
1. `sudo -u admin -i` to open a shell as the user with owner rights to koala.
	Also ensure you're in a `tmux` session or have a separate terminal open to
	`sudo` other things in.
1. As `admin`, `cd /var/www/koala.svsticky.nl`
1. As yourself, `sudo service unicorn stop`. **Checkout, Radio and the Zuil
	will stop working from here on.**
1. Ensure koala has stopped completely (`pgrep ruby` returns no processes).
1. In PHPMyAdmin, create a database backup of _at least_ the entire `koala`
	database, download this to a non-`/tmp` location, and upload it to S3 with
	a descriptive name (`koala-db-predeploy-yyyy-mm-dd.sql`).
1. In your `admin`-shell:
	- `git pull`
	- `git checkout $TARGET_REVISION` (zelf invullen)
	- `bundle`  
		This process will ensure all dependencies are installed. If this
		process fails, we either are missing some package needed to build an
		extension, or something else broke. If the package can be installed,
		install it, else, abort.
	- `RAILS_ENV=production bundle exec rake db:migrate:status`  
		This command will give information about which database migrations are
		present, and whether or not they have been performed. If there are any
		*new* migrations with the `*** NO FILE ***` marker, or any older
		migrations listed as `down`, stop and try to find out why that is.
	- `RAILS_ENV=production bundle exec rake db:migrate`  
		If this fails, you might need to restore the database backup.
1. If everything went well, you _should_ be able to start Koala again by
	running (as non-`admin`): `sudo service koala start`. Verify that you can
	log in, and that the [API] is responding.

## Reverting non-destructive migrations
In order to revert a set number of migrations, the command `bundle exec rake
db:rollback STEP=$n` can be used. This will revert the effects of the `$n` most
recent migrations, like this:

```bash
$ bundle exec rake db:migrate:status
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20160402084056  Add table and stuff
   up     20160506121430  Broken nonsense
   up     20160802082751  Revert me
   up     20160817130851  Dumpster fire

$ bundle exec rake db:rollback STEP=3
...

$ bundle exec rake db:migrate:status
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20160402084056  Add table and stuff
 down     20160506121430  Broken nonsense
 down     20160802082751  Revert me
 down     20160817130851  Dumpster fire
```

Do *not* use `db:migrate:down`, as this will only set a single revision to
`down`, instead of migrating down to the specified version.

[API]: https://koala.svsticky.nl/api/activities
