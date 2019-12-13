<img width="250" src="./logo.svg" alt="Solidus logo">

# Solidus

[![Circle CI](https://circleci.com/gh/solidusio/solidus/tree/master.svg?style=shield)](https://circleci.com/gh/solidusio/solidus/tree/master)
[![Gem](https://img.shields.io/gem/v/solidus.svg)](https://rubygems.org/gems/solidus)
[![License](http://img.shields.io/badge/license-BSD-yellowgreen.svg)](LICENSE.md)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

[![Enthusiasts on Open Collective](https://opencollective.com/solidus/tiers/enthusiast/badge.svg?label=Enthusiasts&color=brightgree)](https://opencollective.com/solidus)
[![Supporters on Open Collective](https://opencollective.com/solidus/tiers/supporter/badge.svg?label=Supporters&color=brightgree)](https://opencollective.com/solidus)
[![Ambassadors on Open Collective](https://opencollective.com/solidus/tiers/ambassador/badge.svg?label=Ambassador&color=brightgree)](https://opencollective.com/solidus)
[![Open Source Helpers](https://www.codetriage.com/solidusio/solidus/badges/users.svg)](https://www.codetriage.com/solidusio/solidus)
[![Slack](http://slack.solidus.io/badge.svg)](http://slack.solidus.io)

**A free, open-source ecommerce platform that gives you complete control over your store.**

- **Visit our website**: [https://solidus.io/](https://solidus.io/)
- **Read our guides**: [https://guides.solidus.io/developers/](https://guides.solidus.io/developers/)
- **Join our Slack**: [http://slack.solidus.io/](http://slack.solidus.io/)
- **Solidus Security**: [mailing list](https://groups.google.com/forum/#!forum/solidus-security)


## Table of Contents
- [Supporting Solidus](#supporting-solidus)
- [Summary](#summary)
- [Demo](#demo)
- [Getting Started](#getting-started)
- [Installation Options](#installation-options)
- [Performance](#performance)
- [Developing Solidus](#developing-solidus)
- [Contributing](#contributing)

## Supporting Solidus
As a community-driven project, Solidus relies on funds and time donated by developers and stakeholders who use Solidus for their businesses. If you'd like to help Solidus keep growing, please consider:

- [Become a backer or sponsor on Open Collective](https://opencollective.com/solidus).
- [Contribute to the project](https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md).

### Main Contributor & Director
At present, Nebulab is the main code contributor and director of Solidus, providing technical guidance and coordinating community efforts and activities.

[![Nebulab](https://nebulab.it/assets/images/public/logo.svg)](https://nebulab.it/)

### Ambassadors
Support this project by becoming a Solidus Ambassador. Your logo will show up here with a link to your website. [Become an Ambassador](https://opencollective.com/solidus).

|[![Engine](https://images.opencollective.com/proxy/images?src=https%3A%2F%2Flogo.clearbit.com%2Fenginecommerce.com&height=100)](https://www.enginecommerce.com/)|[![Super Good Software](https://images.opencollective.com/proxy/images?src=https%3A%2F%2Fopencollective-production.s3-us-west-1.amazonaws.com%2F3bbb1440-727f-11e9-a366-37673cc38cee.png&height=100)](https://supergood.software/)|[![Karma Creative](https://images.opencollective.com/proxy/images?src=https%3A%2F%2Fopencollective-production.s3-us-west-1.amazonaws.com%2Fab94d2a0-7253-11e9-a366-37673cc38cee.png&height=100)](https://karmacreative.io/)|
[![ModdedEuros](https://images.opencollective.com/proxy/images?src=https%3A%2F%2Fimages.opencollective.com%2Fmodded-euros%2Ff1a80ae%2Flogo.png&height=100)](https://www.moddedeuros.com)|
|---|---|---|---|

---

## Summary

Solidus is a complete open source ecommerce solution built with Ruby on Rails.
It is a fork of [Spree](https://spreecommerce.org).

See the [Solidus class documentation](http://docs.solidus.io) and the [Solidus
Guides](https://guides.solidus.io) for information about the functionality that
Solidus provides.

Solidus consists of several gems. When you require the `solidus` gem in your
`Gemfile`, Bundler will install all of the gems maintained in this repository:

- [`solidus_api`](https://github.com/solidusio/solidus/tree/master/api) (RESTful API)
- [`solidus_frontend`](https://github.com/solidusio/solidus/tree/master/frontend) (Cart and storefront)
- [`solidus_backend`](https://github.com/solidusio/solidus/tree/master/backend) (Admin area)
- [`solidus_core`](https://github.com/solidusio/solidus/tree/master/core) (Essential models, mailers, and classes)
- [`solidus_sample`](https://github.com/solidusio/solidus/tree/master/sample) (Sample data)

All of the gems are designed to work together to provide a fully functional
ecommerce platform. However, you may only want to use the
[`solidus_core`](https://github.com/solidusio/solidus/tree/master/core) gem
combine it with your own custom frontend, admin interface, and API.

## Demo

Try out Solidus with one-click on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/solidusio/solidus-example-app)

Alternatively, you can use Docker to run a demo on your local machine. Run the
following command to download the image and run it at
[http://localhost:3000](http://localhost:3000).

```
docker run --rm -it -p 3000:3000 solidusio/solidus-demo:latest
```

The admin interface can be accessed at
[http://localhost:3000/admin/](http://localhost:3000/admin/), the default
credentials are `admin@example.com` and `test123`.

## Getting started

Begin by making sure you have
[Imagemagick](http://imagemagick.org/script/download.php) installed, which is
required for Paperclip. (You can install it using [Homebrew](https://brew.sh) if
you're on a Mac.)

To add solidus, begin with a Rails 5/6 application and a database configured and
created. Add the following to your Gemfile.

```ruby
gem 'solidus'
gem 'solidus_auth_devise'
```

Run the `bundle` command to install.

After installing gems, you'll have to run the generators to create necessary
configuration files and migrations.

```bash
bundle exec rails g spree:install
bundle exec rails g solidus:auth:install
bundle exec rake railties:install:migrations
```

Run migrations to create the new models in the database.

```bash
bundle exec rake db:migrate
```

Finally start the rails server

```bash
bundle exec rails s
```

The [`solidus_frontend`](https://github.com/solidusio/solidus/tree/master/frontend) storefront will be accessible at [http://localhost:3000/](http://localhost:3000/)
and the admin can be found at [http://localhost:3000/admin/](http://localhost:3000/admin/).

For information on how to customize your store, check out the [customization guides](https://guides.solidus.io/developers/customizations/overview.html).

### Default Username/Password

As part of running the above installation steps, you will be asked to set an admin email/password combination. The default values are `admin@example.com` and `test123`, respectively.

### Questions?

The best way to ask questions is to [join the Solidus Slack](http://slack.solidus.io/) and join the [#support channel](https://solidusio.slack.com/messages/support/details/).

## Installation options

Instead of a stable build, if you want to use the bleeding edge version of
Solidus, use this line:

```ruby
gem 'solidus', github: 'solidusio/solidus'
```

**Note: The master branch is not guaranteed to ever be in a fully functioning
state. It is too risky to use this branch in production.**

By default, the installation generator (`rails g spree:install`) will run
migrations as well as adding seed and sample data. This can be disabled using

```bash
rails g spree:install --migrate=false --sample=false --seed=false
```

You can always perform any of these steps later by using these commands.

```bash
bundle exec rake railties:install:migrations
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake spree_sample:load
```

There are also options and rake tasks provided by
[solidus\_auth\_devise](https://github.com/solidusio/solidus_auth_devise).

## Performance

You may notice that your Solidus store runs slowly in development mode. This
can be because in development each CSS and JavaScript is loaded as a separate
include. This can be disabled by adding the following to
`config/environments/development.rb`.

```ruby
config.assets.debug = false
```

### Turbolinks

To gain some extra speed you may enable Turbolinks inside of Solidus admin.

Add `gem 'turbolinks', '~> 5.0.0'` into your `Gemfile` (if not already present)
and change `vendor/assets/javascripts/spree/backend/all.js` as follows:

```js
//= require turbolinks
//
// ... current file content
//
//= require spree/backend/turbolinks-integration.js
```

**CAUTION** Please be aware that Turbolinks can break extensions
and/or customizations to the Solidus admin. Use at your own risk.

## Developing Solidus

* Clone the Git repo

  ```bash
  git clone git://github.com/solidusio/solidus.git
  cd solidus
  ```

* Install the gem dependencies

  ```bash
  bundle install
  ```

  _Note_: If you're using PostgreSQL or MySQL, you'll need to install those gems through the DB environment variable.

  ```bash
  # PostgreSQL
  DB=postgresql bundle install

  # MySQL
  DB=mysql bundle install
  ```

### Sandbox

Solidus is meant to be run within the context of Rails application. You can
easily create a sandbox application inside of your cloned source directory for
testing purposes.

This sandbox includes solidus\_auth\_devise and generates with seed and sample
data already loaded.

* Create the sandbox application

  ```bash
  bundle exec rake sandbox
  ```

  You can create a sandbox with PostgreSQL or MySQL by setting the DB environment variable.

  ```bash
  # PostgreSQL
  DB=postgresql bundle exec rake sandbox

  # MySQL
  DB=mysql bundle exec rake sandbox
  ```

  If you need to create a Rails 5.2 application for your sandbox, for example
  if you are still using Ruby 2.4 which is not supported by Rails 6, you can
  use the `RAILS_VERSION` environment variable.

  ```bash
    export RAILS_VERSION='~> 5.2.0'
    bundle install
    bundle exec rake sandbox
  ```

* Start the server

  ```bash
  cd sandbox
  rails server
  ```

### Tests

Solidus uses [RSpec](http://rspec.info) for tests. Refer to its documentation for
more information about the testing library.

#### CircleCI

We use CircleCI to run the tests for Solidus as well as all incoming pull
requests. All pull requests must pass to be merged.

You can see the build statuses at
[https://circleci.com/gh/solidusio/solidus](https://circleci.com/gh/solidusio/solidus).

#### Run all tests

[ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/home) is
required to run the frontend and backend test suites.

To execute all of the test specs, run the `bin/build` script at the root of the Solidus project:

```bash
createuser --superuser --echo postgres # only the first time
bin/build
```

The `bin/build` script runs using PostgreSQL by default, but it can be overridden by setting the DB environment variable to `DB=sqlite` or `DB=mysql`. For example:

```bash
env DB=mysql bin/build
```

If the command fails with MySQL related errors you can try creating a user with this command:

```bash
# Creates a user with the same name as the current user and no restrictions.
mysql --user="root" --execute="CREATE USER '$USER'@'localhost'; GRANT ALL PRIVILEGES ON * . * TO '$USER'@'localhost';"
```

#### Run an individual test suite

Each gem contains its own series of tests. To run the tests for the core project:

```bash
cd core
bundle exec rspec
```

By default, `rspec` runs the tests for SQLite 3. If you would like to run specs
against another database you may specify the database in the command:

```bash
env DB=postgresql bundle exec rspec
```

#### Code coverage reports

If you want to run the [SimpleCov](https://github.com/colszowka/simplecov) code
coverage report:

```bash
COVERAGE=true bundle exec rspec
```

### Extensions

In addition to core functionality provided in Solidus, there are a number of
ways to add features to your store that are not (or not yet) part of the core
project.

A list can be found at [extensions.solidus.io](http://extensions.solidus.io/).

If you want to write an extension for Solidus, you can use the
[solidus_cmd](https://www.github.com/solidusio/solidus_cmd.git) gem.

## Contributing

Solidus is an open source project and we encourage contributions. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
