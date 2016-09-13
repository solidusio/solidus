
![](https://raw.githubusercontent.com/solidusio/solidus/master/solidus.png)

* [solidus.io](http://solidus.io/)
* [Join our Slack](http://slack.solidus.io/) ([solidusio.slack.com](http://solidusio.slack.com))
* [#solidus.io](http://webchat.freenode.net/?channels=solidus.io) on freenode
* [solidus-security](https://groups.google.com/forum/#!forum/solidus-security) mailing list

Summary
-------

Solidus is a complete open source e-commerce solution built with Ruby on Rails. It
is a fork of Spree.

Solidus actually consists of several different gems, each of which are maintained
in a single repository and documented in a single set of
[online documentation](http://docs.solidus.io/). By requiring the
[`solidus`](https://github.com/solidusio/solidus) gem you automatically require all
of the necessary gem dependencies which are:

* [`solidus_api`](https://github.com/solidusio/solidus/tree/master/api) (RESTful API)
* [`solidus_frontend`](https://github.com/solidusio/solidus/tree/master/frontend) (Cart and storefront)
* [`solidus_backend`](https://github.com/solidusio/solidus/tree/master/backend) (Admin area)
* [`solidus_core`](https://github.com/solidusio/solidus/tree/master/core) (Essential models, mailers, and classes)
* [`solidus_sample`](https://github.com/solidusio/solidus/tree/master/sample) (Sample data)

All of the gems are designed to work together to provide a fully functional
e-commerce platform. It is also possible, however, to use only the pieces you
are interested in. For example, you could use just the barebones
[`solidus_core`](https://github.com/solidusio/solidus/tree/master/core) gem and perhaps combine it with your own
custom frontend instead of using [`solidus_frontend`](https://github.com/solidusio/solidus/tree/master/frontend).

[![Circle CI](https://circleci.com/gh/solidusio/solidus/tree/master.svg?style=shield)](https://circleci.com/gh/solidusio/solidus/tree/master)
[![Gem](https://img.shields.io/gem/v/solidus.svg)](https://rubygems.org/gems/solidus)
[![License](http://img.shields.io/badge/license-BSD-yellowgreen.svg)](LICENSE.md)

Demo
----
Try out Solidus with one-click on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/solidusio/solidus)

Getting started
---------------

To add solidus, begin with a rails 4.2 application. Add the following to your
Gemfile.

```ruby
gem 'solidus'
gem 'solidus_auth_devise'
```

Run the `bundle` command to install.

After installing gems, you'll have to run the generators to create necessary
configuration files and migrations.

```
bundle exec rails g spree:install
bundle exec rails g solidus:auth:install
bundle exec rake railties:install:migrations
```

Run migrations to create the new models in the database.

```
bundle exec rake db:migrate
```

Finally start the rails server

```
bundle exec rails s
```

The [`solidus_frontend`](https://github.com/solidusio/solidus/tree/master/frontend) storefront will be accessible at [http://localhost:3000/](http://localhost:3000/)
and the admin can be found at [http://localhost:3000/admin/](http://localhost:3000/admin/).

### Default Username/Password

As part of running the above installation steps, you will be asked to set an admin email/password combination. The default values are `admin@example.com` and `test123`, respectively.

### Questions?

The best way to ask questions is via the [#support channel on the Solidus Slack](https://solidusio.slack.com/messages/support/details/).

Installation options
--------------------

Instead of a stable build, if you want to use the bleeding edge version of
Solidus, use this line:

```ruby
gem 'solidus', github: 'solidusio/solidus'
```

**Note: The master branch is not guaranteed to ever be in a fully functioning
state. It is unwise to use this branch in a production system you care deeply
about.**

By default, the installation generator (`rails g spree:install`) will run
migrations as well as adding seed and sample data. This can be disabled using

```shell
rails g spree:install --migrate=false --sample=false --seed=false
```

You can always perform any of these steps later by using these commands.

```shell
bundle exec rake railties:install:migrations
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake spree_sample:load
```

There are also options and rake tasks provided by
[solidus\_auth\_devise](https://github.com/solidusio/solidus_auth_devise).

Performance
-----------

You may notice that your Solidus store runs slowly in development mode. This
can be because in development each css and javascript is loaded as a separate
include. This can be disabled by adding the following to
`config/environments/development.rb`.

```ruby
config.assets.debug = false
```

Developing Solidus
------------------

* Clone the Git repo

    ```shell
    git clone git://github.com/solidusio/solidus.git
    cd solidus
    ```

* Install the gem dependencies

    ```shell
    bundle install
    ```

### Sandbox

Solidus is meant to be run within the context of Rails application. You can
easily create a sandbox application inside of your cloned source directory for
testing purposes.

This sandbox includes solidus\_auth\_devise and generates with seed and sample
data already loaded.

* Create the sandbox application (`DB=mysql` or `DB=postgresql` can be specified
  to override the default sqlite)

  ```shell
  bundle exec rake sandbox
  ```

* Start the server

    ```shell
    cd sandbox
    rails server
    ```

### Tests

#### CircleCI
We use CircleCI to run the tests for Solidus as well as all incoming pull
requests. All pull requests must pass to be merged.

You can see the build statuses at
[https://circleci.com/gh/solidusio/solidus](https://circleci.com/gh/solidusio/solidus)

#### Running all tests

To execute all the tests, run this command at the root of the Solidus project
to generate test applications and run specs for all projects:

```shell
bash build.sh
```

This runs using postgresql by default, but can be overridden by specifying
`DB=sqlite` or `DB=mysql` in the environment.

[PhantomJS](http://phantomjs.org/) is required for the frontend and backend
test suites.

#### Running an individual test suite

Each gem contains its own series of tests, and for each directory, you need to
do a quick one-time creation of a test application and then you can use it to run
the tests.  For example, to run the tests for the core project.
```shell
cd core
bundle exec rake test_app
bundle exec rspec spec
```

If you would like to run specs against a particular database you may specify the
dummy apps database, which defaults to sqlite3.
```shell
DB=postgresql bundle exec rake test_app
```

You can also enable fail fast in order to stop tests at the first failure
```shell
FAIL_FAST=true bundle exec rspec spec/models/state_spec.rb
```

If you want to run the simplecov code coverage report
```shell
COVERAGE=true bundle exec rspec spec
```

### Extensions
In addition to core functionality provided in Solidus, there are a number of ways to add
features to your store that are not (or not yet) part of the core project.

A list can be found at [extensions.solidus.io](http://extensions.solidus.io/).

Contributing
------------

Solidus is an open source project and we encourage contributions. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
