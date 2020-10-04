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

## Setup and installation

Using Homebrew, you can install all of the requirements using the following
commands:

```bash
brew install ruby sqlite3 imagemagick
gem install rails
```

You can find more details on Solidus' dependencies in the
[System Requirements][system-requirements] page.

[system-requirements]: system-requirements.html

### Create and configure new Rails project

First, we need a new Rails project:

```bash
rails new your_solidus_project_name --skip_webpack_install
```

This command will create a new Rails application without installing
[webpacker][webpacker], which is not required for a sample Solidus store. You
are free to install and configure webpacker in your Solidus store though.

Once the new project has finished being created, we can open the project's newly
created `Gemfile` in a text editor and add the required Solidus gems as new
lines:

```ruby
gem 'solidus'
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
[webpacker]: https://github.com/rails/webpacker/

### Start generating Solidus configuration files

After the gems have been successfully installed, you need to create the
necessary configuration files and instructions for the database using generators
provided by Solidus and Railties.

#### For Solidus v2.11 (still unreleased) and above

Run the `solidus:install` generator:

```bash
bin/rails generate solidus:install
```

This may take a few minutes to complete, and it requires some user confirmation.

#### For Solidus v2.10 and below

If you are using Solidus 2.10 or below, this step is quite different.

First of all, if you want to install the default authentication system provided
by Solidus ([`solidus_auth_devise`][solidus-auth-devise]), your `Gemfile` should
look like:

```
gem 'solidus'
gem 'solidus_auth_devise'
```

Once you have run `bundle install`, you can install Solidus with the command:

```bash
bin/rails generate spree:install
```

[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise

### Set the administrator username and password

The `solidus:install` generator prompts you to configure the Solidus administrator
username and password values.

The default values are as follows:

- Username: `admin@example.com`
- Password: `test123`

The password must contain a minimum of 6 characters, or the account creation
will fail without asking the user to try again.

### Start the Rails server and use the sample store

Once the database migrations have been created, you should be able to
successfully start the Rails server and see the sample store in your browser.

First, start the server:

```bash
bin/rails server
```

Once the server has started, you can access your store from the following URLs:

- [http://localhost:3000/](http://localhost:3000/) opens the
  [`solidus_frontend`][solidus-frontend] storefront.
- [http://localhost:3000/admin/](http://localhost:3000/admin/) opens the
  [`solidus_backend`][solidus-backend] admin area.

You can browse the sample store's pages and mock products, and so on.
