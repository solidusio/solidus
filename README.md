
![](https://raw.githubusercontent.com/solidusio/solidus/master/solidus.png)

Summary
-------

Solidus is a complete open source e-commerce solution built with Ruby on Rails. It
is a fork of Spree.

Solidus actually consists of several different gems, each of which are maintained
in a single repository and documented in a single set of
[online documentation](http://docs.solidus.io/). By requiring the
solidus gem you automatically require all of the necessary gem dependencies which are:

* solidus\_api (RESTful API)
* solidus\_frontend (User-facing components)
* solidus\_backend (Admin area)
* solidus\_core (Models & Mailers, the basic components of Solidus that it can't run without)
* solidus\_sample (Sample data)

All of the gems are designed to work together to provide a fully functional
e-commerce platform. It is also possible, however, to use only the pieces you
are interested in. For example, you could use just the barebones solidus\_core
gem and perhaps combine it with your own custom frontend instead of using
solidus\_frontend.

[![Circle CI](https://circleci.com/gh/solidusio/solidus/tree/master.svg?style=shield)](https://circleci.com/gh/solidusio/solidus/tree/master)
[![Gem](https://img.shields.io/gem/v/solidus.svg)](https://rubygems.org/gems/solidus)
[![License](http://img.shields.io/badge/license-BSD-yellowgreen.svg)](LICENSE.md)

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
bundle exec rake railties:install:migrations
```

Run migrations to create the new models in the database.

```
bundle exec rake db:migrate
```

Finally start the rails server

```
bundle exec rails s
````

The solidus_frontend storefront will be accessible at http://localhost:3000/
and the admin can be found at http://localhost:3000/admin/.


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

Working with the edge source (latest and greatest features)
-----------------------------------------------------------

The source code is essentially a collection of gems. Solidus is meant to be run
within the context of Rails application. You can easily create a sandbox
application inside of your cloned source directory for testing purposes.


1. Clone the Git repo

```shell
git clone git://github.com/solidusio/solidus.git
cd solidus
```

2. Install the gem dependencies

```shell
bundle install
```

3. Create a sandbox Rails application for testing purposes (and automatically
perform all necessary database setup)

```shell
bundle exec rake sandbox
```

4. Start the server

```shell
cd sandbox
rails server
```

Performance
-----------

You may notice that your Solidus store runs slowly in development mode. This
can be because in development each css and javascript is loaded as a separate
include. This can be disabled by adding the following to
`config/environments/development.rb`.

```ruby
config.assets.debug = false
```

Running Tests
-------------

We use CircleCI to run the tests for Solidus.

You can see the build statuses at [https://circleci.com/gh/solidusio/solidus](https://circleci.com/gh/solidusio/solidus)

---

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
DB=postgres bundle exec rake test_app
```

If you want to run specs for only a single spec file
```shell
bundle exec rspec spec/models/spree/state_spec.rb
```

If you want to run a particular line of spec
```shell
bundle exec rspec spec/models/spree/state_spec.rb:7
```

You can also enable fail fast in order to stop tests at the first failure
```shell
FAIL_FAST=true bundle exec rspec spec/models/state_spec.rb
```

If you want to run the simplecov code coverage report
```shell
COVERAGE=true bundle exec rspec spec
```

If you're working on multiple facets of Solidus to test,
please ensure that you have a postgres user:

```shell
createuser -s -r postgres
```

And also ensure that you have [PhantomJS](http://phantomjs.org/) installed as well:

```shell
brew update && brew install phantomjs
```

To execute all the tests, you may want to run this command at the
root of the Solidus project to generate test applications and run
specs for all the facets:
```shell
bash build.sh
```

Contributing
------------

Solidus is an open source project and we encourage contributions. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
