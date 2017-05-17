# Deploying Koala while having less of a risk of data loss

Note: this guide assumes only a upgrade of Koala's codebase. Changing the nginx
config is out of scope, and will be done separately.
Also note that this guide is based on the current skyblue server, and will
(hopefully) be obsolete and/or need rewriting when the ansible playbook is
done.

1. Ensure that the outage is known by at least one person who is not imaginary
	and who is a board member (bestuurslid). Also ensure that the IT-crowd is
	at least aware of your actions (preferably in the same room), both to
	prevent uninformed reboots and other mishaps and to provide emotional
	support in the event of a screw-up.
1. Ensure Checkout is shut down, to prevent inconsistencies.
1. Ensure that there is a tag at the current revision running on the server,
	and a tag at the revision to be deployed.
1. Log in to the server.
1. `sudo -u admin -i` to open a shell as the user with owner rights to koala.
	Also ensure you're in a `tmux` session or have a separate terminal open to
	`sudo` other things in.
1. As `admin`, `cd /var/www/koala.svsticky.nl`
1. As `admin`, `touch MAINTENANCE_MODE`. This will stop all requests with a 503
	at the nginx level, so don't forget to revert it!
1. As yourself, `sudo service unicorn stop`. **Checkout, Radio and the Zuil
	will stop working from here on.**
1. Ensure koala has stopped completely (`pgrep ruby` returns no processes).
1. Log in as the `koala` user in PHPMyAdmin, and use the 'pre-upgrade backup'
	export template to create a backup of the database. This will give you
	a file named like `pre-upgrade-koala-2017031518_i.sql`, save this file to
	a non-`/tmp` location AND upload it to S3.
1. In your `admin`-shell:
	- `git pull`
	- `git checkout $TARGET_REVISION` (zelf invullen)
	- `bundle`  
		This process will ensure all dependencies are installed. If this
		process fails, we either are missing some package needed to build an
		extension, or something else broke. If the package can be installed,
		install it, else, abort.
	- `RAILS_ENV=production bundle exec rake assets:clobber`  
		`RAILS_ENV=production bundle exec rake assets:precompile`
		This command will ensure that all assets compile, if this fails, abort.
	- `RAILS_ENV=production bundle exec rake db:migrate:status`  
		This command will give information about which database migrations are
		present, and whether or not they have been performed. If there are any
		*new* migrations with the `*** NO FILE ***` marker, or any older
		migrations listed as `down`, stop and try to find out why that is.
	- `RAILS_ENV=production bundle exec rake db:migrate`  
		If this fails, you might need to restore the database backup.
1. If everything went well, you _should_ be able to start Koala again by
	running (as non-`admin`): `sudo service koala start`.
1. Deactivate maintenance mode by removing
	`/var/www/koala.svsticky.nl/MAINTENANCE_MODE`, verify that you can log in,
	and that the [API] is responding.

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
