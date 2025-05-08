# CLI Interaction

![image](https://i.imgflip.com/9tbq2d.jpg)

**This time, we will discuss the commandline interactions with Koala.**

Most if not all common interactions (creating a new admin account, reseeding database, etc.)
are programmed for you in the shape of rake tasks.
These tasks allow you to perform these routines without hassle, and no human mistakes.
However, this document not only covers rake tasks, but also how in general you should use the CLI
properly to talk to koala and its database.

## TLDR;

If you love one-liners:

```bash
$ sudo -u koala nix-shell --run 'dotenv bundle exec rake --tasks'
rake about                                        # List versions of all Rails frameworks and the environment
rake action_mailbox:ingress:exim                  # Relay an inbound email from Exim to Action Mailbox (URL and INGRESS_PASSWORD required)
rake action_mailbox:ingress:postfix               # Relay an inbound email from Postfix to Action Mailbox (URL and INGRESS_PASSWORD required)
rake action_mailbox:ingress:qmail                 # Relay an inbound email from Qmail to Action Mailbox (URL and INGRESS_PASSWORD required)
rake action_mailbox:install                       # Installs Action Mailbox and its dependencies
...
```

## How to run commands in koala, generically

Koala is complicated.
Thus, every command must be run in a nix-shell.
Also, you must ensure you have read permissions for all koala's files.
Lastly, all environment variables must be loaded.

Hence, you must do the following in some sorts in preperation:

```
sudo -u koala bash
nix-shell
```

Now that your environment is prepared, you can do all sorts of commands.
However, if you need to make use of environment variables (when in doubt: yes), prefix all commands with `dotenv`:

```
dotenv rake --tasks
```

## Running koala-specific commands (rails)

In addition to the above, when interacting with koala's components through rails,
you must use bundler.

Koala runs on Ruby on Rails, which brings many `gem`s with it.
All koala-specific commands like database management must make sure that they interact
with the right versions of the gems and tools.
For example, when using rake, rake might be globally installed.
To ensure you use the right versions (think og pyenv), use bundler:

```bash
$ dotenv bundle exec echo I like turtles
I like turtles
```

A more practical example:

```
dotenv bundle exec rake --tasks
```

This way, you make sure you use the right tools.

## Those rake tasks I mentioned

Now, finally, we can interact with rake, one of koala's tools.
Rake is a Ruby on Rails utility which runs ruby scripts for you, talking to koala.
For example, you can reseed the database with this using a single command.

### Usage

Assuming you have the permissions, nix-shell, etc, you can see all configured rake tasks as follows:

```bash
$ dotenv bundle exec rake --tasks
rake about                                        # List versions of all Rails frameworks and the environment
rake action_mailbox:ingress:exim                  # Relay an inbound email from Exim to Action Mailbox (URL and INGRESS_PASSWORD required)
rake action_mailbox:ingress:postfix               # Relay an inbound email from Postfix to Action Mailbox (URL and INGRESS_PASSWORD required)
rake action_mailbox:ingress:qmail                 # Relay an inbound email from Qmail to Action Mailbox (URL and INGRESS_PASSWORD required)
rake action_mailbox:install                       # Installs Action Mailbox and its dependencies
```

This shows all possible rake tasks. Let's drop the database (don't)!

```bash
$ dotenv bundle exec rake db:drop
no
```

### Configuration

All rake tasks are interpreted and found from `/lib/tasks/`.
If you need to understand the workings of a task, find the rake file in there.
You can also of course change the rake files or create new ones.