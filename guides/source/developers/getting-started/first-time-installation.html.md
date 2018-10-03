# First-time installation

This article will help you install and run Solidus on your local machine for the
first time. This guide is aimed specifically at developers running macOS. 

If you run Linux or Windows, or you don't use [Homebrew][brew] on your Mac, you
can still follow this guide. However, you may want to consult other
documentation while installing Ruby, SQLite 3, and other dependencies on your
system.

[brew]: https://brew.sh

## Getting help

If you're following this guide and still having trouble installing Solidus,
[join the Solidus Slack team][slack-invitation] and start a conversation
in the [#support channel][slack-support].

If you are still not able to get Solidus running, [open an issue on
GitHub][solidus-github-issue] with any information you think would help us
reproduce the issues you're having. That would include your operating system and
its version, the versions of Ruby, Rails, and SQLite 3 that you are running, and
the specific error messages you are receiving during installation. 

[solidus-github-issue]: https://github.com/solidusio/solidus/issues/new
[slack-invitation]: http://slack.solidus.io
[slack-support]: https://solidusio.slack.com/messages/supports/details/

## Before you start

Solidus is an ecommerce platform built with [Ruby on
Rails](http://rubyonrails.org). To get the most out of Solidus, we recommend
that you familiarize yourself with Ruby on Rails, as well as [the Ruby
programming language](https://www.ruby-lang.org/) beforehand.

Because Solidus is a Rails engine, much of what the [Rails Guide on
Engines](http://guides.rubyonrails.org/engines.html) explains applies directly
to Solidus, too.

We also recommend configuring your development environment so that you can
[install RubyGems without `sudo`][gem-install-without-sudo].

[gem-install-without-sudo]: https://www.michaelehead.com/2016/02/06/installing-gems-without-sudo.html

## System requirements

The following software is required to get Solidus running:

- [Ruby](https://www.ruby-lang.org) 2.2.2 or newer
- [SQLite 3](https://sqlite.org)
- [Rails](http://guides.rubyonrails.org/getting_started.html) 5.0.0 or newer
- [ImageMagick](http://imagemagick.org/script/download.php)

We recommend using [Homebrew][brew] to install these dependencies on your
Mac. Throughout this article, we will use the `brew` command for installing
system dependencies. [The Ruby documentation also recommends using
Homebrew][ruby-homebrew] if you need to upgrade from your system's Ruby.

[ruby-homebrew]: https://www.ruby-lang.org/en/documentation/installation/#homebrew

### Quick start

Using Homebrew, you can install all of the requirements using the following
commands:

```bash 
brew install ruby sqlite3 imagemagick
gem install rails
```

See more detailed installation information below.

### Upgrade Ruby on macOS 

If you run macOS Sierra or an older OS, you system's version of Ruby will need
to be upgraded from 2.0.x to 2.2.2 or newer. You can check what version of Ruby
you have installed with the following command:

```bash
ruby --version
```

The Ruby documentation recommends installing another, newer instance of Ruby
using Homebrew:

```bash
brew install ruby
```

Homebrew prioritizes the Homebrew installation of Ruby
(`/usr/local/bin/ruby`) above the system installation (`/usr/bin/ruby`).

### Install SQLite 3

Rails and Solidus use SQLite 3 as the default relational database. SQLite is a
widely-supported, lightweight way to send and receive data. Using Homebrew,
you can install the latest version of SQLite 3 using the following command:

```bash
brew install sqlite3
```

Alternatively, you can [download the pre-compiled binary from the SQLite
website](https://www.sqlite.org/download.html).

After installation, check the version number:

```bash
sqlite3 --version
```

If all is well, this command will return a version number that looks something
like `3.16.0 2016-11-04 19:09:39 0f3eed3324eda2a2b8d3301e5a43dc58a3a5fd5f`.

### Install Rails

Rails includes everything you need to build and extend a web application. Once
you have Ruby and SQLite 3 installed on your system, you can install Rails via
the [RubyGems](https://rubygems.org) `gem` command that comes as a part of Ruby:

```bash
gem install rails
```

This will install Rails as well as its dependencies.

### Install ImageMagick

ImageMagick helps you create, edit, and save to hundreds of image file formats.
It is required by [Paperclip](https://github.com/thoughtbot/paperclip),
which Solidus currently uses to handle file attachments. To install ImageMagick
via Homebrew, use the command: 

```bash
brew install imagemagick
```

Alternatively, you can [download a pre-compiled binary for macOS from the
ImageMagick website](http://imagemagick.org/script/download.php).

## Setup and installation

Once you have installed all of the system requirements, we can start setting up
Solidus.

### Create and configure new Rails project

First, we need a new Rails project:

```bash
rails new your_solidus_project_name
```

Once the new project has finished being created, we can open the project's newly
created `Gemfile` in a text editor and add the required Solidus gems as new
lines:

```ruby 
gem 'solidus'
gem 'solidus_auth_devise'
```

By requiring [`solidus`][solidus-repo] in your `Gemfile`, you are actually
requiring all five of the core Solidus gems:

- [`solidus_core`][solidus-core]
- [`solidus_api`][solidus-api]
- [`solidus_frontend`][solidus-frontend]
- [`solidus_backend`][solidus-backend]
- [`solidus_sample`][solidus-sample]

All five of these gems are maintained in the [Solidus GitHub
repository][solidus-repo]. They are documented at a [separate documentation
site][solidus-gem-documentation].

For a first-time installation, we recommend requiring `solidus` as it provides a
fully-functioning online store. However, you may wish to only use a subset of
the gems and create a more custom store.

Once you have saved the `Gemfile`, ensure you are in your Rails project
directory, and then install the project's dependencies using Bundler.

```bash
cd /path/to/your-solidus-project-name
bundle install
```

[solidus-repo]: https://github.com/solidusio/solidus
[solidus-core]: https://github.com/solidusio/solidus/tree/master/core
[solidus-api]: https://github.com/solidusio/solidus/tree/master/api
[solidus-frontend]: https://github.com/solidusio/solidus/tree/master/frontend
[solidus-backend]: https://github.com/solidusio/solidus/tree/master/backend
[solidus-sample]: https://github.com/solidusio/solidus/tree/master/sample
[solidus-gem-documentation]: http://docs.solidus.io

### Start generating Solidus configuration files

After the gems have been successfully installed, you need to create the
necessary configuration files and instructions for the database using generators
provided by Solidus and Railties.

First, run the `spree:install` generator:

```bash
bundle exec rails generate spree:install
```

This may take a few minutes to complete, and it requires some user confirmation.

### Set the administrator username and password

The `spree:install` generator prompts you to configure the Solidus administrator
username and password values.

The default values are as follows:

- Username: `admin@example.com`
- Password: `test123`

The password must contain a minimum of 6 characters, or the account creation
will fail without asking the user to try again.

### Prepare Solidus database migrations

Next, you need to run the `solidus:auth:install` generator and install your
database migrations using the following commands:

```bash
bundle exec rails generate solidus:auth:install
bundle exec rake railties:install:migrations
```

Finally, you need to run the migrations that Railties created. This creates the
e-commerce–friendly models that Solidus uses for its database:

```bash
bundle exec rake db:migrate
```

### Start the Rails server and use the sample store

Once the database migrations have been created, you should be able to
successfully start the Rails server and see the sample store in your browser.

First, start the server:

```bash
bundle exec rails server
```

Once the server has started, you can access your store from the following URLs:

- [http://localhost:3000/](http://localhost:3000/) opens the
  [`solidus_frontend`][solidus-frontend] storefront.
- [http://localhost:3000/admin/](http://localhost:3000/admin/) opens the
  [`solidus_backend`][solidus-backend] admin area.

You can browse the sample store's pages and mock products, and so on.
