# Migrate from Spree

You can migrate your Spree store to Solidus. This article outlines what you
need, how to migrate, and the common problems you should be aware of before
making the switch.

Note that most migrations are not a one-click process. Every store is different
and will have different requirements.

## Prerequisites

- Familiarity with Ruby on Rails.
- Familiarity with your Rails application and your store's database.
- A store running on Spree 2.2, 2.3, or 2.4.
- A Rails application that can readily be upgraded from 4.1.x to a newer
  version.

If your store uses an earlier version of Spree, consider upgrading to 2.4 before
you start the migration process. If your store runs 3.0 or newer, see our note
about [migrating from Spree 3.0 or newer](#migrating-from-spree-3-0-or-newer).

Remember that you should **always back up your databases before attempting a
migration in a production environment.**

## Required reading

- [The Rails Upgrade Guide](http://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [How to upgrade to Rails 4.2](https://www.justinweiss.com/articles/how-to-upgrade-to-rails-4-dot-2/)

## Process

*This article walks you through a basic migration from Spree 2.4 to Solidus 1.4.
Note that if you have customized your Spree-based store, or you use another
version of Spree, this article may not include additional migration steps that
you need to perform. After you have successfully upgraded to Solidus 1.4, you
can [incrementally upgrade to the most recent
version](#upgrade-solidus-incrementally).*

You are running a store on Spree 2.4.4. You use the standard `spree_auth_devise`
gem for authentication, and your application runs on Rails 4.1.x. Your `Gemfile`
has the following lines:

```ruby
gem 'spree', '~> 2.4.0'
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-4-stable'

gem 'rails', '~> 4.1.0'
```

You want to migrate from Spree to Solidus. To make the upgrade process more
straightforward, you plan to migrate to Solidus 1.4 before upgrading to Solidus
2.0 and beyond.

### Replace Spree gems in your Gemfile

First, replace the Spree gems in your `Gemfile`. In their place, you are going
to add Solidus gems locked to their `1.4` versions. You may want to keep the
lines from your Spree gems commented out for reference:

```ruby
gem 'solidus', '~> 1.4.0'
gem 'solidus_auth_devise', '~> 1.4.0'

# gem 'spree', '~> 2.4.0'
# gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-4-stable'
```

### Prepare to upgrade Rails to 4.2.x

If you attempt to run `bundle update` at this point, notice that Bundler runs
into a number of dependency issues. Next, you need to upgrade to Rails 4.2 for
this migration.

Update the Rails version in your `Gemfile` to `~> 4.2.0`:

```ruby
gem 'rails', '~> 4.2.0'
```

Note that upgrading Rails affects many other gem versions in your application.

If you use Rails' default asset pipeline, for example, we recommend that you
explicitly update the versions of the `sass-rails` gem in your `Gemfile`, as
well as explicitly setting the versions for the dependencies `sprockets` and
`bourbon`:

```ruby
gem 'sprockets', '2.11.0'
gem 'bourbon', '< 5.0.0'
gem 'sass-rails', '~> 4.0.0'
```

### Run bundle update

After you have replaced the Spree gems in your `Gemfile` and prepared to upgrade
Rails to 4.2.x, you can update your application with Bundler:

```bash
bundle update
```

At this point, the update should run successfully. If it does not, check your
`Gemfile` for other gems that require specific updates to their dependencies.

### Install Solidus migrations

Now that you have successfully installed the Solidus gems, you need to copy all
of the Solidus-specific migrations into your application:

```bash
bundle exec rake railties:install:migrations
```
### Start the Solidus installation process

Now that your Spree store includes Solidus and its migrations, you can start the
Solidus install process:

1. Run `bundle exec rails generate spree:install`.
2. Run `bundle exec rails generate solidus:auth:install`.
3. Run `bundle exec rake db:migrate`.

During the `rails generate spree:install` step, Rails should prompt you to
overwrite some configuration files:

- `/config/initializers/spree.rb`: Adds additional default configuration
  settings for Solidus gems.
- `/vendor/assets/javascripts/spree/frontend/all.js`: Removes an empty line.
- `/vendor/assets/stylesheets/spree/frontend/all.css`: Removes an empty line.
- `/vendor/assets/javascripts/spree/backend/all.js`: Removes an empty line.
- `/vendor/assets/stylesheets/spree/backend/all.css`: Removes an empty line.

You can respond to the prompt with `d` to see a diff of the changes to each
file.

The `rails generate spree:install` step also asks if you would like to create
another admin user. However, you can safely continue using the admin user from
Spree.

### Manage deprecation warnings

After upgrading your Spree 2.4 application to Solidus 1.4, you may see some
deprecation warnings. The amount of deprecation warnings depends on how many
Spree features you use that are being deprecated in Solidus, as well as
additional gems your application uses.

If you plan to upgrade to Solidus 2.0, you need to deal with the deprecated code
within your application code. The warnings should give you straightforward
solutions.

For deprecation warnings that come from specific gems, you may be able to get
rid of them by simply upgrading those gems.

### Upgrade Solidus incrementally

Now that you have transitioned from Spree to Solidus, you upgrade from Solidus
1.4 to the next major version: 2.0. From 2.0, you can upgrade to each minor
version incrementally until you are at the newest version.

Upgrading incrementally is less risky than upgrading straight from 1.4 to 2.4.
It ensures that you have all of the necessary migrations and don't inadvertently
break existing functionality in your application code.

Use the notes in [Solidus's changelog][changelog] to help you upgrade to each
minor version of Solidus gracefully.

[changelog]: https://github.com/solidusio/solidus/blob/master/CHANGELOG.md

## Migrating from Spree 3.0 or newer

Solidus is a fork of Spree 2.4. After Spree 2.4, the Spree and Solidus code
bases start to diverge. For example, Spree 3.0 introduces a Bootstrap-based
frontend and backend which is significantly different from Solidus's frontend
and backend.

If you run Spree 3.0 and want to migrate, we suggest that you upgrade to some
intermediate versions of Solidus first:

1. Upgrade to Solidus 1.4 first. This is the last version of Solidus that uses
   Rails 4.2.
2. Upgrade from Solidus 1.4 to Solidus 2.0, which runs on Rails 5.0.
3. Upgrade from Solidus 2.0 to Solidus 2.1. Solidus 2.1 removes methods that
   were deprecated in Solidus 1.4.

