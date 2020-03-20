# Installation options

## Stable Solidus

To get the latest stable build of Solidus, just require `solidus` in your
`Gemfile`.

```ruby
gem 'solidus'
```

## Bleeding edge Solidus

If you want to use the bleeding edge version of Solidus, you can require the
Solidus GitHub repo's master branch:

```ruby
gem 'solidus', github: 'solidusio/solidus'
```

The master branch is updated frequently and may break. Do not use this branch on
a production system.

## Manually run migrations

When you run the `solidus:install` generator without arguments, it runs
migrations, adds sample data, and seeds your database:

```bash
bin/rails generate solidus:install
```

You can use command arguments to skip any of these steps of the generator:

```bash
bin/rails generate solidus:install --migrate=false --sample=false --seed=false
```

If you want to perform these tasks later, you can use these commands.

```bash
bin/rails railties:install:migrations       # installs migrations
bin/rails db:migrate                        # runs migrations
bin/rails db:seed                           # seeds your database
bin/rails spree_sample:load                 # loads sample data
```

## Authentication via Devise

During the installation, you have been prompted to add the default authentication extension
to your project. It is called [`solidus_auth_devise`][solidus-auth-devise] and it uses the
well-known authentication library for Rails called [Devise][devise].

If you answered "yes", there's nothing else left to do. The extension is already
added and installed in your application.

If you don't want to install the default authentication extension, you can answer "no",
or run the Solidus installer with the following command:

```bash
bin/rails generate solidus:install --with-authentication=false
```

If you prefer to install [`solidus_auth_devise`][solidus-auth-devise] gem manually,
after adding it in your Gemfile, you can run the following commands to install and
run its migrations, then seed the database:

```bash
bundle install                              # install gem and dependencies
bin/rails solidus_auth:install:migrations   # installs solidus_auth_devise migrations
bin/rails db:migrate                        # runs solidus_auth_devise migrations
bin/rails db:seed                           # seeds your database
```

[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise
[devise]: https://github.com/heartcombo/devise

## Development environment performance gains

You may notice that your Solidus store runs slowly in development mode. You can
change some of its configuration options to speed it up.

### Turn off asset debugging

By default, your development environment includes all CSS and JavaScript assets
as separate `include`s. You can disable this in your project's
`config/environments/development.rb` by changing the following configuration
from `true` to `false`:

```ruby
Rails.application.configure do
  config.assets.debug = false
end
```

### Enable turbolinks

You can gain some extra speed by enabling [Turbolinks][turbolinks] in your
Solidus admin. First, add the `turbolinks` gem to your project's `Gemfile`:

```ruby
gem 'turbolinks', '~> 5.0.0'
```

Then, enable Turbolinks in the backend by changing the Backend
JavaScript manifest at `vendor/assets/javascripts/spree/backend/all.js`
as follow:

```js
//= require turbolinks
//
// ... current file content
//
//= require spree/backend/turbolinks-integration.js
```

Note that Turbolinks can break your custom Solidus extensions or other
customizations you have made to the Solidus admin. Use Turbolinks at your own
risk.

[turbolinks]: https://github.com/turbolinks/turbolinks
