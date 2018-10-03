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

When you run the `spree:install` generator without arguments, it runs
migrations, adds sample data, and seeds your database:

```bash
rails generate spree:install
```

You can use command arguments to skip any of these steps of the generator:

```bash
rails generate spree:install --migrate=false --sample=false --seed=false
```

If you want to perform these tasks later, you can use these commands.

```bash
bundle exec rake railties:install:migrations       # installs migrations
bundle exec rake db:migrate                        # runs migrations
bundle exec rake db:seed                           # seeds your database
bundle exec rake spree_sample:load                 # loads sample data
```

If you use `solidus_auth_devise` for user authentication, you can also install
and run its migrations, then seed the database separately:

```bash
bundle exec rake solidus_auth:install:migrations   # installs solidus_auth_devise migrations
bundle exec rake db:migrate                        # runs solidus_auth_devise migrations
bundle exec rake db:seed                           # seeds your database
```

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

Then, enable Turbolinks in the backend by appending these lines to the
JavaScript manifest at `vendor/assets/spree/backend/all/js`:

```js
//= require turbolinks
//= require backend/app/assets/javascripts/spree/backend/turbolinks-integration.js
```

Note that Turbolinks can break your custom Solidus extensions or other
customizations you have made to the Solidus admin. Use Turbolinks at your own
risk.

[turbolinks]: https://github.com/turbolinks/turbolinks
