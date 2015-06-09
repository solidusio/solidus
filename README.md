
![](https://s3.amazonaws.com/i.hawth.ca/u/solidus.png)

Summary
-------

Solidus is a complete open source e-commerce solution built with Ruby on Rails. It
is a fork of spree.

Solidus actually consists of several different gems, each of which are maintained
in a single repository and documented in a single set of
[online documentation](http://spreecommerce.com/documentation). By requiring the
solidus gem you automatically require all of the necessary gem dependencies which are:

* solidus_api (RESTful API)
* solidus_frontend (User-facing components)
* solidus_backend (Admin area)
* solidus_cmd (Command-line tools)
* solidus_core (Models & Mailers, the basic components of Solidus that it can't run without)
* solidus_sample (Sample data)

All of the gems are designed to work together to provide a fully functional
e-commerce platform. It is also possible, however, to use only the pieces you
are interested in. For example, you could use just the barebones solidus\_core
gem and perhaps combine it with your own custom frontend instead of using
solidus_frontend.

[![Circle CI](https://circleci.com/gh/solidusio/solidus/tree/master.svg?style=svg&circle-token=a181a07d1f92f7297b8174d5c77091ecc5d3cdf7)](https://circleci.com/gh/solidusio/solidus/tree/master)

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


Using stable builds and bleeding edge
-------------

To use a stable build of Spree, you can manually add Spree to your
Rails application. To use the 2-4-stable branch of Spree, add this line to
your Gemfile.

```ruby
gem 'solidus'
```

Alternatively, if you want to use the bleeding edge version of Solidus, use this
line:

```ruby
gem 'solidus', github: 'solidusio/solidus'
```

**Note: The master branch is not guaranteed to ever be in a fully functioning
state. It is unwise to use this branch in a production system you care deeply
about.**

If you wish to have authentication included also, you will need to add the
`solidus_auth_devise` gem as well.

```ruby
gem 'solidus_auth_devise'
```

Once you've done that, then you can install these gems using this command:

```shell
bundle install
```

Use the install generator to set up Solidus:

```shell
rails g spree:install --sample=false --seed=false
```

At this point, if you are using solidus_auth_devise you will need to change this
line in `config/initializers/spree.rb`:

```ruby
Spree.user_class = "Spree::LegacyUser"
```

To this:

```ruby
Spree.user_class = "Spree::User"
```

You can avoid running migrations or generating seed and sample data by passing
in these flags:

```shell
rails g spree:install --migrate=false --sample=false --seed=false
```

You can always perform the steps later by using these commands.

```shell
bundle exec rake railties:install:migrations
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake spree_sample:load
```

Browse Store
------------

http://localhost:nnnn

Browse Admin Interface
----------------------

http://localhost:nnnn/admin

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

You may notice that your Solidus store runs slowly in development mode.  This is
a side-effect of how Rails works in development mode which is to continuously reload
your Ruby objects on each request.  The introduction of the asset pipeline in
Rails 3.1 made default performance in development mode significantly worse. There
are, however, a few tricks to speeding up performance in development mode.

First, in your `config/development.rb`:

```ruby
config.assets.debug = false
```

You can precompile your assets as follows:

```shell
RAILS_ENV=development bundle exec rake assets:precompile
```

If you want to remove precompiled assets (recommended before you commit to Git
and push your changes) use the following rake task:

```shell
RAILS_ENV=development bundle exec rake assets:clean
```

Use Dedicated Solidus Devise Authentication
-------------------------------------------
Add the following to your Gemfile

```ruby
gem 'solidus_auth_devise', github: 'solidusio/solidus_auth_devise'
```

Then run `bundle install`. Authentication will then work exactly as it did in
previous versions of Spree.

If you're installing this in a new Solidus application, you'll need to install
and run the migrations with

```shell
bundle exec rake spree_auth:install:migrations
bundle exec rake db:migrate
```

change the following line in `config/initializers/spree.rb`
```ruby
Spree.user_class = 'Spree::LegacyUser'
```
to
```ruby
Spree.user_class = 'Spree::User'
```

In order to set up the admin user for the application you should then run:

```shell
bundle exec rake spree_auth:admin:create
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
