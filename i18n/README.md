# Solidus Internationalization

[![Build Status](https://travis-ci.org/solidusio/solidus_i18n.svg?branch=master)](https://travis-ci.org/solidusio/solidus_i18n)
[![Code Climate](https://codeclimate.com/github/solidusio/solidus_i18n/badges/gpa.svg)](https://codeclimate.com/github/solidusio/solidus_i18n)
[![Gem Version](https://badge.fury.io/rb/solidus_i18n.svg)](https://badge.fury.io/rb/solidus_i18n)

This is the Internationalization project for [Solidus](https://solidus.io)

---

## Changes in Version 2.0

solidus_i18n Version 2.0+ only contains translation files.

Previous versions of solidus_i18n included extra functionality like locale
selectors and which is now built in to Solidus 2.6+. Configuration for
`routing-fitler` has also been removed and must be configured manually
(See [Locale in URL](#locale-in-url)).

## Installation

Add the following to your `Gemfile`:

```ruby
gem 'solidus_i18n', '~> 2.0'
gem 'rails-i18n', '~> 5.1'
gem 'kaminari-i18n', '~> 0.5.0'
```

## Locale in URL

Older versions of solidus_i18n included the routing-filter gem and configured routes to include the locale in the URL.
This is still supported (maybe even recommended) but requires some additional configuration.

1. Add this gem to your `Gemfile`, then run `bundle install`

``` ruby
gem 'routing-filter', '~> 0.6.0'
```

2. Add `filter :locale` to your `config/routes.rb`

``` ruby
Rails.application.routes.draw do
  filter :locale

  mount Spree::Core::Engine, at: '/'
end
```

3. Configure routing-fitler in `config/initializers/locale_filter.rb` (optional)

``` ruby
# Do not include the default locale in the URL
RoutingFilter::Locale.include_default_locale = false
```

## Supported languages

We currently support the [following locales](https://github.com/solidusio/solidus_i18n/tree/master/config/locales)
by default. If you need a locale that is not in the list you can add a custom
translation file into your application by following the
[Rails translations guide](http://guides.rubyonrails.org/i18n.html#how-to-store-your-custom-translations).

## Updating Translations

If you want to improve the translations on your language, run the tasks:

    bundle exec rake solidus_i18n:update_default
    bundle exec i18n-tasks add-missing --nil-value --locale <LOCALE>

Substitute <LOCALE> with your locale code (e.g: `it`).

This will do a cleanup and prepare `<LOCALE>.yml` with all the missing keys.
You can then write the translations and open a pull request.

## Model Translations

We **removed** support for translating models into [a separate Gem](https://github.com/solidusio-contrib/solidus_globalize).

Please update your `Gemfile` if you still need the model translations.

```ruby
# Gemfile
gem 'solidus_globalize', github: 'solidusio-contrib/solidus_globalize', branch: 'master'
```

Contributing
------------

Solidus is an open source project and we encourage contributions. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
