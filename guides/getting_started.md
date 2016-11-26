# Installing Solidus

This article will explain how to setup a new Rails application with Solidus installed. We assume familiarity with Ruby and Rails, but will link to further resources to help you understand what we are doing.

## Installing ImageMagick

Solidus uses the ImageMagick library for manipulating images. Using this library allows for automatic resizing of product images and the creation of product image thumbnails. ImageMagick is not a Rubygem and it can be a bit tricky to install. There are, however, several excellent sources of information on the Web for how to install it. A basic Google search should help you if you get stuck.

If you are using OSX, a recommended approach is to install ImageMagick using [Homebrew](http://brew.sh/). This can be done with the following command:

```bash
$ brew install imagemagick
```

If you are using Unix or Windows check out [Imagemagick.org](http://www.imagemagick.org/) for more detailed instructions on how to setup ImageMagick for your particular system.

## Installing Ruby

Installing Ruby varies widely from architecture to architecture. There is a good overview on how to
install Ruby on the [Ruby homepage](https://www.ruby-lang.org/en/documentation/installation/).

Please make sure your ruby version is at least 2.2.2:

```
$ ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]
```

## Installing Rails

Ruby comes with the package manager `rubygems`. However, many Ruby projects also use the package manager `bundler`. You use rubygems to install Rails as well as Bundler. If your Ruby is setup correctly, this should be as easy as running the following command:

```
$ gem install rails bundler
```

## Generating your host app

It's important to understand that Solidus is a [Rails engine](http://guides.rubyonrails.org/engines.html), and that your host app simply requires that engine. The first step for installing Solidus is therefore generating a vanilla Rails application.

Rails default `sqlite` database isn't well suited to real Solidus production usage. Solidus will runs best with the `postgresql` (or `MySQL`) database.

The ecosystem in general uses the `rspec` testing framework, so we skip the standard `minitest` installation. To generate your host app with these options, run the following command:

```
rails new my-shop -d postgresql --skip-test
```

Switch into your newly generated app directory:

```
cd my-shop
```

Now, run the tasks to create your development and test databases. If this does not work, please consult the postgres installation instructions for your architecture and the Rails Guide on [Configuring Rails applications](http://edgeguides.rubyonrails.org/configuring.html#rails-general-configuration).

```
bundle exec rake db:create
```

You can find more detailed information about getting started with Rails in the [Rails Guides](http://guides.rubyonrails.org/getting_started.html)

## Installing Solidus, Solidus Authentication (and RSpec)

Installing Solidus into your app consists of adding the `solidus` and `solidus_auth_devise` gems to your `Gemfile`. Here is a working Gemfile for installing Solidus 2.0:

```
source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

# Solidus and Solidus Authentication
gem 'solidus', '~> 2.0'
gem 'solidus_auth_devise'

group :development, :test do
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'listen', '~> 3.0.5'
end
```

Now, run `bundle install` to download `solidus` and `solidus_auth_devise` into your new app, then run
the following generators to get started:

```
bundle exec rails g spree:install --user_class=Spree::User
bundle exec rails g solidus:auth:install
```

These tasks will setup your Rails app as a basic store, with an authentication system and a storefront
and checkout. It will also provide some sample products and configurations. You will be asked to set an admin email/password combination. The default values are `admin@example.com` and `test123`, respectively.

Now, run the rails server (`rails s`) and, in your browser, navigate to `localhost:3000`. Voilà: You'll find an app running an online shop. To access the store admin, visit `localhost:3000/admin`.
